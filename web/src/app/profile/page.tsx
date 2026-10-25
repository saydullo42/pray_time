"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { RequireAuth, useAuth } from "@/lib/auth-context";
import { useTheme, type ThemeMode } from "@/lib/theme-context";
import { api } from "@/lib/api";

const THEME_OPTIONS: { value: ThemeMode; label: string }[] = [
  { value: "light", label: "Yorug'" },
  { value: "dark", label: "Qorong'i" },
];

export default function ProfilePage() {
  return (
    <RequireAuth>
      <Content />
    </RequireAuth>
  );
}

function Content() {
  const { user, logout, refreshUser } = useAuth();
  const { mode, setMode } = useTheme();
  const router = useRouter();
  const [editing, setEditing] = useState(false);
  const [name, setName] = useState(user?.full_name ?? "");
  const [saving, setSaving] = useState(false);
  const [dialog, setDialog] = useState<"contact" | "about" | null>(null);

  async function save() {
    setSaving(true);
    try {
      await api.put("/users/me/", { full_name: name });
      await refreshUser();
      setEditing(false);
    } finally {
      setSaving(false);
    }
  }

  async function handleLogout() {
    await logout();
    router.replace("/login");
  }

  if (!user) return null;

  return (
    <div className="space-y-6 pt-6">
      <div className="flex flex-col items-center gap-2">
        <div className="flex h-20 w-20 items-center justify-center rounded-full bg-surface text-2xl font-semibold text-accent-light">
          {(user.full_name || user.email).charAt(0).toUpperCase()}
        </div>
        {editing ? (
          <div className="flex w-full max-w-xs flex-col items-center gap-2">
            <input
              autoFocus
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full rounded-lg border border-outline bg-transparent px-3 py-2 text-center"
            />
            <div className="flex gap-4">
              <button onClick={() => setEditing(false)} className="text-sm text-foreground-muted">
                Bekor qilish
              </button>
              <button onClick={save} disabled={saving} className="text-sm font-semibold text-accent-light">
                {saving ? "..." : "Saqlash"}
              </button>
            </div>
          </div>
        ) : (
          <button onClick={() => setEditing(true)} className="text-lg font-medium">
            {user.full_name || "Ism kiritilmagan"}
          </button>
        )}
        <p className="text-foreground-muted">{user.email}</p>
      </div>

      <div className="mx-auto w-full max-w-xs">
        <p className="mb-2 text-sm text-foreground-muted">Mavzu</p>
        <div className="flex rounded-full border border-outline p-1">
          {THEME_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              onClick={() => setMode(opt.value)}
              className={`flex-1 rounded-full py-2 text-sm transition-colors ${
                mode === opt.value ? "bg-accent font-semibold text-black" : "text-foreground-muted"
              }`}
            >
              {opt.label}
            </button>
          ))}
        </div>
      </div>

      <div className="mx-auto w-full max-w-xs divide-y divide-outline overflow-hidden rounded-2xl border border-outline bg-surface">
        <MenuRow label="Profilni tahrirlash" icon={<PencilIcon />} onClick={() => setEditing(true)} />
        <MenuRow label="Bog'lanish" icon={<MailIcon />} onClick={() => setDialog("contact")} />
        <MenuRow label="Dastur haqida" icon={<InfoIcon />} onClick={() => setDialog("about")} />
        <MenuRow label="Akkauntni o'chirish" icon={<TrashIcon />} href="/delete-account" danger />
      </div>

      {dialog === "contact" && <ContactDialog onClose={() => setDialog(null)} />}
      {dialog === "about" && <AboutDialog onClose={() => setDialog(null)} />}

      {user.is_staff && (
        <Link
          href="/dashboard"
          className="mx-auto block w-full max-w-xs rounded-full border border-outline py-3 text-center font-medium"
        >
          Dashboard
        </Link>
      )}

      <button
        onClick={handleLogout}
        className="mx-auto block w-full max-w-xs rounded-full border border-danger py-3 font-medium text-danger"
      >
        Chiqish
      </button>
    </div>
  );
}

const SUPPORT_EMAIL = "support.praytime@gmail.com";

