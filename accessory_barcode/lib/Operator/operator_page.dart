// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:csv/csv.dart';
// import 'package:share/share.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class OperatorPage extends StatefulWidget {
//   @override
//   _OperatorPageState createState() => _OperatorPageState();
// }
//
// class _OperatorPageState extends State<OperatorPage> {
//   String _barcode = 'Scan a barcode';
//
//   Future<void> _scanBarcode() async {
//     try {
//       String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
//         '#FF6600',
//         'Cancel',
//         true,
//         ScanMode.BARCODE,
//       );
//
//       if (barcodeScanResult != '-1') {
//         setState(() {
//           _barcode = barcodeScanResult;
//         });
//       }
//     } on PlatformException catch (e) {
//       if (e.code == 'PERMISSION_NOT_GRANTED') {
//         print('Camera permission not granted.');
//       } else {
//         print('Error: $e');
//       }
//     }
//   }
//
//   Future<void> _shareAsCSV() async {
//     if (_barcode == 'Scan a barcode') return;
//
//     final List<List<dynamic>> rows = [
//       ['Barcode Data'],
//       [_barcode],
//     ];
//
//     final String csvData =
//         const ListToCsvConverter().convert(rows.cast<List?>());
//
//     final Directory tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/barcode_data.csv');
//
//     await file.writeAsString(csvData);
//
//     print('CSV File Path: ${file.path}');
//
//     // final fileName = 'barcode_data.csv';
//
//     // Check if the platform is Android and if the required permission is granted
//
//     if (Platform.isAndroid) {
//       final bool hasStoragePermission = await _checkStoragePermission();
//       if (!hasStoragePermission) {
//         print('Storage permission not granted.');
//         return;
//       }
//     }
//
//     // Share the file
//     await Share.shareFiles(
//       [file.path],
//       text: 'CSV Data',
//       subject: 'barcode_data.csv',
//       mimeTypes: ['text/csv'], // Pass the MIME type as a List<String>
//     );
//   }
//
//   Future<bool> _checkStoragePermission() async {
//     if (Platform.isAndroid) {
//       final status = await Permission.storage.status;
//       if (!status.isGranted) {
//         // Request the permission
//         final result = await Permission.storage.request();
//         return result.isGranted;
//       } else {
//         return true;
//       }
//     }
//     return true; // For other platforms, assume permission is granted
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text('Operator Page'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.share),
//             onPressed: _barcode != 'Scan a barcode' ? _shareAsCSV : null,
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.person,
//               size: 80,
//               color: Colors.purple,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Welcome, Operator!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all(Colors.purple),
//               ),
//               onPressed: _scanBarcode,
//               child: Text('Scan Barcode'),
//             ),
//             SizedBox(height: 10),
//             Text(
//               _barcode,
//               style: TextStyle(fontSize: 20),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
