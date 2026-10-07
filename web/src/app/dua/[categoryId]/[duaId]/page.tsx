"use client";

import { use } from "react";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { Loading, ErrorBox } from "@/components/Status";
import { BackLink } from "@/components/BackLink";
import type { Dua } from "@/lib/types";

export default function DuaDetailPage({
  params,
}: {
  params: Promise<{ categoryId: string; duaId: string }>;
}) {
  const { categoryId, duaId } = use(params);
  return (
    <RequireAuth>
      <Content categoryId={categoryId} duaId={Number(duaId)} />
    </RequireAuth>
  );
}

function Content({ categoryId, duaId }: { categoryId: string; duaId: number }) {
  const { data, error, isLoading, mutate } = useSWR(["duas", categoryId], () =>
    api.get<{ results: Dua[] }>("/dua/", { category_id: categoryId })
  );

  if (isLoading) return <Loading />;
  if (error) return <ErrorBox message={error.message} onRetry={() => mutate()} />;

  const dua = data?.results.find((d) => d.id === duaId);
  if (!dua) return <ErrorBox message="Dua topilmadi" />;

  return (
    <div className="space-y-5">
      <BackLink href={`/dua/${categoryId}`} />
      <h1 className="text-center text-xl font-semibold">{dua.title}</h1>
      <p dir="rtl" lang="ar" className="rounded-2xl bg-surface p-5 text-right text-2xl leading-loose font-arabic">
        {dua.arabic_text}
      </p>
      <div>
        <p className="mb-1 font-bold">O&apos;qilishi:</p>
        <p className="italic leading-relaxed">{dua.transliteration}</p>
      </div>
      <div>
        <p className="mb-1 font-bold">Ma&apos;nosi:</p>
        <p className="leading-relaxed">{dua.translation}</p>
      </div>
      {dua.source && <p className="text-sm text-foreground-muted">Manba: {dua.source}</p>}
      {dua.audio_url && (
        <audio controls className="w-full" src={dua.audio_url}>
          Brauzeringiz audio pleerni qo&apos;llab-quvvatlamaydi.
        </audio>
      )}
    </div>
  );
}
