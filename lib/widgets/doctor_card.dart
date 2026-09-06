import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';
import '../theme.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({Key? key, required this.doctor}) : super(key: key);

  /// Prefer one place name so hospital isn't printed twice.
  String get _placeLabel {
    final clinic = doctor.clinic.trim();
    final location = doctor.location.trim();
    if (clinic.isEmpty) return location;
    if (location.isEmpty) return clinic;
    // Same or location already contains clinic → show once
    if (clinic.toLowerCase() == location.toLowerCase() ||
        location.toLowerCase().contains(clinic.toLowerCase()) ||
        clinic.toLowerCase().contains(location.toLowerCase())) {
      return location.length >= clinic.length ? location : clinic;
    }
    return '$clinic · $location';
  }

  @override
  Widget build(BuildContext context) {
    final place = _placeLabel;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.chip, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctor.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctor.specialty,
              style: const TextStyle(fontSize: 14, color: AppColors.primary),
            ),
            if (doctor.rating > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${doctor.rating.toStringAsFixed(1)} (${doctor.reviewCount})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            if (place.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      place,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (doctor.distance.isNotEmpty && doctor.distance != '0.0')
              const SizedBox(height: 4),
            if (doctor.distance.isNotEmpty && doctor.distance != '0.0')
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  '${doctor.distance} km away',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ),
            if (doctor.availability.isNotEmpty) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  doctor.availability,
                  style: const TextStyle(fontSize: 10, color: AppColors.text),
                ),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () => _openDirections(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Get Directions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDirections(BuildContext context) async {
    // Prefer maps; fall back to website only if no map URL
    final target = doctor.mapUrl.isNotEmpty
        ? doctor.mapUrl
        : (doctor.website.isNotEmpty ? doctor.website : '');
    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No directions available.')),
      );
      return;
    }
    await _openUrl(context, target);
  }

  Future<void> _openUrl(BuildContext context, String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this link.')),
      );
    }
  }
}