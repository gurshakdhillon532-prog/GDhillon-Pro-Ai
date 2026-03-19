import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/clipboard_item.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseService._privateConstructor();
  static DatabaseService get instance => _instance ??= DatabaseService._privateConstructor();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'clipboard_manager.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clipboard_items (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0,
        category TEXT,
        charCount INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE clipboard_items ADD COLUMN category TEXT');
    }
  }

  Future<void> insertItem(ClipboardItem item) async {
    final db = await database;
    await db.insert('clipboard_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await _syncToFirestore(item);
  }

  Future<List<ClipboardItem>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clipboard_items',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => ClipboardItem.fromMap(maps[i]));
  }

  Future<List<ClipboardItem>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clipboard_items',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => ClipboardItem.fromMap(maps[i]));
  }

  Future<void> toggleFavorite(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      final item = await txn.query('clipboard_items', where: 'id = ?', whereArgs: [id]);
      if (item.isNotEmpty) {
        final isFavorite = item[0]['isFavorite'] == 1 ? 0 : 1;
        await txn.update(
          'clipboard_items',
          {'isFavorite': isFavorite},
          where: 'id = ?',
          whereArgs: [id],
        );
        await _syncFavoriteToFirestore(id, isFavorite == 1);
      }
    });
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete('clipboard_items', where: 'id = ?', whereArgs: [id]);
    await _deleteFromFirestore(id);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('clipboard_items');
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await _firestore.collection('users').doc(userId).collection('clips').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> _syncToFirestore(ClipboardItem item) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('clips')
          .doc(item.id)
          .set(item.toMap());
    }
  }

  Future<void> _syncFavoriteToFirestore(String id, bool isFavorite) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('clips')
          .doc(id)
          .update({'isFavorite': isFavorite});
    }
  }

  Future<void> _deleteFromFirestore(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('clips')
          .doc(id)
          .delete();
    }
  }

  Stream<List<ClipboardItem>> streamItems() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('clips')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClipboardItem.fromMap(doc.data()))
            .toList());
  }
}
