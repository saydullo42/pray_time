"use client";

import { useState } from "react";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { UZ_MONTHS, formatDateISO, isFutureDate, daysInMonth } from "@/lib/date-utils";
import { Loading, ErrorBox } from "@/components/Status";
import { MonthCalendar } from "@/components/MonthCalendar";
import { DailyChecklistModal } from "@/components/DailyChecklistModal";
import type { MonthCalendarCounts } from "@/lib/types";

export default function TrackingPage() {
  return (
    <RequireAuth>
      <TrackingContent />
    </RequireAuth>
  );
}

function TrackingContent() {
  const [year, setYear] = useState(new Date().getFullYear());
  const [openMonth, setOpenMonth] = useState<number | null>(null);

  const { data, error, isLoading, mutate } = useSWR(["yearly-calendar", year], async () => {
    const months = await Promise.all(
      Array.from({ length: 12 }, (_, i) =>
        api.get<MonthCalendarCounts>("/tracking/calendar/", { year, month: i + 1 })
      )
    );
    return months.map((m) => m.results);
  });

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-center gap-6">
        <button onClick={() => setYear((y) => y - 1)} className="text-foreground-muted hover:text-foreground">
          ‹
        </button>
        <span className="text-xl font-medium">{year}</span>
        <button onClick={() => setYear((y) => y + 1)} className="text-foreground-muted hover:text-foreground">
          ›
        </button>
      </div>

      {isLoading && <Loading />}
      {error && <ErrorBox message={error.message} onRetry={() => mutate()} />}

      {data && (
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
          {Array.from({ length: 12 }, (_, i) => i + 1).map((month) => {
            const now = new Date();
            const isCurrent = now.getFullYear() === year && now.getMonth() + 1 === month;
            return (
              <div
                key={month}
                role="button"
                tabIndex={0}
                onClick={() => setOpenMonth(month)}
                onKeyDown={(e) => e.key === "Enter" && setOpenMonth(month)}
                className={`cursor-pointer rounded-xl border bg-surface p-2 text-left ${
                  isCurrent ? "border-primary" : "border-outline"
                }`}
              >
                <p className={`mb-1 text-center text-xs font-semibold ${isCurrent ? "text-primary" : ""}`}>
                  {UZ_MONTHS[month - 1]}
                </p>
                <MonthCalendar
                  year={year}
                  month={month}
                  counts={data[month - 1]}
                  onSelectDay={() => setOpenMonth(month)}
                  compact
                />
              </div>
            );
          })}
        </div>
      )}

      {openMonth && (
        <MonthDetailModal
          year={year}
          month={openMonth}
          onClose={() => setOpenMonth(null)}
          onChanged={() => mutate()}
        />
      )}
    </div>
  );
}

function MonthDetailModal({
  year,
  month,
  onClose,
  onChanged,
}: {
  year: number;
  month: number;
  onClose: () => void;
  onChanged: () => void;
}) {
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const [busy, setBusy] = useState(false);

  const { data, mutate } = useSWR(["month-calendar", year, month], () =>
    api.get<MonthCalendarCounts>("/tracking/calendar/", { year, month })
  );

  function lastMarkableDay(): number {
    const now = new Date();
    const total = daysInMonth(year, month);
    if (year > now.getFullYear() || (year === now.getFullYear() && month > now.getMonth() + 1)) return 0;
    if (year === now.getFullYear() && month === now.getMonth() + 1) return now.getDate();
    return total;
  }

  const PRAYERS = ["bomdod", "peshin", "asr", "shom", "xufton", "vitr"];

  async function bulkSet(done: boolean) {
    const upTo = lastMarkableDay();
    setBusy(true);
    try {
      await Promise.all(
        Array.from({ length: upTo }, (_, i) => i + 1).map((day) => {
          const body: Record<string, unknown> = {
            date: formatDateISO(new Date(year, month - 1, day)),
          };
          for (const p of PRAYERS) body[p] = done;
          return api.post("/tracking/daily-checklist/", body);
        })
      );
      mutate();
      onChanged();
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4" onClick={onClose}>
      <div
        className="w-full max-w-sm rounded-2xl bg-surface p-4"
        onClick={(e) => e.stopPropagation()}
      >
        <p className="mb-3 text-center font-medium">
          {UZ_MONTHS[month - 1]} {year}
        </p>
        <MonthCalendar
          year={year}
          month={month}
          counts={data?.results ?? {}}
          selectedDay={selectedDay}
          onSelectDay={(day) => {
            const d = new Date(year, month - 1, day);
            if (!isFutureDate(d)) {
              setSelectedDay(day);
            }
          }}
        />
        <div className="mt-4 flex gap-2">
          <button
            onClick={() => bulkSet(false)}
            disabled={busy}
            className="flex-1 rounded-full border border-danger py-2 text-sm text-danger disabled:opacity-60"
          >
            Hammasini o&apos;chirish
          </button>
          <button
            onClick={() => bulkSet(true)}
            disabled={busy}
            className="flex-1 rounded-full bg-accent py-2 text-sm font-semibold text-black disabled:opacity-60"
          >
            Hammasini belgilash
          </button>
        </div>
      </div>

      {selectedDay && (
        <DailyChecklistModal
          date={new Date(year, month - 1, selectedDay)}
          onClose={() => setSelectedDay(null)}
          onSaved={() => {
            mutate();
            onChanged();
          }}
        />
      )}
    </div>
  );
}
