import Link from "next/link";

// TODO: replace "#" with the real store URLs once the app is published.
const GOOGLE_PLAY_URL = "#";
const APP_STORE_URL = "#";

const badgeClass =
  "flex h-12 w-40 items-center justify-center gap-2.5 rounded-lg border-2 border-foreground-muted/60 text-foreground transition-colors hover:border-foreground hover:bg-surface";

export function Footer() {
  return (
    <footer className="border-t border-outline pb-20 pt-6 text-center text-sm text-foreground-muted sm:pb-6">
      <p className="text-lg font-semibold text-foreground">Pray Time - namozlaringiz sarhisobi</p>

      <p className="mt-3">
        Bog&apos;lanish uchun{" "}
        <a href="mailto:support.praytime@gmail.com" className="text-accent-light underline">
          support.praytime@gmail.com
        </a>
      </p>

      <div className="mt-4 flex flex-wrap items-center justify-center gap-3">
        <a href={GOOGLE_PLAY_URL} aria-label="Google Play'dan yuklab olish" className={badgeClass}>
          <svg width="26" height="26" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M3.6 2.3c-.3.3-.5.8-.5 1.4v16.6c0 .6.2 1.1.5 1.4l.1.1 9.3-9.3v-.2L3.7 2.2l-.1.1z" opacity=".9" />
            <path d="M16.1 15.4l-3.1-3.1v-.2l3.1-3.1.1.1 3.7 2.1c1 .6 1 1.6 0 2.200l-3.7 2.1-.1.1z" opacity=".7" />
            <path d="M16.2 15.3L13 12.1 3.6 21.500c.3.4.9.4 1.5.1l11.1-6.3" opacity=".8" />
            <path d="M16.2 8.900L5.1 2.600c-.6-.3-1.2-.3-1.5.1L13 12.100l3.2-3.200z" opacity=".6" />
          </svg>
          <span className="flex flex-col items-start leading-none">
            <span className="text-[9px] font-semibold uppercase tracking-wide">Android app on</span>
            <span className="mt-0.5 text-lg font-medium">Google Play</span>
          </span>
        </a>

        <a href={APP_STORE_URL} aria-label="App Store'dan yuklab olish" className={badgeClass}>
          <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M16.4 12.700c0-2.3 1.9-3.4 2-3.5-1.1-1.6-2.8-1.8-3.4-1.8-1.4-.1-2.8.9-3.5.9-.7 0-1.9-.8-3.1-.8-1.6 0-3.1.9-3.9 2.4-1.7 2.9-.4 7.2 1.2 9.6.8 1.2 1.8 2.5 3 2.4 1.2 0 1.7-.8 3.1-.8 1.5 0 1.9.8 3.2.8 1.3 0 2.1-1.2 2.9-2.3.9-1.3 1.3-2.6 1.3-2.7-.1 0-2.8-1.1-2.8-4.200zM14.1 5.600c.7-.8 1.1-1.9 1-3-1 0-2.1.7-2.8 1.5-.6.7-1.2 1.8-1 2.9 1.1.1 2.1-.5 2.8-1.400z" />
          </svg>
          <span className="flex flex-col items-start leading-none">
            <span className="text-[9px] font-medium">Download on the</span>
            <span className="mt-0.5 text-lg font-medium">App Store</span>
          </span>
        </a>
      </div>

      <p className="mt-2 flex flex-wrap justify-center gap-x-5 gap-y-1 pt-4">
        <Link href="/privacy" className="underline hover:text-foreground">
          Maxfiylik siyosati
        </Link>
        <Link href="/delete-account" className="underline hover:text-foreground">
          Akkauntni o&apos;chirish
        </Link>
      </p>
      <p className="mt-3 text-xs">© {new Date().getFullYear()} Pray Time. Barcha huquqlar himoyalangan.</p>
    </footer>
  );
}
