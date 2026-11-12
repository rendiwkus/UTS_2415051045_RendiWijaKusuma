# PRODUCT REQUIREMENT DOCUMENT (PRD) — FASE 3 (FINAL)

## REFARM AgroStore — Smart Enterprise Pangan & Agro

**NIM Mahasiswa**: 2415051045  
**Nama Mahasiswa**: Rendi Wija Kusuma  
**Framework**: Flutter (Dart)  
**Fokus Fase 3**: Search & Filter Integration, Repository Refactoring, UI/UX Polish, & Final Documentation  
**State Management**: Provider (`ChangeNotifier`)  
**Target Folder**: `lib/` (`repositories/farm_repository.dart`, `providers/order_provider.dart`, `screens/home_screen.dart`, `screens/catalog_screen.dart`, `widgets/reusable_card.dart`) & `README.md`

---

## 1. Lingkup Pengerjaan Fase 3 (Scope)

Fase 3 merupakan tahap penyelesaian akhir (Commit 15 hingga 18) untuk memastikan seluruh komponen aplikasi berjalan mulus, kode terstruktur rapi, dan memenuhi seluruh kriteria penilaian UTS (minimal 16 *commit* Git):

1. **Interactive Search & Category Filter**: Mengaktifkan kolom pencarian (*real-time search*) dan *FilterChip* kategori (`All`, `Daging Unggas`, `Daging Merah`, `Telur`, `Sembako`) pada `CatalogScreen`, serta menghubungkan kartu kategori di `HomeScreen` agar langsung memfilter katalog.
2. **UI/UX Polishing & Formatting (`intl`)**: Memformat seluruh nominal harga menjadi format Rupiah yang rapi (contoh: `Rp 60.000`), merapikan format tanggal pengiriman, dan menyematkan widget `FreshnessIndicator` secara konsisten di kartu produk maupun detail produk.
3. **Architecture Refactoring (Repository Pattern)**: Mengisi `lib/repositories/farm_repository.dart` sebagai jembatan terpusat antara `OrderProvider` dengan `ApiService` (REST API) dan `SupabaseService` (Database).
4. **Final Testing & Documentation (`README.md`)**: Pengujian responsivitas pada mode Compact ($< 600\text{dp}$) dan Wide ($\ge 600\text{dp}$) agar bebas dari *layout overflow*, serta melengkapi dokumentasi `README.md` untuk repositori GitHub.

---

## 2. Spesifikasi Teknis & Refinement (Fase 3)

### 2.1 Logika Filtering Produk (`OrderProvider`)
Pada `lib/providers/order_provider.dart`, tambahkan *getter* `filteredProducts` yang mengombinasikan filter kategori dan kata kunci pencarian secara dinamis:

$$\text{IsMatch} = (\text{Category} == \text{'All'} \lor \text{Product.category} == \text{Category}) \land \text{Product.name.toLowerCase().contains}(\text{Query})$$

* **Aturan Domain**: Kategori yang tersedia hanya `All`, `Daging Unggas`, `Daging Merah`, `Telur`, dan `Sembako` (kategori sayuran tetap ditiadakan).

### 2.2 Repository Layer: `lib/repositories/farm_repository.dart`
Class `FarmRepository` bertugas menyederhanakan pemanggilan sumber data:
* `Future<List<ProductModel>> getCatalogProducts()` $\rightarrow$ memanggil `ApiService().fetchProducts()`.
* `Future<List<OrderModel>> getOrderHistory()` $\rightarrow$ memanggil `SupabaseService().fetchOrders()`.
* `Future<void> submitOrder(OrderModel order)` $\rightarrow$ memanggil `SupabaseService().createOrder(order)`.
* `Future<void> modifyOrder(String id, Map<String, dynamic> data)` $\rightarrow$ memanggil `SupabaseService().updateOrder(id, data)`.
* `Future<void> removeOrder(String id)` $\rightarrow$ memanggil `SupabaseService().deleteOrder(id)`.

### 2.3 Pemformatan Mata Uang & Tanggal (`intl`)
Gunakan package `intl` untuk konsistensi tampilan enterprise:
* **Mata Uang**: `NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)`
* **Tanggal Pengiriman**: `DateFormat('dd MMM yyyy')`

---

## 3. Rincian Penyempurnaan Layar & Widget

### 1. `HomeScreen` (`lib/screens/home_screen.dart`)
* Menambahkan aksi `onTap` pada setiap kartu kategori (`Daging Unggas`, `Daging Merah`, `Telur`, `Sembako`).
* Saat kategori diklik, aplikasi mengatur kategori aktif di `OrderProvider` dan berpindah otomatis ke tab **Katalog**.
* Menampilkan ringkasan jumlah pesanan aktif (*Pending*) yang diambil dari state `ordersList` di `OrderProvider`.

