// lib/screens/trigger_management_screen.dart
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/trigger.dart';

class TriggerManagementScreen extends StatefulWidget {
  const TriggerManagementScreen({super.key});

  @override
  State<TriggerManagementScreen> createState() => _TriggerManagementScreenState();
}

class _TriggerManagementScreenState extends State<TriggerManagementScreen> {
  List<Trigger> _triggers = [];
  final List<String> _categories = ['Work', 'Social', 'Health', 'Family', 'Emotional', 'Other'];
  final List<Color> _colors = [
    Colors.red[300]!,
    Colors.blue[300]!,
    Colors.green[300]!,
    Colors.orange[300]!,
    Colors.purple[300]!,
    Colors.teal[300]!,
  ];

  @override
  void initState() {
    super.initState();
    _loadTriggers();
  }

  Future<void> _loadTriggers() async {
    final triggers = await DatabaseService.instance.getTriggers();
    setState(() {
      _triggers = triggers;
    });
  }

  Future<void> _showAddEditDialog([Trigger? trigger]) async {
    final nameController = TextEditingController(text: trigger?.name ?? '');
    final affirmationController = TextEditingController(text: trigger?.affirmation ?? '');
    String selectedCategory = trigger?.category ?? _categories[0];
    Color selectedColor = trigger?.color ?? _colors[0];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(trigger == null ? 'Add Trigger' : 'Edit Trigger'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView( // Added SingleChildScrollView here
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Trigger Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: affirmationController,
                        decoration: const InputDecoration(
                          labelText: 'Personal Affirmation',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Color:'),
                      Wrap(
                        spacing: 8,
                        children: _colors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color ? Colors.black : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && affirmationController.text.isNotEmpty) {
                      Navigator.of(context).pop({
                        'name': nameController.text,
                        'affirmation': affirmationController.text,
                        'category': selectedCategory,
                        'color': selectedColor,
                      });
                    }
                  },
                  child: Text(trigger == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final newTrigger = Trigger(
        id: trigger?.id,
        name: result['name'],
        affirmation: result['affirmation'],
        category: result['category'],
        color: result['color'],
      );

      if (trigger == null) {
        await DatabaseService.instance.insertTrigger(newTrigger);
      } else {
        await DatabaseService.instance.updateTrigger(newTrigger);
      }

      _loadTriggers();
    }
  }

  Future<void> _deleteTrigger(Trigger trigger) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Trigger'),
          content: Text('Are you sure you want to delete "${trigger.name}"?'),
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

    if (confirm == true && trigger.id != null) {
      await DatabaseService.instance.deleteTrigger(trigger.id!);
      _loadTriggers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Triggers and Affirmations'), // Changed title here
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: _triggers.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No triggers yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first trigger',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _triggers.length,
              itemBuilder: (context, index) {
                final trigger = _triggers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: trigger.color ?? Colors.grey,
                      child: Text(
                        trigger.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      trigger.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (trigger.category != null)
                          Text(
                            trigger.category!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          trigger.affirmation,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showAddEditDialog(trigger);
                        } else if (value == 'delete') {
                          _deleteTrigger(trigger);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
