"use client";

import Link from "next/link";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { Loading, ErrorBox } from "@/components/Status";
import { BackLink } from "@/components/BackLink";
import type { Reciter } from "@/lib/types";

export default function ReciterListPage() {
  return (
    <RequireAuth>
      <Content />
    </RequireAuth>
  );
}

function Content() {
  const { data, error, isLoading, mutate } = useSWR("reciters", () =>
    api.get<{ reciters: Reciter[] }>("/quran/audio/")
  );

  if (isLoading) return <Loading />;
  if (error) return <ErrorBox message={error.message} onRetry={() => mutate()} />;

  return (
    <div className="flex flex-col gap-4 pt-10">
      <BackLink href="/quran" />
      <h1 className="mb-4 text-center text-xl font-semibold">Qur&apos;on audio</h1>
      {(data?.reciters ?? []).map((r) => (
        <Link
          key={r.id}
          href={`/quran/audio/${r.id}`}
          className="rounded-full bg-accent py-4 text-center text-lg font-semibold text-black"
        >
          {r.name}
        </Link>
      ))}
    </div>
  );
}
