import 'package:flutter/material.dart';
import 'package:flutter_dictionary/screens/definition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  void _searchWord() {
    final word = _controller.text.trim();

    if (word.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Empty Input"),
          content: const Text("Please enter a word before searching."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Definition(word: word)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Flutter dictionary app",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hint: Text("Type a word..."),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchWord();
                  },
                  icon: Icon(Icons.search),
                ),
              ),

              onSubmitted: (_) => _searchWord(),
            ),
          ],
        ),
      ),
    );
  }
}
