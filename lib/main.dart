import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String content = "おはようございます";
  var _trans = "";

  // みんなの自動翻訳
  void _fetchApiResuts() async {
    var url = Uri.parse(
        'https://mt-auto-minhon-mlt.ucri.jgn-x.jp/api/mt/generalNT_ja_en/?access_token=アクセストークン');

    final response = await http.post(url,
        body: ({
          'key': '', // API Keyを入力
          'name': '', //ログインIDを入力
          'type': 'json',
          'text': '$content',
          'access_token': '', //アクセストークンを入力
          'api_name': 'mt',
          'api_param': 'generalNT_ja_en'
        }));
    if (response.statusCode == 200) {
      var test = json.decode(response.body) as Map<String, dynamic>;

      setState(() {
        _trans = test['resultset']['result']['text'];
      });
      print(test);
    } else {
      throw Exception('Failed');
    }
  }

  // Translator(Microsoft)
  void _microsoft() async {
    var url = Uri.parse(
        'https://api.cognitive.microsofttranslator.com/translate/?api-version=3.0&from=ja&to=en');
    var headers = {
      'Ocp-Apim-Subscription-Key': '', // API Key
      'Content-Type': 'application/json',
      'Ocp-Apim-Subscription-Region': 'japaneast'
    };

    final response = await http.post(url,
        headers: headers,
        body: json.encode([
          {'text': '$content'}
        ]));

    if (response.statusCode == 200) {
      var test = json.decode(response.body);
      print(test);
      setState(() {
        _trans = test[0]['translations'][0]['text'];
      });
    } else {
      throw Exception('Failed');
    }
  }

  // DeepL
  void _deepl() async {
    var url = Uri.parse('https://api-free.deepl.com/v2/translate');
    var headers = {
      'Authorization': '' // API key
    };

    final response = await http.post(url,
        headers: headers,
        body: ({
          'text': '$content',
          'source_lang': 'JA',
          'target_lang': 'EN',
        }));
    if (response.statusCode == 200) {
      var test = json.decode(response.body) as Map<String, dynamic>;
      setState(() {
        _trans = test['translations'][0]['text'];
      });
      print(test);
    } else {
      throw Exception('Failed');
    }
  }

  // Translation(Google)
  void _google() async {
    var url =
        Uri.parse('https://translation.googleapis.com/language/translate/v2');
    var headers = {
      'Authorization': '', // API Key
      //'Content-Type': 'application/json; charset=utf-8';
    };

    final response = await http.post(url,
        headers: headers,
        body: ({
          'q': '$content',
          'source': 'ja',
          'target': 'en',
          'format': 'text'
        }));
    if (response.statusCode == 200) {
      var test = json.decode(response.body) as Map<String, dynamic>;
      setState(() {
        _trans = test['data']['translations'][0]['translatedText'];
      });
      print(test);
    } else {
      print(response.statusCode);
      throw Exception('Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: '翻訳したい文字列を入力してください'),
              onChanged: (text) {
                content = text;
              },
            ),
            const Text(
              '翻訳結果',
            ),
            Text(
              '$_trans',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            // _google,
            // _deepl,
            // _fetchApiResuts, //みんなの自動翻訳
            _microsoft,
        tooltip: 'Translation',
        child: const Icon(Icons.translate),
      ),
    );
  }
}
