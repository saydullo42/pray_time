"use client";

import Link from "next/link";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { Loading, ErrorBox } from "@/components/Status";
import type { DuaCategory } from "@/lib/types";

export default function DuaCategoriesPage() {
  return (
    <RequireAuth>
      <Content />
    </RequireAuth>
  );
}

function Content() {
  const { data, error, isLoading, mutate } = useSWR("dua-categories", () =>
    api.get<{ results: DuaCategory[] }>("/dua/categories/")
  );

  if (isLoading) return <Loading />;
  if (error) return <ErrorBox message={error.message} onRetry={() => mutate()} />;

  return (
    <div>
      <h1 className="mb-4 text-center text-xl font-semibold">Dualar</h1>
      <div className="space-y-2">
        {(data?.results ?? []).map((c) => (
          <Link
            key={c.id}
            href={`/dua/${c.id}?name=${encodeURIComponent(c.name)}`}
            className="flex items-center justify-between rounded-xl bg-surface px-4 py-4"
          >
            <span className="font-medium">{c.name}</span>
            <span className="text-foreground-muted">›</span>
          </Link>
        ))}
      </div>
    </div>
  );
}
