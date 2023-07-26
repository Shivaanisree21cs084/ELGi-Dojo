import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      print("No camera available on the device.");
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile imageFile = await _controller!.takePicture();
      setState(() {
        _imagePath = imageFile.path;
      });
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  Future<void> _retakePicture() async {
    setState(() {
      _imagePath = null;
    });
  }

  void _sendEmailWithImage() async {
    if (_imagePath != null) {
      final Email email = Email(
        body: 'Please find the image attachment.',
        subject: 'Image from Camera',
        recipients: [],
        attachmentPaths: [_imagePath!],
      );

      try {
        await FlutterEmailSender.send(email);
      } catch (e) {
        print('Error sending email: $e');
        _showNoEmailClientDialog();
      }
    } else {
      print("No image to send.");
    }
  }

  void _showNoEmailClientDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('No Email Client Found'),
          content: Text('Please install an email client to send emails.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Camera App"),
      ),
      body: _imagePath == null
          ? CameraPreview(_controller!)
          : Image.file(File(_imagePath!)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _imagePath == null ? _takePicture : _retakePicture,
        child: Icon(_imagePath == null ? Icons.camera : Icons.refresh),
      ),
      bottomNavigationBar: _imagePath == null
          ? null
          : BottomAppBar(
              child: ElevatedButton(
                onPressed: _sendEmailWithImage,
                child: Text("Send via Email"),
              ),
            ),
    );
  }
}
