import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';
import 'package:image_picker_web/image_picker_web.dart';

// late Box _box;

// const baseURL = 'https://cradle-of-humankind-server.herokuapp.com';
const baseURL = 'http://localhost:1337';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // var box = await Hive.openBox('storage');
  // _box = box;

  runApp(const MyApp());
}

// description: string,
// userId: number,
// Image:

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
  Uint8List? selectedImage;
  final _client = Client();
  void login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseURL/api/v1/entrance/login');

    final body = {"emailAddress": email, "password": password};
    final res = await _client.put(
      url,
      body: json.encode(body),
    );

    print(res);

    // if (res.statusCode >= 200 && res.statusCode < 300) {
    // } else {}
  }

  Future<void> check() async {
    var url =
        Uri.parse('$baseURL/api/rest/users?emailAddress=admin@example.com');

    await _client.get(url);
  }

  Future<void> register() async {
    final url = Uri.parse('$baseURL/api/v1/entrance/signup');
    final body = {
      "emailAddress": "admin3@example.com",
      "password": "abc1233",
      "fullName": "Jane Doe"
    };
    await _client.post(url, body: json.encode(body));
  }

  void selectImage() async {
    Uint8List? selectedFile = await ImagePickerWeb.getImageAsBytes();
    if (selectedFile == null) return;
    setState(() {
      selectedImage = selectedFile;
    });
  }

  Future<void> uploadImage() async {
    if (selectedImage == null) return;
    final req = MultipartRequest(
      'POST',
      Uri.parse('$baseURL/api/v1/image/upload'),
    );

    req.fields.addAll({
      'description': 'Test decription ${DateTime.now().millisecondsSinceEpoch}',
      'userId': '1'
    });
    req.files.add(
      MultipartFile.fromBytes(
        'image',
        selectedImage!,
        // filename: 'image-file-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    final res = await _client.send(
      req,
    );
    res.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
    print(res.statusCode);
  }

  @override
  Widget build(BuildContext context) {
    if (_client is BrowserClient) {
      (_client as BrowserClient).withCredentials = true;
    }

    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () =>
                    login(email: 'admin@example.com', password: 'abc123'),
                child: const Text('Login'),
              ),
              // TextButton(
              //   onPressed: () {},
              //   child: const Text('Sign Up'),
              // ),
              TextButton(
                onPressed: check,
                child: const Text('Check'),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Upload Image',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: selectImage,
                    child: const Text('Select Image'),
                  ),
                  TextButton(
                    onPressed: uploadImage,
                    child: const Text('Upload Image'),
                  ),
                ],
              ),
              if (selectedImage != null) ...[
                const SizedBox(
                  height: 50,
                ),
                const Text('Selected Image:'),
                Image.memory(
                  selectedImage!,
                  width: 400,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
