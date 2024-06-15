import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/parking_location_controller.dart';

class ParkingLocationView extends GetView<ParkingLocationController> {
  const ParkingLocationView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkingLocationView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ParkingLocationView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
