export const UZ_MONTHS = [
  "Yanvar", "Fevral", "Mart", "Aprel", "May", "Iyun",
  "Iyul", "Avgust", "Sentabr", "Oktabr", "Noyabr", "Dekabr",
];

export const UZ_WEEKDAYS_SHORT = ["Dush", "Sesh", "Chor", "Pay", "Jum", "Shan", "Yak"];

// Keyed on Aladhan's exact (diacritic-marked) English Hijri month names.
const HIJRI_MONTHS_UZ: Record<string, string> = {
  "Muḥarram": "Muharram",
  "Ṣafar": "Safar",
  "Rabīʿ al-awwal": "Rabiul-avval",
  "Rabīʿ al-thānī": "Rabiul-oxir",
  "Jumādá al-ūlá": "Jumadul-avval",
  "Jumādá al-ākhirah": "Jumadul-oxir",
  "Rajab": "Rajab",
  "Shaʿbān": "Sha'bon",
  "Ramaḍān": "Ramazon",
  "Shawwāl": "Shavvol",
  "Dhū al-Qaʿdah": "Zul-qa'da",
  "Dhū al-Ḥijjah": "Zul-hijja",
};

export function hijriMonthUz(englishName: string): string {
  return HIJRI_MONTHS_UZ[englishName] ?? englishName;
}

export function formatDateISO(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

export function formatGregorianUz(date: Date): string {
  return `${date.getDate()} ${UZ_MONTHS[date.getMonth()]}, ${date.getFullYear()}`;
}

export function daysInMonth(year: number, month: number): number {
  return new Date(year, month, 0).getDate();
}

/** 0 = Monday .. 6 = Sunday, matching the app's week layout. */
export function firstWeekdayOffset(year: number, month: number): number {
  const jsDay = new Date(year, month - 1, 1).getDay(); // 0=Sun..6=Sat
  return (jsDay + 6) % 7;
}

export function isFutureDate(date: Date): boolean {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d.getTime() > today.getTime();
}
