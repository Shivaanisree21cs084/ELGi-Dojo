import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class StaffPage extends StatefulWidget {
  @override
  _StaffPageState createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  List<List<dynamic>> _csvData = [];
  List<List<dynamic>> _filteredData = [];
  List<String> _columnHeaders = [];
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Staff Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _pickCSVFile,
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareDataAsExcel,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterData,
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
                child: _csvData.isNotEmpty
                    ? _buildCSVDataTable()
                    : Center(
                        child: Text('No data available'),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCSVDataTable() {
    return Table(
      columnWidths: _columnHeaders
          .asMap()
          .map((index, header) => MapEntry(index, FixedColumnWidth(150.0))),
      border: TableBorder.all(),
      children: [
        TableRow(
          children: _columnHeaders.map((header) {
            return _buildTableCell(header, isHeader: true);
          }).toList(),
        ),
        ..._buildDataRowWidgets(),
      ],
    );
  }

  List<TableRow> _buildDataRowWidgets() {
    return _filteredData.asMap().entries.map((entry) {
      int index = entry.key;
      List<dynamic> rowData = entry.value;
      return _buildDataRow(rowData, index);
    }).toList();
  }

  TableRow _buildDataRow(List<dynamic> rowData, int rowIndex) {
    return TableRow(
      children: rowData.map((cell) {
        return _buildTableCell(cell.toString(),
            isHeader: false, rowIndex: rowIndex);
      }).toList(),
    );
  }

  Widget _buildTableCell(String cellValue,
      {bool isHeader = false, int rowIndex = 0}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: GestureDetector(
        onTap: isHeader ? null : () => _toggleRowSelection(rowIndex),
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

  void _loadCSVData(String filePath) async {
    try {
      File file = File(filePath);
      String data = await file.readAsString();
      List<List<dynamic>> csvTable = CsvToListConverter().convert(data);
      setState(() {
        _csvData = csvTable;
        _filteredData = csvTable;
        if (_csvData.isNotEmpty) {
          _columnHeaders = List.from(_csvData[0]);
        }
      });
    } catch (e) {
      print("Error reading CSV file: $e");
    }
  }

  void _filterData(String searchTerm) {
    if (searchTerm.isEmpty) {
      setState(() {
        _filteredData = _csvData;
      });
    } else {
      setState(() {
        _filteredData = _csvData.where((row) {
          return row.any((cell) =>
              cell.toString().toLowerCase().contains(searchTerm.toLowerCase()));
        }).toList();
      });
    }
  }

  void _toggleRowSelection(int index) {
    // Implement row selection logic if needed.
  }

  void _pickCSVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.isNotEmpty) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        _loadCSVData(filePath);
      }
    }
  }

  void _shareDataAsExcel() async {
    final List<dynamic> exportData = [_columnHeaders, ..._filteredData];
    final String csvDataString =
        const ListToCsvConverter().convert(exportData.cast<List?>());

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/data.csv');
    await file.writeAsString(csvDataString);

    final fileName = 'employee_data.csv';

    await Share.shareFiles(
      [file.path],
      text: 'CSV Data',
      subject: fileName,
      mimeTypes: ['text/csv'], // Pass the MIME type as a List<String>
    );
  }
}
