"use client";

import Link from "next/link";
import { RequireAuth } from "@/lib/auth-context";

export default function QuranHubPage() {
  return (
    <RequireAuth>
      <div className="flex flex-col gap-4 pt-16">
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
      className="mx-auto w-full max-w-xs rounded-full bg-[#C0C0C0] py-4 text-center text-lg font-semibold text-black transition-colors hover:bg-[#adadad]"
    >
      {label}
    </Link>
  );
}
