import 'package:flutter/material.dart';
import '../database/database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  List<Map<String, dynamic>> themes = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchLocalData();
  }

  Future<void> fetchData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initDatabase();

    final response = await http.get(
      Uri.parse('http://161.97.81.168:8080/viewTheme/'),
    );
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      for (var jsonData in data) {
        final theme = ThemeD(
          id: jsonData['id'],
          title: jsonData['title'],
          themeCode: jsonData['themeCode'],
          term: jsonData['term'],
          classTaught: jsonData['classTaught'],
          date_created: jsonData['date_created'],
        );
        await dbHelper.insertTheme(theme);
      }

      final themeData = await dbHelper.getThemes();

      setState(() {
        themes = themeData.map((theme) => theme.toMap()).toList();
        print(themes);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchLocalData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initDatabase();

    final themeD = await dbHelper.getThemes();

    setState(() {
      themes = themeD.map((theme) => theme.toMap()).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900], // Dark blue color
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Select Theme",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              "00:00   Choose a theme to explore",
              style: TextStyle(color: Colors.yellow, fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: themes.map((theme) => _buildThemeCard(theme['title'], theme['id'])).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add action here
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: ''),
        ],
      ),
    );
  }

  Widget _buildThemeCard(String title, int themeId) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.recycling, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to theme details
          Navigator.pushReplacementNamed(context, '/sub_theme',  arguments: {'id': themeId, 'themeTitle': title}, );
        },
      ),
    );
  }
}
