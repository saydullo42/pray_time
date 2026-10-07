"use client";

import { daysInMonth, firstWeekdayOffset, isFutureDate, UZ_WEEKDAYS_SHORT } from "@/lib/date-utils";

export function colorForCompletionCount(count: number | undefined): string | undefined {
  if (count === undefined) return undefined;
  if (count >= 6) return "rgba(46, 125, 50, 0.45)"; // green
  if (count >= 3) return "rgba(255, 193, 7, 0.4)"; // amber
  return "rgba(198, 40, 40, 0.45)"; // red
}

interface MonthCalendarProps {
  year: number;
  month: number; // 1-12
  counts: Record<string, number>;
  onSelectDay: (day: number) => void;
  selectedDay?: number | null;
  compact?: boolean;
}

export function MonthCalendar({ year, month, counts, onSelectDay, selectedDay, compact }: MonthCalendarProps) {
  const total = daysInMonth(year, month);
  const offset = firstWeekdayOffset(year, month);
  const cells: (number | null)[] = [
    ...Array(offset).fill(null),
    ...Array.from({ length: total }, (_, i) => i + 1),
  ];
  while (cells.length % 7 !== 0) cells.push(null);

  const now = new Date();
  const isCurrentMonth = now.getFullYear() === year && now.getMonth() + 1 === month;

  return (
    <div>
      {!compact && (
        <div className="mb-2 grid grid-cols-7 text-center text-sm font-bold text-foreground-muted">
          {UZ_WEEKDAYS_SHORT.map((d) => (
            <div key={d}>{d}</div>
          ))}
        </div>
      )}
      <div className={`grid grid-cols-7 ${compact ? "gap-0.5" : "gap-1"}`}>
        {cells.map((day, i) => {
          if (day === null) return <div key={i} />;
          const key = `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
          const isToday = isCurrentMonth && day === now.getDate();
          const isSelected = selectedDay === day;
          const isFuture = isFutureDate(new Date(year, month - 1, day));
          return (
            <button
              key={i}
              onClick={() => onSelectDay(day)}
              style={{ background: colorForCompletionCount(counts[key]) }}
              className={`aspect-square rounded-md ${compact ? "text-[9px]" : "text-xs"} flex items-center justify-center border ${
                isSelected
                  ? "border-accent-light"
                  : isToday
                  ? "border-primary"
                  : "border-transparent"
              } ${isFuture ? "opacity-35" : "hover:border-accent-light/60"}`}
            >
              {day}
            </button>
          );
        })}
      </div>
    </div>
  );
}
