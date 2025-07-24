import 'dart:io';
import 'package:face_attendance_app/api/api_service.dart';
import 'package:face_attendance_app/services/liveness_service.dart';
import 'package:face_attendance_app/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final LivenessService _livenessService = LivenessService();
  final ApiService _apiService = ApiService();

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _message = 'Please look at the camera and blink.';
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    // Use the front camera
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first);

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
      _startLivenessDetection();
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void _startLivenessDetection() {
    _cameraController!.startImageStream((image) {
      if (!_isProcessing) {
        _isProcessing = true;
        _livenessService.detectBlink(image, _onBlinkDetected).then((_) {
          _isProcessing = false;
        });
      }
    });
  }

  void _onBlinkDetected(File? faceImage) {
    if (mounted && faceImage != null) {
      _cameraController?.stopImageStream();
      setState(() {
        _message = "Blink detected! Face captured.";
        _capturedImage = faceImage;
      });
    }
  }

  Future<void> _registerUser() async {
    if (_idController.text.isEmpty || _nameController.text.isEmpty) {
      _showSnackBar("ID and Name cannot be empty.", isError: true);
      return;
    }
    if (_capturedImage == null) {
      _showSnackBar("No face has been captured.", isError: true);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await _apiService.register(
        _idController.text,
        _nameController.text,
        _capturedImage!,
      );

      _showSnackBar(response['message'], isError: !response['success']);
      if (response['success']) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppStyles.errorColor : AppStyles.successColor,
    ));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _livenessService.dispose();
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register New User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildCameraPreview(),
            const SizedBox(height: 20),
            Text(_message, style: AppStyles.subtitleStyle, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'Enter User ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Enter Full Name'),
            ),
            const SizedBox(height: 30),
            _isProcessing
                ? const SpinKitFadingCircle(color: AppStyles.primaryColor, size: 50.0)
                : ElevatedButton.icon(
                    icon: const Icon(Icons.app_registration),
                    label: const Text('Register'),
                    onPressed: _capturedImage != null ? _registerUser : null,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyles.primaryColor, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _isCameraInitialized
            ? (_capturedImage != null
                ? Image.file(_capturedImage!, fit: BoxFit.cover)
                : CameraPreview(_cameraController!))
            : const Center(
                child: SpinKitFadingCircle(color: Colors.white, size: 50.0),
              ),
      ),
    );
  }
}