### 2. `CatalogScreen` (`lib/screens/catalog_screen.dart`)
* Menambahkan `TextField` pencarian di bagian atas layar dengan tombol *clear* (`Icons.clear`).
* Menambahkan baris horizontal `FilterChip` untuk memilih kategori produk.
* Menampilkan *Empty State* yang informatif jika hasil pencarian tidak ditemukan (misal: *"Produk yang Anda cari tidak tersedia"* beserta tombol *"Reset Filter"*).

### 3. `ReusableCard` (`lib/widgets/reusable_card.dart`)
* Mengintegrasikan widget `FreshnessIndicator` di bagian bawah kartu produk agar pengguna dapat melihat tingkat kesegaran daging atau telur langsung dari halaman katalog.
* Mengirimkan objek utuh `ProductModel` ke `ProductDetailScreen` saat kartu ditekan.

### 4. `README.md` (Root Project)
Dokumentasi akhir repositori GitHub wajib memuat:
* Identitas Mahasiswa (Nama: Rendi Wija Kusuma, NIM: `2415051045`).
* Deskripsi Konsep Aplikasi **REFARM AgroStore**.
* Penjelasan Arsitektur Folder (`models`, `services`, `repositories`, `providers`, `screens`, `widgets`).
* Skema Tabel Supabase (`orders`) dan Endpoint REST API yang digunakan.
* Panduan instalasi dan cara menjalankan aplikasi (`flutter pub get` & `flutter run`).

---

## 4. Roadmap Commit Git (Commit 15 – 18 Fase 3)

Gunakan daftar pesan *commit* standar berikut untuk menyelesaikan target minimal 16 *commit* UTS:

| Commit # | Milestone Target | Pesan Commit Standard |
| :--- | :--- | :--- |
| **Commit 15** | Search & Filter Feature | `Implement search and category filter on catalog` |
| **Commit 16** | Repository Refactoring & Formatting | `Refactor repository pattern and format currency UI` |
| **Commit 17** | UI/UX & Responsiveness Polish | `Polish UI responsiveness and fix layout overflow` |
| **Commit 18** | Final Documentation | `Update README documentation for final UTS submission` |

---

## 5. Panduan Prompt AI (Vibe Coding Step-by-Step Fase 3)

Salin prompt modular berikut ke Cursor / Windsurf untuk mengeksekusi Fase 3:

### Prompt Commit 15 & 16 (Search, Filter, & Repository Refactor):
> "Berdasarkan PRD_Fase_3.md, bantu saya:
> 1. Isi `lib/repositories/farm_repository.dart` untuk membungkus pemanggilan `ApiService` dan `SupabaseService`, lalu hubungkan ke `OrderProvider`.
> 2. Tambahkan state `_selectedCategory`, `_searchQuery`, serta getter `filteredProducts` di `lib/providers/order_provider.dart`.
> 3. Perbarui `lib/screens/catalog_screen.dart` dengan menambahkan Search Bar dan FilterChip kategori (All, Daging Unggas, Daging Merah, Telur, Sembako).
> 4. Gunakan package `intl` untuk memformat harga menjadi format Rupiah (`Rp 60.000`) di seluruh layar."

### Prompt Commit 17 & 18 (UI Polish & Final README):
> "Berdasarkan PRD_Fase_3.md, bantu saya:
> 1. Sematkan `FreshnessIndicator` ke dalam `lib/widgets/reusable_card.dart` dan pastikan `HomeScreen` dapat berpindah ke tab Katalog sesuai kategori yang diklik.
> 2. Periksa seluruh layout di `CatalogScreen`, `HomeScreen`, dan `OrderHistoryScreen` agar tidak ada RenderFlex overflow baik di layar kecil (< 600dp) maupun lebar (>= 600dp).
> 3. Perbarui file `README.md` di root proyek dengan dokumentasi lengkap aplikasi REFARM AgroStore, struktur arsitektur, skema Supabase, dan cara menjalankan proyek."

---

## 6. Checklist Final Sebelum Pengumpulan UTS

* [ ] **Aturan Domain**: Tidak ada kategori atau produk sayuran di dalam katalog maupun database.
* [ ] **REST API**: Berhasil mengambil data katalog produk mentah secara *async*.
* [ ] **Supabase CRUD**: Berhasil melakukan *Create* (Checkout), *Read* (Riwayat), *Update* (Edit Alamat/Catatan), dan *Delete* (Batal Order dengan `AlertDialog`).
* [ ] **State Management**: Seluruh state terkelola melalui `OrderProvider` (`ChangeNotifier`).
* [ ] **Responsive UI**: Menggunakan `LayoutBuilder` untuk membedakan tampilan Mobile (List) dan Tablet/Web (Grid).
* [ ] **Riwayat Git**: Total *commit* pada `git log --oneline` berjumlah $\ge 16$ *commit* dengan pesan yang deskriptif.