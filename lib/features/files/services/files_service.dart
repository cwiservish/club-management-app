import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/files_api_models.dart';

class FilesService {
  final ApiClient _apiClient;

  FilesService(this._apiClient);

  /// Fetches the files list for the selected team UUID.
  Future<FilesListResponse> fetchFiles(String uuid) async {
    const endpoint = ApiEndpoints.filesList;
    final requestBody = FilesListRequest(uuid: uuid).toJson();

    // Print Request JSON in logs
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    try {
      final response = await _apiClient.post(
        endpoint,
        body: requestBody,
      );

      // Construct response map for printing
      final rawResponseMap = {
        'success': response.success,
        'message': response.message ?? '',
        'data': response.data,
      };

      // Print Response JSON in logs
      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('[API Response] POST $endpoint');
      debugPrint('[API Response Body]:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
      debugPrint('════════════════════════════════════════════════════════════════');

      final responseDataMap = <String, dynamic>{
        'success': response.success,
        'message': response.message ?? '',
        'data': response.data is Map<String, dynamic> ? response.data : <String, dynamic>{},
      };

      return FilesListResponse.fromJson(responseDataMap);
    } catch (e) {
      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('[API Request Error] POST $endpoint: $e');
      debugPrint('════════════════════════════════════════════════════════════════');
      return FilesListResponse(
        success: false,
        message: e.toString(),
        data: const FilesListData(grid: [], total: 0),
      );
    }
  }

  /// Saves / uploads a new document.
  Future<FileSaveResponse> saveFile({
    required String uuid,
    required String teamId,
    required String filePath,
  }) async {
    const endpoint = ApiEndpoints.filesSave;
    final fileName = filePath.split('/').last;

    // Log the request parameters
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] Multipart POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[Form Fields]:');
    debugPrint('  team_uuid: $uuid');
    debugPrint('  file: $fileName ($filePath)');
    debugPrint('════════════════════════════════════════════════════════════════');

    try {
      final formData = FormData.fromMap({
        'team_uuid': uuid,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiClient.post(
        endpoint,
        body: formData,
      );

      // Construct response map for printing
      final rawResponseMap = {
        'success': response.success,
        'message': response.message ?? '',
        'data': response.data,
      };

      // Print Response JSON in logs
      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('[API Response] POST $endpoint');
      debugPrint('[API Response Body]:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
      debugPrint('════════════════════════════════════════════════════════════════');

      final responseDataMap = <String, dynamic>{
        'success': response.success,
        'message': response.message ?? '',
        'data': response.data is Map<String, dynamic> ? response.data : <String, dynamic>{},
      };

      return FileSaveResponse.fromJson(responseDataMap);
    } catch (e) {
      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('[API Request Error] POST $endpoint: $e');
      debugPrint('════════════════════════════════════════════════════════════════');
      return FileSaveResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Removes / deletes a document by ID.
  Future<FileRemoveResponse> removeFile(int id, String teamUuid) async {
    const endpoint = ApiEndpoints.filesRemove;

    // Log the request parameters
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] Multipart POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[Form Fields]:');
    debugPrint('  id: $id');
    debugPrint('  team_uuid: $teamUuid');
    debugPrint('════════════════════════════════════════════════════════════════');

    try {
      final formData = FormData.fromMap({
        'id': id.toString(),
        'team_uuid': teamUuid,
      });

      final response = await _apiClient.post(
        endpoint,
        body: formData,
      );

      // Construct response map for printing
      final rawResponseMap = {
        'success': response.success,
        'message': response.message ?? '',
        'data': response.data,
      };

      // Print Response JSON in logs
      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('[API Response] POST $endpoint');
      debugPrint('[API Response Body]:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
      debugPrint('════════════════════════════════════════════════════════════════');

      final responseDataMap = <String, dynamic>{
        'success': response.success,
        'message': response.message ?? '',
      };

      return FileRemoveResponse.fromJson(responseDataMap);
    } catch (e) {
      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('[API Request Error] POST $endpoint: $e');
      debugPrint('════════════════════════════════════════════════════════════════');
      return FileRemoveResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}
