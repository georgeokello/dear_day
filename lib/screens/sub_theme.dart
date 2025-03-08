import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/database.dart';

class SubTheme extends StatefulWidget {
  const SubTheme({super.key});

  @override
  State<SubTheme> createState() => _SubThemeState();
}

class _SubThemeState extends State<SubTheme> {

  int? themeId; // Store theme ID
  String? themeTitle;
  List<Map<String, dynamic>> sub_themes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask((){
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        setState(() {
          themeId = args?['id']; // Get ID from arguments
          themeTitle = args?['themeTitle'];
        });
    });
    fetchData();
    fetchLocalData();
  }

  Future<void> fetchData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initDatabase();

    final response = await http.get(
      Uri.parse('http://161.97.81.168:8080/viewSubTheme/${themeId}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      for (var jsonData in data) {
        final sub_theme = SubThemeD(
            id: jsonData['id'],
            title: jsonData['title'],
            themeId: jsonData['theme'],
            duration: jsonData['duration'],
            learningOutcome: jsonData['learning_outcome'],
            practicleProject: jsonData['practicle_project'],
            dateCreated: jsonData['date_created'],
        );
        await dbHelper.insertSubTheme(sub_theme);
      }

      final subthemeData = await dbHelper.getSubThemes(themeId!);

      setState(() {
        sub_themes = subthemeData.map((sub_theme) => sub_theme.toMap()).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchLocalData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initDatabase();

    final sessionsData = await dbHelper.getSubThemes(themeId!);

    setState(() {
      sub_themes = sessionsData.map((sub_theme) => sub_theme.toMap()).toList();
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
              "DEAR Day",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              "00:00   Drop Everything and Read",
              style: TextStyle(color: Colors.yellow, fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                themeTitle!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: sub_themes.map((sub_theme) => _buildSubThemeCard(sub_theme['title'], sub_theme['id'])).toList(),
            ),
          ]
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

  Widget _buildSubThemeCard(String title, int id) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.water, color: Colors.blue), // Water-related icon
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to sub-theme details
          Navigator.pushReplacementNamed(context, '/chapter', arguments: {'id': id, 'subThemeTitle': title});
        },
      ),
    );
  }
}

