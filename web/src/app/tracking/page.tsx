"use client";

import { useEffect, useRef, useState } from "react";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { UZ_MONTHS, formatDateISO, isFutureDate, daysInMonth } from "@/lib/date-utils";
import { Loading, ErrorBox } from "@/components/Status";
import { MonthCalendar } from "@/components/MonthCalendar";
import { DailyChecklistModal } from "@/components/DailyChecklistModal";
import { ModeSelect } from "@/components/ModeSelect";
import { RozaView, rozaBottomYear, rozaCanGoOlder, rozaTopYear } from "@/components/RozaView";
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
  const [mode, setMode] = useState<"namoz" | "roza">("namoz");
  const [rozaPage, setRozaPage] = useState(0);
  const [pickingYear, setPickingYear] = useState(false);
  const isNamoz = mode === "namoz";

  const { data, error, isLoading, mutate } = useSWR(isNamoz ? ["yearly-calendar", year] : null, async () => {
    const months = await Promise.all(
      Array.from({ length: 12 }, (_, i) =>
        api.get<MonthCalendarCounts>("/tracking/calendar/", { year, month: i + 1 })
      )
    );
    return months.map((m) => m.results);
  });

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-center gap-4">
        <ModeSelect
          value={mode}
          onChange={setMode}
          ariaLabel="Namoz yoki Ro'za"
          options={[
            { value: "namoz", label: "Namoz" },
            { value: "roza", label: "Ro'za" },
          ]}
        />
        <button
          onClick={() => (isNamoz ? setYear((y) => y - 1) : setRozaPage((p) => p + 1))}
          disabled={!isNamoz && !rozaCanGoOlder(rozaPage)}
          className="cursor-pointer px-2 text-4xl font-bold leading-none text-foreground-muted hover:text-foreground disabled:cursor-default disabled:opacity-30"
        >
          ‹
        </button>
        {/* A fixed-width middle keeps the arrows in place in both modes. */}
        <div className="flex w-40 justify-center">
          {isNamoz ? (
            <button
              onClick={() => setPickingYear(true)}
              aria-label="Yilni tanlash"
              className="flex cursor-pointer items-center gap-1 rounded-lg border border-outline bg-surface px-3 py-1.5 text-xl font-semibold"
            >
              {year}
              <span aria-hidden="true" className="text-xs">
                ▾
              </span>
            </button>
          ) : (
            <span className="text-center text-xl font-medium">{`${rozaBottomYear(rozaPage)} - ${rozaTopYear(rozaPage)}`}</span>
          )}
        </div>
        <button
          onClick={() => (isNamoz ? setYear((y) => y + 1) : setRozaPage((p) => p - 1))}
          disabled={!isNamoz && rozaPage === 0}
          className="cursor-pointer px-2 text-4xl font-bold leading-none text-foreground-muted hover:text-foreground disabled:cursor-default disabled:opacity-30"
        >
          ›
        </button>
      </div>

      {pickingYear && (
        <YearPicker
          selected={year}
          onSelect={(picked) => {
            setYear(picked);
            setPickingYear(false);
          }}
          onClose={() => setPickingYear(false)}
        />
      )}

      {!isNamoz && <RozaView page={rozaPage} />}

      {isNamoz && isLoading && <Loading />}
      {isNamoz && error && <ErrorBox message={error.message} onRetry={() => mutate()} />}

      {isNamoz && data && (
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
                <p className={`mb-1 text-center text-base font-semibold sm:text-lg ${isCurrent ? "text-primary" : ""}`}>
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
            className="flex-1 cursor-pointer rounded-full border border-danger py-2 text-sm text-danger transition-colors hover:bg-danger/15 disabled:cursor-default disabled:opacity-60 disabled:hover:bg-transparent"
          >
            Hammasini o&apos;chirish
          </button>
          <button
            onClick={() => bulkSet(true)}
            disabled={busy}
            className="flex-1 cursor-pointer rounded-full border border-[#2E7D32] bg-transparent py-2 text-sm font-semibold text-[#2E7D32] transition-colors hover:bg-[#C8E6C9] disabled:cursor-default disabled:opacity-60 disabled:hover:bg-transparent"
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

const OLDEST_YEAR = 1940;

/** A scrolling list of years, newest first (this year at the top). */
function YearPicker({
  selected,
  onSelect,
  onClose,
}: {
  selected: number;
  onSelect: (year: number) => void;
  onClose: () => void;
}) {
  const newest = Math.max(new Date().getFullYear(), selected);
  const years = Array.from({ length: newest - OLDEST_YEAR + 1 }, (_, i) => newest - i);
  const selectedRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    selectedRef.current?.scrollIntoView({ block: "center" });
  }, []);

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 sm:items-center" onClick={onClose}>
      <div
        className="themed-scrollbar max-h-[70vh] w-full max-w-sm overflow-y-auto rounded-t-2xl bg-surface p-4 sm:rounded-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <p className="mb-3 text-center font-medium">Yilni tanlang</p>
        <div className="divide-y divide-outline">
          {years.map((y) => (
            <button
              key={y}
              ref={y === selected ? selectedRef : undefined}
              onClick={() => onSelect(y)}
              className={`block w-full cursor-pointer px-3 py-3 text-center text-lg ${
                y === selected ? "rounded-lg bg-accent font-semibold text-black" : "hover:bg-surface-alt"
              }`}
            >
              {y}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
