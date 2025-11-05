import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Definition extends StatefulWidget {
  final String word;
  const Definition({super.key, required this.word});

  @override
  State<Definition> createState() => _DefinitionState();
}

class _DefinitionState extends State<Definition> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, dynamic>> _meanings = [];
  bool _isLoading = false;
  String? _error;
  String? _audioUrl;

  @override
  void initState() {
    super.initState();
    _searchWord(widget.word);
  }

  Future<void> _searchWord(String word) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _meanings = [];
      _audioUrl = null;
    });

    final url = Uri.parse(
      "https://api.dictionaryapi.dev/api/v2/entries/en/$word",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final List meanings = data[0]["meanings"];

        final List<Map<String, dynamic>> parsed = [];

        for (var m in meanings) {
          final String partOfSpeech = m["partOfSpeech"];
          final List definitions = m["definitions"];

          final List phonetics = data[0]['phonetics'] ?? [];

          if (phonetics.isNotEmpty) {
            final audioEntry = phonetics.firstWhere(
                (p) => p["audio"] != null && p["audio"].toString().isNotEmpty,
              orElse: () => {}
            );

            _audioUrl = audioEntry["audio"];
            print("Playing audio from: $_audioUrl");
          }

          for (var d in definitions) {
            parsed.add({
              "partOfSpeech": partOfSpeech,
              "definition": d["definition"],
              "example": d["example"],
            });
          }
        }

        setState(() {
          _meanings = parsed;
        });
      } else {
        setState(() {
          _error = "Word not found";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error fetching data: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playAudio() async {
    if (_audioUrl!.isEmpty && _audioUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No audio available for this word")),
      );

      return;
    }

    try {
      await _audioPlayer.play(UrlSource(_audioUrl!));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error playing audio: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Definition: ${widget.word}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: _isLoading
              ? const CircularProgressIndicator()
              : _error != null
              ? Text(_error!, style: TextStyle(color: Colors.red))
              : _meanings.isEmpty
              ? Text("No definition found")
              : ListView.builder(
                  itemCount: _meanings.length,
                  itemBuilder: (context, index) {
                    final item = _meanings[index];

                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${index + 1}. (${item["partOfSpeech"]})",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                                
                                IconButton(onPressed: _playAudio, icon: Icon(Icons.volume_down_alt))
                              ],
                            ),

                            SizedBox(height: 6),

                            Text(
                              item["definition"],
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (item["example"] != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                "💡 Example: ${item["example"]}",
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
