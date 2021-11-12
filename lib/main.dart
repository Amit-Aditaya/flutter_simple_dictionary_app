import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String url = 'https://owlbot.info/api/v4/dictionary/';
  String token = '439cae4bc2f45ae28c5a362441bb5017d4b931b7';
  final TextEditingController _controller = TextEditingController();
  StreamController? _streamController;
  Stream? _stream;

  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController!.add(null);
    }
    Response response = await get(Uri.parse(url + _controller.text.trim()),
        headers: {"Authorization": "Token $token"});
    _streamController!.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController!.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
        centerTitle: true,
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextFormField(
                    onFieldSubmitted: (String v) {
                      _search();
                    },
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Search for a word',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _search();
                },
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
      body: StreamBuilder(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: Text(
                  'Enter A Word In The Search Bar',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: (snapshot.data as dynamic)['definitions'].length,
                  itemBuilder: (context, index) {
                    return ListBody(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 6),
                          decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border:
                                  Border.all(width: 2, color: Colors.green)),
                          child: ListTile(
                            leading: (snapshot.data as dynamic)['definitions']
                                        [index]['image_url'] ==
                                    null
                                ? const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 30,
                                  )
                                : CircleAvatar(
                                    backgroundImage: NetworkImage((snapshot.data
                                            as dynamic)['definitions'][index]
                                        ['image_url']),
                                    radius: 30,
                                  ),
                            title: Text(
                              (snapshot.data as dynamic)['word'],
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black),
                            ),
                            subtitle: Text(
                              (snapshot.data as dynamic)['definitions'][index]
                                  ['definition'],
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    );
                  });
            }
          }),
    );
  }
}
