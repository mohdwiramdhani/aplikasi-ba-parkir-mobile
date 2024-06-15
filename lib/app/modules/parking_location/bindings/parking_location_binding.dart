import 'package:get/get.dart';

import '../controllers/parking_location_controller.dart';

class ParkingLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParkingLocationController>(
      () => ParkingLocationController(),
    );
  }
}
