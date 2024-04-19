import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:minio/minio.dart';

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
  List<String?> eTags = [];
  List<String> publicUrls = [];

  /// Pick a file and upload to tebi
  Future<void> uploadFile() async {
    /// File picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      // withData: true,
      withReadStream: true,
      readSequential: true,
    );

    /// S3 storage client
    final client = Minio(
      endPoint: 's3.tebi.io',
      accessKey: 'FhdJ0RbGcUurmHap',
      secretKey: '1ttRgDwGBYgIj9GX2O2ZzcPSwtQluAdO9DN1QBeq',
    );
    if (result == null) return;
    for (var file in result.files) {
      Stream<List<int>>? fileData = file.readStream;
      if (fileData == null) continue;

      String fileName = file.name
          .replaceAll(' ', '_')
          .replaceAll('(', '')
          .replaceAll(')', '');
      String object = 'rentals/payments/$fileName';

      /// Upload the file and get the eTag
      String? eTagLocal = await client.putObject(
        'lesa',
        object,
        fileData.cast<Uint8List>(),
      );
      String publicUrl = 'https://s3.tebi.io/lesa/$object';
      setState(() {
        eTags.add(eTagLocal);
        publicUrls.add(publicUrl);
      });
      debugPrint(fileName);
      debugPrint(eTagLocal);
      debugPrint(publicUrl);
    }
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
            Text(eTags.toString()),
            const Divider(),
            Text(publicUrls.toString()),
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
