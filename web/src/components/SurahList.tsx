"use client";

import Link from "next/link";
import { useEffect, type ReactNode } from "react";

export interface SurahListEntry {
  number: number;
  nameLatin: string;
  nameArabic: string;
  nameTranslation: string;
  ayahCount: number;
}

export function SurahList({
  title,
  surahs,
  hrefFor,
  icon,
}: {
  title: string;
  surahs: SurahListEntry[];
  hrefFor: (number: number) => string;
  icon: ReactNode;
}) {
  const basePath = hrefFor(1).replace(/\/1$/, "");

  // Returning from a surah: scroll the list to the surah that was last open.
  useEffect(() => {
    if (surahs.length === 0) return;
    try {
      const last = sessionStorage.getItem(`lastSurah:${basePath}`);
      if (last) document.getElementById(`surah-${last}`)?.scrollIntoView({ block: "center" });
    } catch {}
  }, [surahs.length, basePath]);

  return (
    <div>
      <h1 className="mb-4 text-center text-xl font-semibold">{title}</h1>
      <div className="space-y-2">
        {surahs.map((s) => (
          <Link
            key={s.number}
            id={`surah-${s.number}`}
            href={hrefFor(s.number)}
            prefetch={false}
            className="flex items-center gap-3 rounded-xl bg-surface px-4 py-3"
          >
            <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full border border-outline text-sm">
              {s.number}
            </span>
            <div className="min-w-0 flex-1">
              <p className="truncate font-medium">
                {s.nameLatin} ({s.nameArabic})
              </p>
              <p className="truncate text-sm text-foreground-muted">
                {s.nameTranslation} · {s.ayahCount} oyat
              </p>
            </div>
            {icon}
          </Link>
        ))}
      </div>
    </div>
  );
}
