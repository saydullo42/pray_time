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
- "Continue with Google" orqali login (parolsiz): Google ID token backendda tekshirilib, JWT beriladi
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
    auth/                   # Google sign-in
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
`/auth/google/`, `/users/me/`, `/prayer-times/custom/`, `/tracking/*`, `/quran/*`, `/dua/*`, `/notifications/settings/`.

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

## Google bilan kirish ("Continue with Google")

1. Google Cloud Console'da OAuth ruxsatnomalarini yarating (bitta loyiha ichida):
   - **Web application** turidagi client ID. Bu ID backendga (`GOOGLE_CLIENT_IDS`), veb saytga
     (`NEXT_PUBLIC_GOOGLE_CLIENT_ID`) va mobil ilovaga (`GOOGLE_SERVER_CLIENT_ID`) beriladi.
   - **Android** turidagi client ID: paket nomi **`uz.praytime.app`** va ilovani imzolagan kalitning
     SHA-1 barmoq izi. Har bir kalit uchun alohida client yaratiladi:
     - **debug** (`flutter run`): `cd android && ./gradlew signingReport` yoki
       `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`;
     - **upload/release** (Play'ga yuklash uchun): o'z `.jks` kalitingizniki;
     - Play **App Signing** yoqilgan bo'lsa, Play Console → App integrity bo'limidagi "App signing key"
       SHA-1 ham alohida client sifatida qo'shiladi (foydalanuvchilarga yetib boradigan ilova shu kalit bilan imzolanadi).
2. Ilovani ishga tushirish:

```bash
flutter run --dart-define=BACKEND_BASE_URL=http://localhost:8000/api/v1 \
            --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
```

Veb sayt uchun `web/.env.local` ga `NEXT_PUBLIC_GOOGLE_CLIENT_ID=<web-client-id>` yoziladi (va "Authorized
JavaScript origins" ga `http://localhost:3000` qo'shiladi). Backend uchun `backend/.env` ga
`GOOGLE_CLIENT_IDS=<web-client-id>` yoziladi.

## Release build (Google Play)

1. Yuklash kalitini bir marta yarating va xavfsiz joyda saqlang (yo'qotsangiz, faqat Play yordami orqali tiklanadi):

```bash
keytool -genkey -v -keystore ~/praytime-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/key.properties.example android/key.properties   # va to'ldiring (git'ga kirmaydi)
```

2. Play'ga yuklanadigan `.aab` ni yig'ing:

```bash
flutter build appbundle --release \
  --dart-define=BACKEND_BASE_URL=https://api.pray-time.uz/api/v1 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
```

`android/key.properties` bo'lmasa, build sinov (debug) kaliti bilan imzolanadi va Play uni rad etadi.

**Eski paket nomida sinash.** `applicationId` hozir `uz.praytime.app`. Google Console'da shu nom uchun Android
client hali yaratilmagan bo'lsa, Google bilan kirish ishlamaydi. Vaqtincha eski nomda ishga tushirish:

```bash
ORG_GRADLE_PROJECT_appId=com.example.mobil flutter run --dart-define=...
```
