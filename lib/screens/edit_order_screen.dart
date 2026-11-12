import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../utils/formatters.dart';

class EditOrderScreen extends StatefulWidget {
  final OrderModel order;

  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  late DateTime _deliveryDate;
  late final DateTime _minDeliveryDate;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: widget.order.deliveryAddress,
    );
    _notesController = TextEditingController(text: widget.order.notes ?? '');
    _deliveryDate = widget.order.deliveryDate;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (widget.order.orderType == 'pre_order') {
      _minDeliveryDate = widget.order.deliveryDate.isBefore(tomorrow)
          ? widget.order.deliveryDate
          : tomorrow;
    } else {
      _minDeliveryDate = widget.order.deliveryDate.isBefore(today)
          ? widget.order.deliveryDate
          : today;
    }
  }

  @override
  void dispose() {
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
      helpText: 'Ubah Tanggal Pengiriman',
    );

    if (picked != null) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.order.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID pesanan tidak valid.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = context.read<OrderProvider>();
    final newAddress = _addressController.text.trim();
    final newNotes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    final success = await provider.updateExistingOrder(
      widget.order.id!,
      newAddress,
      _deliveryDate,
      newNotes,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pesanan "${widget.order.productName}" berhasil diperbarui!',
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
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  provider.orderErrorMessage ?? 'Gagal memperbarui pesanan.',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubah Detail Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Ringkas Pesanan
              Card(
                elevation: 1,
                color: Colors.blueGrey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blueGrey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.order.productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.order.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pemesan: ${widget.order.customerName} (${widget.order.customerPhone ?? "-"})',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jumlah: ${widget.order.quantity} unit • Total: ${formatRupiah(widget.order.totalPrice)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Perbarui Informasi Pengantaran',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Alamat Pengiriman
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap Pengiriman *',
                  hintText: 'Nama jalan, nomor rumah, RT/RW, kecamatan...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.location_on_outlined),
                  ),
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

              // Tanggal Pengiriman
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
                              'Tanggal Pengiriman / Batch Panen *',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatDeliveryDate(_deliveryDate),
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

              // Catatan Khusus
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Catatan Khusus (Opsional)',
                  hintText: 'Instruksi potongan, pengemasan, dll',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tombol Simpan Perubahan
              Consumer<OrderProvider>(
                builder: (context, provider, child) {
                  final isLoading = provider.isLoadingOrders;

                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isLoading ? null : _handleUpdate,
                      icon: isLoading
                          ? const SizedBox.shrink()
                          : const Icon(Icons.save_outlined),
                      label: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
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