function MenuRow({
  label,
  icon,
  onClick,
  href,
  danger,
}: {
  label: string;
  icon: React.ReactNode;
  onClick?: () => void;
  href?: string;
  danger?: boolean;
}) {
  const className = `flex w-full cursor-pointer items-center gap-3 px-4 py-3.5 text-left transition-colors hover:bg-surface-alt ${
    danger ? "text-danger" : ""
  }`;
  const content = (
    <>
      <span className={danger ? "" : "text-foreground-muted"}>{icon}</span>
      <span>{label}</span>
    </>
  );
  return href ? (
    <Link href={href} className={className}>
      {content}
    </Link>
  ) : (
    <button onClick={onClick} className={className}>
      {content}
    </button>
  );
}

function Dialog({
  title,
  onClose,
  actions,
  children,
}: {
  title: string;
  onClose: () => void;
  /** Extra buttons in the bottom row, left of "Yopish". */
  actions?: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4" onClick={onClose}>
      <div
        role="dialog"
        aria-label={title}
        className="max-h-[85vh] w-full max-w-sm overflow-y-auto rounded-2xl bg-surface p-6"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 className="mb-4 text-xl font-semibold">{title}</h2>
        {children}
        <div className="mt-8 flex items-center justify-end gap-6">
          {actions}
          <button onClick={onClose} className="cursor-pointer px-2 py-1 font-semibold text-accent-light">
            Yopish
          </button>
        </div>
      </div>
    </div>
  );
}

function ContactDialog({ onClose }: { onClose: () => void }) {
  const [copied, setCopied] = useState(false);

  async function copy() {
    try {
      await navigator.clipboard.writeText(SUPPORT_EMAIL);
      setCopied(true);
    } catch {}
  }

  return (
    <Dialog
      title="Bog'lanish"
      onClose={onClose}
      actions={
        <button onClick={copy} className="cursor-pointer px-2 py-1 font-semibold text-accent-light">
          {copied ? "Nusxalandi" : "Nusxalash"}
        </button>
      }
    >
      <p>Bog&apos;lanish uchun:</p>
      <a href={`mailto:${SUPPORT_EMAIL}`} className="mt-2 block break-all text-lg font-semibold text-accent-light underline">
        {SUPPORT_EMAIL}
      </a>
    </Dialog>
  );
}

function AboutDialog({ onClose }: { onClose: () => void }) {
  const bullet = "ml-2 mt-1 flex gap-2 before:content-['•']";
  return (
    <Dialog title="Pray Time - namozlaringiz sarhisobi" onClose={onClose}>
      <div className="space-y-4 text-[17px] leading-relaxed">
        <div>
          <p>Ushbu dastur yordamida siz:</p>
          <ul>
            <li className={bullet}>kunlik namozlarni</li>
            <li className={bullet}>yillik ro&apos;zalarni</li>
            <li className={bullet}>qazo namozlarni</li>
            <li className={bullet}>qazo ro&apos;zalarni</li>
          </ul>
          <p className="mt-1">belgilab borishingiz mumkin.</p>
        </div>
        <div>
          <p>Bundan tashqari:</p>
          <ul>
            <li className={bullet}>Duolar bo&apos;limidagi ko&apos;plab kerakli duolarni o&apos;rganishingiz</li>
            <li className={bullet}>
              Qur&apos;on bo&apos;limidagi kitob, audio va tarjima sahifalaridan ham foydalanishingiz mumkin.
            </li>
          </ul>
        </div>
        <p className="font-semibold">Dastur foydali bo&apos;ladi degan umiddaman!</p>
        <p className="text-sm text-foreground-muted">
          <Link href="/privacy" className="underline">
            Maxfiylik siyosati
          </Link>
        </p>
      </div>
    </Dialog>
  );
}

const iconProps = {
  width: 22,
  height: 22,
  viewBox: "0 0 24 24",
  fill: "none",
  stroke: "currentColor",
  strokeWidth: 1.8,
  strokeLinecap: "round" as const,
  strokeLinejoin: "round" as const,
  "aria-hidden": true,
};

function PencilIcon() {
  return (
    <svg {...iconProps}>
      <path d="M4 20h4L19 9l-4-4L4 16v4z" />
      <path d="M13.5 6.5l4 4" />
    </svg>
  );
}
function MailIcon() {
  return (
    <svg {...iconProps}>
      <rect x="3" y="5" width="18" height="14" rx="2" />
      <path d="M3 7l9 6 9-6" />
    </svg>
  );
}
function InfoIcon() {
  return (
    <svg {...iconProps}>
      <circle cx="12" cy="12" r="9" />
      <path d="M12 11v5M12 8h.01" />
    </svg>
  );
}
function TrashIcon() {
  return (
    <svg {...iconProps}>
      <path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3" />
    </svg>
  );
}
