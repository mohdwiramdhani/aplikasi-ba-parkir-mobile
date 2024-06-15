import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skripsi_ba_parkir/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;

  final TextEditingController saldoC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser() async* {
    String uid = auth.currentUser!.uid;

    yield* firestore.collection("users").doc(uid).snapshots();
  }

  Future<void> topUpSaldo() async {
    String uid = await auth.currentUser!.uid;
    try {
      // Ambil nilai saldo saat ini dari Firebase Firestore
      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        double currentSaldo = userData?["balance"]?.toDouble() ?? 0.0;

// Ambil nilai yang akan ditambahkan dari TextField
        double saldoToAdd = double.tryParse(saldoC.text) ?? 0.0;

// Hitung saldo baru
        double newSaldo = currentSaldo + saldoToAdd;

        // Perbarui nilai saldo di Firebase Firestore
        await firestore
            .collection("users")
            .doc(uid)
            .update({"balance": newSaldo});
        print("Saldo berhasil diperbarui");
        Get.back();
      } else {
        print("Dokumen pengguna tidak ditemukan");
      }
    } catch (e) {
      print("Gagal memperbarui saldo: $e");
    }
  }

  void logout() async {
    await auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
