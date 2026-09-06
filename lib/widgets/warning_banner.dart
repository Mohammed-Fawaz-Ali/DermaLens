import 'package:flutter/material.dart';
import '../theme.dart';

/// Widget to display educational purpose warning banner
class WarningBanner extends StatelessWidget {
  const WarningBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        border: Border.all(
          color: AppColors.danger,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is not medical diagnosis. This app is for educational purposes only. Always consult a healthcare professional for medical advice.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.danger,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
