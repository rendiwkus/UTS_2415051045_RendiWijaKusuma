import 'package:flutter/material.dart';
import '../models/product_model.dart';

class FreshnessIndicator extends StatelessWidget {
  final ProductModel product;

  const FreshnessIndicator({super.key, required this.product});

  Color _getStatusColor(String status) {
    if (status.contains('Sangat Segar') || status == 'Tahan Lama') {
      return Colors.green;
    } else if (status.contains('Kondisi Baik')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = product.freshnessStatus;
    final percentage = product.freshnessPercentage;
    final color = _getStatusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (product.category != 'Sembako')
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: product.category == 'Sembako' ? 1.0 : percentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

