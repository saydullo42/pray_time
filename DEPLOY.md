# Productionga chiqarish (Hetzner VPS + Docker)

Stack: **PostgreSQL + Django (gunicorn) + Next.js + Caddy** (HTTPS avtomatik).
Hammasi `docker-compose.yml` orqali ishga tushadi. Domenlar:

- `pray-time.uz` — veb sayt
- `api.pray-time.uz` — backend (API, admin, media)

> Bu fayllar Docker o'rnatilmagan kompyuterda yozilgan, shuning uchun to'liq
> Docker build'ni men sinab ko'ra olmadim. Veb sayt standalone rejimida,
> backend gunicorn/production sozlamalari bilan alohida sinalgan. Birinchi
> ishga tushirishda xato chiqsa, `docker compose logs` natijasini yuboring.

## 1. Serverni yaratish (Hetzner Cloud)

1. Location: **Falkenstein** yoki **Nuremberg** (Germaniya).
2. Image: **Ubuntu 24.04**.
3. Type: umumiy (shared) vCPU, kamida **2 vCPU / 4 GB RAM / 40 GB SSD**.
   Qur'on audiolari (~2.2 GB) va baza o'sadi, joy tanqis bo'lsa diskni kattalashtirish mumkin.
4. SSH key: o'z kompyuteringizning ochiq kalitini (`~/.ssh/id_ed25519.pub`) qo'shing.
   Kalit yo'q bo'lsa: `ssh-keygen -t ed25519`.
5. **Backups** (+20% narx) yoqish tavsiya etiladi.
6. Firewall: faqat kiruvchi **22/tcp, 80/tcp, 443/tcp, 443/udp** ga ruxsat bering.
   Postgres va boshqa portlar tashqariga ochilmaydi.

Server yaratilgach uning **IPv4 manzilini** yozib oling.

## 2. DNS

Domen registratori panelida ikkita `A` yozuvi qo'shing (ikkalasi ham server IP'siga):

| Nomi  | Turi | Qiymati     |
|-------|------|-------------|
| `@`   | A    | `SERVER_IP` |
| `api` | A    | `SERVER_IP` |

Tekshirish: `dig +short pray-time.uz` va `dig +short api.pray-time.uz` server IP'sini
qaytarishi kerak. **HTTPS sertifikat faqat DNS yangilangandan keyin olinadi.**

## 3. Serverni tayyorlash

```bash
ssh root@SERVER_IP

apt update && apt -y upgrade
apt -y install git rsync unattended-upgrades

# Docker (rasmiy o'rnatish skripti: https://docs.docker.com/engine/install/ubuntu/)
curl -fsSL https://get.docker.com | sh

# parol bilan kirishni o'chirish (SSH kalit bilan kirib bo'lgandan keyin!)
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh
```

## 4. Kodni olish va sozlash

```bash
git clone https://github.com/saydullo42/pray_time.git /opt/praytime
cd /opt/praytime

cp .env.production.example .env
nano .env
```

`.env` da to'ldiring:

- `POSTGRES_PASSWORD` — `openssl rand -hex 24`
- `DJANGO_SECRET_KEY` — `python3 -c "import secrets;print(secrets.token_urlsafe(60))"`
- `GOOGLE_CLIENT_ID` — Google Console'dagi **Web** client ID
- `SITE_DOMAIN`, `API_DOMAIN` — odatda o'zgarmaydi

`.env` GitHub'ga yuklanmaydi va hech kimga yuborilmaydi.

Papkalarni tayyorlash:

```bash
mkdir -p data/{postgres,media,static,cache,caddy,caddy-config,backups}
chown -R 1000:1000 data/media data/static data/cache
```

## 5. Google Cloud Console

1. **Credentials → Web client → Authorized JavaScript origins** ga `https://pray-time.uz` qo'shing.
2. **OAuth consent screen** hozir "Testing" holatida bo'lsa, faqat "Test users" kira oladi.
   Hamma foydalanuvchi kirishi uchun **"Publish app" (In production)** qiling.
   Faqat `email`, `profile`, `openid` so'ralgani uchun, odatda qo'shimcha tekshiruv talab qilinmaydi.
   "Authorized domains" ga `pray-time.uz`, "Privacy policy link" ga `https://pray-time.uz/privacy` qo'ying.

## 6. Ishga tushirish

