import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:s3_storage/s3_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
  String? pickedFilePath;
  String? eTag;

  /// Pick a file and upload to tebi
  Future<void> uploadFile() async {
    /// File picker
    File? pickedFile;
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      /// Get the file path when picked
      setState(() {
        pickedFilePath = result.files.single.path!;
      });
      pickedFile = File(pickedFilePath!);
    } else {
      /// User canceled the picker
      return;
    }

    /// S3 storage client
    final s3storage = S3Storage(
      endPoint: 's3.tebi.io',
      // signingType: SigningType.V2,
      accessKey: 'UwW00p7962ypmQDX',
      secretKey: 'Hyvf89c9OHBUNReWXpURStrGCfybCHU2HBNLoTaU',
    );

    /// File data as a stream of Uint8List
    Stream<Uint8List> fileData = pickedFile.readAsBytes().asStream();

    /// Upload the file and get the eTag
    String eTagLocal =
        await s3storage.putObject('lesa', 'example.png', fileData);
    setState(() {
      eTag = eTagLocal;
    });
    debugPrint(eTag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Text(pickedFilePath.toString()),
            Text(eTag.toString()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadFile,
        tooltip: 'Upload',
        child: const Icon(Icons.upload_rounded),
      ),
    );
  }
}
