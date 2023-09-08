import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'function.dart';

void main() {
  runApp(SearchBarApp());
}

class SearchBarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task 2',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Welcome> _data = [];
  final List<Welcome> _filteredData = [];
  List<String> _removedWords = [];
  bool _isTextVisible = false;
  bool _showQuotes = false;

  @override
  void initState() {
    super.initState();
    _fetchData('');
  }

  void _filterList(String searchText) {
    _filteredData.clear();
    if (searchText.isEmpty) {
      _filteredData.addAll(_data);
    } else {
      for (var item in _data) {
        if (item.category.toLowerCase().contains(searchText.toLowerCase())) {
          _filteredData.add(item);
        }
      }
    }
    setState(() {});
  }

  Future<void> _fetchData(String category) async {
    final api = 'https://api.api-ninjas.com/v1/quotes?category=$category';
    final response = await http.get(Uri.parse(api), headers: {
      'X-Api-Key': '9MfzoAXxeXNNacu4xWbtQQ==LteQHEp3c5KSGbpu',
    });

    if (response.statusCode == 200) {
      final List<Welcome> apiData = welcomeFromJson(response.body);
      setState(() {
        _data.clear();
        _filteredData.clear();
        _data.addAll(apiData);
        _filteredData.addAll(apiData);
      });
    } else {
      _showErrorDialog(response.statusCode, response.body);
    }
  }

  void _showErrorDialog(int statusCode, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text("Error: $statusCode $body"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
Future<void> _removeWordAndFetch(String input) async {
  final wordsToRemove = ["angery", "sad", "happy", "tired", "unhealthy"];
  final List<String> words = input.split(' ');

  _removedWords = words.where((word) => wordsToRemove.contains(word.toLowerCase())).toList();
  words.removeWhere((word) => wordsToRemove.contains(word.toLowerCase()));

  if (words.isNotEmpty) {
    final category = _removedWords.isNotEmpty ? _removedWords.first : words.first;
    await _fetchData(category);

    setState(() {
      _isTextVisible = true;
      _showQuotes = true;
    });
  } else {
    return stdout.write('error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 2'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _filterList(value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'How are you feeling Today!',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final text = _searchController.text;
                    await _removeWordAndFetch(text);
                  },
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(
                          side: BorderSide(style: BorderStyle.none))),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Card(
                    elevation: 3,
                    child: ListTile(
                      title: _showQuotes && _isTextVisible
                          ? Center(
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    _filteredData[index].quote,
                                    textStyle: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    speed: const Duration(milliseconds: 100),
                                  ),
                                ],
                                totalRepeatCount: 1,
                              ),
                            )
                          : Container(),
                      subtitle: _showQuotes && _isTextVisible
                          ? Text(_filteredData[index].author)
                          : Container(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
