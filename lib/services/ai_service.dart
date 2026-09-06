import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';

import '../models.dart';

/// Service for handling AI model inference for skin disease classification
class AiService {
  static const _modelPath = 'assets/models/skin_efficientnet_b4.onnx';
  static const _inputSize = 380; // EfficientNet-B4 input size
  static final List<String> _classIds = [
    'Acne',
    'Actinic_Keratosis',
    'Benign_tumors',
    'Bullous',
    'Candidiasis',
    'DrugEruption',
    'Eczema',
    'Infestations_Bites',
    'Lichen',
    'Lupus',
    'Moles',
    'Psoriasis',
    'Rosacea',
    'Seborrh_Keratoses',
    'SkinCancer',
    'Sun_Sunlight_Damage',
    'Tinea',
    'Unknown_Normal',
    'Vascular_Tumors',
    'Vasculitis',
    'Vitiligo',
    'Warts',
  ];

  OrtSession? _session;
  bool _isInitialized = false;

  /// Initialize the ONNX model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load model from assets
      final modelData = await rootBundle.load(_modelPath);

      // Create inference session
      OrtEnv.instance.init();
      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromBuffer(
        modelData.buffer.asUint8List(),
        sessionOptions,
      );

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize AI model: $e');
    }
  }

  /// Decode the image and create the NCHW tensor expected by the ONNX model.
  Float32List _preprocessImage(Uint8List imageBytes) {
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      throw Exception('The selected file is not a supported image.');
    }

    final resizedImage = img.copyResize(
      decodedImage,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );
    final planeSize = _inputSize * _inputSize;
    final tensor = Float32List(3 * planeSize);
    const mean = [0.485, 0.456, 0.406];
    const standardDeviation = [0.229, 0.224, 0.225];

    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final offset = y * _inputSize + x;
        final channels = [pixel.r, pixel.g, pixel.b];
        for (var channel = 0; channel < 3; channel++) {
          final normalized = channels[channel] / 255.0;
          tensor[channel * planeSize + offset] =
              (normalized - mean[channel]) / standardDeviation[channel];
        }
      }
    }
    return tensor;
  }

  /// Run inference on an image
  Future<List<ScanResult>> analyzeImage(
    Uint8List imageBytes, {
    String? imagePath,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_session == null) {
      throw Exception('AI session not initialized');
    }

    try {
      // Preprocess image
      final inputTensor = _preprocessImage(imageBytes);

      // Create input tensor
      final inputTensorOrtValue = OrtValueTensor.createTensorWithDataList(
        inputTensor,
        [1, 3, _inputSize, _inputSize],
      );

      // Run inference
      final runOptions = OrtRunOptions();
      final outputs = _session!.run(
        runOptions,
        {_session!.inputNames.first: inputTensorOrtValue},
        [_session!.outputNames.first],
      );

      // Process outputs
      final outputTensor = outputs.first;
      final values = _flattenNumericTensor(outputTensor?.value);
      if (values.isEmpty) {
        throw Exception('Model output is not a numeric tensor');
      }

      // Apply softmax to get probabilities
      final probabilities = _softmax(values);

      // Get top 3 predictions
      final top3 = _getTopKPredictions(probabilities, 3);

      // Convert to ScanResult objects
      final results = <ScanResult>[];
      final now = DateTime.now();

      for (final prediction in top3) {
        final classIndex = prediction.index;
        final confidence = prediction.value;

        if (classIndex < _classIds.length) {
          final diseaseId = _classIds[classIndex];
          final displayName = _getDisplayName(diseaseId);

          results.add(
            ScanResult(
              labelId: diseaseId,
              displayName: displayName,
              confidence: confidence,
              imagePath: imagePath ?? '',
              at: now,
            ),
          );
        }
      }

      inputTensorOrtValue.release();
      runOptions.release();
      for (final output in outputs) {
        output?.release();
      }
      return results;
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  List<num> _flattenNumericTensor(Object? value) {
    if (value is num) return [value];
    if (value is Iterable) {
      return value.expand(_flattenNumericTensor).toList();
    }
    return [];
  }

  /// Apply softmax to convert logits to probabilities
  List<double> _softmax(List<num> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final expLogs = logits.map((e) => math.exp(e - maxLogit)).toList();
    final sumExp = expLogs.reduce((a, b) => a + b);
    return expLogs.map((e) => e / sumExp).toList();
  }

  /// Get top K predictions with their indices and values
  List<_Prediction> _getTopKPredictions(List<double> probabilities, int k) {
    final indexedProbs = probabilities.asMap().entries.map((entry) {
      return _Prediction(entry.key, entry.value);
    }).toList();

    indexedProbs.sort((a, b) => b.value.compareTo(a.value));
    return indexedProbs.take(k).toList();
  }

  /// Get display name for disease ID
  String _getDisplayName(String diseaseId) {
    return diseaseId;
  }

  /// Dispose resources
  void dispose() {
    _session?.release();
    _session = null;
    _isInitialized = false;
  }
}

/// Helper class for storing predictions with indices
class _Prediction {
  final int index;
  final double value;

  _Prediction(this.index, this.value);
}
