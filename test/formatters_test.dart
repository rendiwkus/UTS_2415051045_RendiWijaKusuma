import 'package:flutter_test/flutter_test.dart';
import 'package:uts_2415051045_rendiwijakusuma/utils/formatters.dart';

void main() {
  test('formats Rupiah with Indonesian thousands separators', () {
    expect(formatRupiah(60000), 'Rp 60.000');
  });
}
