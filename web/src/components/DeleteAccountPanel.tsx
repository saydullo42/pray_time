"use client";

import { useState } from "react";
import Link from "next/link";
import { useAuth } from "@/lib/auth-context";

/** Lets a signed-in user permanently delete their account and all of its data. */
export function DeleteAccountPanel() {
  const { user, isLoading, isAuthenticated, deleteAccount } = useAuth();
  const [confirming, setConfirming] = useState(false);
  const [busy, setBusy] = useState(false);
  const [done, setDone] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleDelete() {
    setBusy(true);
    setError(null);
    try {
      await deleteAccount();
      // Ro'za marks kept in this browser belong to the account too.
      try {
        Object.keys(localStorage)
          .filter((k) => k.startsWith("roza_days_"))
          .forEach((k) => localStorage.removeItem(k));
      } catch {}
      setDone(true);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Xatolik yuz berdi. Qayta urinib ko'ring.");
      setConfirming(false);
    } finally {
      setBusy(false);
    }
  }

  const box = "rounded-2xl border border-outline bg-surface p-5";

  if (done) {
    return (
      <div className={box}>
        <p className="text-lg font-semibold text-accent-light">Akkauntingiz o&apos;chirildi.</p>
        <p className="mt-1 text-foreground-muted">Barcha ma&apos;lumotlaringiz o&apos;chirib tashlandi.</p>
      </div>
    );
  }

  if (isLoading) {
    return <div className={`${box} text-foreground-muted`}>Yuklanmoqda...</div>;
  }

  if (!isAuthenticated || !user) {
    return (
      <div className={box}>
        <p>Akkauntni o&apos;chirish uchun avval tizimga kiring.</p>
        <Link
          href="/login"
          className="mt-4 inline-block rounded-full bg-accent px-6 py-2 font-semibold text-black hover:bg-accent-light"
        >
          Kirish
        </Link>
      </div>
    );
  }

  return (
    <div className={box}>
      <p className="text-foreground-muted">Akkaunt</p>
      <p className="text-lg font-semibold">{user.email}</p>

      {error && <p className="mt-3 text-danger">{error}</p>}

      {!confirming ? (
        <button
          onClick={() => setConfirming(true)}
          className="mt-4 cursor-pointer rounded-full border border-danger px-6 py-2 font-semibold text-danger transition-colors hover:bg-danger/15"
        >
          Akkauntni o&apos;chirish
        </button>
      ) : (
        <div className="mt-4 space-y-3">
          <p className="font-medium">
            Rostdan ham o&apos;chirmoqchimisiz? Bu amalni qaytarib bo&apos;lmaydi.
          </p>
          <div className="flex flex-wrap gap-3">
            <button
              onClick={() => setConfirming(false)}
              disabled={busy}
              className="cursor-pointer rounded-full border border-outline px-6 py-2 transition-colors hover:bg-foreground/10 disabled:cursor-default disabled:opacity-60"
            >
              Bekor qilish
            </button>
            <button
              onClick={handleDelete}
              disabled={busy}
              className="cursor-pointer rounded-full bg-danger px-6 py-2 font-semibold text-white transition-opacity hover:opacity-90 disabled:cursor-default disabled:opacity-60"
            >
              {busy ? "O'chirilmoqda..." : "Ha, o'chirish"}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
