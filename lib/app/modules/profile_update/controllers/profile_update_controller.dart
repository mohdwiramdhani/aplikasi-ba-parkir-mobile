import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileUpdateController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<String> selectedVehicle = "Mobil".obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseStorage storage = FirebaseStorage.instance;

  final ImagePicker picker = ImagePicker();

  final TextEditingController nameC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  // final TextEditingController vehicleC = TextEditingController();
  final TextEditingController plateC = TextEditingController();

  XFile? image;

  void pickImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print(image!.name);
      print(image!.path.split(".").last);
      print(image!.path);
    } else {
      print(image);
    }
    update();
  }

  Future<void> updateProfile(String uid) async {
    if (nameC.text.isNotEmpty &&
        phoneC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        Map<String, dynamic> data = {
          "name": nameC.text,
          "phone": phoneC.text,
          "vehicle": selectedVehicle.value,
          "plate": plateC.text.toUpperCase(),
        };
        if (image != null) {
          File file = File(image!.path);
          String ext = image!.path.split(".").last;
          await storage.ref('$uid/profile.$ext').putFile(file);
          String urlImage =
              await storage.ref('$uid/profile.$ext').getDownloadURL();

          data.addAll({"profile": urlImage});
        }
        await firestore.collection("users").doc(uid).update(data);

        Get.back();
        Get.snackbar("Berhasil", "berhasil perbarui profil");
      } catch (e) {
        Get.snackbar("Terjadi kesalahan", "Tidak dapat update profile");
      } finally {
        isLoading.value = false;
      }
    }
  }
}
