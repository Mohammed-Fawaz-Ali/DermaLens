import 'package:flutter/material.dart';

import '../../models.dart';
import '../../data/doctors.dart';
import '../../services/doctors_service.dart';
import '../../theme.dart';
import '../../widgets/doctor_card.dart';

class DoctorsScreen extends StatefulWidget {
  final Patient? patient;

  const DoctorsScreen({Key? key, this.patient}) : super(key: key);

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  late final DoctorsService _doctorsService;
  List<Doctor> _nearbyDoctors = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _doctorsService = DoctorsService(allDoctors: doctors);
    _loadNearbyDoctors();
  }

  @override
  void didUpdateWidget(covariant DoctorsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient?.location != widget.patient?.location) {
      _loadNearbyDoctors();
    }
  }

  Future<void> _loadNearbyDoctors() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final location = widget.patient?.location ?? '';
      final results = await _doctorsService.fetchNearbyDoctors(location);
      if (!mounted) return;
      setState(() {
        _nearbyDoctors = results;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      setState(() {
        _nearbyDoctors = [];
        _loadError = message.isEmpty
            ? 'No live clinic results found for this location.'
            : message;
        _isLoading = false;
      });
    }
  }

  List<Doctor> get _filteredDoctors {
    final queryLower = _searchQuery.trim().toLowerCase();

    // Get nearby doctors based on user location, or all doctors if no location
    return _nearbyDoctors.where((doctor) {
      final matchesSpecialty =
          _selectedSpecialty == 'All' || doctor.specialty == _selectedSpecialty;
      final searchableText = [
        doctor.name,
        doctor.clinic,
        doctor.specialty,
        doctor.location,
        doctor.bio,
      ].join(' ').toLowerCase();
      return matchesSpecialty && searchableText.contains(queryLower);
    }).toList();
  }

  List<String> get _specialties {
    final Set<String> specialties = {};
    for (var doctor in _nearbyDoctors) {
      specialties.add(doctor.specialty);
    }
    return ['All', ...specialties.toList()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.patient?.location.isNotEmpty == true
            ? Text('Find Dermatologists Near ${widget.patient!.location}')
            : const Text('Find Dermatologists'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_loadError != null)
            MaterialBanner(
              content: Text(_loadError!),
              actions: [
                TextButton(
                  onPressed: _loadNearbyDoctors,
                  child: const Text('Retry'),
                ),
              ],
            ),
          // Specialty Filter
          _buildSpecialtyFilter(),
          // Search Bar
          _buildSearchBar(),
          // Doctors List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
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
