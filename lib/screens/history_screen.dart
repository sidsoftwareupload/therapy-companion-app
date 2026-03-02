// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../services/database_service.dart';
import '../models/episode.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Episode> _episodes = [];
  List<Episode> _filteredEpisodes = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
    _searchController.addListener(() {
      _filterEpisodes(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEpisodes() async {
    final episodes = await DatabaseService.instance.getEpisodes();
    setState(() {
      _episodes = episodes;
      _filterEpisodes(_searchQuery); // Apply current search query
    });
  }

  void _filterEpisodes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredEpisodes = _episodes;
      } else {
        _filteredEpisodes = _episodes
            .where((episode) =>
                (episode.trigger?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (episode.notes?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      initialDateRange: _selectedDateRange ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<String?> _generateCsvData() async {
    List<Episode> episodesToExport;
    if (_selectedDateRange != null) {
      episodesToExport = _episodes.where((episode) {
        final episodeDate = DateTime(episode.timestamp.year, episode.timestamp.month, episode.timestamp.day);
        final startDate = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final endDate = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day);
        return !episodeDate.isBefore(startDate) && !episodeDate.isAfter(endDate);
      }).toList();
    } else {
      episodesToExport = List.from(_episodes); // Export all if no range selected
    }

    if (episodesToExport.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export for the selected range or in total')),
        );
      }
      return null;
    }

    List<List<dynamic>> csvData = [
      ['Date', 'Time', 'Trigger', 'Affirmation', 'Notes'],
    ];

    for (final episode in episodesToExport) {
      csvData.add([
        DateFormat('yyyy-MM-dd').format(episode.timestamp),
        DateFormat('HH:mm:ss').format(episode.timestamp),
        episode.trigger ?? '',
        episode.affirmation ?? '',
        episode.notes ?? '',
      ]);
    }
    return const ListToCsvConverter().convert(csvData);
  }

  Future<void> _shareCsvFile(String csvData) async {
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/therapy_companion_export.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'Therapy Companion Episode Data',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing CSV: $e')),
        );
      }
    }
  }

  Future<void> _saveCsvFile(String csvData) async {
    try {
      Uint8List bytes = Uint8List.fromList(utf8.encode(csvData));
      await FileSaver.instance.saveFile(
        name: "therapy_data",
        bytes: bytes,
        ext: "csv",
        mimeType: MimeType.csv,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV saved successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving CSV: $e')),
        );
      }
    }
  }

  Future<void> _showExportOptionsDialog() async {
    final csvData = await _generateCsvData();
    if (csvData == null) return; 

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Options'),
          content: const Text('Choose how you want to export the CSV data.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Share'),
              onPressed: () {
                Navigator.of(context).pop();
                _shareCsvFile(csvData);
              },
            ),
            TextButton(
              child: const Text('Save to Device'),
              onPressed: () {
                Navigator.of(context).pop();
                _saveCsvFile(csvData);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEpisode(Episode episode) async {
    if (episode.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Episode ID is missing.')),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Episode'),
          content: const Text('Are you sure you want to delete this episode? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DatabaseService.instance.deleteEpisode(episode.id!);
      _loadEpisodes(); // Reload episodes to reflect the deletion
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Episode deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Episode History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _showExportOptionsDialog, 
            tooltip: 'Export Data',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedDateRange == null
                        ? 'Exporting: All Data'
                        : 'Range: ${DateFormat('MM/dd/yy').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd/yy').format(_selectedDateRange!.end)}',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectDateRange,
                  child: const Text('Select Range'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search episodes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _filteredEpisodes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _episodes.isEmpty ? Icons.history : Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _episodes.isEmpty
                              ? 'No episodes recorded yet'
                              : (_searchQuery.isNotEmpty ? 'No episodes match your search' : 'No episodes recorded yet'),
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        if (_episodes.isEmpty && _searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Record your first episode from the home screen',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredEpisodes.length,
                    itemBuilder: (context, index) {
                      final episode = _filteredEpisodes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2E7D32),
                            child: Text(
                              DateFormat('dd').format(episode.timestamp),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            episode.trigger ?? 'No trigger specified',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            DateFormat('MMM dd, yyyy - HH:mm').format(episode.timestamp),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                           trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                            tooltip: 'Delete Episode',
                            onPressed: () {
                              _deleteEpisode(episode);
                            },
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (episode.affirmation != null && episode.affirmation!.isNotEmpty) ...[
                                    const Text(
                                      'Affirmation:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(episode.affirmation!),
                                    const SizedBox(height: 12),
                                  ],
                                  if (episode.mood != null && episode.mood!.isNotEmpty) ...[
                                    Text(
                                      'Mood: ${episode.mood}',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  if (episode.sleepHours != null) ...[
                                    Text(
                                      'Sleep: ${episode.sleepHours} hours',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  if (episode.notes != null && episode.notes!.isNotEmpty) ...[
                                    const Text(
                                      'Notes:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(episode.notes!),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
