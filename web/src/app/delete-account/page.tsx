import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Akkauntni o'chirish — Pray Time",
  description: "Pray Time akkauntingiz va unga bog'liq ma'lumotlarni o'chirish tartibi.",
};

const linkClass = "text-accent-light underline";
const h2Class = "mt-8 mb-2 text-xl font-semibold text-accent-light";

export default function DeleteAccountPage() {
  return (
    <article className="space-y-2 leading-relaxed">
      <h1 className="text-3xl font-semibold leading-tight">Akkauntni o&apos;chirish</h1>
      <p className="mb-6 text-sm text-foreground-muted">
        Pray Time (Namoz vaqtlari) ilovasi va{" "}
        <a className={linkClass} href="https://pray-time.uz">
          pray-time.uz
        </a>{" "}
        sayti
      </p>

      <p>
        Pray Time akkauntingizni va unga bog&apos;liq ma&apos;lumotlarni o&apos;chirishni xohlasangiz, quyidagi tartibda
        so&apos;rov yuboring.
      </p>

      <h2 className={h2Class}>Qanday o&apos;chiriladi</h2>
      <ol className="list-decimal space-y-1 pl-6">
        <li>
          <a className={linkClass} href="mailto:support.praytime@gmail.com?subject=Akkauntni%20o%27chirish">
            support.praytime@gmail.com
          </a>{" "}
          manziliga xat yuboring.
        </li>
        <li>
          Mavzuga <strong>&quot;Akkauntni o&apos;chirish&quot;</strong> deb yozing.
        </li>
        <li>
          Xatda akkauntga ulangan <strong>telefon raqamingizni</strong> ko&apos;rsating.
        </li>
        <li>
          Raqam sizga tegishli ekanini tasdiqlash uchun bu raqamga SMS kod yuboriladi. Kodni javob xatida yuboring.
        </li>
      </ol>

      <div className="my-4 rounded-xl border border-outline bg-surface px-4 py-3">
        So&apos;rovingiz tasdiqlangach, akkaunt va ma&apos;lumotlar <strong>30 kun ichida</strong> o&apos;chiriladi va bu
        haqda sizga xabar beriladi.
      </div>

      <h2 className={h2Class}>Nimalar o&apos;chiriladi</h2>
      <ul className="list-disc space-y-1 pl-5">
        <li>Akkauntga ulangan telefon raqamingiz.</li>
        <li>Akkaunt bilan bog&apos;liq boshqa barcha ma&apos;lumotlar.</li>
      </ul>
      <p>
        O&apos;chirilgan akkauntni qayta tiklab bo&apos;lmaydi. Xizmatdan yana foydalanish uchun yangidan ro&apos;yxatdan
        o&apos;tishingiz kerak bo&apos;ladi.
      </p>

      <h2 className={h2Class}>Qo&apos;shimcha</h2>
      <p>
        Ma&apos;lumotlar qanday ishlatilishi haqida batafsil:{" "}
        <Link className={linkClass} href="/privacy">
          Maxfiylik siyosati
        </Link>
        .
      </p>
    </article>
  );
}
