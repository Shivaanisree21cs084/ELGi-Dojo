import 'package:flutter/material.dart';
import 'Operator/operator_page.dart';
import 'Staff/staff_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        // '/operator': (context) => OperatorPage(),
        '/staff': (context) => StaffPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Accessory Barcode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(padding: EdgeInsets.all(15.0)),
            // ElevatedButton(
            //   style: ButtonStyle(
            //     backgroundColor: MaterialStateProperty.all(Colors.purple),
            //   ),
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/operator');
            //   },
            //   child: Text('Operator'),
            // ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.purple),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/staff');
              },
              child: Text('Staff'),
            ),
          ],
        ),
      ),
    );
  }
}
