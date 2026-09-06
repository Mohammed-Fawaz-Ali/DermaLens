import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/ai_service.dart';
import '../../services/history_service.dart';
import '../../models.dart';
import '../../theme.dart';

import 'dart:io';

class ScanScreen extends StatefulWidget {
  final VoidCallback? onScanSaved;

  const ScanScreen({Key? key, this.onScanSaved}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final AiService _aiService = AiService();
  final HistoryService _historyService = HistoryService();
  final ImagePicker _picker = ImagePicker();

  List<ScanResult> _results = [];
  bool _isAnalyzing = false;
  bool _isInitialized = false;
  String? _errorMessage;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeAiService();
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }

  Future<void> _initializeAiService() async {
    try {
      await _aiService.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize AI model: $e';
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final permission = source == ImageSource.camera
          ? Permission.camera
          : Permission.photos;
      final permissionStatus = await permission.request();
      if (!permissionStatus.isGranted) {
        if (mounted) {
          setState(() {
            _errorMessage = source == ImageSource.camera
                ? 'Camera permission is required to take a photo.'
                : 'Photo permission is required to choose an image.';
          });
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
          _results = [];
          _errorMessage = null;
          _isAnalyzing = true;
        });

        if (!_isInitialized) {
          throw Exception('The AI model is still loading. Please try again.');
        }

        final imageBytes = await image.readAsBytes();
        final results = await _aiService.analyzeImage(
          imageBytes,
          imagePath: image.path,
        );
        if (results.length < 3) {
          throw Exception('The model returned fewer than 3 predictions.');
        }

        await _historyService.saveScan(imagePath: image.path, results: results);
        widget.onScanSaved?.call();

        if (mounted) {
          setState(() {
            _results = results;
            _isAnalyzing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'Failed to analyze image: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Analysis'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image Preview
              _selectedImage == null
                  ? _buildImagePlaceholder()
                  : _buildImagePreview(),

              const SizedBox(height: 20),

              // Action Buttons
              _buildActionButtons(),

              const SizedBox(height: 20),

              // Loading / Error / Results
              if (_isAnalyzing)
                _buildLoadingIndicator()
              else if (_errorMessage != null)
                _buildErrorMessage()
              else if (_results.isNotEmpty)
                _buildResults()
              else
                _buildInstructions(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 300,
      color: AppColors.chip,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            'Tap to add an image',
            style: TextStyle(color: AppColors.muted, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(_selectedImage!.path)),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          Icons.camera_alt,
          'Take Photo',
          () => _pickImage(ImageSource.camera),
        ),
        _buildActionButton(
          Icons.photo_library,
          'Choose from Gallery',
          () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: _isAnalyzing ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Analyzing image...',
            style: TextStyle(color: AppColors.text, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        _errorMessage ?? '',
        style: TextStyle(color: AppColors.danger, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Analysis Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final result = _results[index];
            return ListTile(
              title: Text(result.displayName),
              subtitle: Text(
                'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(fontSize: 16, color: AppColors.muted),
          children: [
            TextSpan(
              text: 'Select an image using the buttons above to begin skin analysis.\n\n',
            ),
            TextSpan(
              text: 'The AI model will provide educational insights about potential skin conditions.\n\n',
            ),
            TextSpan(
              text: 'Remember: This is for educational purposes only. Always consult a healthcare professional for medical advice.',
              style: TextStyle(color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }
}
