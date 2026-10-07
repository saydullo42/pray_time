"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { RequireAuth, useAuth } from "@/lib/auth-context";
import { useTheme, type ThemeMode } from "@/lib/theme-context";
import { api } from "@/lib/api";

const THEME_OPTIONS: { value: ThemeMode; label: string }[] = [
  { value: "light", label: "Yorug'" },
  { value: "dark", label: "Qorong'i" },
];

export default function ProfilePage() {
  return (
    <RequireAuth>
      <Content />
    </RequireAuth>
  );
}

function Content() {
  const { user, logout, refreshUser } = useAuth();
  const { mode, setMode } = useTheme();
  const router = useRouter();
  const [editing, setEditing] = useState(false);
  const [name, setName] = useState(user?.full_name ?? "");
  const [saving, setSaving] = useState(false);

  async function save() {
    setSaving(true);
    try {
      await api.put("/users/me/", { full_name: name });
      await refreshUser();
      setEditing(false);
    } finally {
      setSaving(false);
    }
  }

  async function handleLogout() {
    await logout();
    router.replace("/login");
  }

  if (!user) return null;

  return (
    <div className="space-y-6 pt-6">
      <div className="flex flex-col items-center gap-2">
        <div className="flex h-20 w-20 items-center justify-center rounded-full bg-surface text-2xl font-semibold text-accent-light">
          {(user.full_name || user.phone_number).charAt(0).toUpperCase()}
        </div>
        {editing ? (
          <div className="flex w-full max-w-xs flex-col items-center gap-2">
            <input
              autoFocus
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full rounded-lg border border-outline bg-transparent px-3 py-2 text-center"
            />
            <div className="flex gap-4">
              <button onClick={() => setEditing(false)} className="text-sm text-foreground-muted">
                Bekor qilish
              </button>
              <button onClick={save} disabled={saving} className="text-sm font-semibold text-accent-light">
                {saving ? "..." : "Saqlash"}
              </button>
            </div>
          </div>
        ) : (
          <button onClick={() => setEditing(true)} className="text-lg font-medium">
            {user.full_name || "Ism kiritilmagan"}
          </button>
        )}
        <p className="text-foreground-muted">{user.phone_number}</p>
      </div>

      <div className="mx-auto w-full max-w-xs">
        <p className="mb-2 text-sm text-foreground-muted">Mavzu</p>
        <div className="flex rounded-full border border-outline p-1">
          {THEME_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              onClick={() => setMode(opt.value)}
              className={`flex-1 rounded-full py-2 text-sm transition-colors ${
                mode === opt.value ? "bg-accent font-semibold text-black" : "text-foreground-muted"
              }`}
            >
              {opt.label}
            </button>
          ))}
        </div>
      </div>

      <button
        onClick={handleLogout}
        className="mx-auto block w-full max-w-xs rounded-full border border-danger py-3 font-medium text-danger"
      >
        Chiqish
      </button>
    </div>
  );
}
