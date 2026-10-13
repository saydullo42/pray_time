import type { QuranAyah } from "./types";

const ALQURAN_BASE = "https://api.alquran.cloud/v1";

interface AlquranAyah {
  numberInSurah: number;
  text: string;
  page: number;
}

async function fetchSurahEdition(surahNumber: number, edition: string): Promise<QuranAyah[]> {
  const res = await fetch(`${ALQURAN_BASE}/surah/${surahNumber}/${edition}`);
  if (!res.ok) throw new Error("Qur'on matnini yuklab bo'lmadi");
  const json = await res.json();
  const ayahs: AlquranAyah[] = json.data.ayahs;
  return ayahs.map((a) => ({ numberInSurah: a.numberInSurah, text: a.text, page: a.page }));
}

export function fetchArabicSurah(surahNumber: number) {
  return fetchSurahEdition(surahNumber, "quran-uthmani");
}

export function fetchTranslationSurah(surahNumber: number) {
  return fetchSurahEdition(surahNumber, "uz.sodik");
}

export const BASMALA = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";

/** al-Fatiha has the basmala as its ayah 1, at-Tawba has none. */
export function surahShowsBasmala(surahNumber: number): boolean {
  return surahNumber !== 1 && surahNumber !== 9;
}

/**
 * The API puts the basmala at the start of ayah 1's text. Drop those four
 * words so it can be shown as its own line under the surah name.
 */
export function withoutBasmala(surahNumber: number, ayahs: QuranAyah[]): QuranAyah[] {
  if (!surahShowsBasmala(surahNumber)) return ayahs;
  return ayahs.map((a) => {
    if (a.numberInSurah !== 1) return a;
    const words = a.text.trim().split(" ");
    return words.length > 4 ? { ...a, text: words.slice(4).join(" ") } : a;
  });
}
