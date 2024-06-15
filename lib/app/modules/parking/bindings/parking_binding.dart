import 'package:get/get.dart';

import '../controllers/parking_controller.dart';

class ParkingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParkingController>(
      () => ParkingController(),
    );
  }
}
