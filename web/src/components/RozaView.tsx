"use client";

import { useEffect, useState } from "react";

import { api } from "@/lib/api";

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

// After the first sync the server is the source of truth for this browser.
const SYNCED_KEY = "roza_synced";
// The account the cached days belong to.
const OWNER_KEY = "roza_owner";
// Years whose latest change has not reached the server yet (offline, server error).
const DIRTY_KEY = "roza_dirty";

function readDirty(): number[] {
  try {
    return JSON.parse(localStorage.getItem(DIRTY_KEY) ?? "[]") as number[];
  } catch {
    return [];
  }
}

function writeDirty(years: Iterable<number>) {
  try {
    localStorage.setItem(DIRTY_KEY, JSON.stringify([...new Set(years)]));
  } catch {}
}

function saveLocal(year: number, days: number[]) {
  try {
    localStorage.setItem(`${STORAGE_PREFIX}${year}`, days.join(","));
  } catch {}
}

/** Days of fasting kept, per year, as cached in this browser. */
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

async function pushYear(year: number, days: number[]): Promise<boolean> {
  try {
    await api.put(`/tracking/roza/${year}/`, { days });
    return true;
  } catch {
    return false;
  }
}

/** Pulls the days from the server (and sends up what the server lacks). */
async function syncWithServer(): Promise<DaysByYear | null> {
  let server: Record<string, number[]>;
  let userId: string;
  try {
    const response = await api.get<{ user_id: number; results: Record<string, number[]> }>("/tracking/roza/");
    server = response.results;
    userId = String(response.user_id);
  } catch {
    return null; // offline: keep showing the cached days
  }
  try {
    // Days cached for another account (e.g. the session expired and someone else
    // signed in) must not leak into this one.
    const owner = localStorage.getItem(OWNER_KEY);
    if (owner && owner !== userId) {
      Object.keys(localStorage)
        .filter((key) => key.startsWith("roza_"))
        .forEach((key) => localStorage.removeItem(key));
    }
    localStorage.setItem(OWNER_KEY, userId);
  } catch {}
  const local = loadDays();
  const dirty = new Set(readDirty());
  // The first time on this browser, the days marked here before the server stored
  // them are added to the server's instead of being overwritten.
  const firstSync = !localStorage.getItem(SYNCED_KEY);

  const merged: DaysByYear = {};
  const toPush: number[] = [];
  const years = new Set([...Object.keys(server).map(Number), ...Object.keys(local).map(Number)]);
  for (const year of years) {
    const fromServer = server[year] ?? [];
    const fromHere = local[year] ?? [];
    if (dirty.has(year)) {
      merged[year] = fromHere;
      toPush.push(year);
    } else if (firstSync) {
      const union = [...new Set([...fromServer, ...fromHere])].sort((a, b) => a - b);
      merged[year] = union;
      if (union.length !== fromServer.length) toPush.push(year);
    } else {
      merged[year] = fromServer;
    }
  }

  const stillDirty: number[] = [];
  for (const year of toPush) {
    if (!(await pushYear(year, merged[year]))) stillDirty.push(year);
  }
  writeDirty(stillDirty);
  if (stillDirty.length === 0) {
    try {
      localStorage.setItem(SYNCED_KEY, "1");
    } catch {}
  }
  for (const [year, list] of Object.entries(merged)) saveLocal(Number(year), list);
  return merged;
}

function useRozaDays() {
  // Only mounted after the user switches to "Ro'za", so never during SSR.
  const [days, setDays] = useState<DaysByYear>(loadDays);

  useEffect(() => {
    let cancelled = false;
    syncWithServer().then((merged) => {
      if (merged && !cancelled) setDays(merged);
    });
    return () => {
      cancelled = true;
    };
  }, []);

  /** Shows and caches the new days of a year at once, then sends them to the server. */
  function commit(year: number, list: number[]) {
    setDays((prev) => ({ ...prev, [year]: list }));
    saveLocal(year, list);
    pushYear(year, list).then((ok) => {
      const dirty = new Set(readDirty());
      if (ok) dirty.delete(year);
      else dirty.add(year);
      writeDirty(dirty);
    });
  }

  function setDone(year: number, day: number, done: boolean) {
    const set = new Set(days[year] ?? []);
    if (done) set.add(day);
    else set.delete(day);
    commit(year, [...set].sort((a, b) => a - b));
  }

  /** Marks all 30 days of a year as kept, or clears the year. */
  function setAllDone(year: number, done: boolean) {
    commit(year, done ? Array.from({ length: DAYS }, (_, i) => i + 1) : []);
  }

  return { days, setDone, setAllDone };
}

/**
 * Ro'za view: the twelve month slots hold years in reverse order — the last
 * slot (Dekabr) is the newest year of the page, the first (Yanvar) the oldest.
 */
export function RozaView({ page }: { page: number }) {
  const { days, setDone, setAllDone } = useRozaDays();
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
            <div className="mt-4 flex gap-2">
              <button
                onClick={() => setAllDone(openYear, false)}
                className="flex-1 cursor-pointer rounded-full border border-danger py-2 text-sm text-danger transition-colors hover:bg-danger/15"
              >
                Hammasini o&apos;chirish
              </button>
              <button
                onClick={() => setAllDone(openYear, true)}
                className="flex-1 cursor-pointer rounded-full border border-[#2E7D32] bg-transparent py-2 text-sm font-semibold text-[#2E7D32] transition-colors hover:bg-[#C8E6C9]"
              >
                Hammasini belgilash
              </button>
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
