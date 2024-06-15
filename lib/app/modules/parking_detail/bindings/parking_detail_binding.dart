import 'package:get/get.dart';

import '../controllers/parking_detail_controller.dart';

class ParkingDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParkingDetailController>(
      () => ParkingDetailController(),
    );
  }
}
