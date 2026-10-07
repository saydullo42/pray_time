"use client";

import { use } from "react";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { Loading, ErrorBox } from "@/components/Status";
import { SurahList } from "@/components/SurahList";
import { BackLink } from "@/components/BackLink";
import type { Reciter, ReciterSurahAudio } from "@/lib/types";

export default function ReciterSurahListPage({
  params,
}: {
  params: Promise<{ reciterId: string }>;
}) {
  const { reciterId } = use(params);
  return (
    <RequireAuth>
      <Content reciterId={Number(reciterId)} />
    </RequireAuth>
  );
}

function Content({ reciterId }: { reciterId: number }) {
  const { data: reciters } = useSWR("reciters", () =>
    api.get<{ reciters: Reciter[] }>("/quran/audio/")
  );
  const reciterName = reciters?.reciters.find((r) => r.id === reciterId)?.name ?? "Qur'on audio";

  const { data, error, isLoading, mutate } = useSWR(["reciter-surahs", reciterId], () =>
    api.get<{ results: ReciterSurahAudio[] }>(`/quran/audio/${reciterId}/surahs/`)
  );

  if (isLoading) return <Loading />;
  if (error) return <ErrorBox message={error.message} onRetry={() => mutate()} />;

  return (
    <>
      <BackLink href="/quran/audio" />
      <SurahList
        title={reciterName}
        surahs={(data?.results ?? []).map((s) => ({
          number: s.number,
          nameLatin: s.name_latin,
          nameArabic: s.name_arabic,
          nameTranslation: s.name_translation,
          ayahCount: s.ayah_count,
        }))}
        hrefFor={(n) => `/quran/audio/${reciterId}/${n}`}
        icon={<HeadphonesIcon />}
      />
    </>
  );
}

function HeadphonesIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" className="text-foreground-muted">
      <path d="M4 14v-2a8 8 0 0 1 16 0v2" />
      <rect x="2.5" y="14" width="5" height="7" rx="2" />
      <rect x="16.5" y="14" width="5" height="7" rx="2" />
    </svg>
  );
}
