"use client";

import { use, useEffect, useRef } from "react";
import Link from "next/link";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { Loading, ErrorBox } from "@/components/Status";
import { AudioPlayer } from "@/components/AudioPlayer";
import { BackLink } from "@/components/BackLink";
import type { ReciterSurahAudio } from "@/lib/types";

export default function AudioPlayerPage({
  params,
}: {
  params: Promise<{ reciterId: string; number: string }>;
}) {
  const { reciterId, number } = use(params);
  return (
    <RequireAuth>
      <Content reciterId={Number(reciterId)} surahNumber={Number(number)} />
    </RequireAuth>
  );
}

function Content({ reciterId, surahNumber }: { reciterId: number; surahNumber: number }) {
  const { data, error, isLoading, mutate } = useSWR(["reciter-surahs", reciterId], () =>
    api.get<{ results: ReciterSurahAudio[] }>(`/quran/audio/${reciterId}/surahs/`)
  );

  const activeItemRef = useRef<HTMLAnchorElement>(null);
  useEffect(() => {
    activeItemRef.current?.scrollIntoView({ block: "center" });
  }, [surahNumber, data]);

  if (isLoading) return <Loading />;
  if (error) return <ErrorBox message={error.message} onRetry={() => mutate()} />;

  const surahs = data?.results ?? [];
  const surah = surahs.find((s) => s.number === surahNumber);
  if (!surah) return <ErrorBox message="Sura topilmadi" />;

  return (
    // Phones: the page fits one screen (100dvh minus the bottom menu and the page
    // padding) and only the surah list scrolls. Larger screens: the usual layout.
    <div className="flex h-[calc(100dvh-7rem)] flex-col sm:block sm:h-auto">
      <div className="relative mb-3 flex shrink-0 items-center justify-center sm:hidden">
        <BackLink href={`/quran/audio/${reciterId}`} className="absolute left-0 mb-0!" />
        <h1 className="text-xl font-semibold">
          {surah.number}. {surah.name_latin}
        </h1>
      </div>
      <div className="hidden sm:block">
        <BackLink href={`/quran/audio/${reciterId}`} />
      </div>
      <div className="flex min-h-0 flex-1 flex-col gap-3 sm:flex-none sm:flex-row sm:items-start sm:gap-6">
        <div className="flex shrink-0 flex-col items-center gap-3 sm:flex-1 sm:gap-6">
          <p className="text-3xl sm:text-4xl" lang="ar" dir="rtl">
            {surah.name_arabic}
          </p>
          <h1 className="hidden text-xl font-semibold sm:block">
            {surah.number}. {surah.name_latin}
          </h1>
          <p className="text-sm text-foreground-muted">
            {surah.name_translation} · {surah.ayah_count} oyat
          </p>
          <AudioPlayer
            key={surah.audio_url}
            src={surah.audio_url}
            autoPlay
            className="w-full max-w-sm"
            prevSlot={
              surahNumber > 1 ? (
                <a href={`/quran/audio/${reciterId}/${surahNumber - 1}`} className="text-accent-light">
                  ‹ Oldingi
                </a>
              ) : undefined
            }
            nextSlot={
              surahNumber < 114 ? (
                <a href={`/quran/audio/${reciterId}/${surahNumber + 1}`} className="text-accent-light">
                  Keyingi ›
                </a>
              ) : undefined
            }
          />
        </div>

        <div className="themed-scrollbar min-h-0 w-full flex-1 overflow-y-auto rounded-2xl bg-surface p-2 sm:max-h-[75vh] sm:w-72 sm:flex-none sm:shrink-0">
          {surahs.map((s) => {
            const active = s.number === surahNumber;
            return (
              <Link
                key={s.number}
                ref={active ? activeItemRef : undefined}
                href={`/quran/audio/${reciterId}/${s.number}`}
                prefetch={false}
                className={`flex items-center gap-3 rounded-xl px-3 py-2.5 ${
                  active ? "bg-[#E5E4E2] text-black" : "hover:bg-surface-alt"
                }`}
              >
                <span
                  className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full border text-sm ${
                    active ? "border-black/40" : "border-outline"
                  }`}
                >
                  {s.number}
                </span>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-base font-medium">{s.name_latin}</p>
                </div>
                {active && <PlayingIcon />}
              </Link>
            );
          })}
        </div>
      </div>
    </div>
  );
}

function PlayingIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" className="shrink-0">
      <path d="M8 5v14l11-7z" />
    </svg>
  );
}
