import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_saver/file_saver.dart';
import 'package:csv/csv.dart';

import '../models/episode.dart';
import '../models/trigger.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  // 🔹 Initialize the correct database for each platform
  Future<void> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
      await Hive.openBox('episodes');
      final triggersBox = await Hive.openBox('triggers');

      if (triggersBox.isEmpty) {
        await _createDefaultTriggersForWeb(triggersBox);
      } else {
        // Migration for existing web users who might not have trigger colors
        final firstTriggerMap =
            Map<String, dynamic>.from(triggersBox.get(triggersBox.keys.first));
        if (firstTriggerMap['color'] == null) {
          await _migrateTriggersForWeb(triggersBox);
        }
      }
    } else {
      await database;
    }
  }

  Future<void> _migrateTriggersForWeb(Box box) async {
    final defaultColors = {
      'Work Stress': Colors.orange,
      'Social Anxiety': Colors.blue,
      'Overwhelming Emotions': Colors.purple,
    };

    for (var key in box.keys) {
      final value = box.get(key);
      final map = Map<String, dynamic>.from(value);
      if (defaultColors.containsKey(map['name']) && map['color'] == null) {
        final newColor = defaultColors[map['name']];
        map['color'] = newColor?.value;
        await box.put(key, map);
      }
    }
  }

  Future<void> _createDefaultTriggersForWeb(Box box) async {
    await box.add(Trigger(
            name: 'Work Stress',
            affirmation:
                'I am capable and resilient. This feeling will pass, and I am safe.',
            category: 'Work',
            color: Colors.orange)
        .toMap());
    await box.add(Trigger(
            name: 'Social Anxiety',
            affirmation:
                'I belong here. I am worthy of connection and understanding.',
            category: 'Social',
            color: Colors.blue)
        .toMap());
    await box.add(Trigger(
            name: 'Overwhelming Emotions',
            affirmation:
                'My feelings are valid. I can breathe through this moment.',
            category: 'Emotional',
            color: Colors.purple)
        .toMap());
  }

  // ---------------------- -
  // 🔹 SQLite (Android/iOS)
  // ---------------------- -
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('therapy_companion.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE episodes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        trigger TEXT,
        affirmation TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE triggers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        affirmation TEXT NOT NULL,
        category TEXT,
        color INTEGER
      )
    ''');

    // Default triggers
    await db.insert('triggers', {
      'name': 'Work Stress',
      'affirmation':
          'I am capable and resilient. This feeling will pass, and I am safe.',
      'category': 'Work',
      'color': Colors.orange.value,
    });

    await db.insert('triggers', {
      'name': 'Social Anxiety',
      'affirmation':
          'I belong here. I am worthy of connection and understanding.',
      'category': 'Social',
      'color': Colors.blue.value,
    });

    await db.insert('triggers', {
      'name': 'Overwhelming Emotions',
      'affirmation':
          'My feelings are valid. I can breathe through this moment.',
      'category': 'Emotional',
      'color': Colors.purple.value,
    });
  }

  // ---------------------- -
  // 🔹 Episodes CRUD
  // ---------------------- -
  Future<int> insertEpisode(Episode episode) async {
    if (kIsWeb) {
      var box = Hive.box('episodes');
      return await box.add(episode.toMap());
    } else {
      final db = await instance.database;
      return await db.insert('episodes', episode.toMap());
    }
  }

  Future<List<Episode>> getEpisodes() async {
    if (kIsWeb) {
      var box = Hive.box('episodes');
      final episodes = box.keys.map((key) {
        final value = box.get(key);
        final map = Map<String, dynamic>.from(value);
        map['id'] = key; // Use the Hive key as the ID
        return Episode.fromMap(map);
      }).toList();
      // Sort episodes by timestamp descending
      episodes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return episodes;
    } else {
      final db = await instance.database;
      final result = await db.query('episodes', orderBy: 'timestamp DESC');
      return result.map((map) => Episode.fromMap(map)).toList();
    }
  }

  Future<int> deleteEpisode(int id) async {
    if (kIsWeb) {
      var box = Hive.box('episodes');
      await box.delete(id); // Use the key to delete
      return id;
    } else {
      final db = await instance.database;
      return await db.delete('episodes', where: 'id = ?', whereArgs: [id]);
    }
  }

  // ---------------------- -
  // 🔹 Triggers CRUD
  // ---------------------- -
  Future<int> insertTrigger(Trigger trigger) async {
    if (kIsWeb) {
      var box = Hive.box('triggers');
      return await box.add(trigger.toMap());
    } else {
      final db = await instance.database;
      return await db.insert('triggers', trigger.toMap());
    }
  }

  Future<List<Trigger>> getTriggers() async {
    if (kIsWeb) {
      var box = Hive.box('triggers');
      final triggers = box.keys.map((key) {
        final value = box.get(key);
        final map = Map<String, dynamic>.from(value);
        map['id'] = key; // Use the Hive key as the ID
        return Trigger.fromMap(map);
      }).toList();
      // Sort triggers by name ascending
      triggers.sort((a, b) => a.name.compareTo(b.name));
      return triggers;
    } else {
      final db = await instance.database;
      final result = await db.query('triggers', orderBy: 'name ASC');
      return result.map((map) => Trigger.fromMap(map)).toList();
    }
  }

  Future<int> updateTrigger(Trigger trigger) async {
    if (kIsWeb) {
      var box = Hive.box('triggers');
      // trigger.id is now the Hive key, so this works correctly
      if (trigger.id != null) {
        await box.put(trigger.id, trigger.toMap());
        return trigger.id!;
      }
      return 0;
    } else {
      final db = await instance.database;
      return await db.update(
        'triggers',
        trigger.toMap(),
        where: 'id = ?',
        whereArgs: [trigger.id],
      );
    }
  }

  Future<int> deleteTrigger(int id) async {
    if (kIsWeb) {
      var box = Hive.box('triggers');
      await box.delete(id); // Use the key to delete
      return id;
    } else {
      final db = await instance.database;
      return await db.delete('triggers', where: 'id = ?', whereArgs: [id]);
    }
  }

  // ---------------------- -
  // 🔹 Export to CSV
  // ---------------------- -
  Future<void> exportToCSV() async {
    final episodes = await getEpisodes();
    List<List<dynamic>> rows = [
      ["Date", "Trigger", "Affirmation", "Notes"]
    ];

    for (var e in episodes) {
      rows.add([
        e.timestamp,
        e.trigger,
        e.affirmation,
        e.notes,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    Uint8List bytes = Uint8List.fromList(utf8.encode(csvData));

    await FileSaver.instance.saveFile(
      name: "therapy_data",
      bytes: bytes,
      mimeType: MimeType.csv,
    );
  }

  // ---------------------- -
  // 🔹 Close DB
  // ---------------------- -
  Future close() async {
    if (!kIsWeb) {
      final db = await instance.database;
      db.close();
    }
  }
}
