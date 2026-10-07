"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { ApiError } from "@/lib/api";

export default function LoginPage() {
  const { requestOtp, verifyOtp, isAuthenticated, isLoading } = useAuth();
  const router = useRouter();

  const [step, setStep] = useState<"phone" | "otp">("phone");
  const [digits, setDigits] = useState(""); // 9 digits after +998
  const [code, setCode] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!isLoading && isAuthenticated) router.replace("/");
  }, [isLoading, isAuthenticated, router]);

  const phoneNumber = `+998${digits}`;

  function formatDigits(d: string): string {
    const groups = [d.slice(0, 2), d.slice(2, 5), d.slice(5, 7), d.slice(7, 9)];
    return groups.filter(Boolean).join(" ");
  }

  async function submitPhone(e: React.FormEvent) {
    e.preventDefault();
    if (digits.length !== 9) {
      setError("Telefon raqamni to'liq kiriting");
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await requestOtp(phoneNumber);
      setStep("otp");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Xatolik yuz berdi");
    } finally {
      setBusy(false);
    }
  }

  async function submitOtp(e: React.FormEvent) {
    e.preventDefault();
    if (code.length !== 6) {
      setError("Tasdiqlash kodini to'liq kiriting");
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await verifyOtp(phoneNumber, code);
      router.replace("/");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Kod noto'g'ri yoki muddati o'tgan");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="flex min-h-[80vh] flex-col items-center justify-center">
      <h1 className="mb-10 text-3xl font-semibold">Kirish</h1>

      {step === "phone" ? (
        <form onSubmit={submitPhone} className="w-full max-w-xs space-y-6">
          <div>
            <label className="mb-2 block text-lg text-foreground-muted">
              Telefon raqamingizni kiriting
            </label>
            <div className="flex items-center gap-2 rounded-xl border border-outline px-4 py-3">
              <span className="text-foreground-muted">+998</span>
              <input
                autoFocus
                inputMode="numeric"
                maxLength={12}
                value={formatDigits(digits)}
                onChange={(e) => setDigits(e.target.value.replace(/\D/g, "").slice(0, 9))}
                placeholder="90 123 45 67"
                className="w-full bg-transparent tracking-wider outline-none"
              />
            </div>
          </div>
          {error && <p className="text-sm text-danger">{error}</p>}
          <button
            type="submit"
            disabled={busy}
            className="w-full rounded-full bg-accent py-3 font-semibold text-black disabled:opacity-60"
          >
            {busy ? "..." : "Tasdiqlash"}
          </button>
        </form>
      ) : (
        <form onSubmit={submitOtp} className="w-full max-w-xs space-y-6">
          <p className="text-center text-sm text-foreground-muted">
            {phoneNumber} telefon raqamiga kelgan kodni kiriting
          </p>
          <input
            autoFocus
            inputMode="numeric"
            maxLength={6}
            value={code}
            onChange={(e) => setCode(e.target.value.replace(/\D/g, "").slice(0, 6))}
            placeholder="000000"
            className="w-full rounded-xl border border-outline bg-transparent px-4 py-3 text-center text-2xl tracking-[0.5em] outline-none"
          />
          {error && <p className="text-center text-sm text-danger">{error}</p>}
          <button
            type="submit"
            disabled={busy}
            className="w-full rounded-full bg-accent py-3 font-semibold text-black disabled:opacity-60"
          >
            {busy ? "..." : "Tasdiqlash"}
          </button>
          <button
            type="button"
            onClick={() => setStep("phone")}
            className="w-full text-center text-sm text-accent-light"
          >
            Telefon raqamni o&apos;zgartirish
          </button>
        </form>
      )}
    </div>
  );
}
