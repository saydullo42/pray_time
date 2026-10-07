"use client";

import { useState } from "react";
import { useLocation } from "@/lib/location-context";
import { UZBEKISTAN_REGIONS, districtLabel, findRegion } from "@/lib/uzbekistan-regions";

export function LocationSelector() {
  const { regionName, districtName, setRegion, setDistrict } = useLocation();
  const [picker, setPicker] = useState<"region" | "district" | null>(null);

  const districts = findRegion(regionName)?.districts ?? [];

  return (
    <div className="-ml-4 flex w-36 shrink-0 flex-col gap-1.5 sm:w-48">
      <div>
        <p className="mb-0.5 text-xs font-bold text-foreground-muted">Viloyatni tanlang:</p>
        <button
          onClick={() => setPicker("region")}
          className="flex w-full items-center justify-between gap-1 rounded-lg border border-outline bg-surface px-2 py-1.5 text-left text-sm font-semibold"
        >
          <span className="truncate">{regionName}</span>
          <ChevronDown />
        </button>
      </div>
      <div className="mt-3">
        <p className="mb-0.5 text-xs font-bold text-foreground-muted">Tumanni tanlang:</p>
        <button
          onClick={() => setPicker("district")}
          className="flex w-full items-center justify-between gap-1 rounded-lg border border-outline bg-surface px-2 py-1.5 text-left text-sm font-semibold text-accent-light"
        >
          <span className="truncate">{districtLabel(districtName)}</span>
          <ChevronDown />
        </button>
      </div>

      {picker === "region" && (
        <PickerModal
          title="Viloyatni tanlang"
          items={UZBEKISTAN_REGIONS.map((r) => r.name)}
          selected={regionName}
          onSelect={(name) => {
            setRegion(name);
            setPicker(null);
          }}
          onClose={() => setPicker(null)}
        />
      )}
      {picker === "district" && (
        <PickerModal
          title="Tumanni tanlang"
          items={districts.map((d) => d.name)}
          labelFor={districtLabel}
          selected={districtName}
          onSelect={(name) => {
            setDistrict(name);
            setPicker(null);
          }}
          onClose={() => setPicker(null)}
        />
      )}
    </div>
  );
}

function ChevronDown() {
  return (
    <svg
      width="12"
      height="12"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className="shrink-0"
    >
      <path d="M6 9l6 6 6-6" />
    </svg>
  );
}

function PickerModal({
  title,
  items,
  labelFor = (name) => name,
  selected,
  onSelect,
  onClose,
}: {
  title: string;
  items: string[];
  labelFor?: (name: string) => string;
  selected: string;
  onSelect: (name: string) => void;
  onClose: () => void;
}) {
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 sm:items-center" onClick={onClose}>
      <div
        className="max-h-[70vh] w-full max-w-sm overflow-y-auto rounded-t-2xl bg-surface p-4 sm:rounded-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <p className="mb-3 text-center font-medium">{title}</p>
        <div className="space-y-1">
          {items.map((name) => (
            <button
              key={name}
              onClick={() => onSelect(name)}
              className={`block w-full rounded-lg px-3 py-2 text-left ${
                name === selected ? "bg-accent font-semibold text-black" : "hover:bg-surface-alt"
              }`}
            >
              {labelFor(name)}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
