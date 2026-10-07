"use client";

import { use } from "react";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { fetchArabicSurah } from "@/lib/alquran";
import { Loading, ErrorBox } from "@/components/Status";
import { SurahReaderHeader } from "@/components/SurahReaderHeader";

export default function QuranBookReaderPage({ params }: { params: Promise<{ number: string }> }) {
  const { number } = use(params);
  const surahNumber = Number(number);

  return (
    <RequireAuth>
      <Content surahNumber={surahNumber} />
    </RequireAuth>
  );
}

function Content({ surahNumber }: { surahNumber: number }) {
  const { data, error, isLoading, mutate } = useSWR(["arabic-surah", surahNumber], () =>
    fetchArabicSurah(surahNumber)
  );

  return (
    <div>
      <SurahReaderHeader surahNumber={surahNumber} />
      {isLoading && <Loading />}
      {error && <ErrorBox message={error.message} onRetry={() => mutate()} />}
      {data && (
        <p
          dir="rtl"
          lang="ar"
          className="rounded-2xl bg-surface p-5 text-right text-2xl leading-[2.4] font-arabic"
        >
          {data.map((ayah) => (
            <span key={ayah.numberInSurah}>
              {ayah.text}
              <span className="mx-1.5 inline-flex h-7 w-7 items-center justify-center rounded-full border border-accent-light align-middle text-sm text-accent-light">
                {toArabicIndic(ayah.numberInSurah)}
              </span>{" "}
            </span>
          ))}
        </p>
      )}
    </div>
  );
}

const ARABIC_INDIC = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"];
function toArabicIndic(n: number): string {
  return String(n)
    .split("")
    .map((d) => ARABIC_INDIC[Number(d)])
    .join("");
}
