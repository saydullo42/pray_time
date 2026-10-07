"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { useLocation } from "@/lib/location-context";
import { formatDateISO, formatGregorianUz } from "@/lib/date-utils";
import { Loading } from "./Status";
import type { DailyTracking, PrayerTime } from "@/lib/types";

const PRAYERS = ["Bomdod", "Peshin", "Asr", "Shom", "Xufton", "Vitr"];
const FIELD_BY_PRAYER: Record<string, string> = {
  Bomdod: "bomdod",
  Peshin: "peshin",
  Asr: "asr",
  Shom: "shom",
  Xufton: "xufton",
  Vitr: "vitr",
};
// Vitr has no separate time from the API; it follows Isha, so it unlocks with it.
const TIME_FIELD_BY_PRAYER: Record<string, keyof PrayerTime> = {
  Bomdod: "fajr",
  Peshin: "dhuhr",
  Asr: "asr",
  Shom: "maghrib",
  Xufton: "isha",
  Vitr: "isha",
};

export function DailyChecklistModal({
  date,
  onClose,
  onSaved,
}: {
  date: Date;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [checked, setChecked] = useState<Record<string, boolean> | null>(null);
  const [saving, setSaving] = useState(false);
  const dateIso = formatDateISO(date);
  const isToday = dateIso === formatDateISO(new Date());

  const { latitude, longitude } = useLocation();
  const [todayTimes, setTodayTimes] = useState<PrayerTime | null>(null);

  useEffect(() => {
    let cancelled = false;
    const initial = Object.fromEntries(PRAYERS.map((p) => [p, false]));
    api
      .get<DailyTracking>("/tracking/daily/", { date: dateIso })
      .then((data) => {
        if (cancelled) return;
        const merged = { ...initial };
        for (const [prayer, done] of Object.entries(data.statuses)) {
          if (prayer in merged) merged[prayer] = done;
        }
        setChecked(merged);
      })
      .catch(() => {
        if (!cancelled) setChecked(initial);
      });
    return () => {
      cancelled = true;
    };
  }, [dateIso]);

  useEffect(() => {
    if (!isToday) return;
    let cancelled = false;
    api
      .get<PrayerTime>("/prayer-times/today/", { latitude, longitude, date: dateIso, method: 3 })
      .then((data) => {
        if (!cancelled) setTodayTimes(data);
      })
      .catch(() => {});
    return () => {
      cancelled = true;
    };
  }, [isToday, latitude, longitude, dateIso]);

  function isLocked(prayer: string): boolean {
    if (!isToday || !todayTimes) return false;
    const hhmm = todayTimes[TIME_FIELD_BY_PRAYER[prayer]] as string;
    const [h, m] = hhmm.split(":").map(Number);
    const prayerMoment = new Date();
    prayerMoment.setHours(h, m, 0, 0);
    return new Date() < prayerMoment;
  }

  function toggle(prayer: string) {
    if (!checked || isLocked(prayer)) return;
    setChecked({ ...checked, [prayer]: !checked[prayer] });
  }

  async function save() {
    if (!checked) return;
    setSaving(true);
    try {
      const body: Record<string, unknown> = { date: dateIso };
      for (const prayer of PRAYERS) {
        body[FIELD_BY_PRAYER[prayer]] = checked[prayer] ?? false;
      }
      await api.post("/tracking/daily-checklist/", body);
      onSaved();
      onClose();
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 sm:items-center" onClick={onClose}>
      <div
        className="w-full max-w-sm rounded-t-2xl bg-surface p-6 sm:rounded-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <p className="mb-4 text-center text-lg font-medium">{formatGregorianUz(date)}</p>
        {checked === null ? (
          <Loading />
        ) : (
          <>
            <div className="space-y-1">
              {PRAYERS.map((prayer) => {
                const locked = isLocked(prayer);
                return (
                  <label
                    key={prayer}
                    className={`flex items-center justify-between rounded-lg px-1 py-2.5 ${
                      locked ? "cursor-not-allowed opacity-40" : "cursor-pointer"
                    }`}
                    onClick={() => toggle(prayer)}
                  >
                    <span className="text-lg">{prayer}</span>
                    <input
                      type="checkbox"
                      readOnly
                      disabled={locked}
                      checked={checked[prayer] ?? false}
                      className="h-6 w-6 accent-accent"
                    />
                  </label>
                );
              })}
            </div>
            <button
              onClick={save}
              disabled={saving}
              className="mx-auto mt-6 block w-3/5 rounded-full bg-accent py-2.5 font-semibold text-black disabled:opacity-60"
            >
              {saving ? "..." : "Saqlash"}
            </button>
          </>
        )}
      </div>
    </div>
  );
}
