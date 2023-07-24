import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(CSVSearchApp());

class CSVSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CSVData()),
        ChangeNotifierProvider(create: (context) => QRScannerSectionState()),
      ],
      child: MaterialApp(
        home: CSVSearchScreen(),
      ),
    );
  }
}

class CSVData extends ChangeNotifier {
  List<List<dynamic>> _csvData = [];
  List<List<dynamic>> _filteredData = [];
  List<String> _columnHeaders = [];
  List<bool> _selectedRows = [];
  TextEditingController _searchController = TextEditingController();

  List<List<dynamic>> get csvData => _csvData;
  List<List<dynamic>> get filteredData => _filteredData;
  List<String> get columnHeaders => _columnHeaders;
  List<bool> get selectedRows => _selectedRows;

  Future<void> loadCSVData(String filePath) async {
    try {
      File file = File(filePath);
      String data = await file.readAsString();
      List<List<dynamic>> csvTable = CsvToListConverter().convert(data);
      _csvData = csvTable;
      _filteredData = csvTable;
      if (_csvData.isNotEmpty) {
        _columnHeaders = List.from(_csvData[0]);
        _selectedRows = List.filled(_csvData.length, false);
      }
      notifyListeners();
    } catch (e) {
      // Handle any errors that may occur while reading the file
      print("Error reading CSV file: $e");
    }
  }

  void filterData(String searchTerm) {
    if (searchTerm.isEmpty) {
      _filteredData = _csvData;
    } else {
      _filteredData = _csvData.where((row) {
        return row.any((cell) =>
            cell.toString().toLowerCase().contains(searchTerm.toLowerCase()));
      }).toList();
    }
    notifyListeners();
  }

  void toggleRowSelection(int index) {
    _selectedRows[index] = !_selectedRows[index];
    notifyListeners();
  }
}

class CSVSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick App')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _pickCSVFile(context),
              child: Text('Select CSV File'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (searchTerm) => _filterData(context, searchTerm),
              decoration: InputDecoration(
                hintText: 'Search',
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Consumer<CSVData>(
                  builder: (context, csvData, _) {
                    if (csvData.csvData.isNotEmpty) {
                      return _buildCSVDataTable(context, csvData);
                    } else {
                      return Center(
                        child: Text('No data available'),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _loadSelectedRow(context),
            child: Text('Load Selected Row'),
          ),
        ],
      ),
    );
  }

  Widget _buildCSVDataTable(BuildContext context, CSVData csvData) {
    return Table(
      columnWidths: csvData.columnHeaders
          .asMap()
          .map((index, header) => MapEntry(index, FixedColumnWidth(150.0))),
      border: TableBorder.all(),
      children: [
        TableRow(
          children: csvData.columnHeaders.map((header) {
            return _buildTableCell(context, header, isHeader: true);
          }).toList(),
        ),
        ..._buildDataRowWidgets(context, csvData),
      ],
    );
  }

  List<TableRow> _buildDataRowWidgets(BuildContext context, CSVData csvData) {
    return csvData.filteredData.asMap().entries.map((entry) {
      int index = entry.key;
      List<dynamic> rowData = entry.value;
      bool isSelected = csvData.selectedRows[index];
      return _buildDataRow(context, rowData, isSelected, index);
    }).toList();
  }

  TableRow _buildDataRow(BuildContext context, List<dynamic> rowData,
      bool isSelected, int rowIndex) {
    return TableRow(
      decoration: BoxDecoration(
        color: isSelected ? Colors.yellow : null,
      ),
      children: rowData.map((cell) {
        return _buildTableCell(context, cell.toString(),
            isHeader: false, rowIndex: rowIndex);
      }).toList(),
    );
  }

  Widget _buildTableCell(BuildContext context, String cellValue,
      {bool isHeader = false, int rowIndex = 0}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: GestureDetector(
        onTap: isHeader ? null : () => _toggleRowSelection(rowIndex, context),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            cellValue,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Colors.black : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  void _loadCSVData(BuildContext context, String filePath) {
    Provider.of<CSVData>(context, listen: false).loadCSVData(filePath);
  }

  void _filterData(BuildContext context, String searchTerm) {
    Provider.of<CSVData>(context, listen: false).filterData(searchTerm);
  }

  void _toggleRowSelection(int rowIndex, BuildContext context) {
    Provider.of<CSVData>(context, listen: false).toggleRowSelection(rowIndex);
  }

  void _pickCSVFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.isNotEmpty) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        _loadCSVData(context, filePath);
      }
    }
  }

  void _loadSelectedRow(BuildContext context) {
    CSVData csvData = Provider.of<CSVData>(context, listen: false);
    int lastSelectedRowIndex =
        csvData.selectedRows.indexWhere((selected) => selected == true);
    if (lastSelectedRowIndex != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(
            rowData: csvData.filteredData[lastSelectedRowIndex],
          ),
        ),
      );
    } else {
      // Show a snackbar or an alert to inform the user to select a row first.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a row first.'),
        ),
      );
    }
  }
}

