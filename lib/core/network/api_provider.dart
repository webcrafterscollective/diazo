// lib/core/network/api_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../utils/app_exceptions.dart';
import '../controllers/auth_controller.dart';
import '../routes/routes.dart';

class ApiProvider {
  String? _getToken() {
    if (Get.isRegistered<StorageService>()) {
      return Get.find<StorageService>().getTokenSync();
    }
    print("Warning: StorageService not registered yet in ApiProvider._getToken");
    return null;
  }

  Future<void> _handleUnauthorizedAccess() async {
    print("Unauthorized access detected. Logging out.");
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      await authController.logout();
    } else {
      if (Get.isRegistered<StorageService>()) {
        await Get.find<StorageService>().clearAll();
      }
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Map<String, String> _getHeaders() {
    final token = _getToken();
    final headers = {'Accept': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    print("API Headers: $headers");
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.apiUrl + endpoint),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw ApiNotRespondingException('API not responding');
    } on UnauthorisedException {
      await _handleUnauthorizedAccess();
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, String>? fields, List<http.MultipartFile>? files}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppConstants.apiUrl + endpoint));
      request.headers.addAll(_getHeaders());

      if (fields != null) {
        request.fields.addAll(fields);
      }
      if (files != null) {
        request.files.addAll(files);
      }

      print("API POST Request: ${request.method} ${request.url}");
      print("API POST Fields: ${request.fields}");

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw ApiNotRespondingException('API not responding');
    } on UnauthorisedException {
      await _handleUnauthorizedAccess();
      rethrow;
    } on AppException catch (e) {
      print("AppException in POST: ${e.message}");
      rethrow;
    } catch (e) {
      print("Generic Error in POST: $e");
      throw FetchDataException('An unexpected error occurred during the request.');
    }
  }

  dynamic _processResponse(http.Response response) {
    print("API Response Status Code: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    dynamic responseJson;
    try {
      responseJson = json.decode(response.body);
    } catch (e) {
      print("Failed to decode JSON response body: $e");
      // Handle common error codes without valid JSON body first
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw UnauthorisedException('Unauthorized or Forbidden (${response.statusCode})');
      }
      if (response.statusCode == 404) {
        throw FetchDataException('Resource not found (404)');
      }
      if (response.statusCode >= 500) {
        throw FetchDataException('Server Error: ${response.statusCode}');
      }
      // Throw generic error if JSON parsing failed for other codes
      throw FetchDataException('Error processing response: Invalid format or status ${response.statusCode}');
    }

    // Check if responseJson is a map, needed for type/text checking
    if (responseJson is! Map<String, dynamic>) {
      print("Error: API response is not a valid JSON object.");
      // Handle non-map JSON responses based on status code
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // If success status but not a map, decide how to handle
        return responseJson; // Example: return as is if expected
      }
      throw FetchDataException('Received unexpected response format with status: ${response.statusCode}');
    }


    // Extract type and text, default to empty strings if null
    final String type = responseJson['type'] as String? ?? '';
    final String text = responseJson['text'] as String? ?? 'An unknown error occurred.';

    // --- Main Logic based on Status Code and 'type' field ---
    switch (response.statusCode) {
      case 200: // OK
      case 201: // Created
        if (type == 'success') {
          // Success case
          return responseJson;
        } else {
          // Treat non-'success' type with 2xx status as an application error
          print("API Warning: Status ${response.statusCode} but type is '$type'. Treating as error.");
          // Use 'text' field for the error message
          throw BadRequestException(text); // Or a more specific exception if needed
        }

      case 400: // Bad Request
      // Use 'text' field from response if available, otherwise default message
        throw BadRequestException(text);
      case 401: // Unauthorized
      case 403: // Forbidden
      // Use 'text' field from response if available, otherwise default message
        throw UnauthorisedException(text);
      case 422: // Unprocessable Entity (Validation Errors)
        String errorMessage = text; // Start with the main text message
        if (responseJson.containsKey('errors') && responseJson['errors'] is Map) {
          // Append specific validation errors if provided
          final errors = responseJson['errors'] as Map<String, dynamic>;
          final errorDetails = errors.entries.map((e) {
            // Handle cases where error value might be a list
            final value = e.value;
            if (value is List) return '${e.key}: ${value.join(', ')}';
            return '${e.key}: $value';
          }).join('; ');
          errorMessage += ' ($errorDetails)';
        }
        throw InvalidInputException(errorMessage);
      case 500: // Internal Server Error
      default: // Other errors (e.g., 404, 5xx)
      // Use 'text' field from response if available, otherwise default message
        throw FetchDataException('$text (Status code: ${response.statusCode})');
    }
  }
}