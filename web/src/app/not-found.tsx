import Link from "next/link";

export default function NotFound() {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center gap-4 text-center">
      <p className="text-5xl font-semibold text-accent-light">404</p>
      <h1 className="text-2xl font-semibold">Sahifa topilmadi</h1>
      <p className="max-w-xs text-foreground-muted">Bunday sahifa mavjud emas yoki ko&apos;chirilgan.</p>
      <Link
        href="/"
        className="rounded-full bg-accent px-6 py-2 font-semibold text-black transition-colors hover:bg-accent-light"
      >
        Bosh sahifaga
      </Link>
    </div>
  );
}
