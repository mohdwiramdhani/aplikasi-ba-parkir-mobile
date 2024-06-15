import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  RxBool isHidden = true.obs;
  RxBool isLoading = false.obs;

  TextEditingController nameC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  TextEditingController confirmPasswordC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void togglePasswordVisibility() {
    isHidden.toggle();
  }

  void register() async {
    try {
      if (nameC.text.isNotEmpty &&
          phoneC.text.isNotEmpty &&
          emailC.text.isNotEmpty &&
          passwordC.text.isNotEmpty &&
          confirmPasswordC.text.isNotEmpty) {
        // Validasi password minimal 6 karakter
        if (passwordC.text.length < 6) {
          Get.snackbar(
            "Password Lemah",
            "Password harus terdiri dari minimal 6 karakter.",
          );
          return;
        }

        // Validasi konfirmasi password
        if (passwordC.text != confirmPasswordC.text) {
          Get.snackbar(
            "Password Tidak Cocok",
            "Konfirmasi password tidak sesuai.",
          );
          return;
        }

        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: passwordC.text,
        );

        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;

          isLoading.value = true;

          await firestore.collection("users").doc(uid).set({
            "name": nameC.text,
            "phone": phoneC.text,
            "email": emailC.text,
            "plate": "",
            "uid": uid,
            "role": "user",
            "createAt": DateTime.now().toIso8601String(),
          });

          await userCredential.user!.sendEmailVerification();

          isLoading.value = false;

          Get.back();

          Get.snackbar("Berhasil", "Berhasil daftar akun");
        } else {
          Get.snackbar(
            "Terjadi kesalahan",
            "Gagal melakukan pendaftaran, silahkan hubungi admin.",
          );
        }
      } else {
        Get.snackbar("Terjadi kesalahan", "Data wajib di isi.");
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        Get.snackbar(
          "Email Sudah Ada",
          "Email sudah terdaftar, gunakan email lain.",
        );
      } else {
        Get.snackbar(
          "Terjadi kesalahan",
          "Gagal melakukan pendaftaran, silahkan hubungi admin.",
        );
      }
    }
  }
}
