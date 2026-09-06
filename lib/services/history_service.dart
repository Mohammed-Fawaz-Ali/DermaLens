import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class HistoryService {
  static const _historyKey = 'scan_history';

  Future<List<ScanHistoryItem>> loadHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedItems = preferences.getStringList(_historyKey) ?? [];
    final history = <ScanHistoryItem>[];

    for (final encodedItem in encodedItems) {
      try {
        history.add(
          ScanHistoryItem.fromJson(
            jsonDecode(encodedItem) as Map<String, dynamic>,
          ),
        );
      } catch (_) {
        // Ignore malformed records so one damaged scan does not hide all history.
      }
    }

    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history;
  }

  Future<void> saveScan({
    required String imagePath,
    required List<ScanResult> results,
  }) async {
    if (results.isEmpty) return;

    final savedImagePath = await _copyImageToAppStorage(imagePath);
    final item = ScanHistoryItem(
      timestamp: DateTime.now(),
      imagePath: savedImagePath,
      results: results,
      primaryResult: results.first,
    );

    final preferences = await SharedPreferences.getInstance();
    final encodedItems = preferences.getStringList(_historyKey) ?? [];
    encodedItems.insert(0, jsonEncode(item.toJson()));
    await preferences.setStringList(_historyKey, encodedItems);
  }

  Future<void> clearHistory() async {
    final history = await loadHistory();
    for (final item in history) {
      final imageFile = File(item.imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_historyKey);
  }

  Future<String> _copyImageToAppStorage(String imagePath) async {
    final source = File(imagePath);
    if (!await source.exists()) return imagePath;

    final directory = await getApplicationDocumentsDirectory();
    final scansDirectory = Directory(path.join(directory.path, 'scans'));
    await scansDirectory.create(recursive: true);

    final extension = path.extension(imagePath).isEmpty
        ? '.jpg'
        : path.extension(imagePath);
    final destination = path.join(
      scansDirectory.path,
      'scan_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    return (await source.copy(destination)).path;
  }
}
