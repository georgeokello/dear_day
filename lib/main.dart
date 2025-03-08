import 'package:flutter/material.dart';
import 'package:dear_day/screens/login.dart';
import 'package:dear_day/screens/register.dart';
import 'package:dear_day/screens/theme.dart';
import 'package:dear_day/screens/sub_theme.dart';
import'package:dear_day/screens/chapter.dart';
import 'package:dear_day/screens/articles.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DEAR DAY',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/theme': (context) => ThemePage(),
        '/sub_theme': (context) => SubTheme(),
        '/chapter': (context) => ChaptersScreen(),
      },
    );
  }
}