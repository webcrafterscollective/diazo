import 'dart:io';
import 'package:get/get.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';

class UserController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isProfileUpdated = false.obs;
  final RxBool isPasswordChanged = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  void setUser(UserModel userData) {
    user.value = userData;
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    File? image,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isProfileUpdated.value = false;

      final updatedUser = await _userRepository.updateProfile(
        name: name,
        phone: phone,
        image: image,
      );

      user.value = updatedUser;
      isProfileUpdated.value = true;

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isPasswordChanged.value = false;

      await _userRepository.changePassword(
        oldPassword: oldPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      isPasswordChanged.value = true;

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAddress(AddressModel address) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _userRepository.addAddress(address);

      // Refresh addresses list after adding new address
      await fetchAddresses();

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final addressList = await _userRepository.getAddresses();
      addresses.assignAll(addressList);

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void resetFlags() {
    isProfileUpdated.value = false;
    isPasswordChanged.value = false;
    errorMessage.value = '';
  }
}