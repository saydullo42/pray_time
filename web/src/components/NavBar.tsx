"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { useTheme, type ThemeMode } from "@/lib/theme-context";

const ITEMS = [
  { href: "/", label: "Bosh sahifa", icon: HomeIcon },
  { href: "/tracking", label: "Yillik", icon: ChartIcon },
  { href: "/quran", label: "Qur'on", icon: BookIcon },
  { href: "/dua", label: "Duo", icon: DuaIcon },
  { href: "/profile", label: "Profil", icon: ProfileIcon },
];

const NEXT_MODE: Record<ThemeMode, ThemeMode> = {
  light: "dark",
  dark: "light",
};

const MODE_LABEL: Record<ThemeMode, string> = {
  light: "Yorug'",
  dark: "Qorong'i",
};

export function NavBar() {
  const pathname = usePathname();
  const { isAuthenticated } = useAuth();
  const { mode, setMode } = useTheme();

  if (!isAuthenticated) return null;

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 border-t border-outline bg-surface/95 backdrop-blur sm:sticky sm:top-0 sm:bottom-auto sm:border-t-0 sm:border-b">
      <div className="mx-auto flex max-w-3xl items-stretch justify-between px-2 sm:justify-center sm:gap-10">
        {ITEMS.map((item) => {
          const active = item.href === "/" ? pathname === "/" : pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex flex-1 flex-col items-center gap-1 py-2 text-xs font-semibold sm:flex-none sm:flex-row sm:gap-2 sm:py-3 sm:text-sm ${
                active ? "text-accent-light" : "text-foreground-muted"
              }`}
            >
              <item.icon active={active} />
              <span>{item.label}</span>
            </Link>
          );
        })}
        <button
          onClick={() => setMode(NEXT_MODE[mode])}
          title={`Mavzu: ${MODE_LABEL[mode]}`}
          className="flex flex-1 flex-col items-center gap-1 py-2 text-xs font-semibold text-foreground-muted sm:flex-none sm:flex-row sm:gap-2 sm:py-3 sm:text-sm"
        >
          <ThemeIcon mode={mode} />
          <span>{MODE_LABEL[mode]}</span>
        </button>
      </div>
    </nav>
  );
}

function ThemeIcon({ mode }: { mode: ThemeMode }) {
  const props = iconProps(false);
  if (mode === "light") {
    return (
      <svg {...props}>
        <circle cx="12" cy="12" r="4.5" />
        <path d="M12 2.5v2.5M12 19v2.5M4.6 4.6l1.8 1.8M17.6 17.6l1.8 1.8M2.5 12H5M19 12h2.5M4.6 19.4l1.8-1.8M17.6 6.4l1.8-1.8" />
      </svg>
    );
  }
  return (
    <svg {...props}>
      <path d="M20 14.5A8.5 8.5 0 1 1 9.5 4a7 7 0 0 0 10.5 10.5Z" />
    </svg>
  );
}

function iconProps(active: boolean) {
  return {
    width: 22,
    height: 22,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: active ? "var(--accent-light)" : "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };
}

function HomeIcon({ active }: { active: boolean }) {
  return (
    <svg {...iconProps(active)}>
      <path d="M3 10.5 12 3l9 7.5" />
      <path d="M5 9.5V21h14V9.5" />
    </svg>
  );
}
function ChartIcon({ active }: { active: boolean }) {
  return (
    <svg {...iconProps(active)}>
      <path d="M4 20V10M12 20V4M20 20v-7" />
    </svg>
  );
}
function BookIcon({ active }: { active: boolean }) {
  return (
    <svg {...iconProps(active)}>
      <path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H12v18H6.5A2.5 2.5 0 0 1 4 18.5z" />
      <path d="M20 5.5A2.5 2.5 0 0 0 17.5 3H12v18h5.5a2.5 2.5 0 0 0 2.5-2.5z" />
    </svg>
  );
}
function DuaIcon({ active }: { active: boolean }) {
  return (
    <svg {...iconProps(active)}>
      <path d="M7 11c0-3 2-5 5-5s5 2 5 5" />
      <path d="M4 15c0 3 3.5 6 8 6s8-3 8-6" />
      <path d="M4 15c0-2 1-3 3-3M20 15c0-2-1-3-3-3" />
    </svg>
  );
}
function ProfileIcon({ active }: { active: boolean }) {
  return (
    <svg {...iconProps(active)}>
      <circle cx="12" cy="8" r="3.5" />
      <path d="M4.5 20c1.5-4 5-5.5 7.5-5.5s6 1.5 7.5 5.5" />
    </svg>
  );
}
