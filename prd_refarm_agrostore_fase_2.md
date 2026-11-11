# PRODUCT REQUIREMENT DOCUMENT (PRD) — FASE 2

## REFARM AgroStore — Smart Enterprise Pangan & Agro

**NIM Mahasiswa**: 2415051045  
**Framework**: Flutter (Dart)  
**Fokus Fase 2**: Integrasi Backend Supabase Database, Full CRUD, Form Validation, User Feedback, & Error Handling  
**State Management**: Provider (`ChangeNotifier`)  
**Backend Database**: Supabase PostgreSQL (Tabel `orders`)  
**Target Folder**: `lib/` (`services/supabase_service.dart`, `providers/order_provider.dart`, `screens/checkout_screen.dart`, `screens/edit_order_screen.dart`, `screens/order_history_screen.dart`)

---

## 1. Lingkup Pengerjaan Fase 2 (Scope)

Fase 2 berfokus menyelesaikan fitur database *persistent*, operasi data interaktif, dan pemenuhan spesifikasi utama UTS (Commit 9 hingga 14):

1. **Database Supabase Setup & SDK Integration**: Menghubungkan Flutter Client ke tabel `orders` pada Supabase PostgreSQL.
2. **Form Checkout & Create Data (C)**: Form pemesanan dengan validasi ketat, DatePicker pengiriman (minimal $H+1$ untuk Pre-Order), dan penyimpanan record baru ke database.
3. **Order History & Read Data (R)**: Menampilkan riwayat transaksi secara *real-time* / *async* dari Supabase dengan penanganan status *Loading*, *Error*, dan *Empty State*.
4. **Edit Order & Update Data (U)**: Mengubah detail alamat pengantaran, tanggal kirim, atau catatan pesanan yang masih berstatus `Pending`.
5. **Cancel Order & Delete Data (D)**: Penghapusan data transaksi dari database yang diawali dengan konfirmasi modal `AlertDialog`.
6. **User Interaction & Feedback**: Penggunaan `SnackBar` untuk notifikasi aksi sukses/gagal, serta indikator `CircularProgressIndicator` saat proses mutasi database berjalan.

---

## 2. Aturan Bisnis & Integrasi Database Supabase

### 2.1 Skema Tabel Supabase (`public.orders`)

AI Assistant harus menyelaraskan properti objek Dart `OrderModel` dengan kolom tabel `orders` berikut:

