import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:path/path.dart';

import '../constants/app_constants.dart';
import '../models/address_model.dart';
import '../models/user_model.dart';
import '../network/api_provider.dart';


class UserRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    File? image,
  }) async {
    final fields = {
      'name': name,
      'phone': phone,
    };

    List<http.MultipartFile>? files;

    if (image != null) {
      final fileStream = http.ByteStream(image.openRead());
      final length = await image.length();

      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        length,
        filename: basename(image.path),
      );

      files = [multipartFile];
    }

    final response = await _apiProvider.post(
      AppConstants.profileEndpoint,
      fields: fields,
      files: files,
    );

    return UserModel.fromJson(response['data']);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final fields = {
      'old_password': oldPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    await _apiProvider.post(
      AppConstants.passwordEndpoint,
      fields: fields,
    );
  }

  Future<void> addAddress(AddressModel address) async {
    await _apiProvider.post(
      AppConstants.addAddressEndpoint,
      fields: address.toJson(),
    );
  }

  Future<List<AddressModel>> getAddresses() async {
    final response = await _apiProvider.post(AppConstants.getAddressEndpoint);

    List<AddressModel> addresses = [];
    for (var item in response['data']) {
      addresses.add(AddressModel.fromJson(item));
    }

    return addresses;
  }
}
