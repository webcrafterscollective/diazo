// lib/core/repositories/auth_repository.dart
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../network/api_provider.dart';
import '../utils/app_exceptions.dart'; // Import App Exceptions

class AuthRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<UserModel> login({required String email, required String password}) async {
    final fields = {
      'email': email,
      'password': password,
    };

    // The _apiProvider.post call will now throw specific exceptions
    // based on the response status code and 'type' field, handled by ApiProvider._processResponse
    try {
      final response = await _apiProvider.post(
        AppConstants.loginEndpoint,
        fields: fields,
      ); // This is expected to be the full JSON map on success

      print("AuthRepository Login Response (parsed): $response"); // Debug log

      // Check if the response structure is as expected for success
      if (response is Map<String, dynamic> &&
          response['type'] == 'success' &&
          response.containsKey('user') &&
          response.containsKey('token') &&
          response['user'] is Map<String, dynamic>)
      {
        // Extract the user map and the token
        final Map<String, dynamic> userMap = response['user'] as Map<String, dynamic>;
        final String? token = response['token'] as String?;

        if (token == null || token.isEmpty) {
          print("Login Error: Token is missing or empty in successful response.");
          throw FetchDataException("Login successful, but token was missing.");
        }

        // Add the token to the user map before creating the UserModel
        userMap['token'] = token;

        // Create UserModel from the combined map
        return UserModel.fromJson(userMap);

      } else {
        // This case should ideally be caught by ApiProvider._processResponse if type != 'success'
        // But as a fallback:
        print("Login Error: Unexpected success response format: $response");
        throw FetchDataException("Received an unexpected response format from the server.");
      }
    } on AppException catch (e) {
      // Re-throw AppExceptions (like BadRequestException, UnauthorisedException)
      // caught from ApiProvider for AuthController to handle
      print("AuthRepository Login caught AppException: ${e.message}");
      rethrow;
    } catch (e) {
      // Catch any other unexpected errors during the process
      print("AuthRepository Login caught generic error: $e");
      throw FetchDataException("An unexpected error occurred during login processing.");
    }
  }

  // --- Other methods (register, getOtp, verifyOtp, deleteAccount) ---
  // Ensure they also handle potential errors thrown by ApiProvider
  // For example, register might need similar parsing if its response format changed.

  Future<UserModel> register({
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final fields = {
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    try {
      final response = await _apiProvider.post(
        AppConstants.registerEndpoint,
        fields: fields,
      );
      // TODO: Adjust parsing based on the ACTUAL registration response format
      // Assuming it returns user data directly under 'data' or similar
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return UserModel.fromJson(response['data']);
      } else {
        throw FetchDataException("Unexpected registration response format.");
      }
    } on AppException catch (e) {
      rethrow;
    } catch(e) {
      throw FetchDataException("An unexpected error occurred during registration.");
    }
  }

  Future<void> getOtp({required String email, String? phone}) async {
    final fields = {'email': email};
    if (phone != null) fields['phone'] = phone;

    try {
      await _apiProvider.post(
        AppConstants.getOtpEndpoint,
        fields: fields,
      );
      // OTP endpoint might not return data, just success/error handled by ApiProvider
    } on AppException catch (e) {
      rethrow;
    } catch(e) {
      throw FetchDataException("An unexpected error occurred requesting OTP.");
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    final fields = {
      'email': email,
      'otp': otp,
    };

    try {
      final response = await _apiProvider.post(
        AppConstants.verifyOtpEndpoint,
        fields: fields,
      );
      // Assuming verifyOtp returns { "type": "success", ... } or similar
      // ApiProvider handles the error case based on type/status
      return response['type'] == 'success'; // Check type for confirmation
    } on AppException catch (e) {
      print("Verify OTP failed: ${e.message}");
      return false; // Return false on known errors
    } catch (e) {
      print("Verify OTP failed with generic error: $e");
      return false; // Return false on unexpected errors
    }
  }


  Future<void> deleteAccount({
    required String userId,
    required String password,
    String? description,
  }) async {
    final fields = {
      'user_id': userId,
      'password': password,
    };
    if (description != null) fields['description'] = description;

    try {
      await _apiProvider.post(
        AppConstants.accountDeleteEndpoint,
        fields: fields,
      );
      // Assume success if no exception is thrown by ApiProvider
    } on AppException catch (e) {
      rethrow;
    } catch(e) {
      throw FetchDataException("An unexpected error occurred deleting the account.");
    }
  }
}