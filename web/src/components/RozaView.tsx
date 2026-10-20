"use client";

import { useState } from "react";

const OLDEST_YEAR = 1940;
const YEARS_PER_PAGE = 12;
const DAYS = 30;
const STORAGE_PREFIX = "roza_days_";

/** First (newest) year shown on the given page: page 0 starts at the current year. */
export function rozaTopYear(page: number): number {
  return new Date().getFullYear() - page * YEARS_PER_PAGE;
}

export function rozaBottomYear(page: number): number {
  return Math.max(rozaTopYear(page) - YEARS_PER_PAGE + 1, OLDEST_YEAR);
}

export function rozaCanGoOlder(page: number): boolean {
  return rozaTopYear(page) - YEARS_PER_PAGE >= OLDEST_YEAR;
}

type DaysByYear = Record<number, number[]>;

/** Days of fasting kept, per year. Stored in this browser only (no backend yet). */
function loadDays(): DaysByYear {
  const loaded: DaysByYear = {};
  if (typeof window === "undefined") return loaded;
  try {
    for (let year = OLDEST_YEAR; year <= new Date().getFullYear(); year++) {
      const raw = localStorage.getItem(`${STORAGE_PREFIX}${year}`);
      if (raw) loaded[year] = raw.split(",").map(Number);
    }
  } catch {}
  return loaded;
}

function useRozaDays() {
  // Only mounted after the user switches to "Ro'za", so never during SSR.
  const [days, setDays] = useState<DaysByYear>(loadDays);

  function setDone(year: number, day: number, done: boolean) {
    setDays((prev) => {
      const set = new Set(prev[year] ?? []);
      if (done) set.add(day);
      else set.delete(day);
      const sorted = [...set].sort((a, b) => a - b);
      try {
        localStorage.setItem(`${STORAGE_PREFIX}${year}`, sorted.join(","));
      } catch {}
      return { ...prev, [year]: sorted };
    });
  }

  return { days, setDone };
}

/**
 * Ro'za view: the twelve month slots hold years in reverse order — the last
 * slot (Dekabr) is the newest year of the page, the first (Yanvar) the oldest.
 */
export function RozaView({ page }: { page: number }) {
  const { days, setDone } = useRozaDays();
  const [openYear, setOpenYear] = useState<number | null>(null);
  const [openDay, setOpenDay] = useState<number | null>(null);
  const top = rozaTopYear(page);
  const currentYear = new Date().getFullYear();

  return (
    <>
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
        {Array.from({ length: YEARS_PER_PAGE }, (_, slot) => {
          const year = top - (YEARS_PER_PAGE - 1 - slot);
          if (year < OLDEST_YEAR) return <div key={slot} />;
          const done = new Set(days[year] ?? []);
          const isCurrent = year === currentYear;
          return (
            <div
              key={slot}
              role="button"
              tabIndex={0}
              onClick={() => setOpenYear(year)}
              onKeyDown={(e) => e.key === "Enter" && setOpenYear(year)}
              className={`cursor-pointer rounded-xl border bg-surface p-2 ${
                isCurrent ? "border-primary" : "border-outline"
              }`}
            >
              <p className={`mb-1 text-center text-sm font-semibold ${isCurrent ? "text-primary" : ""}`}>{year}</p>
              <div className="grid grid-cols-6 gap-0.5">
                {Array.from({ length: DAYS }, (_, i) => i + 1).map((day) => (
                  <span
                    key={day}
                    className={`flex aspect-square items-center justify-center rounded text-[13px] sm:text-sm ${
                      done.has(day) ? "bg-green-600/45" : ""
                    }`}
                  >
                    {day}
                  </span>
                ))}
              </div>
            </div>
          );
        })}
      </div>

      {openYear !== null && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4"
          onClick={() => {
            setOpenYear(null);
            setOpenDay(null);
          }}
        >
          <div className="w-full max-w-sm rounded-2xl bg-surface p-4" onClick={(e) => e.stopPropagation()}>
            <p className="mb-3 text-center text-lg font-medium">{openYear}</p>
            <div className="grid grid-cols-5 gap-2">
              {Array.from({ length: DAYS }, (_, i) => i + 1).map((day) => (
                <button
                  key={day}
                  onClick={() => setOpenDay(day)}
                  className={`flex aspect-square cursor-pointer items-center justify-center rounded-lg border border-outline text-lg transition-colors ${
                    (days[openYear] ?? []).includes(day)
                      ? "bg-green-600/45 hover:bg-green-600/65"
                      : "hover:bg-foreground/15"
                  }`}
                >
                  {day}
                </button>
              ))}
            </div>
          </div>

          {openDay !== null && (
            <DayDialog
              key={`${openYear}-${openDay}`}
              year={openYear}
              day={openDay}
              initiallyDone={(days[openYear] ?? []).includes(openDay)}
              onSave={(done) => {
                setDone(openYear, openDay, done);
                setOpenDay(null);
              }}
              onClose={() => setOpenDay(null)}
            />
          )}
        </div>
      )}
    </>
  );
}

/** The day's check box only takes effect when "Saqlash" is pressed. */
function DayDialog({
  year,
  day,
  initiallyDone,
  onSave,
  onClose,
}: {
  year: number;
  day: number;
  initiallyDone: boolean;
  onSave: (done: boolean) => void;
  onClose: () => void;
}) {
  const [done, setDone] = useState(initiallyDone);

  return (
    <div
      className="fixed inset-0 z-[60] flex items-center justify-center bg-black/40 p-4"
      onClick={(e) => {
        e.stopPropagation();
        onClose();
      }}
    >
      <div className="w-full max-w-xs rounded-2xl bg-surface px-6 py-7" onClick={(e) => e.stopPropagation()}>
        <p className="text-center text-2xl">{year}</p>
        <label className="mt-6 flex cursor-pointer items-center justify-end gap-20 pr-1">
          <span className="text-2xl">{day} - kun</span>
          <input
            type="checkbox"
            checked={done}
            onChange={(e) => setDone(e.target.checked)}
            className="h-7 w-7 cursor-pointer accent-accent-light"
          />
        </label>
        <button
          onClick={() => onSave(done)}
          className="mx-auto mt-6 block w-3/5 cursor-pointer rounded-full bg-[var(--checklist-save-bg)] py-2.5 font-semibold text-black"
        >
          Saqlash
        </button>
      </div>
    </div>
  );
}
