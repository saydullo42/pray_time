"use client";

import { use } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { Loading, ErrorBox } from "@/components/Status";
import { BackLink } from "@/components/BackLink";
import type { Dua, DuaCategory } from "@/lib/types";

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
  const categoryName = searchParams.get("name") ?? "Duolar";

  const { data, error, isLoading, mutate } = useSWR(["duas", categoryId], () =>
    api.get<{ results: Dua[] }>("/dua/", { category_id: categoryId })
  );

  const { data: categories, isLoading: categoriesLoading } = useSWR("dua-categories", () =>
    api.get<{ results: DuaCategory[] }>("/dua/categories/")
  );

  if (isLoading || categoriesLoading) return <Loading />;
  if (error) return <ErrorBox message={error.message} onRetry={() => mutate()} />;

  const inline = categories?.results.some((c) => String(c.id) === categoryId && c.inline_images) ?? false;

  if (inline) {
    return (
      <div>
        <BackLink href="/dua" />
        <h1 className="mb-4 text-center text-xl font-semibold">{categoryName}</h1>
        <div className="space-y-5">
          {(data?.results ?? []).map((d, i, all) => (
            <InlineDua key={d.id} dua={d} isLast={i === all.length - 1} />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div>
      <BackLink href="/dua" />
      <h1 className="mb-4 text-center text-xl font-semibold">{categoryName}</h1>
      <div className="space-y-2">
        {(data?.results ?? []).map((d) => (
          <Link
            key={d.id}
            href={`/dua/${categoryId}/${d.id}`}
            className="flex items-center justify-between rounded-xl bg-surface py-4 pl-12 pr-4"
          >
            <span className="font-medium">{d.title}</span>
            <span className="text-foreground-muted">›</span>
          </Link>
        ))}
      </div>
    </div>
  );
}

function StyledLines({ text, prefix }: { text: string; prefix?: string }) {
  return (
    <>
      {text.split("\n").map((line, i) => {
        const bold = line.length > 4 && line.startsWith("**") && line.endsWith("**");
        return (
          <p key={i} className={`min-h-[1.5em] ${bold ? "font-semibold" : ""}`}>
            {i === 0 && prefix && <span className="font-bold">{prefix}</span>}
            {bold ? line.slice(2, -2) : line}
          </p>
        );
      })}
    </>
  );
}

function InlineDua({ dua, isLast }: { dua: Dua; isLast: boolean }) {
  const hasImage = !!dua.image_url;
  const showDivider = dua.title !== "" || !hasImage || isLast;
  return (
    <div>
      {dua.title && <h2 className="mb-3 text-lg font-bold">{dua.title}</h2>}
      {dua.image_url && (
        // eslint-disable-next-line @next/next/no-img-element
        <img src={dua.image_url} alt={dua.title} className="mb-3 w-full rounded-xl" />
      )}
      {dua.translation && (
        <div className="text-lg leading-relaxed">
          <StyledLines text={dua.translation} prefix={hasImage ? "Ma'nosi: " : undefined} />
        </div>
      )}
      {showDivider && <hr className="mt-5 border-foreground-muted/30" />}
    </div>
  );
}
