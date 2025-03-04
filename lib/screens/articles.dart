import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class ArticleScreen extends StatefulWidget {
  final String pdfPath; // PDF file path
  final chapterTitle;
  final chapterId;

  const ArticleScreen({super.key, required this.pdfPath, required this.chapterId, required this.chapterTitle});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  int totalPages = 0;
  int currentPage = 0;
  late PDFViewController pdfController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.chapterTitle, style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 4),
            Text("00:00  Page 1/2", style: TextStyle(color: Colors.yellow, fontSize: 14)),
          ],
        ),
        centerTitle: true,
      ),
      body: PDFView(
        filePath: widget.pdfPath,
        autoSpacing: true,
        enableSwipe: true,
        pageSnap: true,
        fitPolicy: FitPolicy.BOTH,
        onRender: (pages) => setState(() => totalPages = pages ?? 0),
        onPageChanged: (page, _) => setState(() => currentPage = page ?? 0),
        onViewCreated: (PDFViewController controller) {
          pdfController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add PDF-related actions here
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.play_arrow, color: Colors.white), // Play button
      ),
    );
  }
}
