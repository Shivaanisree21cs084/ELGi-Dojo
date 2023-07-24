import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV File Opener',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<dynamic>>? _csvData;

  Future<void> _openCSVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      // Read CSV file data
      String csvString = await file.readAsString();
      List<List<dynamic>> csvData = CsvToListConverter().convert(csvString);

      setState(() {
        _csvData = csvData;
      });
    } else {
      // User canceled the file picking
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CSV File Opener'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _openCSVFile,
              child: Text('Open CSV File'),
            ),
            SizedBox(height: 20),
            if (_csvData != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _csvData!.length,
                  itemBuilder: (context, index) {
                    List<dynamic> rowData = _csvData![index];
                    return ListTile(
                      title: Text(rowData.join(', ')),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
