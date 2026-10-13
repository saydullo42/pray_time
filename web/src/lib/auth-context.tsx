"use client";

import { createContext, useCallback, useContext, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "./api";
import { tokenStorage } from "./token-storage";
import type { AuthResponse, User } from "./types";

interface AuthContextValue {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  /** Exchanges a Google ID token (from "Continue with Google") for our own session. */
  signInWithGoogle: (idToken: string) => Promise<User>;
  logout: () => Promise<void>;
  deleteAccount: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(() => !!tokenStorage.getAccess());

  const refreshUser = useCallback(async () => {
    const token = tokenStorage.getAccess();
    if (!token) {
      setUser(null);
      return;
    }
    try {
      const me = await api.get<User>("/users/me/");
      setUser(me);
    } catch {
      setUser(null);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (tokenStorage.getAccess()) {
      // eslint-disable-next-line react-hooks/set-state-in-effect -- refreshUser is async; its setState calls happen after the awaited request, not synchronously
      refreshUser();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const signInWithGoogle = useCallback(async (idToken: string) => {
    const data = await api.post<AuthResponse>("/auth/google/", { id_token: idToken }, false);
    tokenStorage.set(data.access_token, data.refresh_token);
    setUser(data.user);
    return data.user;
  }, []);

  const logout = useCallback(async () => {
    try {
      await api.post("/auth/logout/");
    } catch {
      // ignore network/logout errors — clear local state regardless
    }
    tokenStorage.clear();
    setUser(null);
  }, []);

  /** Permanently deletes the signed-in account and all of its data, then signs out locally. */
  const deleteAccount = useCallback(async () => {
    await api.delete("/users/me/");
    tokenStorage.clear();
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        isAuthenticated: !!user,
        signInWithGoogle,
        logout,
        deleteAccount,
        refreshUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}

/** Wrap a page's content to redirect to /login when not authenticated. */
export function RequireAuth({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.replace("/login");
    }
  }, [isLoading, isAuthenticated, router]);

  if (isLoading || !isAuthenticated) {
    return (
      <div className="flex min-h-[60vh] items-center justify-center text-foreground-muted">
        Yuklanmoqda...
      </div>
    );
  }
  return <>{children}</>;
}