class DetailsScreen extends StatelessWidget {
  final List<dynamic> rowData;

  DetailsScreen({required this.rowData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selected Row Data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...rowData
                .map((data) =>
                    Text(data.toString(), style: TextStyle(fontSize: 16)))
                .toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startScan(context),
              child: Text('Start QR Scan'),
            ),
            SizedBox(height: 20),
            ScannedDataSection(),
            SizedBox(height: 20),
            Consumer<QRScannerSectionState>(
              builder: (context, qrScanState, _) {
                return ElevatedButton(
                  onPressed: () => _compareData(context, qrScanState),
                  child: Text('Compare Data'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerSection(),
      ),
    );
  }

  void _compareData(BuildContext context, QRScannerSectionState qrScanState) {
    List<dynamic> qrData = qrScanState.scannedData;
    if (rowData.length >= 3) {
      String selectedColumnData = rowData[2].toString();
      String qrCodeData = qrData.isNotEmpty ? qrData[0].toString() : '';

      double selectedNumericData = 0; // Initialize with a default value
      double qrCodeNumericData = 0; // Initialize with a default value

      bool isNumericSelected = _isNumeric(selectedColumnData);
      bool isNumericQRCode = _isNumeric(qrCodeData);

      if (isNumericSelected && isNumericQRCode) {
        selectedNumericData = double.parse(selectedColumnData);
        qrCodeNumericData = double.parse(qrCodeData);
      }

      bool isMatched;

      if (isNumericSelected && isNumericQRCode) {
        isMatched = selectedNumericData == qrCodeNumericData;
      } else {
        isMatched =
            selectedColumnData.toLowerCase() == qrCodeData.toLowerCase();
      }

      String comparisonResult = isMatched
          ? 'The data in the third column of the selected row and scanned QR code data match.'
          : 'The data in the third column of the selected row and scanned QR code data do not match.';

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Data Comparison'),
            content: Text(comparisonResult),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // The selected row does not have enough data for comparison
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Data Comparison'),
            content: Text(
                'The selected row does not have enough data for comparison.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  bool _isNumeric(String value) {
    if (value == null) {
      return false;
    }
    return double.tryParse(value) != null;
  }
}

class QRScannerSectionState extends ChangeNotifier {
  List<dynamic> _scannedData = [];

  List<dynamic> get scannedData => _scannedData;

  void updateScannedData(String? data) {
    if (data != null && data.isNotEmpty) {
      _scannedData = [data];
    } else {
      _scannedData = [];
    }
    notifyListeners();
  }
}

class QRScannerSection extends StatelessWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: _buildQrView(context),
          ),
          Expanded(
            flex: 1,
            child: ScannedDataSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: (controller) {
        this.controller = controller;
        controller.scannedDataStream.listen((scanData) {
          Provider.of<QRScannerSectionState>(context, listen: false)
              .updateScannedData(scanData.code);
        });
      },
    );
  }
}

class ScannedDataSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<QRScannerSectionState>(
      builder: (context, scanState, _) {
        List<dynamic> scannedData = scanState.scannedData;
        return scannedData.isNotEmpty
            ? Text(
                'Scanned Data: ${scannedData[0]}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            : Text(
                'No Data Scanned',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              );
      },
    );
  }
}
