"use client";

import { use, useState } from "react";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { fetchTranslationSurah } from "@/lib/alquran";
import { Loading, ErrorBox } from "@/components/Status";
import { SurahReaderHeader } from "@/components/SurahReaderHeader";
import { scrollPageToTop } from "@/lib/scroll";

export default function QuranTranslationReaderPage({
  params,
}: {
  params: Promise<{ number: string }>;
}) {
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
  const { data, error, isLoading, mutate } = useSWR(["translation-surah", surahNumber], () =>
    fetchTranslationSurah(surahNumber)
  );

  const [page, setPage] = useState(1);
  const totalPages = data ? Math.ceil(data.length / AYAHS_PER_PAGE) : 1;
  const visible = data?.slice((page - 1) * AYAHS_PER_PAGE, page * AYAHS_PER_PAGE) ?? [];

  const goTo = (p: number) => {
    setPage(p);
    scrollPageToTop();
  };

  return (
    <div>
      <SurahReaderHeader surahNumber={surahNumber} />
      {isLoading && <Loading />}
      {error && <ErrorBox message={error.message} onRetry={() => mutate()} />}
      {data && (
        <div className="space-y-3 rounded-2xl bg-surface p-5">
          {visible.map((ayah) => (
            <p key={ayah.numberInSurah} className="leading-relaxed">
              <span className="mr-2 inline-flex h-6 w-6 items-center justify-center rounded-full border border-accent-light align-middle text-xs text-accent-light">
                {ayah.numberInSurah}
              </span>
              {ayah.text}
            </p>
          ))}
        </div>
      )}
      {data && totalPages > 1 && (
        <div className="mt-4 flex items-center justify-center gap-4">
          <button
            onClick={() => goTo(page - 1)}
            disabled={page === 1}
            className="rounded-full border border-outline px-4 py-2 text-sm disabled:opacity-40"
          >
            ‹ Oldingi
          </button>
          <span className="text-sm text-foreground-muted">
            {page} / {totalPages}
          </span>
          <button
            onClick={() => goTo(page + 1)}
            disabled={page === totalPages}
            className="rounded-full border border-outline px-4 py-2 text-sm disabled:opacity-40"
          >
            Keyingi ›
          </button>
        </div>
      )}
    </div>
  );
}
