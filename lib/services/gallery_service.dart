import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/gallery_photo_model.dart';
import '../constant/constant.dart';

class GalleryService {
  /// Uses staff_id when present (staff module), otherwise adminId (admin module).
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final staffId = prefs.getString('staff_id');
    final adminId = prefs.getString('adminId');
    final id = (staffId != null && staffId.isNotEmpty) ? staffId : adminId;
    return {
      'authorization': 'CRM $token',
      'Content-Type': 'application/json; charset=UTF-8',
      'id': 'CRM $id',
    };
  }

  /// GET /api/rentals/gallery/{rental_id}
  static Future<GalleryResponse> getGallery(String rentalId) async {
    final url = '$Api_url/api/rentals/gallery/$rentalId';
    final response = await apiGet(
      Uri.parse(url),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return GalleryResponse.fromJson(json);
    }
    throw Exception('Failed to load gallery: ${response.statusCode}');
  }

  /// POST /api/images/upload - returns list of filenames
  static Future<List<String>> uploadImages(List<File> files) async {
    final uploadUrl = '$image_upload_url/api/images/upload';
    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    final headers = await _headers();
    request.headers['authorization'] = headers['authorization']!;
    request.headers['id'] = headers['id']!;
    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }
    final streamed = await apiSend(request);
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body);
    if (body['status'] == 'ok' && body['files'] != null) {
      return (body['files'] as List)
          .map<String>((e) => e['filename'] as String)
          .toList();
    }
    throw Exception('Upload failed: ${body['message'] ?? response.statusCode}');
  }

  /// POST /api/rentals/gallery/{rental_id} - add one photo (body: image filename, description)
  static Future<GalleryResponse> addPhotoToGallery(
    String rentalId, {
    required String image,
    String description = '',
  }) async {
    final url = '$Api_url/api/rentals/gallery/$rentalId';
    final response = await apiPost(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode({'image': image, 'description': description}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return GalleryResponse.fromJson(json);
    }
    throw Exception('Failed to add photo: ${response.statusCode}');
  }

  /// PUT /api/rentals/gallery/{rental_id}/{photo_id} - update description and/or image
  static Future<GalleryResponse> updatePhoto(
    String rentalId,
    String photoId, {
    String? description,
    String? image,
  }) async {
    final url = '$Api_url/api/rentals/gallery/$rentalId/$photoId';
    final body = <String, dynamic>{};
    if (description != null) body['description'] = description;
    if (image != null) body['image'] = image;
    final response = await apiPut(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return GalleryResponse.fromJson(json);
    }
    throw Exception('Failed to update photo: ${response.statusCode}');
  }

  /// DELETE /api/rentals/gallery/{rental_id}/{photo_id}
  static Future<GalleryResponse> deletePhoto(
      String rentalId, String photoId) async {
    final url = '$Api_url/api/rentals/gallery/$rentalId/$photoId';
    final response = await apiDelete(
      Uri.parse(url),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return GalleryResponse.fromJson(json);
    }
    throw Exception('Failed to delete photo: ${response.statusCode}');
  }

  /// PUT /api/rentals/gallery/{rental_id}/{photo_id}/set-cover
  static Future<GalleryResponse> setCover(
      String rentalId, String photoId) async {
    final url = '$Api_url/api/rentals/gallery/$rentalId/$photoId/set-cover';
    final response = await apiPut(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode({}),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return GalleryResponse.fromJson(json);
    }
    throw Exception('Failed to set cover: ${response.statusCode}');
  }

  /// POST /api/history - log "Gallery Photo Added"
  static Future<void> postGalleryHistory(
    String entityId, {
    required String description,
  }) async {
    final url = '$Api_url/api/history';
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('userName') ?? prefs.getString('name') ?? 'User';
    final body = {
      'entity_type': 'property',
      'entity_id': entityId,
      'action_type': 'created',
      'description': 'Gallery Photo Added: ${description.isEmpty ? 'Photo' : description}',
      'username': username,
      'category': 'Gallery',
      'metadata': {'description': description},
    };
    final response = await apiPost(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to post history: ${response.statusCode}');
    }
  }
}
