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
    <div>
      <BackLink href={`/quran/audio/${reciterId}`} />
      <div className="flex flex-col gap-6 sm:flex-row sm:items-start">
        <div className="flex flex-1 flex-col items-center gap-6">
          <p className="text-4xl" lang="ar" dir="rtl">
            {surah.name_arabic}
          </p>
          <h1 className="text-xl font-semibold">
            {surah.number}. {surah.name_latin}
          </h1>
          <p className="text-sm text-foreground-muted">
            {surah.name_translation} · {surah.ayah_count} oyat
          </p>
          <AudioPlayer
            key={surah.audio_url}
            src={surah.audio_url}
            autoPlay
            className="max-w-sm"
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

        <div className="themed-scrollbar max-h-[50vh] w-full shrink-0 overflow-y-auto rounded-2xl bg-surface p-2 sm:w-72 sm:max-h-[75vh]">
          {surahs.map((s) => {
            const active = s.number === surahNumber;
            return (
              <Link
                key={s.number}
                ref={active ? activeItemRef : undefined}
                href={`/quran/audio/${reciterId}/${s.number}`}
                prefetch={false}
                className={`flex items-center gap-3 rounded-xl px-3 py-2.5 ${
                  active ? "bg-accent text-black" : "hover:bg-surface-alt"
                }`}
              >
                <span
                  className={`flex h-7 w-7 shrink-0 items-center justify-center rounded-full border text-xs ${
                    active ? "border-black/40" : "border-outline"
                  }`}
                >
                  {s.number}
                </span>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium">{s.name_latin}</p>
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
