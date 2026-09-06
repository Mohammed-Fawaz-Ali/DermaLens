import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.chip, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.chip,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: product.imagePath != null
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: _productImage(product),
                  )
                : product.icon != null
                ? Icon(product.icon, size: 32, color: AppColors.muted)
                : const Icon(
                    Icons.image_not_supported,
                    size: 32,
                    color: AppColors.muted,
                  ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: product.diseases.take(3).map((disease) {
                    final displayName = disease.replaceAll('_', ' ');
                    return Chip(
                      label: Text(
                        displayName,
                        style: TextStyle(fontSize: 10, color: AppColors.text),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productImage(Product product) {
    final path = product.imagePath!;
    final image = path.startsWith('http')
        ? Image.network(path, fit: BoxFit.contain)
        : Image.asset(path, fit: BoxFit.contain);
    return Image(
      image: image.image,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        product.icon ?? Icons.image_not_supported,
        size: 32,
        color: AppColors.muted,
      ),
    );
  }
}
