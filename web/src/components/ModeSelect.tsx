"use client";

import { useEffect, useRef, useState } from "react";

export interface ModeOption<T extends string> {
  value: T;
  label: string;
}

/** Dropdown button; the selected option gets a green check next to its text. */
export function ModeSelect<T extends string>({
  value,
  options,
  onChange,
  ariaLabel,
}: {
  value: T;
  options: ModeOption<T>[];
  onChange: (value: T) => void;
  ariaLabel: string;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    const close = (e: MouseEvent) => {
      if (!ref.current?.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", close);
    return () => document.removeEventListener("mousedown", close);
  }, [open]);

  const current = options.find((o) => o.value === value);

  return (
    <div ref={ref} className="relative">
      <button
        type="button"
        aria-label={ariaLabel}
        aria-haspopup="listbox"
        aria-expanded={open}
        onClick={() => setOpen((o) => !o)}
        className="flex cursor-pointer items-center gap-1 rounded-lg border border-outline bg-surface px-3 py-1.5 text-sm font-semibold"
      >
        {current?.label}
        <span aria-hidden="true" className="text-xs">▾</span>
      </button>
      {open && (
        <ul
          role="listbox"
          className="absolute left-0 z-30 mt-1 min-w-full rounded-lg border border-outline bg-surface py-1 shadow-lg"
        >
          {options.map((o, i) => (
            <li
              key={o.value}
              role="option"
              aria-selected={o.value === value}
              className={i > 0 ? "border-t border-outline" : ""}
            >
              <button
                type="button"
                onClick={() => {
                  onChange(o.value);
                  setOpen(false);
                }}
                className={`flex w-full cursor-pointer items-center gap-2 whitespace-nowrap px-3 py-2 text-left text-sm hover:bg-foreground/15 ${
                  o.value === value ? "bg-foreground/10" : ""
                }`}
              >
                {o.label}
                {o.value === value && (
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#22c55e" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                    <path d="M5 12l5 5L20 7" />
                  </svg>
                )}
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
