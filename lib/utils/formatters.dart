import 'package:intl/intl.dart';

final NumberFormat _rupiahFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatRupiah(num amount) => _rupiahFormatter.format(amount);

String formatDeliveryDate(DateTime date) =>
    DateFormat('dd MMM yyyy').format(date);
