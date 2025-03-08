import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';


class ThemeD {
  final int id;
  final String title;
  final String themeCode;
  final String term;
  final String classTaught;
  final String date_created;

  ThemeD({
    required this.id,
    required this.title,
    required this.themeCode,
    required this.term,
    required this.classTaught,
    required this.date_created,
  });

  Map<String, dynamic> toMap(){
    return {
    'id':id,
    'title':title,
    'themeCode':themeCode,
    'term':term,
    'classTaught':classTaught,
    'date_created':date_created,
    };
  }

  factory ThemeD.fromMap(Map<String, dynamic> map){
    return ThemeD(
      id: map['id'],
      title: map['title'],
      themeCode: map['themeCode'],
      term: map['term'],
      classTaught: map['classTaught'],
      date_created: map['date_created'],
    );
  }

}

class SubThemeD {
  final int id;
  final String title;
  final int themeId; // Foreign key reference to Theme
  final int? duration;
  final String learningOutcome;
  final String practicleProject;
  final String dateCreated;

  SubThemeD({
    required this.id,
    required this.title,
    required this.themeId,
    this.duration,
    required this.learningOutcome,
    required this.practicleProject,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'themeId': themeId,
      'duration': duration,
      'learningOutcome': learningOutcome,
      'practicleProject': practicleProject,
      'dateCreated': dateCreated,
    };
  }

  factory SubThemeD.fromMap(Map<String, dynamic> map) {
    return SubThemeD(
      id: map['id'],
      title: map['title'],
      themeId: map['themeId'],
      duration: map['duration'],
      learningOutcome: map['learningOutcome'],
      practicleProject: map['practicleProject'],
      dateCreated: map['dateCreated'],
    );
  }
}

class Chapter {
  final int id;
  final String title;
  final int subThemeId; // Foreign key reference to SubTheme
  final String? articlePath;
  final String dateCreated;

  Chapter({
    required this.id,
    required this.title,
    required this.subThemeId,
    this.articlePath,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subThemeId': subThemeId,
      'articlePath': articlePath,
      'dateCreated': dateCreated,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'],
      title: map['title'],
      subThemeId: map['subThemeId'],
      articlePath: map['articlePath'],
      dateCreated: map['dateCreated'],
    );
  }
}


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();


  Future<void> initDatabase() async {
    // initialize the database
    WidgetsFlutterBinding.ensureInitialized();
    _database = await openDatabase(
      join(await getDatabasesPath(), 'dear_day8.db'),
      onCreate: (db, version){
        db.execute('''
          CREATE TABLE themes (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            themeCode TEXT NOT NULL,
            term TEXT NOT NULL,
            classTaught TEXT NOT NULL,
            date_created TEXT NOT NULL
          )
        ''');

        db.execute('''
          CREATE TABLE sub_themes (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            themeId INTEGER NOT NULL,
            duration INTEGER,
            learningOutcome TEXT NOT NULL,
            practicleProject TEXT NOT NULL,
            dateCreated TEXT NOT NULL,
            FOREIGN KEY (themeId) REFERENCES themes (id) ON DELETE CASCADE
          )
        ''');

        db.execute('''
          CREATE TABLE chapters (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            subThemeId INTEGER NOT NULL,
            articlePath TEXT,
            dateCreated TEXT NOT NULL,
            FOREIGN KEY (subThemeId) REFERENCES sub_themes (id) ON DELETE CASCADE
          )
        ''');
      },
      version: 2,
    );
  }

  /// Insert a theme
  Future<int> insertTheme(ThemeD theme) async {
    Database? db = await _database;
    return await db!.insert('themes', theme.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch all themes
  Future<List<ThemeD>> getThemes() async {
    Database? db = await _database;
    List<Map<String, dynamic>> maps = await db!.query('themes');
    return maps.map((map) => ThemeD.fromMap(map)).toList();
  }

  /// Insert a sub-theme
  Future<int> insertSubTheme(SubThemeD subThemeD) async {
    Database? db = await _database;
    return await db!.insert('sub_themes', subThemeD.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch all sub-themes by themeId
  Future<List<SubThemeD>> getSubThemes(int themeId) async {
    Database? db = await _database;
    List<Map<String, dynamic>> maps = await db!.query(
      'sub_themes',
      where: 'themeId = ?',
      whereArgs: [themeId],
    );
    return maps.map((map) => SubThemeD.fromMap(map)).toList();
  }

  /// Insert a chapter
  Future<int> insertChapter(Chapter chapter) async {
    Database? db = await _database;
    return await db!.insert('chapters', chapter.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch all chapters by subThemeId
  Future<List<Chapter>> getChapters(int subThemeId) async {
    Database? db = await _database;
    List<Map<String, dynamic>> maps = await db!.query(
      'chapters',
      where: 'subThemeId = ?',
      whereArgs: [subThemeId],
    );
    return maps.map((map) => Chapter.fromMap(map)).toList();
  }

  /// Delete a theme (this will cascade delete sub-themes and chapters)
  Future<int> deleteTheme(int id) async {
    Database? db = await _database;
    return await db!.delete('themes', where: 'id = ?', whereArgs: [id]);
  }

  Future<Chapter?> getChapterById(int chapterId) async {
    final db = await _database;
    List<Map<String, dynamic>> result = await db!.query(
      'chapters',
      where: 'id = ?',
      whereArgs: [chapterId],
    );

    if (result.isNotEmpty) {
      return Chapter.fromMap(result.first);
    }
    return null;
  }


  /// Delete a sub-theme
  Future<int> deleteSubTheme(int id) async {
    Database? db = await _database;
    return await db!.delete('sub_themes', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete a chapter
  Future<int> deleteChapter(int id) async {
    Database? db = await _database;
    return await db!.delete('chapters', where: 'id = ?', whereArgs: [id]);
  }

  /// Close the database
  Future<void> closeDatabase() async {
    Database? db = await _database;
    await db!.close();
  }
}

