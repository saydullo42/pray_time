export interface District {
  name: string;
  latitude: number;
  longitude: number;
}

export interface Region {
  name: string;
  districts: District[];
}

export const UZBEKISTAN_REGIONS: Region[] = [
  {
    name: "Toshkent shahri",
    districts: [
      { name: "Bektemir", latitude: 41.2186, longitude: 69.3267 },
      { name: "Chilonzor", latitude: 41.2746, longitude: 69.2034 },
      { name: "Mirzo Ulug'bek", latitude: 41.3312, longitude: 69.3297 },
      { name: "Mirobod", latitude: 41.2898, longitude: 69.2815 },
      { name: "Olmazor", latitude: 41.3479, longitude: 69.1889 },
      { name: "Sergeli", latitude: 41.2094, longitude: 69.2274 },
      { name: "Shayxontohur", latitude: 41.327, longitude: 69.2272 },
      { name: "Uchtepa", latitude: 41.3101, longitude: 69.1852 },
      { name: "Yakkasaroy", latitude: 41.2851, longitude: 69.2551 },
      { name: "Yashnobod", latitude: 41.2991, longitude: 69.3151 },
      { name: "Yunusobod", latitude: 41.3658, longitude: 69.2881 },
      { name: "Yangihayot", latitude: 41.2451, longitude: 69.1551 },
    ],
  },
  {
    name: "Toshkent viloyati",
    districts: [
      { name: "Bekobod", latitude: 40.2184, longitude: 69.2642 },
      { name: "Bo'ka", latitude: 40.8102, longitude: 69.1875 },
      { name: "Bo'stonliq", latitude: 41.5611, longitude: 69.7583 },
      { name: "Chinoz", latitude: 40.9311, longitude: 68.7694 },
      { name: "Qibray", latitude: 41.435, longitude: 69.465 },
      { name: "Oqqo'rg'on", latitude: 40.8564, longitude: 69.015 },
      { name: "Ohangaron", latitude: 40.9139, longitude: 69.7747 },
      { name: "Parkent", latitude: 41.2908, longitude: 69.69 },
      { name: "Piskent", latitude: 40.8664, longitude: 69.3486 },
      { name: "Quyichirchiq", latitude: 40.8872, longitude: 68.94 },
      { name: "O'rtachirchiq", latitude: 41.0211, longitude: 69.21 },
      { name: "Yuqorichirchiq", latitude: 41.0333, longitude: 69.35 },
      { name: "Yangiyo'l", latitude: 41.1136, longitude: 69.0514 },
      { name: "Zangiota", latitude: 41.17, longitude: 69.17 },
      { name: "Nurafshon", latitude: 41.0356, longitude: 69.3414 },
      { name: "Olmaliq", latitude: 40.8444, longitude: 69.5939 },
      { name: "Angren", latitude: 41.0167, longitude: 70.1442 },
      { name: "Chirchiq", latitude: 41.4689, longitude: 69.5822 },
    ],
  },
  {
    name: "Andijon viloyati",
    districts: [
      { name: "Andijon shahri", latitude: 40.7833, longitude: 72.3442 },
      { name: "Asaka", latitude: 40.6381, longitude: 72.2439 },
      { name: "Baliqchi", latitude: 40.6181, longitude: 71.9208 },
      { name: "Bo'z", latitude: 40.7489, longitude: 72.0636 },
      { name: "Buloqboshi", latitude: 40.77, longitude: 72.19 },
      { name: "Izboskan", latitude: 40.8186, longitude: 72.3269 },
      { name: "Jalaquduq", latitude: 40.7922, longitude: 72.5361 },
      { name: "Qo'rg'ontepa", latitude: 40.5167, longitude: 72.1333 },
      { name: "Marhamat", latitude: 40.4581, longitude: 72.0269 },
      { name: "Oltinko'l", latitude: 40.5331, longitude: 72.2983 },
      { name: "Paxtaobod", latitude: 40.6625, longitude: 72.3667 },
      { name: "Shahrixon", latitude: 40.7281, longitude: 72.0497 },
      { name: "Ulug'nor", latitude: 40.8019, longitude: 72.5983 },
      { name: "Xo'jaobod", latitude: 40.6619, longitude: 72.5417 },
      { name: "Xonobod", latitude: 40.6417, longitude: 72.3267 },
    ],
  },
  {
    name: "Farg'ona viloyati",
    districts: [
      { name: "Farg'ona shahri", latitude: 40.3842, longitude: 71.7843 },
      { name: "Bag'dod", latitude: 40.45, longitude: 71.4 },
      { name: "Beshariq", latitude: 40.4411, longitude: 71.0919 },
      { name: "Buvayda", latitude: 40.5042, longitude: 71.28 },
      { name: "Dang'ara", latitude: 40.3167, longitude: 70.9 },
      { name: "Furqat", latitude: 40.5831, longitude: 71.0211 },
      { name: "Qo'shtepa", latitude: 40.6583, longitude: 71.45 },
      { name: "Oltiariq", latitude: 40.45, longitude: 71.62 },
      { name: "Quva", latitude: 40.5194, longitude: 71.9336 },
      { name: "Quvasoy", latitude: 40.2958, longitude: 71.9711 },
      { name: "Rishton", latitude: 40.3658, longitude: 71.2847 },
      { name: "So'x", latitude: 39.98, longitude: 71.15 },
      { name: "Toshloq", latitude: 40.4397, longitude: 71.5789 },
      { name: "Uchko'prik", latitude: 40.5333, longitude: 71.6667 },
      { name: "Yozyovon", latitude: 40.2297, longitude: 71.19 },
      { name: "Farg'ona tumani", latitude: 40.33, longitude: 71.67 },
      { name: "Marg'ilon", latitude: 40.4717, longitude: 71.7244 },
      { name: "Qo'qon", latitude: 40.5283, longitude: 70.9428 },
    ],
  },
  {
    name: "Namangan viloyati",
    districts: [
      { name: "Namangan shahri", latitude: 40.9983, longitude: 71.6726 },
      { name: "Chortoq", latitude: 41.1167, longitude: 71.8833 },
      { name: "Chust", latitude: 41.0042, longitude: 71.2353 },
      { name: "Kosonsoy", latitude: 41.2503, longitude: 71.5497 },
      { name: "Mingbuloq", latitude: 40.8167, longitude: 71.3333 },
      { name: "Namangan tumani", latitude: 41.0, longitude: 71.55 },
      { name: "Norin", latitude: 41.0333, longitude: 71.9833 },
      { name: "Pop", latitude: 40.8711, longitude: 71.1114 },
      { name: "To'raqo'rg'on", latitude: 41.0019, longitude: 71.5425 },
      { name: "Uychi", latitude: 40.9333, longitude: 71.85 },
      { name: "Uchqo'rg'on", latitude: 41.1167, longitude: 72.0667 },
      { name: "Yangiqo'rg'on", latitude: 41.1167, longitude: 71.35 },
    ],
  },
  {
    name: "Samarqand viloyati",
    districts: [
      { name: "Samarqand shahri", latitude: 39.6542, longitude: 66.9597 },
      { name: "Bulung'ur", latitude: 39.9497, longitude: 67.3406 },
      { name: "Ishtixon", latitude: 39.9667, longitude: 66.65 },
      { name: "Jomboy", latitude: 39.8167, longitude: 67.0833 },
      { name: "Kattaqo'rg'on", latitude: 39.9, longitude: 66.25 },
      { name: "Narpay", latitude: 39.87, longitude: 65.98 },
      { name: "Nurobod", latitude: 39.9794, longitude: 67.6342 },
      { name: "Oqdaryo", latitude: 39.5667, longitude: 66.8333 },
      { name: "Pastdarg'om", latitude: 39.3833, longitude: 66.7833 },
      { name: "Payariq", latitude: 39.8333, longitude: 66.8833 },
      { name: "Paxtachi", latitude: 40.0333, longitude: 66.4833 },
      { name: "Qo'shrabot", latitude: 40.1833, longitude: 66.7333 },
      { name: "Samarqand tumani", latitude: 39.7, longitude: 67.05 },
      { name: "Toyloq", latitude: 39.7333, longitude: 67.1167 },
      { name: "Urgut", latitude: 39.4, longitude: 67.2333 },
    ],
  },
  {
    name: "Buxoro viloyati",
    districts: [
      { name: "Buxoro shahri", latitude: 39.7747, longitude: 64.4286 },
      { name: "Buxoro tumani", latitude: 39.85, longitude: 64.5 },
      { name: "G'ijduvon", latitude: 40.1, longitude: 64.6833 },
      { name: "Jondor", latitude: 39.8833, longitude: 64.1333 },
      { name: "Kogon", latitude: 39.7206, longitude: 64.5503 },
      { name: "Olot", latitude: 39.5667, longitude: 64.3667 },
      { name: "Peshku", latitude: 39.9833, longitude: 63.8667 },
      { name: "Qorako'l", latitude: 39.5167, longitude: 63.8167 },
      { name: "Qorovulbozor", latitude: 39.4833, longitude: 64.2333 },
      { name: "Romitan", latitude: 39.9333, longitude: 64.3667 },
      { name: "Shofirkon", latitude: 40.0167, longitude: 64.4333 },
      { name: "Vobkent", latitude: 40.0167, longitude: 64.5333 },
    ],
  },
  {
    name: "Qashqadaryo viloyati",
    districts: [
      { name: "Qarshi shahri", latitude: 38.8606, longitude: 65.7892 },
      { name: "Dehqonobod", latitude: 38.46, longitude: 66.5333 },
      { name: "G'uzor", latitude: 38.6267, longitude: 66.2514 },
      { name: "Kasbi", latitude: 38.9833, longitude: 66.0833 },
      { name: "Kitob", latitude: 39.1167, longitude: 66.8667 },
      { name: "Koson", latitude: 38.8833, longitude: 65.5667 },
      { name: "Mirishkor", latitude: 38.6333, longitude: 65.4167 },
      { name: "Muborak", latitude: 38.9333, longitude: 65.1667 },
      { name: "Nishon", latitude: 38.9667, longitude: 64.9167 },
      { name: "Chiroqchi", latitude: 39.0167, longitude: 66.5667 },
      { name: "Shahrisabz", latitude: 39.0556, longitude: 66.8339 },
      { name: "Yakkabog'", latitude: 38.95, longitude: 66.65 },
      { name: "Qamashi", latitude: 38.8333, longitude: 66.35 },
    ],
  },
  {
    name: "Surxondaryo viloyati",
    districts: [
      { name: "Termiz", latitude: 37.2242, longitude: 67.2783 },
      { name: "Angor", latitude: 37.6167, longitude: 67.0333 },
      { name: "Bandixon", latitude: 38.0167, longitude: 67.3333 },
      { name: "Boysun", latitude: 38.2097, longitude: 67.2017 },
      { name: "Denov", latitude: 38.2706, longitude: 67.8992 },
      { name: "Jarqo'rg'on", latitude: 37.5167, longitude: 67.4167 },
      { name: "Qiziriq", latitude: 37.8, longitude: 67.3 },
      { name: "Qumqo'rg'on", latitude: 37.8667, longitude: 67.5833 },
      { name: "Muzrabot", latitude: 37.7833, longitude: 67.95 },
      { name: "Oltinsoy", latitude: 38.0667, longitude: 67.8667 },
      { name: "Sariosiyo", latitude: 38.4, longitude: 67.9167 },
      { name: "Sherobod", latitude: 37.6667, longitude: 67.0167 },
      { name: "Sho'rchi", latitude: 37.8667, longitude: 67.75 },
      { name: "Uzun", latitude: 38.2833, longitude: 67.95 },
    ],
  },
  {
    name: "Jizzax viloyati",
    districts: [
      { name: "Jizzax shahri", latitude: 40.1158, longitude: 67.8422 },
      { name: "Arnasoy", latitude: 40.5833, longitude: 67.6333 },
      { name: "Baxmal", latitude: 39.9333, longitude: 68.0667 },
      { name: "Do'stlik", latitude: 40.5167, longitude: 68.1833 },
      { name: "Forish", latitude: 40.1667, longitude: 67.6167 },
      { name: "G'allaorol", latitude: 39.9667, longitude: 67.4167 },
      { name: "Mirzacho'l", latitude: 40.45, longitude: 68.0 },
      { name: "Paxtakor", latitude: 40.35, longitude: 68.2 },
      { name: "Yangiobod", latitude: 39.95, longitude: 68.4 },
      { name: "Zafarobod", latitude: 40.3833, longitude: 67.5167 },
      { name: "Zarbdor", latitude: 40.55, longitude: 68.0333 },
      { name: "Zomin", latitude: 39.95, longitude: 68.3833 },
    ],
  },
  {
    name: "Sirdaryo viloyati",
    districts: [
      { name: "Guliston", latitude: 40.4897, longitude: 68.7842 },
      { name: "Boyovut", latitude: 40.2667, longitude: 68.6 },
      { name: "Mirzaobod", latitude: 40.5167, longitude: 68.4833 },
      { name: "Oqoltin", latitude: 40.6167, longitude: 68.5833 },
      { name: "Sardoba", latitude: 40.1667, longitude: 68.6833 },
      { name: "Sayxunobod", latitude: 40.6833, longitude: 68.7167 },
      { name: "Sirdaryo", latitude: 40.8481, longitude: 68.665 },
      { name: "Xovos", latitude: 40.2167, longitude: 69.1333 },
      { name: "Shirin", latitude: 40.5667, longitude: 68.9667 },
    ],
  },
  {
    name: "Navoiy viloyati",
    districts: [
      { name: "Navoiy shahri", latitude: 40.0844, longitude: 65.3792 },
      { name: "Konimex", latitude: 40.2667, longitude: 65.0333 },
      { name: "Karmana", latitude: 40.1319, longitude: 65.3792 },
      { name: "Navbahor", latitude: 40.25, longitude: 65.6667 },
      { name: "Nurota", latitude: 40.5667, longitude: 65.6833 },
      { name: "Qiziltepa", latitude: 40.1333, longitude: 64.95 },
      { name: "Tomdi", latitude: 40.0833, longitude: 64.6 },
      { name: "Uchquduq", latitude: 42.1547, longitude: 63.55 },
      { name: "Xatirchi", latitude: 39.9833, longitude: 65.6833 },
      { name: "Zarafshon", latitude: 41.5706, longitude: 64.1997 },
    ],
  },
  {
    name: "Xorazm viloyati",
    districts: [
      { name: "Urganch shahri", latitude: 41.55, longitude: 60.6333 },
      { name: "Bog'ot", latitude: 41.4167, longitude: 60.4 },
      { name: "Gurlan", latitude: 41.85, longitude: 60.3833 },
      { name: "Qo'shko'pir", latitude: 41.65, longitude: 60.3333 },
      { name: "Shovot", latitude: 41.65, longitude: 60.3167 },
      { name: "Urganch tumani", latitude: 41.5833, longitude: 60.5833 },
      { name: "Xazorasp", latitude: 41.3167, longitude: 60.4333 },
      { name: "Xiva", latitude: 41.3783, longitude: 60.3617 },
      { name: "Yangiariq", latitude: 41.4667, longitude: 60.2667 },
      { name: "Yangibozor", latitude: 41.7167, longitude: 60.2667 },
    ],
  },
  {
    name: "Qoraqalpog'iston Respublikasi",
    districts: [
      { name: "Nukus shahri", latitude: 42.4531, longitude: 59.6103 },
      { name: "Amudaryo", latitude: 42.0167, longitude: 59.5833 },
      { name: "Beruniy", latitude: 41.6889, longitude: 60.7497 },
      { name: "Chimboy", latitude: 42.9333, longitude: 59.7833 },
      { name: "Ellikqal'a", latitude: 41.85, longitude: 60.85 },
      { name: "Kegeyli", latitude: 42.7333, longitude: 59.8167 },
      { name: "Mo'ynoq", latitude: 43.77, longitude: 59.02 },
      { name: "Nukus tumani", latitude: 42.4, longitude: 59.5 },
      { name: "Qanliko'l", latitude: 42.5667, longitude: 59.95 },
      { name: "Qorao'zak", latitude: 42.6167, longitude: 59.8667 },
      { name: "Qo'ng'irot", latitude: 43.0597, longitude: 58.8894 },
      { name: "Shumanay", latitude: 42.6167, longitude: 59.4333 },
      { name: "Taxtako'pir", latitude: 43.0667, longitude: 60.35 },
      { name: "To'rtko'l", latitude: 41.55, longitude: 61.0167 },
      { name: "Xo'jayli", latitude: 42.4167, longitude: 59.45 },
    ],
  },
];

export const DEFAULT_REGION_NAME = "Toshkent shahri";
export const DEFAULT_DISTRICT_NAME = "Mirzo Ulug'bek";

export function findRegion(name: string): Region | undefined {
  return UZBEKISTAN_REGIONS.find((r) => r.name === name);
}

export function findDistrict(regionName: string, districtName: string): District | undefined {
  return findRegion(regionName)?.districts.find((d) => d.name === districtName);
}

/** Appends "tumani" for plain district names, leaving names that are already
 * a city ("... shahri") or already say "... tumani" unchanged. */
export function districtLabel(name: string): string {
  if (name.endsWith("shahri") || name.endsWith("tumani")) return name;
  return `${name} tumani`;
}
