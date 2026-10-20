import { tokenStorage } from "./token-storage";

const BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1";

export class ApiError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

/** "rejected": the refresh token is no longer valid, the person must sign in again.
 * "unavailable": the server could not be reached or failed; the session is still fine. */
type RefreshResult = string | "rejected" | "unavailable";

let refreshPromise: Promise<RefreshResult> | null = null;

async function refreshAccessToken(): Promise<RefreshResult> {
  const refresh = tokenStorage.getRefresh();
  if (!refresh) return "rejected";

  if (!refreshPromise) {
    refreshPromise = fetch(`${BASE_URL}/auth/token/refresh/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh }),
    })
      .then(async (res): Promise<RefreshResult> => {
        if (res.status === 401) {
          // The backend rotates refresh tokens, so another tab may have just used
          // this one and stored a new pair: that session is fine.
          const current = tokenStorage.getRefresh();
          const access = tokenStorage.getAccess();
          return current && current !== refresh && access ? access : "rejected";
        }
        if (!res.ok) return "unavailable";
        const data = await res.json();
        tokenStorage.setAccess(data.access);
        // Every refresh returns a new refresh token and invalidates the old one.
        if (data.refresh) tokenStorage.setRefresh(data.refresh);
        return data.access as string;
      })
      .catch((): RefreshResult => "unavailable")
      .finally(() => {
        refreshPromise = null;
      });
  }
  return refreshPromise;
}

interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "PATCH" | "DELETE";
  body?: unknown;
  query?: Record<string, string | number | boolean | undefined>;
  auth?: boolean;
}

function buildUrl(path: string, query?: RequestOptions["query"]) {
  const url = new URL(`${BASE_URL}${path}`);
  if (query) {
    for (const [key, value] of Object.entries(query)) {
      if (value !== undefined) url.searchParams.set(key, String(value));
    }
  }
  return url.toString();
}

async function request<T>(path: string, options: RequestOptions = {}, retried = false): Promise<T> {
  const { method = "GET", body, query, auth = true } = options;

  const headers: Record<string, string> = { "Content-Type": "application/json" };
  if (auth) {
    const token = tokenStorage.getAccess();
    if (token) headers.Authorization = `Bearer ${token}`;
  }

  const res = await fetch(buildUrl(path, query), {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });

  if (res.status === 401 && auth && !retried) {
    const refreshed = await refreshAccessToken();
    if (refreshed === "unavailable") {
      // Offline or a server hiccup: keep the session and let the caller show an error.
      throw new ApiError(0, "Internetga ulanishda xatolik yuz berdi.");
    }
    if (refreshed !== "rejected") {
      return request<T>(path, options, true);
    }
    tokenStorage.clear();
    if (typeof window !== "undefined") {
      // eslint-disable-next-line @next/next/no-location-assign-relative-destination -- full reload clears in-memory state outside React's reach here
      window.location.href = "/login";
    }
    throw new ApiError(401, "Sessiya tugadi");
  }

  if (!res.ok) {
    let detail = res.statusText;
    try {
      const data = await res.json();
      detail = data.detail ?? JSON.stringify(data);
    } catch {
      // ignore parse failure
    }
    throw new ApiError(res.status, detail);
  }

  if (res.status === 204 || res.status === 205) {
    return undefined as T;
  }
  const text = await res.text();
  if (!text) return undefined as T;
  return JSON.parse(text) as T;
}

export const api = {
  get: <T>(path: string, query?: RequestOptions["query"], auth = true) =>
    request<T>(path, { method: "GET", query, auth }),
  post: <T>(path: string, body?: unknown, auth = true) =>
    request<T>(path, { method: "POST", body, auth }),
  put: <T>(path: string, body?: unknown, auth = true) =>
    request<T>(path, { method: "PUT", body, auth }),
  delete: <T>(path: string, auth = true) => request<T>(path, { method: "DELETE", auth }),
};
