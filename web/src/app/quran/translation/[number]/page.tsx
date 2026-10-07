"use client";

import { use } from "react";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { fetchTranslationSurah } from "@/lib/alquran";
import { Loading, ErrorBox } from "@/components/Status";
import { SurahReaderHeader } from "@/components/SurahReaderHeader";

export default function QuranTranslationReaderPage({
  params,
}: {
  params: Promise<{ number: string }>;
}) {
  const { number } = use(params);
  const surahNumber = Number(number);

  return (
    <RequireAuth>
      <Content surahNumber={surahNumber} />
    </RequireAuth>
  );
}

function Content({ surahNumber }: { surahNumber: number }) {
  const { data, error, isLoading, mutate } = useSWR(["translation-surah", surahNumber], () =>
    fetchTranslationSurah(surahNumber)
  );

  return (
    <div>
      <SurahReaderHeader surahNumber={surahNumber} />
      {isLoading && <Loading />}
      {error && <ErrorBox message={error.message} onRetry={() => mutate()} />}
      {data && (
        <div className="space-y-3 rounded-2xl bg-surface p-5">
          {data.map((ayah) => (
            <p key={ayah.numberInSurah} className="leading-relaxed">
              <span className="mr-2 inline-flex h-6 w-6 items-center justify-center rounded-full border border-accent-light align-middle text-xs text-accent-light">
                {ayah.numberInSurah}
              </span>
              {ayah.text}
            </p>
          ))}
        </div>
      )}
    </div>
  );
}
