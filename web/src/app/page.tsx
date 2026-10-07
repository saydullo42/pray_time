"use client";

import { useState } from "react";
import useSWR from "swr";
import { RequireAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { useLocation } from "@/lib/location-context";
import { formatDateISO, formatGregorianUz, hijriMonthUz, isFutureDate, UZ_MONTHS } from "@/lib/date-utils";
import { Loading, ErrorBox } from "@/components/Status";
import { MonthCalendar } from "@/components/MonthCalendar";
import { DailyChecklistModal } from "@/components/DailyChecklistModal";
import { LocationSelector } from "@/components/LocationSelector";
import type { MonthCalendarCounts, PrayerTime } from "@/lib/types";

export default function HomePage() {
  return (
    <RequireAuth>
      <HomeContent />
    </RequireAuth>
  );
}

function HomeContent() {
  const { latitude, longitude } = useLocation();
  const [focused, setFocused] = useState(new Date());
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const today = new Date();
  const dateIso = formatDateISO(today);

  const {
    data: prayerTime,
    error: ptError,
    isLoading: ptLoading,
    mutate: mutatePt,
  } = useSWR(["today", latitude, longitude, dateIso], () =>
    api.get<PrayerTime>("/prayer-times/today/", {
      latitude,
      longitude,
      date: dateIso,
      method: 3,
    })
  );

  const year = focused.getFullYear();
  const month = focused.getMonth() + 1;
  const {
    data: counts,
    mutate: mutateCounts,
  } = useSWR(["calendar", year, month], () =>
    api.get<MonthCalendarCounts>("/tracking/calendar/", { year, month })
  );

  return (
    <div className="-mt-4 space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start">
        <LocationSelector />

        <div className="flex-1 space-y-4">
          <div className="flex items-center justify-between">
            {prayerTime && (
              <span className="text-sm text-accent-light">
                {prayerTime.hijri_day} {hijriMonthUz(prayerTime.hijri_month)} {prayerTime.hijri_year}
              </span>
            )}
            <span className="shrink-0 whitespace-nowrap text-sm font-medium">
              {formatGregorianUz(today)}
            </span>
          </div>

          {ptLoading && <Loading />}
          {ptError && <ErrorBox message={ptError.message} onRetry={() => mutatePt()} />}

          {prayerTime && (
            <PrayerTimesBar
              entries={[
                ["Bomdod", prayerTime.fajr],
                ["Quyosh", prayerTime.sunrise],
                ["Peshin", prayerTime.dhuhr],
                ["Asr", prayerTime.asr],
                ["Shom", prayerTime.maghrib],
                ["Xufton", prayerTime.isha],
              ]}
            />
          )}

          <div className="grid grid-cols-3 sm:grid-cols-6">
            <p className="col-span-3 whitespace-nowrap text-left text-[11px] font-semibold text-foreground-muted sm:col-span-6 sm:text-sm">
              * Oylik kalendarga o&apos;qilgan namozlarni belgilab borishingiz mumkin.
            </p>
          </div>
        </div>
      </div>

      <div className="mx-auto max-w-sm rounded-2xl border border-outline bg-surface p-3">
        <div className="mb-3 flex items-center justify-center gap-6">
          <button
            onClick={() => setFocused(new Date(year, month - 2, 1))}
            className="text-2xl font-bold text-foreground-muted hover:text-foreground"
          >
            ‹
          </button>
          <span className="font-medium">
            {UZ_MONTHS[month - 1]} {year}
          </span>
          <button
            onClick={() => setFocused(new Date(year, month, 1))}
            className="text-2xl font-bold text-foreground-muted hover:text-foreground"
          >
            ›
          </button>
        </div>
        <MonthCalendar
          year={year}
          month={month}
          counts={counts?.results ?? {}}
          selectedDay={selectedDay}
          onSelectDay={(day) => {
            if (!isFutureDate(new Date(year, month - 1, day))) {
              setSelectedDay(day);
            }
          }}
        />
      </div>

      {selectedDay && (
        <DailyChecklistModal
          date={new Date(year, month - 1, selectedDay)}
          onClose={() => setSelectedDay(null)}
          onSaved={() => mutateCounts()}
        />
      )}
    </div>
  );
}

function PrayerTimesBar({ entries }: { entries: [string, string][] }) {
  return (
    <div className="grid grid-cols-3 gap-y-3 rounded-2xl border border-outline bg-surface py-5 sm:grid-cols-6">
      {entries.map(([label, time]) => (
        <div key={label} className="flex flex-col items-center gap-1">
          <span className="text-xs font-bold text-foreground-muted">{label}</span>
          <span className="font-medium">{time}</span>
        </div>
      ))}
    </div>
  );
}
