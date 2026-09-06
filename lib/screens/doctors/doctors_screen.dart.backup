import 'package:flutter/material.dart';

import '../../models.dart';
import '../../data/doctors.dart';
import '../../theme.dart';
import '../../widgets/doctor_card.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String _searchQuery = '';
  String _selectedSpecialty = 'All';

  List<Doctor> get _filteredDoctors {
    final queryLower = _searchQuery.trim().toLowerCase();
    return doctors.where((doctor) {
      final matchesSpecialty =
          _selectedSpecialty == 'All' || doctor.specialty == _selectedSpecialty;
      final searchableText = [
        doctor.name,
        doctor.specialty,
        doctor.location,
        doctor.bio,
      ].join(' ').toLowerCase();
      return matchesSpecialty && searchableText.contains(queryLower);
    }).toList();
  }

  List<String> get _specialties {
    final Set<String> specialties = {};
    for (var doctor in doctors) {
      specialties.add(doctor.specialty);
    }
    return ['All', ...specialties.toList()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Dermatologists'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Specialty Filter
          _buildSpecialtyFilter(),
          // Search Bar
          _buildSearchBar(),
          // Doctors List
          Expanded(
            child: _filteredDoctors.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _filteredDoctors[index];
                      return DoctorCard(doctor: doctor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyFilter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _specialties.length,
        itemBuilder: (context, index) {
          final specialty = _specialties[index];
          final isSelected = specialty == _selectedSpecialty;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecialty = specialty;
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
              backgroundColor: AppColors.chip,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search doctors, specialties, or locations',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E0DC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E0DC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.muted),
          SizedBox(height: 16),
          Text(
            'No doctors found',
            style: TextStyle(fontSize: 16, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
