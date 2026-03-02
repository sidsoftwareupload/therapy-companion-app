import 'package:flutter/material.dart';

class CopingStrategiesScreen extends StatefulWidget {
  const CopingStrategiesScreen({super.key});

  @override
  State<CopingStrategiesScreen> createState() => _CopingStrategiesScreenState();
}

class _CopingStrategiesScreenState extends State<CopingStrategiesScreen> {
  final List<Map<String, dynamic>> _strategies = [
    {
      'title': '5-4-3-2-1 Grounding',
      'icon': Icons.visibility,
      'color': const Color(0xFF2E7D32),
      'steps': [
        '5 things you can SEE around you',
        '4 things you can TOUCH',
        '3 things you can HEAR',
        '2 things you can SMELL',
        '1 thing you can TASTE',
      ],
    },
    {
      'title': 'Box Breathing',
      'icon': Icons.air,
      'color': Colors.blue,
      'steps': [
        'Breathe IN for 4 seconds',
        'HOLD your breath for 4 seconds',
        'Breathe OUT for 4 seconds',
        'HOLD empty lungs for 4 seconds',
        'Repeat this cycle 4-8 times',
      ],
    },
    {
      'title': 'Progressive Muscle Relaxation',
      'icon': Icons.self_improvement,
      'color': Colors.purple,
      'steps': [
        'Start with your toes - tense for 5 seconds, then release',
        'Move to your calves - tense and release',
        'Continue with thighs, abdomen, hands, arms',
        'Finish with shoulders, neck, and face',
        'Notice the difference between tension and relaxation',
      ],
    },
    {
      'title': 'STOP Technique',
      'icon': Icons.stop,
      'color': Colors.red,
      'steps': [
        'STOP what you are doing',
        'TAKE a deep breath',
        'OBSERVE your thoughts and feelings',
        'PROCEED with awareness and intention',
      ],
    },
    {
      'title': 'Safe Place Visualization',
      'icon': Icons.home,
      'color': Colors.green,
      'steps': [
        'Close your eyes and take deep breaths',
        'Imagine a place where you feel completely safe',
        'Notice all the details - colors, sounds, smells',
        'Feel the safety and peace of this place',
        'Know you can return here anytime in your mind',
      ],
    },
    {
      'title': 'Cold Water Technique',
      'icon': Icons.water_drop,
      'color': Colors.cyan,
      'steps': [
        'Splash cold water on your face',
        'Or hold ice cubes in your hands',
        'Focus on the cold sensation',
        'This activates your dive response',
        'Helps calm your nervous system quickly',
      ],
    },
  ];

  void _showStrategyDetails(Map<String, dynamic> strategy) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                strategy['icon'],
                color: strategy['color'],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(strategy['title']),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Steps:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...strategy['steps'].asMap().entries.map<Widget>((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: strategy['color'],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coping Strategies'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF81C784).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF81C784).withOpacity(0.5),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 48,
                    color: Color(0xFF2E7D32),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Grounding Techniques',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'These techniques can help you feel more present and grounded when experiencing dissociation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _strategies.length,
              itemBuilder: (context, index) {
                final strategy = _strategies[index];
                return Card(
                  child: InkWell(
                    onTap: () => _showStrategyDetails(strategy),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: strategy['color'].withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              strategy['icon'],
                              size: 32,
                              color: strategy['color'],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            strategy['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Color(0xFF2E7D32),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Quick Tips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Remember that dissociation is temporary'),
                    _buildTip('You are safe in this moment'),
                    _buildTip('Focus on what you can control right now'),
                    _buildTip('''It\'s okay to take breaks when you need them'''),
                    _buildTip('Reach out for support when you need it'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF81C784),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
