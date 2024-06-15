import 'package:get/get.dart';

import '../controllers/parking_history_controller.dart';

class ParkingHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParkingHistoryController>(
      () => ParkingHistoryController(),
    );
  }
}
