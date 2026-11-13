import 'package:flutter/material.dart';

import '../models/product_model.dart';
import 'animated_press.dart';
import 'freshness_indicator.dart';

class ReusableCard extends StatelessWidget {
  final ProductModel product;
  final Widget child;
  final VoidCallback? onTap;
  final bool isGrid;

  const ReusableCard({
    super.key,
    required this.product,
    required this.child,
    this.onTap,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: isGrid
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: isGrid ? Clip.antiAlias : Clip.none,
      child: AnimatedPress(
        enabled: onTap != null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: isGrid
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: child),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: FreshnessIndicator(product: product),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      child,
                      const SizedBox(height: 8),
                      FreshnessIndicator(product: product),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
