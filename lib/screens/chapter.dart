import 'package:flutter/material.dart';
import 'package:dear_day/screens/articles.dart';
import '../database/database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {

  int? subThemeId; // Store theme ID
  String? subThemeTitle;
  List<Map<String, dynamic>> chapters = [];
  double _downloadProgress = 0.0; // Track progress
  bool _isDownloading = false;
  Map<int, bool> isDownloadingMap = {}; // Track progress per chapter

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask((){
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        subThemeId = args?['id']; // Get ID from arguments
        subThemeTitle = args?['subThemeTitle'];
      });
    });
    fetchData();
    fetchLocalData();
  }

  Future<void> fetchData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initDatabase();

    final response = await http.get(
      Uri.parse('http://161.97.81.168:8080/viewChapters/${subThemeId}'),
    );
    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      final Dio _dio = Dio();

      for (var jsonData in data) {

        int chapterId = jsonData['id'];

        // Check if chapter exists in the database
        final existingChapter = await dbHelper.getChapterById(chapterId);
        if (existingChapter != null) {
          print("Chapter $chapterId already exists, skipping download.");
          continue; // Skip downloading if chapter already exists
        }

        // Reset progress
        setState(() {
          _downloadProgress = 0.0;
          _isDownloading = true;
        });

        // Download PDF if available
        String? localPdfPath;
        if (jsonData['article'] != null && jsonData['article'].isNotEmpty) {
          localPdfPath = await downloadPdf('http://161.97.81.168:8080${jsonData['article']}', _dio);
        }

        final chapter = Chapter(
          id: jsonData['id'],
          title: jsonData['title'],
          subThemeId: jsonData['sub_theme'],
          articlePath: localPdfPath ?? jsonData['article'], // Store local path if downloaded
          dateCreated: jsonData['date_created'],
        );
        await dbHelper.insertChapter(chapter);
      }

      final chapterD = await dbHelper.getChapters(subThemeId!);

      setState(() {
        chapters = chapterD.map((chapter) => chapter.toMap()).toList();
        _isDownloading = false; // Hide progress after completion
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchLocalData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initDatabase();

    final chapterD = await dbHelper.getChapters(subThemeId!);

    setState(() {
      chapters = chapterD.map((chapter) => chapter.toMap()).toList();
    });
  }

  // Function to download PDF
  // Function to download PDF with progress
  Future<String?> downloadPdf(String url, Dio dio) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String fileName = url.split('/').last;
      String filePath = '${directory.path}/$fileName';

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total; // Update progress
              print(_downloadProgress);
            });
          }
        },
      );

      return filePath; // Return the local file path
    } catch (e) {
      print("Error downloading file: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              subThemeTitle!,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              _isDownloading ? "Downloading... ${_downloadProgress}" : "00:00   Select Chapter",
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Chapters",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: chapters.map((chapter) => _buildChapterCard(chapter['title'], chapter['id'], chapter['articlePath'] ?? "",isDownloadingMap[chapter['id']] ?? false,)).toList(),
            ),
          ],
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

  Widget _buildChapterCard(String title, int id, String pdfPath, bool isDownloading) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.book, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: _isDownloading
            ? const CircularProgressIndicator() // Show progress if downloading
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _isDownloading
            ? null // Disable tap while downloading
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleScreen(
                pdfPath: pdfPath,
                chapterId: id,
                chapterTitle: title,
              ),
            ),
          );
        },
      ),
    );
  }
}
