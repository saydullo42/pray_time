"use client";

import { use } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { Loading, ErrorBox } from "@/components/Status";
import { BackLink } from "@/components/BackLink";
import type { Dua } from "@/lib/types";

export default function DuaListPage({ params }: { params: Promise<{ categoryId: string }> }) {
  const { categoryId } = use(params);
  return (
    <RequireAuth>
      <Content categoryId={categoryId} />
    </RequireAuth>
  );
}

function Content({ categoryId }: { categoryId: string }) {
  const searchParams = useSearchParams();
  const categoryName = searchParams.get("name") ?? "Dualar";

  const { data, error, isLoading, mutate } = useSWR(["duas", categoryId], () =>
    api.get<{ results: Dua[] }>("/dua/", { category_id: categoryId })
  );

  if (isLoading) return <Loading />;
  if (error) return <ErrorBox message={error.message} onRetry={() => mutate()} />;

  return (
    <div>
      <BackLink href="/dua" />
      <h1 className="mb-4 text-center text-xl font-semibold">{categoryName}</h1>
      <div className="space-y-2">
        {(data?.results ?? []).map((d) => (
          <Link
            key={d.id}
            href={`/dua/${categoryId}/${d.id}`}
            className="flex items-center justify-between rounded-xl bg-surface px-4 py-4"
          >
            <span className="font-medium">{d.title}</span>
            <span className="text-foreground-muted">›</span>
          </Link>
        ))}
      </div>
    </div>
  );
}