```sql
create table public.orders (
    id uuid default gen_random_uuid() primary key,
    customer_name text not null,
    customer_phone text,
    product_name text not null,
    category text not null check (category in ('Daging Unggas', 'Daging Merah', 'Telur', 'Sembako')),
    quantity int2 not null check (quantity > 0),
    order_type text not null check (order_type in ('pre_order', 'direct')),
    delivery_address text not null,
    delivery_date date not null,
    notes text,
    total_price numeric(12, 2) not null check (total_price >= 0),
    status text default 'Pending' check (status in ('Pending', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan')),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

### 2.2 Aturan Validasi Form Pemesanan (Checkout & Edit)
* **Customer Name**: Wajib diisi (minimal 3 karakter).
* **Customer Phone**: Wajib diisi (hanya angka, 10–13 digit).
* **Delivery Address**: Wajib diisi (minimal 10 karakter).
* **Delivery Date**: 
  * Untuk `order_type == 'pre_order'`: Tanggal minimal $H+1$ dari hari ini.
  * Untuk `order_type == 'direct'`: Tanggal minimal hari ini ($H+0$).
* **Quantity**: Minimal 1 kg / pack, tidak boleh melebihi `stockAvailable` dari katalog.

---

## 3. Spesifikasi Komponen Kode (Fase 2)

### 3.1 Backend Service: `lib/services/supabase_service.dart`

Method yang wajib diimplementasikan:
* `Future<List<OrderModel>> fetchOrders()`: `SELECT` seluruh data dari tabel `orders` yang diurutkan berdasar `created_at DESC`.
* `Future<void> createOrder(OrderModel order)`: `INSERT` record pesanan baru.
* `Future<void> updateOrder(String id, Map<String, dynamic> data)`: `UPDATE` kolom `delivery_address`, `delivery_date`, dan `notes` berdasarkan `id`.
* `Future<void> deleteOrder(String id)`: `DELETE` record pesanan berdasarkan `id`.

### 3.2 State Management Update: `lib/providers/order_provider.dart`

Properti dan Method Tambahan:
* `List<OrderModel> _ordersList = []`
* `List<OrderModel> get ordersList => _ordersList`
* `Future<void> fetchOrdersFromDatabase()`
* `Future<bool> submitNewOrder(OrderModel order)`
* `Future<bool> updateExistingOrder(String id, String newAddress, DateTime newDate, String? newNotes)`
* `Future<bool> cancelOrder(String id)`

### 3.3 Screen Specifications

#### 1. `CheckoutScreen` (`lib/screens/checkout_screen.dart`) — **CREATE**
* Menerima passing parameter `ProductModel` dari detail produk.
* Menggunakan `FormKey` dan `TextFormField` dengan `validator`.
* DatePicker interaktif untuk memilih `deliveryDate`.
* Mengubah tombol *Submit* menjadi `CircularProgressIndicator` saat proses `submitNewOrder` berlangsung.
* Menampilkan `SnackBar` hijau saat berhasil dan kembali ke layar sebelumnya, atau `SnackBar` merah saat error.

#### 2. `OrderHistoryScreen` (`lib/screens/order_history_screen.dart`) — **READ & DELETE**
* Menggunakan `Consumer<OrderProvider>` untuk menampilkan daftar `OrderModel` secara async.
* Card daftar pesanan menampilkan: Nama Produk, Tanggal Kirim, Alamat, Total Biaya, dan Chip Status (`Pending`, `Diproses`, dll).
* Tombol Edit: Bernavigasi ke `EditOrderScreen` membawa objek `OrderModel`.
* Tombol Hapus/Batal: Memicu `showDialog` (`AlertDialog`) konfirmasi. Jika "Ya", panggil `cancelOrder(id)` dan tampilkan `SnackBar` feedback.

#### 3. `EditOrderScreen` (`lib/screens/edit_order_screen.dart`) — **UPDATE**
* Menerima data `OrderModel`.
* Pre-fill controller form dengan alamat, tanggal, dan catatan lama.
* Menjalankan validasi form sebelum memanggil `updateExistingOrder()`.
* Umpan balik berupa `SnackBar` saat berhasil disimpan.

---

## 4. Roadmap Commit Git (Commit 9 – 14 Fase 2)

Gunakan daftar pesan *commit* standar ini untuk Fase 2:

| Commit # | Milestone Target | Pesan Commit Standard |
| :--- | :--- | :--- |
| **Commit 9** | Database Integration | `Integrate backend database` |
| **Commit 10** | Create Data Feature | `Implement create data feature` |
| **Commit 11** | Update Data Feature | `Implement update data feature` |
| **Commit 12** | Delete Data Feature | `Implement delete data feature` |
| **Commit 13** | User Interaction & Feedback | `Add interaction and user feedback` |
| **Commit 14** | Loading & Error Handling | `Add loading and error handling` |

---

## 5. Panduan Prompt AI (Vibe Coding Step-by-Step Fase 2)

Salin prompt modular berikut ke Cursor / Windsurf per milestone:

### Prompt Commit 9 & 10 (Database Init & Create Order):
> "Berdasarkan PRD_Fase_2.md, bantu saya:
> 1. Isi `lib/services/supabase_service.dart` dengan fungsi `createOrder` dan `fetchOrders` menggunakan `SupabaseClient`.
> 2. Perbarui `lib/providers/order_provider.dart` untuk menambahkan fungsi `submitNewOrder` yang memanggil service Supabase.
> 3. Perbarui `lib/screens/checkout_screen.dart` agar form pemesanan divalidasi dengan benar (nama, HP, alamat, dan DatePicker minimal H+1 untuk Pre-Order). Saat submit, simpan ke Supabase dan tampilkan SnackBar feedback."

### Prompt Commit 11 & 12 (Update & Delete Order):
> "Berdasarkan PRD_Fase_2.md, bantu saya:
> 1. Buat metode `updateOrder` dan `deleteOrder` di `supabase_service.dart` dan sambungkan ke `order_provider.dart`.
> 2. Perbarui `lib/screens/order_history_screen.dart` untuk memuat data dari Supabase. Tambahkan tombol Delete yang memicu AlertDialog konfirmasi pembatalan order sebelum menghapus data.
> 3. Perbarui `lib/screens/edit_order_screen.dart` agar form dapat mengubah alamat dan catatan pesanan di Supabase."

### Prompt Commit 13 & 14 (User Feedback & Error State Refinement):
> "Berdasarkan PRD_Fase_2.md, rapikan user feedback dan error handling:
> 1. Pastikan seluruh operasi CRUD di CheckoutScreen, EditOrderScreen, dan OrderHistoryScreen menampilkan SnackBar feedback yang informatif (sukses/gagal).
> 2. Tambahkan CircularProgressIndicator saat data sedang di-fetch atau di-insert, serta perbaiki tampilan Empty State jika riwayat pesanan masih kosong."