```bash
cd /opt/praytime
docker compose up -d --build
docker compose ps
docker compose logs -f caddy backend
```

Birinchi yig'ish bir necha daqiqa oladi. `caddy` jurnalida
`certificate obtained successfully` chiqsa, HTTPS tayyor.

Admin yaratish (email va parolni o'zingiz kiritasiz):

```bash
docker compose exec backend python manage.py createsuperuser
```

## 7. Ma'lumotlarni ko'chirish

Foydalanuvchilar ko'chirilmaydi (yangi baza toza boshlanadi), faqat **kontent**:
duolar, suralar, qorilar. Rasm va audio fayllar alohida.

**Lokal kompyuterda** (loyiha papkasidan, backend `venv` yoqilgan holda):

```bash
cd backend
source venv/bin/activate
# DATABASE_URL ni backend/.env dan oling; parolni so'rasa shu yerdagi parolni kiriting
pg_dump "postgres://USER:PAROL@localhost:5432/backend" \
  --data-only --column-inserts --no-owner -t 'dua_*' -t 'quran_*' -f content.sql

scp content.sql root@SERVER_IP:/opt/praytime/
rsync -avP media/ root@SERVER_IP:/opt/praytime/data/media/
```

**Serverda:**

```bash
cd /opt/praytime
chown -R 1000:1000 data/media
docker compose exec -T db psql -U praytime praytime < content.sql

# bazadagi localhost havolalarni haqiqiy domenga almashtirish (avval quruq ishga tushirib ko'ring)
docker compose exec backend python manage.py rewrite_media_urls \
  --old http://localhost:8000 --new https://api.pray-time.uz
docker compose exec backend python manage.py rewrite_media_urls \
  --old http://localhost:8000 --new https://api.pray-time.uz --apply

rm content.sql
```

## 8. Tekshirish

- `https://pray-time.uz` — sayt ochiladi, "Continue with Google" ishlaydi.
- `https://api.pray-time.uz/api/v1/dua/categories/` — `401` (kirish kerak) qaytaradi. Bu to'g'ri.
- `https://api.pray-time.uz/media/quran_audio/ibrohim_elhaq/112.mp3` — fayl yuklanadi.
- `https://api.pray-time.uz/admin/` — admin panelga email va parol bilan kirasiz.
- `https://api.pray-time.uz/api/docs/` — `404` bo'lishi kerak (production'da yopiq).

Hammasi ishlagach, `.env` da `DJANGO_HSTS_SECONDS=31536000` qo'ying va
`docker compose up -d` qiling.

## 8a. Xavfsizlik sarlavhalari (CSP)

Sayt `Content-Security-Policy` bilan ishlaydi: brauzer faqat saytning o'ziga, API domeniga,
Google (kirish tugmasi) va `api.alquran.cloud` ga ulanishi mumkin. Agar kelajakda boshqa tashqi
manba qo'shilsa (rasm, shrift, API), uni `web/next.config.ts` dagi `contentSecurityPolicy` ro'yxatiga
ham qo'shish kerak, aks holda brauzer uni to'sib qo'yadi.

Kundalik tozalash (`scheduler` konteyneri o'zi bajaradi): har kuni soat 01:00 da namoz vaqtlari keshi
yangilanadi va muddati o'tgan JWT tokenlar bazadan o'chiriladi (`flushexpiredtokens`).

## 9. Mobil ilovani production'ga ulash

Ilovani yig'ishda API manzili va Google ID'ni bering:

```bash
flutter build apk --release \
  --dart-define=BACKEND_BASE_URL=https://api.pray-time.uz/api/v1 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
```

Google Play uchun: `com.example.mobil` paket nomini o'zgartirish, o'z kalitingiz bilan imzolash
va shu kalitning SHA-1 ini Google Console'dagi Android client'ga qo'shish kerak.

## 10. Kundalik ishlar

```bash
cd /opt/praytime
git pull && docker compose up -d --build     # yangilash
docker compose logs --tail=100 backend       # jurnal
./deploy/backup.sh                           # baza zaxirasi (data/backups/)
```

Har kuni avtomatik zaxira (`crontab -e`):

```
0 3 * * * cd /opt/praytime && ./deploy/backup.sh >> data/backups/backup.log 2>&1
```

`data/media` (rasm va audio) ham zaxiralanishi kerak, Hetzner Backups yoki `rsync` bilan.
Zaxirani **boshqa joyga** ham nusxalang.
