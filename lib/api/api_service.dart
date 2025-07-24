import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // IMPORTANT: Replace with your server's IP address or domain when you deploy the Python backend.
  // For local testing with an Android emulator, use 10.0.2.2.
  final String _baseUrl = 'http://192.168.1.200:8000';

  Future<Map<String, dynamic>> register(
      String id, String name, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/register'),
      );
      request.fields['user_id'] = id;
      request.fields['name'] = name;
      request.files
          .add(await http.MultipartFile.fromPath('face_image', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        return json.decode(respStr);
      } else {
        final respStr = await response.stream.bytesToString();
        return {'success': false, 'message': 'Server Error: ${response.statusCode}. Details: $respStr'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> markAttendance(
      String id, File imageFile, Position position) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/attend'),
      );
      request.fields['user_id'] = id;
      request.fields['latitude'] = position.latitude.toString();
      request.fields['longitude'] = position.longitude.toString();
      request.files
          .add(await http.MultipartFile.fromPath('face_image', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        return json.decode(respStr);
      } else {
        final respStr = await response.stream.bytesToString();
        return {'success': false, 'message': 'Server Error: ${response.statusCode}. Details: $respStr'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
