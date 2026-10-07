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
