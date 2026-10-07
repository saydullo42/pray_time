"use client";

import Link from "next/link";

export function BackLink({ href, className = "" }: { href: string; className?: string }) {
  return (
    <Link
      href={href}
      aria-label="Orqaga"
      className={`mb-3 inline-flex h-9 w-9 items-center justify-center self-start rounded-full text-foreground-muted hover:text-foreground ${className}`}
    >
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M19 12H5M12 19l-7-7 7-7" />
      </svg>
    </Link>
  );
}
