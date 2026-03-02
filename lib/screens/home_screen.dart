// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:therapy_companion/models/episode.dart';
import 'package:therapy_companion/models/trigger.dart';
import 'package:therapy_companion/screens/ai_second_opinion_screen.dart';
import 'package:therapy_companion/screens/coping_strategies_screen.dart';
import 'package:therapy_companion/screens/history_screen.dart';
import 'package:therapy_companion/screens/summary_screen.dart';
import 'package:therapy_companion/screens/trigger_management_screen.dart';
import 'package:therapy_companion/services/database_service.dart';
import 'package:therapy_companion/utils/web_prompt.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  List<Trigger> _triggers = [];
  bool _isRecording = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    showAddToHomeScreenPrompt(context);
    _loadTriggers();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTriggers() async {
    final triggers = await DatabaseService.instance.getTriggers();
    setState(() {
      _triggers = triggers;
    });
  }

  Future<void> _recordEpisode() async {
    await _loadTriggers(); // Reload triggers before showing the dialog

    if (!mounted) return; // Ensure the widget is still in the tree

    setState(() {
      _isRecording = true;
    });

    // Clear previous notes
    _notesController.clear();

    // Show trigger selection dialog
    final selectedTrigger = await showDialog<Trigger>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Trigger (Optional)'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              children: [
                ListTile(
                  title: const Text('No specific trigger'),
                  subtitle: const Text('Record episode without trigger'),
                  leading: const Icon(Icons.help_outline),
                  onTap: () => Navigator.of(context).pop(null),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _triggers.length,
                    itemBuilder: (context, index) {
                      final trigger = _triggers[index];
                      return ListTile(
                        title: Text(trigger.name),
                        subtitle: Text(trigger.category ?? ''),
                        leading: CircleAvatar(
                          backgroundColor: trigger.color ?? Colors.grey,
                          // Ensure trigger.name is not empty before accessing index 0
                          child: Text(trigger.name.isNotEmpty ? trigger.name[0].toUpperCase() : '?'),
                        ),
                        onTap: () => Navigator.of(context).pop(trigger),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return; // Check if the widget is still mounted after async gap

    // After selecting a trigger, show affirmation and notes dialog
    await _showAffirmationAndSaveNotes(selectedTrigger);

    if (!mounted) return; // Check again

    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _showAffirmationAndSaveNotes(Trigger? trigger) async {
    final affirmation = trigger?.affirmation;

    // This will resolve when the dialog is popped
    final bool episodeSaved = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.favorite, color: Colors.red[400]),
              const SizedBox(width: 8),
              const Text('Your Affirmation'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (affirmation != null && affirmation.isNotEmpty) ...[
                Text(
                  affirmation,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 20),
              ],
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes for Therapist',
                  hintText: 'Add any details here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final episode = Episode(
                  timestamp: DateTime.now(),
                  trigger: trigger?.name,
                  affirmation: trigger?.affirmation,
                  notes: _notesController.text,
                );
                await DatabaseService.instance.insertEpisode(episode);
                Navigator.of(context).pop(true); // Pop with success status
              },
              child: const Text('Save Episode'),
            ),
          ],
        );
      },
    ) ?? false; // If dialog is dismissed, default to false

    if (episodeSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Episode recorded successfully'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  Widget _buildHomeContent() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2E7D32),
                      const Color(0xFF81C784).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Therapy Companion',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You are not alone in this journey',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Central Recording Button
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: GestureDetector(
                              onTap: _isRecording ? null : _recordEpisode,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: _isRecording
                                        ? [Colors.grey, Colors.grey[400]!]
                                        : [
                                      const Color(0xFF2E7D32),
                                      const Color(0xFF81C784),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2E7D32).withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isRecording ? Icons.hourglass_empty : Icons.record_voice_over,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isRecording ? 'Recording...' : 'Record Episode',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Tap to record a dissociation episode',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 3;
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.self_improvement, color: Color(0xFF2E7D32)),
                              SizedBox(height: 8),
                              Text('Coping Strategies'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 4;
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.analytics, color: Color(0xFF2E7D32)),
                              SizedBox(height: 8),
                              Text('Summary'), // Changed from Dashboard
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeContent(),
      const TriggerManagementScreen(),
      const HistoryScreen(),
      const CopingStrategiesScreen(),
      const SummaryScreen(), // Changed from DashboardScreen
      const AiSecondOpinionScreen(),
    ];

    return SafeArea(
      child: Scaffold(
        body: screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Triggers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology),
              label: 'Coping',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), // Icon can remain dashboard, or you can suggest a change
              label: 'Summary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_alt),
              label: 'AI',
            ),
          ],
        ),
      ),
    );
  }
}
