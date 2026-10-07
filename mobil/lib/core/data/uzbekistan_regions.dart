/// Uzbekistan's 14 administrative regions (viloyat) with their districts
/// (tuman), each carrying an approximate center coordinate used to compute
/// prayer times for that district without relying on device GPS.
class District {
  const District(this.name, this.latitude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;
}

class Region {
  const Region(this.name, this.districts);

  final String name;
  final List<District> districts;
}

const uzbekistanRegions = <Region>[
  Region('Toshkent shahri', [
    District("Bektemir", 41.2186, 69.3267),
    District("Chilonzor", 41.2746, 69.2034),
    District("Mirzo Ulug'bek", 41.3312, 69.3297),
    District("Mirobod", 41.2898, 69.2815),
    District("Olmazor", 41.3479, 69.1889),
    District("Sergeli", 41.2094, 69.2274),
    District("Shayxontohur", 41.327, 69.2272),
    District("Uchtepa", 41.3101, 69.1852),
    District("Yakkasaroy", 41.2851, 69.2551),
    District("Yashnobod", 41.2991, 69.3151),
    District("Yunusobod", 41.3658, 69.2881),
    District("Yangihayot", 41.2451, 69.1551),
  ]),
  Region('Toshkent viloyati', [
    District("Bekobod", 40.2184, 69.2642),
    District("Bo'ka", 40.8102, 69.1875),
    District("Bo'stonliq", 41.5611, 69.7583),
    District("Chinoz", 40.9311, 68.7694),
    District("Qibray", 41.435, 69.465),
    District("Oqqo'rg'on", 40.8564, 69.015),
    District("Ohangaron", 40.9139, 69.7747),
    District("Parkent", 41.2908, 69.69),
    District("Piskent", 40.8664, 69.3486),
    District("Quyichirchiq", 40.8872, 68.94),
    District("O'rtachirchiq", 41.0211, 69.21),
    District("Yuqorichirchiq", 41.0333, 69.35),
    District("Yangiyo'l", 41.1136, 69.0514),
    District("Zangiota", 41.17, 69.17),
    District("Nurafshon", 41.0356, 69.3414),
    District("Olmaliq", 40.8444, 69.5939),
    District("Angren", 41.0167, 70.1442),
    District("Chirchiq", 41.4689, 69.5822),
  ]),
  Region('Andijon viloyati', [
    District("Andijon shahri", 40.7833, 72.3442),
    District("Asaka", 40.6381, 72.2439),
    District("Baliqchi", 40.6181, 71.9208),
    District("Bo'z", 40.7489, 72.0636),
    District("Buloqboshi", 40.77, 72.19),
    District("Izboskan", 40.8186, 72.3269),
    District("Jalaquduq", 40.7922, 72.5361),
    District("Qo'rg'ontepa", 40.5167, 72.1333),
    District("Marhamat", 40.4581, 72.0269),
    District("Oltinko'l", 40.5331, 72.2983),
    District("Paxtaobod", 40.6625, 72.3667),
    District("Shahrixon", 40.7281, 72.0497),
    District("Ulug'nor", 40.8019, 72.5983),
    District("Xo'jaobod", 40.6619, 72.5417),
    District("Xonobod", 40.6417, 72.3267),
  ]),
  Region("Farg'ona viloyati", [
    District("Farg'ona shahri", 40.3842, 71.7843),
    District("Bag'dod", 40.45, 71.4),
    District("Beshariq", 40.4411, 71.0919),
    District("Buvayda", 40.5042, 71.28),
    District("Dang'ara", 40.3167, 70.9),
    District("Furqat", 40.5831, 71.0211),
    District("Qo'shtepa", 40.6583, 71.45),
    District("Oltiariq", 40.45, 71.62),
    District("Quva", 40.5194, 71.9336),
    District("Quvasoy", 40.2958, 71.9711),
    District("Rishton", 40.3658, 71.2847),
    District("So'x", 39.98, 71.15),
    District("Toshloq", 40.4397, 71.5789),
    District("Uchko'prik", 40.5333, 71.6667),
    District("Yozyovon", 40.2297, 71.19),
    District("Farg'ona tumani", 40.33, 71.67),
    District("Marg'ilon", 40.4717, 71.7244),
    District("Qo'qon", 40.5283, 70.9428),
  ]),
  Region('Namangan viloyati', [
    District("Namangan shahri", 40.9983, 71.6726),
    District("Chortoq", 41.1167, 71.8833),
    District("Chust", 41.0042, 71.2353),
    District("Kosonsoy", 41.2503, 71.5497),
    District("Mingbuloq", 40.8167, 71.3333),
    District("Namangan tumani", 41.0, 71.55),
    District("Norin", 41.0333, 71.9833),
    District("Pop", 40.8711, 71.1114),
    District("To'raqo'rg'on", 41.0019, 71.5425),
    District("Uychi", 40.9333, 71.85),
    District("Uchqo'rg'on", 41.1167, 72.0667),
    District("Yangiqo'rg'on", 41.1167, 71.35),
  ]),
  Region('Samarqand viloyati', [
    District("Samarqand shahri", 39.6542, 66.9597),
    District("Bulung'ur", 39.9497, 67.3406),
    District("Ishtixon", 39.9667, 66.65),
    District("Jomboy", 39.8167, 67.0833),
    District("Kattaqo'rg'on", 39.9, 66.25),
    District("Narpay", 39.87, 65.98),
    District("Nurobod", 39.9794, 67.6342),
    District("Oqdaryo", 39.5667, 66.8333),
    District("Pastdarg'om", 39.3833, 66.7833),
    District("Payariq", 39.8333, 66.8833),
    District("Paxtachi", 40.0333, 66.4833),
    District("Qo'shrabot", 40.1833, 66.7333),
    District("Samarqand tumani", 39.7, 67.05),
    District("Toyloq", 39.7333, 67.1167),
    District("Urgut", 39.4, 67.2333),
  ]),
  Region('Buxoro viloyati', [
    District("Buxoro shahri", 39.7747, 64.4286),
    District("Buxoro tumani", 39.85, 64.5),
    District("G'ijduvon", 40.1, 64.6833),
    District("Jondor", 39.8833, 64.1333),
    District("Kogon", 39.7206, 64.5503),
    District("Olot", 39.5667, 64.3667),
    District("Peshku", 39.9833, 63.8667),
    District("Qorako'l", 39.5167, 63.8167),
    District("Qorovulbozor", 39.4833, 64.2333),
    District("Romitan", 39.9333, 64.3667),
    District("Shofirkon", 40.0167, 64.4333),
    District("Vobkent", 40.0167, 64.5333),
  ]),
  Region('Qashqadaryo viloyati', [
    District("Qarshi shahri", 38.8606, 65.7892),
    District("Dehqonobod", 38.46, 66.5333),
    District("G'uzor", 38.6267, 66.2514),
    District("Kasbi", 38.9833, 66.0833),
    District("Kitob", 39.1167, 66.8667),
    District("Koson", 38.8833, 65.5667),
    District("Mirishkor", 38.6333, 65.4167),
    District("Muborak", 38.9333, 65.1667),
    District("Nishon", 38.9667, 64.9167),
    District("Chiroqchi", 39.0167, 66.5667),
    District("Shahrisabz", 39.0556, 66.8339),
    District("Yakkabog'", 38.95, 66.65),
    District("Qamashi", 38.8333, 66.35),
  ]),
  Region('Surxondaryo viloyati', [
    District("Termiz", 37.2242, 67.2783),
    District("Angor", 37.6167, 67.0333),
    District("Bandixon", 38.0167, 67.3333),
    District("Boysun", 38.2097, 67.2017),
    District("Denov", 38.2706, 67.8992),
    District("Jarqo'rg'on", 37.5167, 67.4167),
    District("Qiziriq", 37.8, 67.3),
    District("Qumqo'rg'on", 37.8667, 67.5833),
    District("Muzrabot", 37.7833, 67.95),
    District("Oltinsoy", 38.0667, 67.8667),
    District("Sariosiyo", 38.4, 67.9167),
    District("Sherobod", 37.6667, 67.0167),
    District("Sho'rchi", 37.8667, 67.75),
    District("Uzun", 38.2833, 67.95),
  ]),
  Region('Jizzax viloyati', [
    District("Jizzax shahri", 40.1158, 67.8422),
    District("Arnasoy", 40.5833, 67.6333),
    District("Baxmal", 39.9333, 68.0667),
    District("Do'stlik", 40.5167, 68.1833),
    District("Forish", 40.1667, 67.6167),
    District("G'allaorol", 39.9667, 67.4167),
    District("Mirzacho'l", 40.45, 68.0),
    District("Paxtakor", 40.35, 68.2),
    District("Yangiobod", 39.95, 68.4),
    District("Zafarobod", 40.3833, 67.5167),
    District("Zarbdor", 40.55, 68.0333),
    District("Zomin", 39.95, 68.3833),
  ]),
  Region('Sirdaryo viloyati', [
    District("Guliston", 40.4897, 68.7842),
    District("Boyovut", 40.2667, 68.6),
    District("Mirzaobod", 40.5167, 68.4833),
    District("Oqoltin", 40.6167, 68.5833),
    District("Sardoba", 40.1667, 68.6833),
    District("Sayxunobod", 40.6833, 68.7167),
    District("Sirdaryo", 40.8481, 68.665),
    District("Xovos", 40.2167, 69.1333),
    District("Shirin", 40.5667, 68.9667),
  ]),
  Region('Navoiy viloyati', [
    District("Navoiy shahri", 40.0844, 65.3792),
    District("Konimex", 40.2667, 65.0333),
    District("Karmana", 40.1319, 65.3792),
    District("Navbahor", 40.25, 65.6667),
    District("Nurota", 40.5667, 65.6833),
    District("Qiziltepa", 40.1333, 64.95),
    District("Tomdi", 40.0833, 64.6),
    District("Uchquduq", 42.1547, 63.55),
    District("Xatirchi", 39.9833, 65.6833),
    District("Zarafshon", 41.5706, 64.1997),
  ]),
  Region('Xorazm viloyati', [
    District("Urganch shahri", 41.55, 60.6333),
    District("Bog'ot", 41.4167, 60.4),
    District("Gurlan", 41.85, 60.3833),
    District("Qo'shko'pir", 41.65, 60.3333),
    District("Shovot", 41.65, 60.3167),
    District("Urganch tumani", 41.5833, 60.5833),
    District("Xazorasp", 41.3167, 60.4333),
    District("Xiva", 41.3783, 60.3617),
    District("Yangiariq", 41.4667, 60.2667),
    District("Yangibozor", 41.7167, 60.2667),
  ]),
  Region("Qoraqalpog'iston Respublikasi", [
    District("Nukus shahri", 42.4531, 59.6103),
    District("Amudaryo", 42.0167, 59.5833),
    District("Beruniy", 41.6889, 60.7497),
    District("Chimboy", 42.9333, 59.7833),
    District("Ellikqal'a", 41.85, 60.85),
    District("Kegeyli", 42.7333, 59.8167),
    District("Mo'ynoq", 43.77, 59.02),
    District("Nukus tumani", 42.4, 59.5),
    District("Qanliko'l", 42.5667, 59.95),
    District("Qorao'zak", 42.6167, 59.8667),
    District("Qo'ng'irot", 43.0597, 58.8894),
    District("Shumanay", 42.6167, 59.4333),
    District("Taxtako'pir", 43.0667, 60.35),
    District("To'rtko'l", 41.55, 61.0167),
    District("Xo'jayli", 42.4167, 59.45),
  ]),
];

const defaultRegionName = 'Toshkent shahri';
const defaultDistrictName = "Mirzo Ulug'bek";

Region? findRegion(String name) {
  for (final r in uzbekistanRegions) {
    if (r.name == name) return r;
  }
  return null;
}

District? findDistrict(String regionName, String districtName) {
  final region = findRegion(regionName);
  if (region == null) return null;
  for (final d in region.districts) {
    if (d.name == districtName) return d;
  }
  return null;
}

/// Appends "tumani" for plain district names, leaving names that are
/// already a city ("... shahri") or already say "... tumani" unchanged.
String districtLabel(String name) {
  if (name.endsWith('shahri') || name.endsWith('tumani')) return name;
  return '$name tumani';
}
