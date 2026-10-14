"use client";

export default function Error({ reset }: { error: Error & { digest?: string }; reset: () => void }) {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center gap-4 text-center">
      <h1 className="text-2xl font-semibold">Xatolik yuz berdi</h1>
      <p className="max-w-xs text-foreground-muted">Kutilmagan xato. Qayta urinib ko&apos;ring.</p>
      <button
        onClick={reset}
        className="cursor-pointer rounded-full bg-accent px-6 py-2 font-semibold text-black transition-colors hover:bg-accent-light"
      >
        Qayta urinish
      </button>
    </div>
  );
}
