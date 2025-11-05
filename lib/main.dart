import 'package:flutter/material.dart';
import 'package:flutter_dictionary/screens/home.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme()
      ),
    ),
  );
}
