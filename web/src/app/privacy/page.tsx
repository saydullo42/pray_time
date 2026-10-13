import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Maxfiylik siyosati — Pray Time",
  description: "Pray Time (Namoz vaqtlari) ilovasi va pray-time.uz saytining maxfiylik siyosati.",
};

const linkClass = "text-accent-light underline";
const h2Class = "mt-8 mb-2 text-xl font-semibold text-accent-light";

export default function PrivacyPage() {
  return (
    <article className="space-y-2 leading-relaxed">
      <h1 className="text-3xl font-semibold leading-tight">Maxfiylik siyosati</h1>
      <p className="mb-6 text-sm text-foreground-muted">
        Pray Time (Namoz vaqtlari) ilovasi va{" "}
        <a className={linkClass} href="https://pray-time.uz">
          pray-time.uz
        </a>{" "}
        sayti
        <br />
        Oxirgi yangilanish: 2026-yil 10-oktabr
      </p>

      <p>
        Ushbu siyosat Pray Time mobil ilovasi va pray-time.uz sayti (keyingi o&apos;rinlarda &quot;Xizmat&quot;)
        foydalanuvchilarining qanday ma&apos;lumotlari yig&apos;ilishi, ular nima uchun ishlatilishi va qanday himoya
        qilinishini tushuntiradi. Xizmatdan foydalanish orqali siz ushbu siyosat bilan tanishganingizni tasdiqlaysiz.
      </p>

      <h2 className={h2Class}>1. Ma&apos;lumotlar egasi</h2>
      <p>
        Xizmat dasturchisi: Saydullo. Aloqa:{" "}
        <a className={linkClass} href="mailto:support.praytime@gmail.com">
          support.praytime@gmail.com
        </a>
      </p>

      <h2 className={h2Class}>2. Qanday ma&apos;lumotlar yig&apos;iladi</h2>
      <ul className="list-disc space-y-1 pl-5">
        <li>
          <strong>Telefon raqami.</strong> Ro&apos;yxatdan o&apos;tish va tizimga kirish uchun siz kiritadigan telefon
          raqamingiz.
        </li>
      </ul>
      <p>
        Xizmat sizning <strong>joylashuvingizni so&apos;ramaydi va yig&apos;maydi</strong>. Ismingiz, manzilingiz,
        kontaktlar ro&apos;yxatingiz, rasm yoki boshqa shaxsiy fayllaringizga kirish talab qilinmaydi.
      </p>

      <h2 className={h2Class}>3. Ma&apos;lumotlar nima uchun ishlatiladi</h2>
      <ul className="list-disc space-y-1 pl-5">
        <li>Sizni ro&apos;yxatdan o&apos;tkazish va akkauntingizga kirishni ta&apos;minlash.</li>
        <li>
          Telefon raqamingiz sizga tegishli ekanini tasdiqlash (bir martalik SMS kod orqali).
        </li>
        <li>
          Xizmat ishlashi bilan bog&apos;liq masalalarda siz bilan bog&apos;lanish va murojaatlaringizga javob berish.
        </li>
      </ul>
      <p>Ma&apos;lumotlaringiz reklama maqsadida ishlatilmaydi va sotilmaydi.</p>

      <h2 className={h2Class}>4. Uchinchi tomonlar</h2>
      <p>
        Tasdiqlash kodi telefoningizga yuborilishi uchun telefon raqamingiz SMS xizmati provayderi{" "}
        <strong>Eskiz.uz</strong> (Eskiz) orqali uzatiladi. Provayder raqamni faqat SMS yuborish maqsadida qayta
        ishlaydi. Boshqa uchinchi tomonlarga ma&apos;lumotlaringiz berilmaydi, qonunda nazarda tutilgan hollar
        (vakolatli davlat organlarining qonuniy talabi) bundan mustasno.
      </p>

      <h2 className={h2Class}>5. Ma&apos;lumotlar qayerda va qancha saqlanadi</h2>
      <ul className="list-disc space-y-1 pl-5">
        <li>Ma&apos;lumotlar O&apos;zbekiston Respublikasi hududidagi serverda saqlanadi.</li>
        <li>
          Ma&apos;lumotlaringiz akkauntingiz faol ekan saqlanadi. Akkauntni o&apos;chirish so&apos;ralganda ular
          o&apos;chiriladi (6-bo&apos;limga qarang).
        </li>
        <li>
          Ma&apos;lumotlar ruxsatsiz kirishdan himoyalash uchun zarur texnik choralar ko&apos;riladi, jumladan, HTTPS
          orqali shifrlangan uzatish.
        </li>
      </ul>

      <h2 className={h2Class}>6. Sizning huquqlaringiz va akkauntni o&apos;chirish</h2>
      <p>
        Siz istalgan vaqtda quyidagilarni so&apos;rashingiz mumkin: ma&apos;lumotlaringiz haqida axborot olish, ularni
        tuzatish yoki to&apos;liq o&apos;chirish.
      </p>
      <p>
        Akkaunt va unga bog&apos;liq barcha ma&apos;lumotlarni o&apos;chirish tartibi:{" "}
        <a className={linkClass} href="https://pray-time.uz/delete-account">
          pray-time.uz/delete-account
        </a>
        .
      </p>
      <p>
        Shuningdek,{" "}
        <a className={linkClass} href="mailto:support.praytime@gmail.com">
          support.praytime@gmail.com
        </a>{" "}
        manziliga yozishingiz mumkin.
      </p>

      <h2 className={h2Class}>7. Bolalar</h2>
      <p>
        Xizmat 13 yoshdan kichik bolalarga mo&apos;ljallanmagan va ularning ma&apos;lumotlarini bilib turib
        yig&apos;maydi. Agar bola ma&apos;lumotlari yig&apos;ilganini aniqlasangiz, bizga yozing, ular o&apos;chiriladi.
      </p>

      <h2 className={h2Class}>8. Siyosatdagi o&apos;zgarishlar</h2>
      <p>
        Ushbu siyosat yangilanishi mumkin. Yangi versiya shu sahifada e&apos;lon qilinadi va yuqoridagi &quot;Oxirgi
        yangilanish&quot; sanasi o&apos;zgaradi.
      </p>

      <h2 className={h2Class}>9. Bog&apos;lanish</h2>
      <p>
        Savollar bo&apos;lsa:{" "}
        <a className={linkClass} href="mailto:support.praytime@gmail.com">
          support.praytime@gmail.com
        </a>
      </p>
    </article>
  );
}
