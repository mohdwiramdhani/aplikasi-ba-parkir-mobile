import 'package:get/get.dart';

import '../controllers/profile_update_password_controller.dart';

class ProfileUpdatePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileUpdatePasswordController>(
      () => ProfileUpdatePasswordController(),
    );
  }
}
