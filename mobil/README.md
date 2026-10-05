# Namoz Vaqtlari

Namoz vaqtlari, Qur'on, dua va ibodat tracking uchun Flutter ilovasi. Backend (Django) alohida ishlab chiqiladi va bu repo faqat mobil (Flutter) qismini o'z ichiga oladi.

## Xususiyatlar

- Namoz vaqtlari — [Aladhan API](https://aladhan.com/prayer-times-api) orqali GPS koordinatalari asosida hisoblanadi
- Qo'lda kiritiladigan custom namoz vaqtlari (backendda saqlanadi, qurilmalar orasida sinxronlanadi)
- Milodiy va hijriy sana (`hijri` paketi)
- Kunlik / oylik / yillik namoz tracking va statistikasi (grafiklar)
- Qur'oni Karim — PDF, audio (tilovat) va video formatlarda
- Dua kategoriyalari va matnlari
- Foydalanuvchi profili
- SMS OTP orqali login/register (parolsiz), backend Eskiz.uz orqali SMS yuboradi
- Namoz vaqtidan 10/15/20 daqiqa oldin push-eslatmalar (`flutter_local_notifications`)
- Dark/Light tema

## Texnologiyalar

- **State management:** Riverpod (`flutter_riverpod`)
- **Routing:** `go_router` (bottom-nav uchun `StatefulShellRoute`)
- **Networking:** `dio`
- **Local storage:** `shared_preferences` (sozlamalar), `flutter_secure_storage` (tokenlar)
- **Bildirishnomalar:** `flutter_local_notifications` + `timezone`

## Loyiha tuzilmasi

```
lib/
  main.dart                # Entry point: ProviderContainer, SharedPreferences, notification init
  app.dart                 # MaterialApp.router + tema
  core/
    constants/             # AppColors, AppConstants, ApiEndpoints
    theme/                 # AppTheme, ThemeModeNotifier (persisted dark/light)
    network/                # DioClient, ApiException
    storage/                # LocalStorageService, SecureStorageService
    utils/                  # DateConverter (hijriy/milodiy), Validators
    widgets/                # CustomButton, CustomTextField, LoadingIndicator, ErrorView
    routing/                # RouteNames, GoRouter konfiguratsiyasi
  features/
    auth/                   # SMS OTP login/register
    prayer_times/           # Aladhan API + custom vaqtlar
    tracking/               # Kunlik/oylik/yillik tracking
    quran/                  # Surah ro'yxati, PDF/audio/video
    dua/                    # Dua kategoriyalari va matnlari
    profile/                # Foydalanuvchi profili
    notifications/          # Eslatma sozlamalari va scheduler
    home/                   # Bosh sahifa va bottom-nav shell
    settings/               # Umumiy sozlamalar
    splash/                 # Ilova ochilganda auth holatini tekshirish
```

Har bir feature ichida `data/` (models, repositories, services) va `presentation/` (providers, screens, widgets) qatlamlariga bo'lingan.

## Backend bilan bog'lanish

Flutter tomoni Django backendga quyidagi bazaviy URL orqali murojaat qiladi:

```
lib/core/constants/api_endpoints.dart
```

Standart qiymat: `http://10.0.2.2:8000/api/v1` (Android emulyatordan localhost'ga yo'l). Boshqa manzil bilan ishga tushirish uchun:

```bash
flutter run --dart-define=BACKEND_BASE_URL=https://api.example.com/api/v1
```

Backend quyidagi endpointlarni ta'minlashi kutiladi (barchasi `api_endpoints.dart` faylida sanab o'tilgan):
`/auth/otp/request/`, `/auth/otp/verify/`, `/auth/register/`, `/users/me/`, `/prayer-times/custom/`, `/tracking/*`, `/quran/*`, `/dua/*`, `/notifications/settings/`.

## Ishga tushirish

```bash
flutter pub get
flutter run
```

Kod generatsiyasi kerak bo'lsa (freezed/riverpod_generator qo'shilganda):

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Qurilma ruxsatlari

- **Joylashuv (GPS):** namoz vaqtlarini hisoblash uchun kerak (`geolocator`, `permission_handler`)
- **Bildirishnomalar:** eslatmalar uchun kerak (Android 13+ da runtime ruxsat so'raladi)

Android/iOS manifest fayllariga tegishli ruxsat yozuvlarini (`ACCESS_FINE_LOCATION`, `POST_NOTIFICATIONS`, `NSLocationWhenInUseUsageDescription` va h.k.) qo'shish kerak bo'ladi.
