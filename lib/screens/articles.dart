import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:async';

class ArticleScreen extends StatefulWidget {
  final String pdfPath;
  final String chapterTitle;
  final int chapterId;

  const ArticleScreen({super.key, required this.pdfPath, required this.chapterId, required this.chapterTitle});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  int totalPages = 0;
  int currentPage = 0;
  late PDFViewController pdfController;
  Timer? _timer;
  bool isTiming = false;
  int secondsElapsed = 0;

  void _toggleTimer() {
    if (isTiming) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          secondsElapsed++;
        });
      });
    }
    setState(() {
      isTiming = !isTiming;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
            Text("${_formatTime(secondsElapsed)}  Page ${currentPage + 1}/$totalPages",
                style: TextStyle(color: Colors.yellow, fontSize: 14)),
          ],
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              return Container(
                width: orientation == Orientation.landscape ? constraints.maxWidth : null,
                height: orientation == Orientation.landscape ? constraints.maxHeight : null,
                child: PDFView(
                  filePath: widget.pdfPath,
                  autoSpacing: true,
                  enableSwipe: true,
                  pageSnap: true,
                  fitPolicy: FitPolicy.WIDTH,
                  onRender: (pages) => setState(() => totalPages = pages ?? 0),
                  onPageChanged: (page, _) => setState(() => currentPage = page ?? 0),
                  onViewCreated: (PDFViewController controller) {
                    pdfController = controller;
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTimer,
        backgroundColor: isTiming ? Colors.red : Colors.green,
        child: Icon(isTiming ? Icons.stop : Icons.play_arrow, color: Colors.white),
      ),
    );
  }
}
