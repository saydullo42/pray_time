"use client";

import Link from "next/link";
import { RequireAuth } from "@/lib/auth-context";

export default function QuranHubPage() {
  return (
    <RequireAuth>
      <div className="flex flex-col gap-4 pb-80 pt-16 sm:pb-12">
        <h1 className="mb-4 text-center text-2xl font-semibold">Qur&apos;oni Karim</h1>
        <HubButton href="/quran/book" label="Qur'on kitob" />
        <HubButton href="/quran/audio" label="Qur'on audio" />
        <HubButton href="/quran/translation" label="Qur'on tarjimasi" />
      </div>
    </RequireAuth>
  );
}

function HubButton({ href, label }: { href: string; label: string }) {
  return (
    <Link
      href={href}
      className="mx-auto w-full max-w-xs rounded-full bg-[var(--hub-btn-bg)] py-4 text-center text-lg font-semibold text-[color:var(--hub-btn-text)] transition-colors hover:bg-[var(--hub-btn-hover)]"
    >
      {label}
    </Link>
  );
}
