import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/profile_service.dart';
import '../../theme.dart';

class SettingsScreen extends StatefulWidget {
  final Patient? patient;
  final bool isFirstRun;
  final ValueChanged<Patient> onSaved;

  const SettingsScreen({
    Key? key,
    required this.patient,
    required this.onSaved,
    this.isFirstRun = false,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _profileService = ProfileService();

  String _gender = 'Prefer not to say';
  String _skinType = 'Not sure';
  bool _isSaving = false;

  static const _genders = ['Prefer not to say', 'Female', 'Male', 'Non-binary'];
  static const _skinTypes = [
    'Not sure',
    'Normal',
    'Dry',
    'Oily',
    'Combination',
    'Sensitive',
  ];

  @override
  void initState() {
    super.initState();
    _setFields(widget.patient);
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient != widget.patient) _setFields(widget.patient);
  }

  void _setFields(Patient? patient) {
    if (patient == null) return;
    _nameController.text = patient.name;
    _ageController.text = patient.age == 0 ? '' : '${patient.age}';
    _allergiesController.text = patient.allergies;
    _phoneController.text = patient.phone;
    _gender = _genders.contains(patient.gender)
        ? patient.gender
        : _genders.first;
    _skinType = _skinTypes.contains(patient.skinType)
        ? patient.skinType
        : _skinTypes.first;
    _locationController.text = patient.location;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _allergiesController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final patient = Patient(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      gender: _gender,
      skinType: _skinType,
      allergies: _allergiesController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
    );
    await _profileService.saveProfile(patient);
    if (!mounted) return;
    widget.onSaved(patient);
    setState(() => _isSaving = false);
    if (!widget.isFirstRun) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved on this device')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isFirstRun,
        title: Text(
          widget.isFirstRun ? 'Set up your profile' : 'Patient Profile',
        ),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.isFirstRun) ...[
                Center(
                  child: Image.asset(
                    'assets/models/branding/dermalens_logo.png',
                    height: 84,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your details are stored only on this device and can be edited later.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 24),
              ],
              _textField(
                _nameController,
                'Full name',
                Icons.person_outline,
                required: true,
              ),
              const SizedBox(height: 14),
              _textField(
                _ageController,
                'Age',
                Icons.cake_outlined,
                required: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _dropdown(
                'Gender',
                _gender,
                _genders,
                (value) => setState(() => _gender = value!),
              ),
              const SizedBox(height: 14),
              _dropdown(
                'Skin type',
                _skinType,
                _skinTypes,
                (value) => setState(() => _skinType = value!),
              ),
              const SizedBox(height: 14),
              _textField(
                _allergiesController,
                'Allergies (optional)',
                Icons.warning_amber_outlined,
              ),
              const SizedBox(height: 14),
              _textField(
                _phoneController,
                'Phone number (optional)',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),
              const SizedBox(height: 14),
              _textField(
                _locationController,
                "Location",
                Icons.location_on_outlined,
                required: true,
              ),
              const SizedBox(height: 14),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    widget.isFirstRun ? 'Save and continue' : 'Save profile',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty))
          return 'Required';
        if (label == 'Age' && int.tryParse(value?.trim() ?? '') == null) {
          return 'Enter a valid age';
        }
        return null;
      },
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.tune),
      ),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
