import 'package:flutter/material.dart'; // Added import

class Trigger {
  final int? id;
  final String name;
  final String affirmation;
  final String? category;
  final Color? color;

  Trigger({
    this.id,
    required this.name,
    required this.affirmation,
    this.category,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'affirmation': affirmation,
      'category': category,
      'color': color?.value,
    };
  }

  factory Trigger.fromMap(Map<String, dynamic> map) {
    return Trigger(
      id: map['id'],
      name: map['name'],
      affirmation: map['affirmation'],
      category: map['category'],
      color: map['color'] != null ? Color(map['color']) : null,
    );
  }
}
