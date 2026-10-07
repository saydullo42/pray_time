"use client";

import { createContext, useCallback, useContext, useState } from "react";

export type ThemeMode = "light" | "dark";

const STORAGE_KEY = "nv_theme_mode";
const DEFAULT_MODE: ThemeMode = "dark";

function applyTheme(mode: ThemeMode) {
  document.documentElement.setAttribute("data-theme", mode);
}

/** Inline script injected before hydration so the correct theme applies on first paint. */
export const THEME_INIT_SCRIPT = `
(function () {
  try {
    var mode = localStorage.getItem("${STORAGE_KEY}");
    document.documentElement.setAttribute("data-theme", mode === "light" ? "light" : "${DEFAULT_MODE}");
  } catch (e) {
    document.documentElement.setAttribute("data-theme", "${DEFAULT_MODE}");
  }
})();
`;

interface ThemeContextValue {
  mode: ThemeMode;
  setMode: (mode: ThemeMode) => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

function readStoredMode(): ThemeMode {
  if (typeof window === "undefined") return DEFAULT_MODE;
  return window.localStorage.getItem(STORAGE_KEY) === "light" ? "light" : DEFAULT_MODE;
}

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [mode, setModeState] = useState<ThemeMode>(readStoredMode);

  const setMode = useCallback((next: ThemeMode) => {
    setModeState(next);
    window.localStorage.setItem(STORAGE_KEY, next);
    applyTheme(next);
  }, []);

  return <ThemeContext.Provider value={{ mode, setMode }}>{children}</ThemeContext.Provider>;
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error("useTheme must be used within ThemeProvider");
  return ctx;
}
