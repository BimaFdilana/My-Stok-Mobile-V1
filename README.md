# MyStok — Mobile App (Flutter)

Aplikasi mobile manajemen stok & kasir untuk usaha kecil/menengah (kedai kopi, restoran, dll). Terhubung ke backend Laravel [My-Stok-Web-Dashboard-V1](https://github.com/BimaFdilana/My-Stok-Web-Dashboard-V1).

## Fitur

### Admin
- Dashboard ringkasan stok (total barang, stok masuk/keluar, transaksi)
- Kasir (POS) — pilih menu, atur qty, pembayaran Tunai/QRIS
- CRUD Barang + Bahan Baku
- Manajemen Stok, Barang Masuk, Barang Keluar
- Laporan (Barang Masuk, Barang Keluar, Transaksi per hari + breakdown Tunai vs QRIS)
- Profil pengguna

### Kasir
- Akses menu dinamis sesuai izin yang diatur admin lewat web
- Default: Dashboard + Kasir

## Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Framework | Flutter (Dart) |
| HTTP | package `http` |
| State | StatefulWidget + setState |
| Storage | shared_preferences (token + session) |
| Auth | Bearer token (Laravel Sanctum) |
| Format | intl (Rupiah Indonesia) |
| Image | image_picker |

## Desain

- Design system terpusat di `lib/utils/app_theme.dart` (warna, radius, shadow, gradient)
- Full color: tiap fitur punya warna aksen sendiri (Kasir cyan, Barang ungu, Stok teal, dll)
- Responsive: utility `lib/utils/responsive.dart` (mobile, tablet, iPad)
- Widget reusable: AppCard, AppButton, LoadingShimmer, EmptyState, ErrorState

## Struktur

```
lib/
├── main.dart                    # Entry + ThemeData global
├── config/
│   └── api.dart                 # Base URL + endpoint + storageUrl helper
├── models/                      # Item, Category, Ingredient, Stock, Kasir, dll
├── services/                    # Auth, Item, Category, Kasir, Laporan, Qris, Session
├── utils/
│   ├── app_theme.dart           # Design tokens
│   ├── responsive.dart          # Breakpoint helper
│   └── currency.dart            # Format Rupiah (Rp.100.000)
├── widgets/                     # AppCard, AppButton, shimmer, empty/error state
└── pages/
    ├── auth/                    # Login, Register
    ├── home/                    # BottomNav shell
    ├── dashboard/               # Dashboard
    ├── feature/                 # Grid menu (filtered by permission)
    ├── kasir/                   # Kasir, Pembayaran, Receipt
    ├── barang/                  # CRUD Barang
    ├── barang_masuk/            # Barang Masuk
    ├── barang_keluar/           # Barang Keluar
    ├── stock/                   # Stok
    ├── laporan/                 # Laporan Masuk/Keluar/Transaksi
    └── profile/                 # Profil
```

## Konfigurasi

Set base URL backend di `lib/config/api.dart`:

```dart
static const String host = "http://10.25.105.44:8000"; // ganti sesuai IP server
```

- Android Emulator: `http://10.0.2.2:8000`
- Device fisik: IP LAN komputer (mis. `http://192.168.x.x:8000`)

## Instalasi

```bash
git clone https://github.com/BimaFdilana/My-Stok-Mobile-V1.git
cd My-Stok-Mobile-V1
flutter pub get
flutter run
```

## Akun Default (dari seeder backend)

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `password123` |
| Kasir | `kasir1` | `password123` |

## Lisensi

Private — untuk keperluan akademik.
