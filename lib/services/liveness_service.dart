import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit_face_detection/google_ml_kit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class LivenessService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableClassification: true, // Needed for blink detection
    ),
  );

  bool _isBlinkDetected = false;

  Future<void> detectBlink(CameraImage cameraImage, Function(File?) onBlink) async {
    if (_isBlinkDetected) return;

    final inputImage = _inputImageFromCameraImage(cameraImage);
    if (inputImage == null) return;

    final List<Face> faces = await _faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      final face = faces.first;
      // A simple liveness check: if both eyes are closed, we consider it a blink.
      if ((face.leftEyeOpenProbability ?? 1.0) < 0.1 &&
          (face.rightEyeOpenProbability ?? 1.0) < 0.1) {
        _isBlinkDetected = true;

        // Crop the face from the image
        final croppedFaceImage = await _cropFace(cameraImage, face);
        onBlink(croppedFaceImage);
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // get image rotation
    // it is used in android to convert the InputImage from Dart plane format to native plane format
    // `rotation` is not used in iOS to convert the InputImage from Dart plane format to native plane format
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    final camera = CameraDescription(
        name: 'camera',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90);
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  Future<File?> _cropFace(CameraImage cameraImage, Face face) async {
    // Convert CameraImage to a format the 'image' package can use
    img.Image? originalImage;
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      // YUV420 to RGB conversion (simplified)
      originalImage = _convertYUV420toImageColor(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      originalImage = img.Image.fromBytes(
        width: cameraImage.width,
        height: cameraImage.height,
        bytes: cameraImage.planes[0].bytes.buffer,
        order: img.ChannelOrder.bgra,
      );
    }

    if (originalImage == null) return null;

    // The bounding box from ML Kit might need rotation adjustment.
    // For front camera, it's often flipped horizontally.
    final x = face.boundingBox.left.toInt();
    final y = face.boundingBox.top.toInt();
    final w = face.boundingBox.width.toInt();
    final h = face.boundingBox.height.toInt();

    // Crop the image
    img.Image croppedImage =
        img.copyCrop(originalImage, x: x, y: y, width: w, height: h);
    
    // For front camera, flip horizontally
    croppedImage = img.flipHorizontal(croppedImage);

    // Save to a temporary file
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(tempPath);
    await file.writeAsBytes(img.encodeJpg(croppedImage));

    return file;
  }

  // Simplified YUV to RGB conversion for cropping
  img.Image _convertYUV420toImageColor(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final yuvBytes = [
      image.planes[0].bytes,
      image.planes[1].bytes,
      image.planes[2].bytes,
    ];

    var im = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex =
            (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int yValue = yuvBytes[0][yIndex];
        final int uValue = yuvBytes[1][uvIndex];
        final int vValue = yuvBytes[2][uvIndex];

        final r = (yValue + 1.13983 * (vValue - 128)).round();
        final g = (yValue - 0.39465 * (uValue - 128) - 0.58060 * (vValue - 128))
            .round();
        final b = (yValue + 2.03211 * (uValue - 128)).round();

        im.setPixelRgb(x, y, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
      }
    }
    return im;
  }

  void dispose() {
    _faceDetector.close();
  }
}