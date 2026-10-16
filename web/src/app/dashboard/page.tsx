"use client";

import { useState } from "react";
import { notFound } from "next/navigation";
import useSWR from "swr";
import { RequireAuth, useAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { Loading, ErrorBox } from "@/components/Status";
import { BarChart } from "@/components/BarChart";
import type { DashboardStats } from "@/lib/types";

const PERIODS = [7, 30, 90];

export default function DashboardPage() {
  return (
    <RequireAuth>
      <Gate />
    </RequireAuth>
  );
}

// Only staff accounts may see this page; everyone else gets the normal 404.
function Gate() {
  const { user } = useAuth();
  if (!user?.is_staff) notFound();
  return <Content />;
}

function Content() {
  const [days, setDays] = useState(30);
  const { data, error, isLoading, mutate } = useSWR(
    ["dashboard", days],
    () => api.get<DashboardStats>("/dashboard/", { days }),
    { refreshInterval: 60_000 }
  );

  return (
    <div className="space-y-6 pb-6">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">Dashboard</h1>
          {data && (
            <p className="text-sm text-foreground-muted">
              Yangilangan: {new Date(data.generated_at).toLocaleTimeString("uz-UZ", { hour: "2-digit", minute: "2-digit" })}
            </p>
          )}
        </div>
        <div className="flex rounded-full border border-outline p-1">
          {PERIODS.map((p) => (
            <button
              key={p}
              onClick={() => setDays(p)}
              className={`rounded-full px-3 py-1 text-sm transition-colors ${
                days === p ? "bg-accent font-semibold text-black" : "text-foreground-muted"
              }`}
            >
              {p} kun
            </button>
          ))}
        </div>
      </div>

      {isLoading && !data && <Loading />}
      {error && <ErrorBox message={error.message} onRetry={() => mutate()} />}
      {data && <Stats data={data} />}
    </div>
  );
}

function percent(part: number, whole: number): string {
  return whole ? `${Math.round((part / whole) * 100)}%` : "0%";
}

function Stats({ data }: { data: DashboardStats }) {
  const { users, activity, features } = data;
  const platformTotal = activity.platforms_30d.mobile + activity.platforms_30d.web;
  const change = activity.dau - activity.dau_yesterday;

  return (
    <>
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Card label="Jami foydalanuvchilar" value={users.total} />
        <Card
          label="Bugun faol"
          value={activity.dau}
          hint={`kecha ${activity.dau_yesterday} (${change >= 0 ? "+" : ""}${change})`}
        />
        <Card
          label="Haftalik faol (7 kun)"
          value={activity.wau}
          hint={`shundan ${activity.returning_7d} tasi eski foydalanuvchi`}
        />
        <Card label="Oylik faol (30 kun)" value={activity.mau} />
        <Card label="Bugun yangi" value={users.new_today} />
        <Card label="7 kunda yangi" value={users.new_7d} />
        <Card label="30 kunda yangi" value={users.new_30d} />
        <Card
          label="Faollik ulushi"
          value={`${activity.stickiness}%`}
          hint="oylik foydalanuvchilar ichida bugun kirganlar"
        />
      </div>

      <Section title={`Kunlik faol foydalanuvchilar (${data.days} kun)`}>
        <BarChart data={activity.daily} />
        <p className="mt-3 text-xs text-foreground-muted">
          {activity.tracked_since
            ? `Faollik statistikasi ${activity.tracked_since} dan boshlab yig'ilgan, undan oldingi kunlar bo'sh ko'rinadi.`
            : "Faollik statistikasi hali yig'ilmagan: foydalanuvchilar kirgach shu yerda paydo bo'ladi."}
        </p>
      </Section>

      <Section title={`Yangi ro'yxatdan o'tganlar (${data.days} kun)`}>
        <BarChart data={users.signups} color="var(--primary)" />
      </Section>

      <Section title="Qaysi qurilmadan kirishadi (30 kun)">
        <div className="space-y-3">
          <Bar label="Mobil ilova" value={activity.platforms_30d.mobile} total={platformTotal} />
          <Bar label="Veb sayt" value={activity.platforms_30d.web} total={platformTotal} />
        </div>
        <p className="mt-3 text-xs text-foreground-muted">
          Bir odam ikkalasidan ham kirgan bo&apos;lsa, ikkala qatorda ham hisoblanadi.
        </p>
      </Section>

      <Section title="Funksiyalardan foydalanish">
        <div className="space-y-3">
          <Bar label="Namoz belgilagan" value={features.users_who_marked_prayers} total={users.total} />
          <Bar label="So'nggi 7 kunda belgilagan" value={features.users_marking_7d} total={users.total} />
          <Bar label="Eslatma sozlagan" value={features.users_with_reminder_settings} total={users.total} />
          <Bar label="2-jadvalni (o'z vaqtlari) ishlatadi" value={features.users_with_custom_times} total={users.total} />
        </div>
      </Section>

      <Section title="So'nggi ro'yxatdan o'tganlar">
        <ul className="divide-y divide-outline">
          {data.recent_signups.map((u) => (
            <li key={u.email} className="flex items-center justify-between gap-3 py-2 text-sm">
              <div className="min-w-0">
                <p className="truncate font-medium">{u.full_name || "Ism kiritilmagan"}</p>
                <p className="truncate text-foreground-muted">{u.email}</p>
              </div>
              <time className="shrink-0 text-foreground-muted" dateTime={u.date_joined}>
                {new Date(u.date_joined).toLocaleDateString("uz-UZ", { day: "2-digit", month: "2-digit", year: "numeric" })}
              </time>
            </li>
          ))}
        </ul>
      </Section>
    </>
  );
}

function Card({ label, value, hint }: { label: string; value: number | string; hint?: string }) {
  return (
    <div className="rounded-2xl border border-outline bg-surface p-4">
      <p className="text-sm text-foreground-muted">{label}</p>
      <p className="mt-1 text-3xl font-semibold tabular-nums">{value}</p>
      {hint && <p className="mt-1 text-xs text-foreground-muted">{hint}</p>}
    </div>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="rounded-2xl border border-outline bg-surface p-4">
      <h2 className="mb-3 font-semibold">{title}</h2>
      {children}
    </section>
  );
}

function Bar({ label, value, total }: { label: string; value: number; total: number }) {
  const width = total ? Math.min(100, (value / total) * 100) : 0;
  return (
    <div>
      <div className="mb-1 flex justify-between text-sm">
        <span>{label}</span>
        <span className="tabular-nums text-foreground-muted">
          {value} ({percent(value, total)})
        </span>
      </div>
      <div className="h-2 rounded-full bg-surface-alt">
        <div className="h-2 rounded-full bg-accent-light" style={{ width: `${width}%` }} />
      </div>
    </div>
  );
}
