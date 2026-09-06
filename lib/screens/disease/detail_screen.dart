import 'package:flutter/material.dart';
import '../../models.dart';
import '../../data/catalog.dart';
import '../../theme.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final String diseaseId;

  const DiseaseDetailScreen({
    Key? key,
    required this.diseaseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final diseaseInfo = diseases[diseaseId];
    if (diseaseInfo == null) {
      return const Scaffold(
        body: Center(
          child: Text('Disease information not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(diseaseInfo.name),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Card
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diseaseInfo.overview,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.text,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Symptoms Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Symptoms',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diseaseInfo.symptoms,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.text,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Care Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Care & Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diseaseInfo.care,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.text,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // When to See Doctor
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When to See a Doctor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diseaseInfo.seeDoctor,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.text,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}
