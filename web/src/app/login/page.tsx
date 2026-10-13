"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { ApiError } from "@/lib/api";
import { GoogleSignInButton } from "@/components/GoogleSignInButton";

export default function LoginPage() {
  const { signInWithGoogle, isAuthenticated, isLoading } = useAuth();
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!isLoading && isAuthenticated) router.replace("/");
  }, [isLoading, isAuthenticated, router]);

  async function handleCredential(idToken: string) {
    setBusy(true);
    setError(null);
    try {
      await signInWithGoogle(idToken);
      router.replace("/");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Xatolik yuz berdi");
      setBusy(false);
    }
  }

  return (
    <div className="flex min-h-[80vh] flex-col items-center justify-center gap-6">
      <h1 className="text-3xl font-semibold">Kirish</h1>
      <p className="max-w-xs text-center text-foreground-muted">
        Davom etish uchun Google akkauntingiz bilan kiring.
      </p>
      <GoogleSignInButton onCredential={handleCredential} />
      {busy && <p className="text-sm text-foreground-muted">Kirilmoqda...</p>}
      {error && <p className="max-w-xs text-center text-sm text-danger">{error}</p>}
    </div>
  );
}
