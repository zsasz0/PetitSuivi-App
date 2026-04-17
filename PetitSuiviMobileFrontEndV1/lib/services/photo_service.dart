import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:newv/utils/api_constants.dart';

/// Service responsible for managing child photos, including uploads and downloads.
///
/// This service allows teachers to upload photos for specific children and
/// enables both teachers and parents to retrieve or download shared photos.
class PhotoService {
  /// The base URL for the photo API endpoints.
  final String baseUrl = '${ApiConstants.baseUrl}/api';

  /// Helper to construct standard request headers.
  Map<String, String> _getHeaders(String token) {
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  /// Fetches the raw image bytes for a photo via the authenticated download endpoint.
  ///
  /// This is used for displaying photos in the app since direct `/storage/` URLs
  /// are unreliable on mobile devices (wrong host, missing symlink, no auth).
  Future<List<int>> getPhotoBytes(int photoId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/photos/$photoId/download'),
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    if (response.statusCode == 410) {
      throw Exception('Cette photo a expiré.');
    }
    throw Exception('Failed to load photo: ${response.statusCode}');
  }

  /// Uploads a photo to the backend for a list of associated children.
  ///
  /// Requires the [photo] file, [teacherId], a list of [childIds],
  /// and an authentication [token].
  Future<Map<String, dynamic>> uploadPhoto({
    required File photo,
    required int teacherId,
    required List<int> childIds,
    required String token,
    int expiresInDays = 30,
  }) async {
    final headers = _getHeaders(token);
    final uri = Uri.parse('$baseUrl/teacher/photos');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.fields['teacher_id'] = teacherId.toString();
    request.fields['expires_in_days'] = expiresInDays.toString();
    for (int i = 0; i < childIds.length; i++) {
      request.fields['child_ids[$i]'] = childIds[i].toString();
    }
    request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
    }
    throw Exception(
      'Failed to upload photo: ${response.statusCode} - ${response.body}',
    );
  }

  /// Retrieves a list of photos uploaded by a specific teacher.
  Future<List<dynamic>> getTeacherPhotos(int teacherCin, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teacher/photos'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'] ?? [];
      }
    }
    throw Exception('Failed to fetch teacher photos');
  }

  /// Retrieves a list of photos that are visible to a specific child.
  Future<List<dynamic>> getChildPhotos(int childId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/$childId/photos'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'] ?? [];
      }
    }
    throw Exception(
      'Failed to fetch child photos: ${response.statusCode} - ${response.body}',
    );
  }

  /// Downloads a photo from the server and saves it to the device's
  /// public Downloads folder so the user can find it in their gallery/files app.
  ///
  /// Returns the absolute local file path of the downloaded image.
  Future<String> downloadPhoto(int photoId, String token) async {
    final headers = _getHeaders(token);
    final response = await http.get(
      Uri.parse('$baseUrl/photos/$photoId/download'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Try saving to public Downloads folder (visible in gallery/file manager)
      Directory? saveDir;

      // 1. Try the public Downloads directory directly
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (publicDownloads.existsSync()) {
        saveDir = publicDownloads;
      }

      // 2. Fall back to app's external storage
      if (saveDir == null) {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final downloadsDir = Directory('${extDir.path}/Downloads');
          if (!downloadsDir.existsSync()) {
            downloadsDir.createSync(recursive: true);
          }
          saveDir = downloadsDir;
        }
      }

      // 3. Last resort: temp directory
      saveDir ??= await getTemporaryDirectory();

      final ext = _getExtFromContentType(response.headers['content-type']);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${saveDir.path}/photo_${photoId}_$timestamp$ext');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    }
    if (response.statusCode == 410) {
      throw Exception('Cette photo a expiré.');
    }
    throw Exception('Failed to download photo: ${response.statusCode}');
  }

  /// Deletes a specific photo by its [photoId].
  Future<void> deletePhoto(int photoId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/teacher/photos/$photoId'),
      headers: _getHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete photo: ${response.statusCode}');
    }
  }

  /// Internal helper to determine file extension based on MIME type.
  String _getExtFromContentType(String? contentType) {
    if (contentType == null) return '.jpg';
    if (contentType.contains('png')) return '.png';
    if (contentType.contains('webp')) return '.webp';
    return '.jpg';
  }
}
