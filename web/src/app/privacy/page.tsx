import type { Metadata } from "next";
import Link from "next/link";

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
        Oxirgi yangilanish: 2026-yil 13-oktabr
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
      <p>Serverimizda quyidagilar saqlanadi:</p>
      <ul className="list-disc space-y-1 pl-5">
        <li>
          <strong>Email manzili.</strong> Google akkauntingiz bilan kirganingizda Google bizga email manzilingizni
          beradi. Ro&apos;yxatdan o&apos;tish va tizimga kirish uchun shu manzil ishlatiladi.
        </li>
        <li>
          <strong>Ism va profil rasmi.</strong> Google akkauntingizdagi ism va rasm havolasi. Ismni keyin profilingizda
          o&apos;zgartira olasiz. Parolingiz bizga berilmaydi va saqlanmaydi.
        </li>
        <li>
          <strong>Namoz belgilari.</strong> Kalendarda o&apos;qilgan namozlarni belgilasangiz, sana va belgilangan
          namozlar saqlanadi.
        </li>
        <li>
          <strong>Eslatma sozlamalari va namoz vaqtlari.</strong> Eslatma sozlamalaringiz hamda 2-jadvalga o&apos;zingiz
          kiritgan namoz vaqtlari.
        </li>
      </ul>
      <p>
        Xizmat qurilmangizning <strong>joylashuvini (GPS) so&apos;ramaydi va yig&apos;maydi</strong>. Viloyat va
        tumanni o&apos;zingiz tanlaysiz. Tanlovingiz faqat qurilmangiz yoki brauzeringizda saqlanadi. Namoz vaqtlarini
        hisoblash uchun faqat tanlangan tumanning koordinatalari serverga yuboriladi, ular sizning akkauntingiz
        bilan bog&apos;lanmaydi. Kontaktlar ro&apos;yxati, rasm yoki boshqa shaxsiy fayllaringizga kirish talab
        qilinmaydi.
      </p>
      <p>
        Quyidagilar <strong>faqat qurilmangiz yoki brauzeringizda</strong> saqlanadi va serverga yuborilmaydi:
        belgilangan ro&apos;za kunlari, tanlangan mavzu (yorug&apos; yoki qorong&apos;i), tanlangan hudud va tizimga
        kirganingizni eslab turuvchi kirish kaliti.
      </p>

      <h2 className={h2Class}>3. Ma&apos;lumotlar nima uchun ishlatiladi</h2>
      <ul className="list-disc space-y-1 pl-5">
        <li>Sizni ro&apos;yxatdan o&apos;tkazish va akkauntingizga kirishni ta&apos;minlash.</li>
        <li>
          Akkauntingiz sizga tegishli ekanini Google orqali tasdiqlash (parol yoki SMS kod kerak emas).
        </li>
        <li>Namoz belgilaringizni kalendarda ko&apos;rsatish va eslatmalarni o&apos;zingiz sozlaganingizdek ishlatish.</li>
        <li>
          Xizmat ishlashi bilan bog&apos;liq masalalarda siz bilan bog&apos;lanish va murojaatlaringizga javob berish.
        </li>
      </ul>
      <p>
        Ma&apos;lumotlaringiz reklama maqsadida ishlatilmaydi va sotilmaydi. Xizmatda reklama, analitika yoki
        foydalanuvchini kuzatuvchi vositalar yo&apos;q.
      </p>

      <h2 className={h2Class}>4. Uchinchi tomonlar</h2>
      <ul className="list-disc space-y-2 pl-5">
        <li>
          <strong>Google</strong> (Google bilan kirish). Kirishda Google akkauntingizni tanlaysiz va Google bizga
          email manzilingiz, ismingiz va rasmingizni beradi. Google bu jarayonni o&apos;z maxfiylik siyosatiga ko&apos;ra
          qayta ishlaydi:{" "}
          <a className={linkClass} href="https://policies.google.com/privacy" target="_blank" rel="noreferrer">
            policies.google.com/privacy
          </a>
          .
        </li>
        <li>
          <strong>Aladhan</strong> (namoz vaqtlarini hisoblash xizmati). Serverimiz u yerga faqat tanlangan
          tumanning koordinatalarini yuboradi. Email manzilingiz va boshqa shaxsiy ma&apos;lumotlaringiz
          yuborilmaydi.
        </li>
        <li>
          <strong>alquran.cloud</strong> (Qur&apos;on matni va tarjimasi). Ilova va sayt Qur&apos;on matnini shu
          xizmatdan to&apos;g&apos;ridan-to&apos;g&apos;ri oladi. Shuning uchun u xizmat serveri odatdagidek
          qurilmangizning IP manzilini ko&apos;rishi mumkin. Akkaunt ma&apos;lumotlaringiz u yerga yuborilmaydi.
        </li>
      </ul>
      <p>
        Boshqa uchinchi tomonlarga ma&apos;lumotlaringiz berilmaydi, qonunda nazarda tutilgan hollar (vakolatli
        davlat organlarining qonuniy talabi) bundan mustasno.
      </p>

      <h2 className={h2Class}>5. Ma&apos;lumotlar qayerda va qancha saqlanadi</h2>
      <ul className="list-disc space-y-1 pl-5">
        <li>Ma&apos;lumotlar O&apos;zbekiston Respublikasi hududidagi serverda saqlanadi.</li>
        <li>
          Ma&apos;lumotlaringiz akkauntingiz faol ekan saqlanadi. Akkauntni o&apos;chirsangiz, ular darhol
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
        tuzatish (ismni profil orqali o&apos;zingiz o&apos;zgartira olasiz) yoki to&apos;liq o&apos;chirish.
      </p>
      <p>
        Akkaunt va unga bog&apos;liq barcha ma&apos;lumotlarni <strong>o&apos;zingiz darhol o&apos;chirishingiz</strong>{" "}
        mumkin:
      </p>
      <ul className="list-disc space-y-1 pl-5">
        <li>
          mobil ilovada: <strong>Profil → Akkauntni o&apos;chirish</strong>;
        </li>
        <li>
          saytda:{" "}
          <Link className={linkClass} href="/delete-account">
            pray-time.uz/delete-account
          </Link>
          .
        </li>
      </ul>
      <p>
        O&apos;chirishda email manzilingiz, ismingiz, namoz belgilaringiz, eslatma sozlamalaringiz va namoz
        vaqtlaringiz o&apos;chiriladi. Bu amalni qaytarib bo&apos;lmaydi. Tizimga kira olmasangiz,{" "}
        <a className={linkClass} href="mailto:support.praytime@gmail.com">
          support.praytime@gmail.com
        </a>{" "}
        manziliga yozing.
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
