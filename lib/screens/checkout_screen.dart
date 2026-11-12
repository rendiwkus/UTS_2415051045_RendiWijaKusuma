import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final ProductModel product;

  const CheckoutScreen({super.key, required this.product});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  late int _quantity;
  late DateTime _deliveryDate;
  late final DateTime _minDeliveryDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _notesController = TextEditingController();

    _quantity = 1;

    final now = DateTime.now();
    // Aturan PRD 2.2:
    // Pre-Order: Tanggal minimal H+1 dari hari ini
    // Direct: Tanggal minimal hari ini (H+0)
    if (widget.product.isPreOrder) {
      _minDeliveryDate = DateTime(now.year, now.month, now.day + 1);
    } else {
      _minDeliveryDate = DateTime(now.year, now.month, now.day);
    }
    _deliveryDate = _minDeliveryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDeliveryDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate.isBefore(_minDeliveryDate)
          ? _minDeliveryDate
          : _deliveryDate,
      firstDate: _minDeliveryDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: widget.product.isPreOrder
          ? 'Pilih Jadwal Batch Panen (Min. H+1)'
          : 'Pilih Tanggal Pengiriman',
    );

    if (picked != null) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<OrderProvider>();

    final order = OrderModel(
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      productName: widget.product.name,
      category: widget.product.category,
      quantity: _quantity,
      orderType: widget.product.isPreOrder ? 'pre_order' : 'direct',
      deliveryAddress: _addressController.text.trim(),
      deliveryDate: _deliveryDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      totalPrice: widget.product.price * _quantity,
      status: 'Pending',
    );

    final success = await provider.submitNewOrder(order);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pesanan "${widget.product.name}" berhasil dibuat!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 3),
        ),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  provider.errorMessage ?? 'Gagal membuat pesanan.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxStock = widget.product.stockAvailable;
    final totalPrice = widget.product.price * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.isPreOrder ? 'Form Pre-Order' : 'Form Checkout Pesanan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan Produk Terpilih
              Card(
                elevation: 1,
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.product.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 70,
                            height: 70,
                            color: Colors.green.shade100,
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.green,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.product.category} • Rp ${widget.product.price.toStringAsFixed(0)}/unit',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.product.isPreOrder
                                  ? 'Jenis: Pre-Order (Potong Sesuai Batch)'
                                  : 'Jenis: Direct Order (Stok Langsung)',
                              style: TextStyle(
                                fontSize: 11,
                                color: widget.product.isPreOrder
                                    ? Colors.orange.shade900
                                    : Colors.blueGrey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pemilih Jumlah / Quantity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah Pesanan (kg / pack):',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: _quantity < maxStock
                              ? () => setState(() => _quantity++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tersedia: $maxStock unit/pack',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const Divider(height: 24),

              const Text(
                'Data Pelanggan & Pengiriman',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Customer Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Pemesan *',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama pemesan wajib diisi.';
                  }
                  if (val.trim().length < 3) {
                    return 'Nama minimal 3 karakter.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // Customer Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor WhatsApp / HP *',
                  hintText: '08123456789',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nomor HP wajib diisi.';
                  }
                  final trimmed = val.trim();
                  final phoneRegex = RegExp(r'^[0-9]{10,13}$');
                  if (!phoneRegex.hasMatch(trimmed)) {
                    return 'Nomor HP harus berupa angka 10-13 digit.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // Delivery Address Field
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap Pengiriman *',
                  hintText: 'Nama jalan, nomor rumah, RT/RW, kecamatan...',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Alamat pengiriman wajib diisi.';
                  }
                  if (val.trim().length < 10) {
                    return 'Alamat minimal 10 karakter untuk kejelasan kurir.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // Interactive DatePicker Field
              InkWell(
                onTap: () => _selectDeliveryDate(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.isPreOrder
                                  ? 'Tanggal Batch Potong / Panen (Min. H+1) *'
                                  : 'Tanggal Pengiriman (Min. H+0) *',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_deliveryDate.day.toString().padLeft(2, '0')}/${_deliveryDate.month.toString().padLeft(2, '0')}/${_deliveryDate.year}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Notes Field (Optional)
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Catatan Khusus (Opsional)',
                  hintText: 'Contoh: potong 8 bagian, bungkus per 1 kg',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Rp ${totalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Consumer<OrderProvider>(
                builder: (context, provider, child) {
                  final isLoading = provider.isSubmittingOrder;

                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isLoading ? null : _handleSubmit,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.product.isPreOrder
                                  ? 'Konfirmasi Pre-Order'
                                  : 'Konfirmasi Pesanan Sekarang',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
