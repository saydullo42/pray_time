"use client";

import { use, useState } from "react";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { BASMALA, fetchArabicSurah, surahShowsBasmala, withoutBasmala } from "@/lib/alquran";
import { Loading, ErrorBox } from "@/components/Status";
import { SurahReaderHeader } from "@/components/SurahReaderHeader";

export default function QuranBookReaderPage({ params }: { params: Promise<{ number: string }> }) {
  const { number } = use(params);
  const surahNumber = Number(number);

  return (
    <RequireAuth>
      <Content key={surahNumber} surahNumber={surahNumber} />
    </RequireAuth>
  );
}

const AYAHS_PER_PAGE = 20;

function Content({ surahNumber }: { surahNumber: number }) {
  const { data, error, isLoading, mutate } = useSWR(["arabic-surah", surahNumber], () =>
    fetchArabicSurah(surahNumber)
  );

  const [page, setPage] = useState(1);
  const ayahs = data ? withoutBasmala(surahNumber, data) : undefined;
  const totalPages = ayahs ? Math.ceil(ayahs.length / AYAHS_PER_PAGE) : 1;
  const visible = ayahs?.slice((page - 1) * AYAHS_PER_PAGE, page * AYAHS_PER_PAGE) ?? [];
  const showBasmala = page === 1 && surahShowsBasmala(surahNumber);

  const goTo = (p: number) => {
    setPage(p);
    window.scrollTo({ top: 0 });
  };

  return (
    <div>
      <SurahReaderHeader surahNumber={surahNumber} />
      {isLoading && <Loading />}
      {error && <ErrorBox message={error.message} onRetry={() => mutate()} />}
      {ayahs && showBasmala && (
        <p dir="rtl" lang="ar" className="mb-3 text-center text-3xl leading-[2.4] font-arabic">
          {BASMALA}
        </p>
      )}
      {ayahs && (
        <p
          dir="rtl"
          lang="ar"
          className="rounded-2xl bg-surface p-5 text-right text-2xl leading-[2.4] font-arabic"
        >
          {visible.map((ayah) => (
            <span key={ayah.numberInSurah}>
              {ayah.text}
              <span className="mx-1.5 inline-flex h-7 w-7 items-center justify-center rounded-full border border-accent-light align-middle text-sm text-accent-light">
                {toArabicIndic(ayah.numberInSurah)}
              </span>{" "}
            </span>
          ))}
        </p>
      )}
      {ayahs && totalPages > 1 && (
        <div className="mt-4 flex items-center justify-center gap-4">
          <button
            onClick={() => goTo(page + 1)}
            disabled={page === totalPages}
            className="rounded-full border border-outline px-4 py-2 text-sm disabled:opacity-40"
          >
            ‹ Keyingisi
          </button>
          <span className="text-sm text-foreground-muted">
            {page} / {totalPages}
          </span>
          <button
            onClick={() => goTo(page - 1)}
            disabled={page === 1}
            className="rounded-full border border-outline px-4 py-2 text-sm disabled:opacity-40"
          >
            Oldingisi ›
          </button>
        </div>
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
