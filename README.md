# REFARM AgroStore

**Nama:** Rendi Wija Kusuma | **NIM:** 2415051045
**Framework:** Flutter (Dart)

REFARM AgroStore adalah aplikasi katalog dan pemesanan produk pangan segar. Pengguna dapat mencari dan menyaring produk berdasarkan kategori, melihat indikator kesegaran serta harga Rupiah, mengajukan pesanan, dan mengelola riwayat pesanan.

## Fitur

- Katalog produk dari REST API, dengan data contoh sebagai fallback saat API gagal.
- Pencarian produk dan filter kategori: Daging Unggas, Daging Merah, Telur, dan Sembako.
- Indikator kesegaran di kartu dan detail produk.
- Checkout pesanan langsung maupun pre-order.
- Riwayat dan operasi buat, baca, ubah, dan hapus pesanan melalui Supabase.
- Harga Rupiah dan tanggal pengiriman berformat `dd MMM yyyy`.
- Tampilan katalog responsif: daftar pada layar compact dan grid pada layar lebar.

## Arsitektur Folder

```text
lib/
  main.dart                 # Inisialisasi aplikasi, tema, dan Provider
  models/                   # ProductModel dan OrderModel
  providers/                # State katalog dan pesanan (ChangeNotifier)
  repositories/             # FarmRepository sebagai penghubung sumber data
  screens/                  # Beranda, katalog, detail, checkout, dan riwayat
  services/                 # ApiService (REST) dan SupabaseService (database)
  utils/                    # Formatter harga dan tanggal Indonesia
  widgets/                  # Kartu produk dan indikator kesegaran
test/                       # Unit dan widget tests
```

`OrderProvider` mengelola state UI dan memanggil `FarmRepository`. Repository meneruskan permintaan katalog ke `ApiService` dan operasi pesanan ke `SupabaseService`.

## Sumber Data

### REST API katalog

`ApiService` melakukan HTTP GET ke:

```text
https://api.mockfly.dev/mocks/96f502b8/refarm/products
```

API mengembalikan array produk atau objek dengan properti `products`. Jika permintaan gagal atau hasilnya kosong, aplikasi menggunakan katalog contoh lokal. Produk berkategori `Sayuran` dikeluarkan dari katalog.

### Supabase

Aplikasi memakai tabel `orders`. Kolom yang dibaca atau ditulis oleh aplikasi:

| Kolom | Tipe yang disarankan | Keterangan |
|---|---|---|
| `id` | `uuid` primary key | ID pesanan yang dibuat database |
| `customer_name` | `text` | Nama pemesan |
| `customer_phone` | `text`, nullable | Nomor telepon pemesan |
| `product_name` | `text` | Nama produk |
| `category` | `text` | Kategori produk |
| `quantity` | `integer` | Jumlah pesanan |
| `order_type` | `text` | `direct` atau `pre_order` |
| `delivery_address` | `text` | Alamat pengiriman |
| `delivery_date` | `date` | Tanggal pengiriman |
| `notes` | `text`, nullable | Catatan pesanan |
| `total_price` | `numeric` | Total harga |
| `status` | `text` | Status, default `Pending` |
| `created_at` | `timestamptz` | Waktu pembuatan untuk urutan riwayat |

Buat tabel dengan kolom-kolom tersebut di Supabase, lalu atur kebijakan Row Level Security sesuai autentikasi dan kebutuhan aplikasi Anda. Jangan membuka akses tulis publik di lingkungan produksi.

Konfigurasi URL proyek dan publishable/anon key Supabase di `lib/main.dart` sebelum menjalankan aplikasi dengan proyek Anda sendiri. Gunakan konfigurasi lokal atau mekanisme rahasia build untuk kredensial, dan jangan memasukkan service-role key ke aplikasi Flutter.

## Menjalankan Aplikasi

Pastikan Flutter SDK telah terpasang, lalu jalankan dari root proyek:

```bash
flutter pub get
flutter run
```

Untuk memeriksa kode dan menjalankan tes:

```bash
flutter analyze
flutter test
```
