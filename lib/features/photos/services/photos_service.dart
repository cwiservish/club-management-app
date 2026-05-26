import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/photos_api_models.dart';

class PhotosService {
  final ApiClient _apiClient;

  PhotosService(this._apiClient);

  /// Fetches the photos list for the selected team UUID.
  Future<PhotosListResponse> fetchPhotos(String uuid) async {
    const endpoint = ApiEndpoints.photosList;
    final requestBody = PhotosListRequest(uuid: uuid).toJson();

    // Print Request JSON in logs
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

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

    return PhotosListResponse.fromJson(responseDataMap);
  }

  /// Saves / uploads a new photo.
  Future<PhotoSaveResponse> savePhoto({
    required String uuid,
    required String teamId,
    required String imagePath,
  }) async {
    const endpoint = ApiEndpoints.photoSave;
    final fileName = imagePath.split('/').last;

    // Log the request parameters
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] Multipart POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[Form Fields]:');
    debugPrint('  uuid: $uuid');
    debugPrint('  team_id: $teamId');
    debugPrint('  uploaded_by_type: customer');
    debugPrint('  image: $fileName ($imagePath)');
    debugPrint('════════════════════════════════════════════════════════════════');

    final formData = FormData.fromMap({
      'uuid': uuid,
      'team_id': teamId,
      'uploaded_by_type': 'customer',
      'image': await MultipartFile.fromFile(imagePath, filename: fileName),
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

    return PhotoSaveResponse.fromJson(responseDataMap);
  }

  /// Deletes / removes a photo by ID.
  Future<PhotoRemoveResponse> removePhoto(int id) async {
    const endpoint = ApiEndpoints.photoRemove;

    // Log the request parameters
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] Multipart POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[Form Fields]:');
    debugPrint('  id: $id');
    debugPrint('════════════════════════════════════════════════════════════════');

    final formData = FormData.fromMap({
      'id': id.toString(),
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

    return PhotoRemoveResponse.fromJson(responseDataMap);
  }
}
