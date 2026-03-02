class Episode {
  final int? id;
  final DateTime timestamp;
  final String? trigger;
  final String? affirmation;
  final String? mood;
  final double? sleepHours;
  final String? notes;

  Episode({
    this.id,
    required this.timestamp,
    this.trigger,
    this.affirmation,
    this.mood,
    this.sleepHours,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'trigger': trigger,
      'affirmation': affirmation,
      'mood': mood,
      'sleep_hours': sleepHours,
      'notes': notes,
    };
  }

  factory Episode.fromMap(Map<String, dynamic> map) {
    return Episode(
      id: map['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      trigger: map['trigger'],
      affirmation: map['affirmation'],
      mood: map['mood'],
      sleepHours: map['sleep_hours']?.toDouble(),
      notes: map['notes'],
    );
  }
}