const ACCESS_KEY = "nv_access_token";
const REFRESH_KEY = "nv_refresh_token";

export const tokenStorage = {
  getAccess(): string | null {
    if (typeof window === "undefined") return null;
    return window.localStorage.getItem(ACCESS_KEY);
  },
  getRefresh(): string | null {
    if (typeof window === "undefined") return null;
    return window.localStorage.getItem(REFRESH_KEY);
  },
  set(access: string, refresh: string) {
    window.localStorage.setItem(ACCESS_KEY, access);
    window.localStorage.setItem(REFRESH_KEY, refresh);
  },
  setAccess(access: string) {
    window.localStorage.setItem(ACCESS_KEY, access);
  },
  setRefresh(refresh: string) {
    window.localStorage.setItem(REFRESH_KEY, refresh);
  },
  clear() {
    window.localStorage.removeItem(ACCESS_KEY);
    window.localStorage.removeItem(REFRESH_KEY);
    // The cached Ro'za days belong to the account that just signed out; the next
    // account must not inherit them.
    for (const key of Object.keys(window.localStorage)) {
      if (key.startsWith("roza_")) window.localStorage.removeItem(key);
    }
  },
};
