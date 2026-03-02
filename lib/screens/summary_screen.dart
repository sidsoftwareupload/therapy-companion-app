import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/episode.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'help_centre_screen.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<Episode> _episodes = [];
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Week', 'Month', 'Year'];

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    final episodes = await DatabaseService.instance.getEpisodes();
    setState(() {
      _episodes = episodes;
    });
  }

  List<Episode> _getFilteredEpisodes() {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return _episodes.where((episode) => episode.timestamp.isAfter(startDate)).toList();
  }

  Map<String, int> _getTriggerCounts() {
    final filtered = _getFilteredEpisodes();
    final Map<String, int> counts = {};

    for (final episode in filtered) {
      final trigger = episode.trigger ?? 'Unknown';
      counts[trigger] = (counts[trigger] ?? 0) + 1;
    }

    return counts;
  }

  Map<String, int> _getMoodCounts() {
    final filtered = _getFilteredEpisodes();
    final Map<String, int> counts = {};

    for (final episode in filtered) {
      if (episode.mood != null) {
        counts[episode.mood!] = (counts[episode.mood!] ?? 0) + 1;
      }
    }

    return counts;
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerChart() {
    final triggerCounts = _getTriggerCounts();

    if (triggerCounts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No trigger data available'),
          ),
        ),
      );
    }

    final colors = [
      const Color(0xFF2E7D32),
      const Color(0xFF81C784),
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.red,
    ];

    final sections = triggerCounts.entries.take(5).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return PieChartSectionData(
        value: data.value.toDouble(),
        title: data.value.toString(),
        color: colors[index % colors.length],
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Triggers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: triggerCounts.entries.take(5).toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: colors[index % colors.length],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data.key.length > 12
                                  ? '${data.key.substring(0, 12)}...'
                                  : data.key,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLink(BuildContext context, String title, Widget screen) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEpisodes = _getFilteredEpisodes();
    final totalEpisodes = filteredEpisodes.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [
          DropdownButton<String>(
            value: _selectedPeriod,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: _periods.map((period) {
              return DropdownMenuItem(
                value: period,
                child: Text(
                  period,
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPeriod = value!;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Header
            Text(
              'Past $_selectedPeriod Overview',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    'Total Episodes',
                    totalEpisodes.toString(),
                    Icons.record_voice_over,
                    const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Trigger Chart
            _buildTriggerChart(),

            const SizedBox(height: 16),

            // Recent Episodes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Episodes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filteredEpisodes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No episodes in selected period',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...filteredEpisodes.take(5).map((episode) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF81C784),
                            radius: 16,
                            child: Text(
                              DateFormat('dd').format(episode.timestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            episode.trigger ?? 'No trigger',
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            DateFormat('MMM dd, HH:mm').format(episode.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: episode.mood != null
                              ? Chip(
                            label: Text(
                              episode.mood!,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: const Color(0xFF81C784),
                          )
                              : null,
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App Information Links
            const Text(
              'App Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _buildInfoLink(context, 'About', const AboutScreen()),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoLink(context, 'Privacy Policy', const PrivacyPolicyScreen()),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoLink(context, 'Terms of Service', const TermsOfServiceScreen()),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoLink(context, 'Help Centre', const HelpCentreScreen()),
                ],
              ),
            ),
            const SizedBox(height: 16), // Added some padding at the very bottom
          ],
        ),
      ),
    );
  }
}
