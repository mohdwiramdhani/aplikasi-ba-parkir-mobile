import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_update_password_controller.dart';

class ProfileUpdatePasswordView
    extends GetView<ProfileUpdatePasswordController> {
  const ProfileUpdatePasswordView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProfileUpdatePasswordView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ProfileUpdatePasswordView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
