# PRODUCT REQUIREMENT DOCUMENT (PRD) — FASE 1
## REFARM AgroStore — Smart Enterprise Pangan & Agro

**NIM Mahasiswa**: 2415051045  
**Framework**: Flutter (Dart)  
**Fokus Fase**: Core Architecture, UI Responsif, REST API Katalog, & Freshness Engine  
**State Management**: Provider (`ChangeNotifier`)  
**Target Folder**: `lib/` (models, services, repositories, providers, screens, widgets)

---

## 1. Lingkup Pengerjaan Fase 1 (Scope)

Fase 1 berfokus menyelesaikan setengah dari target aplikasi dan milestone Git (Commit 1 hingga 8). Fitur yang dikerjakan mencakup:

1. **Project & Architecture Setup**: Inisialisasi struktur folder clean architecture.
2. **Data Model**: Pembuatan `ProductModel` lengkap dengan logika kalkulasi kesegaran (*Freshness Gauge*).
3. **Services & Repository**: Layanan REST API Client (`http`) untuk fetching data katalog.
4. **State Management**: `OrderProvider` / `CatalogProvider` untuk mengelola state loading, data katalog, filter, dan error.
5. **Responsive UI**: Tampilan responsif menggunakan `LayoutBuilder` (Compact Mobile vs Wide Tablet).
6. **Screen Implementation**:
   - `HomeScreen` (Dashboard & Batch Panen)
   - `CatalogScreen` (List/Grid Produk Pangan Mentah & Sembako)
   - `ProductDetailScreen` (Detail Produk & Visual Freshness Bar)
7. **Custom Widgets**: `FreshnessIndicator` & `ProductCard`.

---

## 2. Aturan Bisnis Domain & Spesifikasi Teknis (Fase 1)

### 2.1 Ketentuan Kategori Pangan
- **Kategori Valid**: `Daging Unggas`, `Daging Merah`, `Telur`, `Sembako`.
- **Aturan Pembatasan**: Kategori **Sayuran** *wajib ditiadakan*.

### 2.2 Freshness Estimation Engine Formula
Kalkulasi masa segar produk protein mentah dihitung secara otomatis dengan rumus matematika berikut:

$$ \text{Percentage} = \text{clamp}\left( \frac{(\text{maxFreshDays} \times 24) - \text{hoursElapsed}}{\text{maxFreshDays} \times 24}, 0.0, 1.0 \right) $$

Status label berdasarkan persentase:
- Jika `category == 'Sembako'`: `"Tahan Lama"`
- Jika $\text{Percentage} > 0.75$: `"Sangat Segar (Fresh Cut/Harvested)"`
- Jika $\text{Percentage} > 0.40$: `"Kondisi Baik (Chilled Storage)"`
- Else ($\le 0.40$): `"Segera Dikonsumsi"`

### 2.3 Responsivitas Layout
- **Compact View (< 600dp)**: Tampilan daftar produk dalam bentuk Single Column List View.
- **Wide View ($\ge$ 600dp)**: Tampilan daftar produk dalam bentuk Multi-Column Grid View (3–4 kolom).

---

## 3. Spesifikasi File & Kode (Fase 1)

### 3.1 Data Model: `lib/models/product_model.dart`
AI Assistant harus mengimplementasikan class `ProductModel` dengan struktur:
- `String id`
- `String name`
- `String category`
- `double price`
- `int stockAvailable`
- `bool isPreOrder`
- `DateTime processedAt`
- `int maxFreshDays`
- `String imageUrl`
- `double get freshnessPercentage`
- `String get freshnessStatus`

### 3.2 Service Layer: `lib/services/api_service.dart`
- Method `Future<List<ProductModel>> fetchProducts()`: Mengambil data JSON katalog produk (dapat menggunakan mock API / dummy online endpoint) dan mengonversinya menjadi daftar instance `ProductModel`.

### 3.3 State Management: `lib/providers/order_provider.dart`
Properties & State:
- `List<ProductModel> _products`
- `bool _isLoading`
- `String? _errorMessage`
- `String _selectedCategory = 'All'`
- `String _searchQuery = ''`
Methods:
- `Future<void> loadCatalog()`
- `void setCategory(String category)`
- `void setSearchQuery(String query)`

### 3.4 Custom Widgets: `lib/widgets/freshness_indicator.dart`
- Menerima parameter `ProductModel`.
- Menampilkan `LinearProgressIndicator` dengan warna dinamis (Hijau untuk segar, Oranye untuk kondisi baik, Merah untuk segera dikonsumsi) beserta label statusnya.

---

## 4. Rincian Tampilan Screen (Fase 1)

### 1. `HomeScreen` (`lib/screens/home_screen.dart`)
- Menampilkan Banner: *"Batch Potong & Panen Hari Ini - Fresh Guarantee"*.
- Quick Filter Button untuk 4 kategori pangan (Daging Unggas, Daging Merah, Telur, Sembako).
- Card informasi kuota Pre-Order yang tersedia.

### 2. `CatalogScreen` (`lib/screens/catalog_screen.dart`)
- Search bar dan pilihan Filter Chip kategori.
- Menggunakan `LayoutBuilder` untuk membedakan mode Compact (List) dan Wide (Grid).
- Menampilkan indikator `CircularProgressIndicator` saat loading, error view jika gagal fetch, dan empty view jika data kosong.

### 3. `ProductDetailScreen` (`lib/screens/product_detail_screen.dart`)
- Menerima parameter `ProductModel` dari `CatalogScreen`.
- Gambar produk, badge kategori, harga per kg/pack, dan sisa stok pre-order.
- Mengintegrasikan widget `FreshnessIndicator`.
- Tombol Aksi *"Pesan Sekarang / Pre-Order"* (Menampilkan SnackBar placeholder untuk Fase 2).

---

## 5. Roadmap Commit Git (Commit 1 – 8 Fase 1)

Gunakan daftar message commit ini secara disiplin saat menyelesaikan tiap sub-fitur di Fase 1:

| Commit # | Milestone | Pesan Commit Standard |
| :--- | :--- | :--- |
| **Commit 1** | Project Initialization | `Initialize Flutter UTS project for 2415051045` |
| **Commit 2** | Architecture Setup | `Setup project architecture and folder structures` |
| **Commit 3** | Basic UI Layout | `Build initial application UI and screen placeholders` |
| **Commit 4** | Responsive Layout | `Implement responsive catalog layout using LayoutBuilder` |
| **Commit 5** | Navigation System | `Add application navigation and data passing to detail screen` |
| **Commit 6** | Data Models | `Add ProductModel with freshness calculation logic` |
| **Commit 7** | State Management | `Implement OrderProvider for catalog state using ChangeNotifier` |
| **Commit 8** | REST API Integration | `Integrate REST API HTTP GET for product catalog data` |

---

