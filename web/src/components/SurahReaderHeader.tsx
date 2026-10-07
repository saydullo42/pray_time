"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import useSWR from "swr";
import { api } from "@/lib/api";
import { BackLink } from "@/components/BackLink";
import type { Surah } from "@/lib/types";

export function SurahReaderHeader({ surahNumber }: { surahNumber: number }) {
  const { data } = useSWR("surahs", () => api.get<{ results: Surah[] }>("/quran/surahs/"));
  const surah = data?.results.find((s) => s.number === surahNumber);
  const pathname = usePathname();
  const basePath = pathname.replace(/\/\d+$/, "");

  return (
    <>
      <BackLink href={basePath} />
      <div className="mb-4 flex items-center justify-between">
        <Link
          href={surahNumber > 1 ? `${basePath}/${surahNumber - 1}` : "#"}
          aria-disabled={surahNumber <= 1}
          className={`px-2 py-1 text-xl ${surahNumber <= 1 ? "pointer-events-none opacity-30" : "text-accent-light"}`}
        >
          ‹
        </Link>
        <h1 className="text-lg font-semibold">
          {surah ? `${surah.number}. ${surah.name_latin}` : `Sura ${surahNumber}`}
        </h1>
        <Link
          href={surahNumber < 114 ? `${basePath}/${surahNumber + 1}` : "#"}
          aria-disabled={surahNumber >= 114}
          className={`px-2 py-1 text-xl ${surahNumber >= 114 ? "pointer-events-none opacity-30" : "text-accent-light"}`}
        >
          ›
        </Link>
      </div>
    </>
  );
}
