import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

late Box _box;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var box = await Hive.openBox('storage');
  _box = box;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _client = Client();
  void login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('http://localhost:1337/api/v1/entrance/login');

    final body = {"emailAddress": email, "password": password};
    final res = await _client.put(
      url,
      body: json.encode(body),
    );

    // if (res.statusCode >= 200 && res.statusCode < 300) {
    // } else {}
  }

  Future<void> check() async {
    var url = Uri.parse(
        'http://localhost:1337/api/rest/users?emailAddress=admin@example.com');

    await _client.get(url);
  }

  Future<void> register() async {
    final url = Uri.parse('http://localhost:1337/api/v1/entrance/signup');
    final body = {
      "emailAddress": "admin3@example.com",
      "password": "abc1233",
      "fullName": "Jane Doe"
    };
    await _client.post(url, body: json.encode(body));
  }

  @override
  Widget build(BuildContext context) {
    if (_client is BrowserClient) {
      (_client as BrowserClient).withCredentials = true;
    }
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () =>
                login(email: 'admin@example.com', password: 'abc123'),
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Sign Up'),
          ),
          TextButton(
            onPressed: check,
            child: const Text('Check'),
          ),
        ],
      ),
    );
  }
}
