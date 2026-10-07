"use client";

import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { Loading, ErrorBox } from "@/components/Status";
import { SurahList } from "@/components/SurahList";
import { BackLink } from "@/components/BackLink";
import type { Surah } from "@/lib/types";

export default function QuranTranslationListPage() {
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
        title="Qur'on tarjimasi"
        surahs={(data?.results ?? []).map((s) => ({
          number: s.number,
          nameLatin: s.name_latin,
          nameArabic: s.name_arabic,
          nameTranslation: s.name_translation,
          ayahCount: s.ayah_count,
        }))}
        hrefFor={(n) => `/quran/translation/${n}`}
        icon={<TranslateIcon />}
      />
    </>
  );
}

function TranslateIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" className="text-foreground-muted">
      <path d="M4 5h9M8 3v2M11 5a9 9 0 0 1-6 7" />
      <path d="M5 10c1.5 2 5 3 7 3" />
      <path d="M13 21l4-9 4 9M14.5 18h5" />
    </svg>
  );
}
