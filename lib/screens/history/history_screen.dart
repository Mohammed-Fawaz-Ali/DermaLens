import 'dart:io';

import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models.dart';
import '../../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  final int refreshToken;

  const HistoryScreen({Key? key, this.refreshToken = 0}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<ScanHistoryItem> _history = [];
  bool _isLoading = true;

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _loadHistory();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.loadHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    await _historyService.clearHistory();
    if (mounted) {
      setState(() => _history = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _showClearConfirmation(context),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_history.isEmpty) {
      return const Center(
        child: Text(
          'No scans saved yet.\nComplete a skin analysis to see it here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) => _buildHistoryCard(_history[index]),
    );
  }

  Widget _buildHistoryCard(ScanHistoryItem item) {
    final primary = item.primaryResult;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(item.imagePath),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(item.timestamp)}  |  ${item.results.length} predictions',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  ...item.results.take(3).map(
                        (result) => Text(
                          '${result.displayName}: ${(result.confidence * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(color: AppColors.text),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String imagePath) {
    if (imagePath.isEmpty) {
      return _thumbnailPlaceholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(imagePath),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _thumbnailPlaceholder(),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.chip,
      child: const Icon(Icons.image_outlined, color: AppColors.muted),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day}/${localDate.month}/${localDate.year} '
        '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showClearConfirmation(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear scan history?'),
        content: const Text('This will remove all saved scans from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (shouldClear == true) await _clearHistory();
  }
}
