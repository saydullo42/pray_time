"use client";

import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { Loading, ErrorBox } from "@/components/Status";
import { SurahList } from "@/components/SurahList";
import { BackLink } from "@/components/BackLink";
import type { Surah } from "@/lib/types";

export default function QuranBookListPage() {
  return (
    <RequireAuth>
      <Content />
    </RequireAuth>
  );
}

function Content() {
  const { data, error, isLoading, mutate } = useSWR("surahs", () =>
    api.get<{ results: Surah[] }>("/quran/surahs/")
  );

  if (isLoading) return <Loading />;
  if (error) return <ErrorBox message={error.message} onRetry={() => mutate()} />;

  return (
    <>
      <BackLink href="/quran" />
      <SurahList
        title="Qur'on kitob"
        surahs={(data?.results ?? []).map((s) => ({
          number: s.number,
          nameLatin: s.name_latin,
          nameArabic: s.name_arabic,
          nameTranslation: s.name_translation,
          ayahCount: s.ayah_count,
        }))}
        hrefFor={(n) => `/quran/book/${n}`}
        icon={<BookIcon />}
      />
    </>
  );
}

function BookIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" className="text-foreground-muted">
      <path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H12v18H6.5A2.5 2.5 0 0 1 4 18.5z" />
      <path d="M20 5.5A2.5 2.5 0 0 0 17.5 3H12v18h5.5a2.5 2.5 0 0 0 2.5-2.5z" />
    </svg>
  );
}
