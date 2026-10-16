import type { DailyCount } from "@/lib/types";

/** "2026-10-16" -> "16.10" */
function shortDate(iso: string): string {
  const [, month, day] = iso.split("-");
  return `${day}.${month}`;
}

/** A small bar chart with one bar per day; hovering a bar shows its date and value. */
export function BarChart({ data, color = "var(--accent-light)" }: { data: DailyCount[]; color?: string }) {
  const max = Math.max(1, ...data.map((d) => d.count));
  const width = data.length * 10;

  return (
    <div>
      <div className="flex items-stretch gap-2">
        <div className="flex h-32 flex-col justify-between text-right text-xs tabular-nums text-foreground-muted">
          <span>{max}</span>
          <span>0</span>
        </div>
        <svg
          viewBox={`0 0 ${width} 100`}
          preserveAspectRatio="none"
          className="h-32 w-full flex-1 border-b border-l border-outline"
          role="img"
          aria-label="Kunlik grafik"
        >
          {data.map((d, i) => {
            const height = (d.count / max) * 96;
            return (
              <rect key={d.date} x={i * 10 + 1} y={100 - height} width={8} height={Math.max(height, d.count ? 1 : 0)} fill={color}>
                <title>{`${shortDate(d.date)}: ${d.count}`}</title>
              </rect>
            );
          })}
        </svg>
      </div>
      <div className="mt-1 flex justify-between pl-8 text-xs text-foreground-muted">
        <span>{shortDate(data[0].date)}</span>
        <span>{shortDate(data[data.length - 1].date)}</span>
      </div>
    </div>
  );
}
