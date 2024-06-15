import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  final _stopwatch = Stopwatch()..start();
  RxBool isRunning = false.obs;
  final TextEditingController saldoC = TextEditingController();

  // Map to store stopwatches for each parking entry
  final Map<String, Stopwatch> _stopwatches = {};

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser() async* {
    String uid = await auth.currentUser!.uid;

    yield* firestore.collection("users").doc(uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamParking() {
    String uid = auth.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('parking')
        .orderBy('entryTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamEntranceInformation() {
    String uid = auth.currentUser!.uid;

    return firestore
        .collection('users')
        .doc(uid)
        .collection('parking')
        .where('status',
            isEqualTo: 'Masuk') // Hanya dokumen dengan status 'Masuk'
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamLastParking() async* {
    String uid = await auth.currentUser!.uid;

    yield* firestore
        .collection("users")
        .doc(uid)
        .collection("parking")
        .orderBy("entryTime",
            descending:
                true) //set yang terakhir paling duluan muncul atau desc asc
        //kenapa masih bukan tanggal terakahir / skip akhir
        // .limitToLast(5)
        .limit(5)
        .snapshots();
  }

  void toggleStopwatch() {
    if (isRunning.value) {
      _stopwatch.stop();
      print("stop");
    } else {
      _stopwatch.start();
      print("start");
    }
    isRunning.toggle();
  }

  String get formattedTime {
    final duration = _stopwatch.elapsed;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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

// Method to get or create a stopwatch for a parking entry
  Stopwatch _getStopwatch(String entryId) {
    if (!_stopwatches.containsKey(entryId)) {
      _stopwatches[entryId] = Stopwatch()..start();
    }
    return _stopwatches[entryId]!;
  }

  // Method to get the elapsed time for a parking entry
  String getElapsedTime(String entryId) {
    final duration = _getStopwatch(entryId).elapsed;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void call(String phoneNumber) async {
    String url = 'tel:$phoneNumber';

    try {
      await launch(url);
    } catch (e) {
      print('Error launching phone call: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSlot(String mitraUid) {
    String mitraID = "h08P4LepcqgAy0OmVROZxI0ppIw1";
    return firestore
        .collection('mitras')
        .doc(mitraID)
        .collection('slot')
        .snapshots();
  }

  Stream<Map<int, Map<String, String>>> positionListStream() {
    String uid = "h08P4LepcqgAy0OmVROZxI0ppIw1";
    return FirebaseFirestore.instance
        .collection("mitras")
        .doc(uid)
        .collection("slot")
        .snapshots()
        .map((snapshot) {
      final Map<int, Map<String, String>> positionData = {};

      for (var doc in snapshot.docs) {
        int position = int.parse(doc["positionSlot"].toString());
        String codeSlot = doc["codeSlot"].toString();
        String status = doc["status"].toString();
        String plat = doc["plat"].toString();

        // Filter hanya untuk status "on" dan "off"
        if (status == "on" || status == "off") {
          positionData[position] = {
            "codeSlot": codeSlot,
            "status": status,
            "plat": plat
          };
        }
      }

      return positionData;
    });
  }

    Stream<Map<String, dynamic>> streamUserMulti() async* {
    String uid = await auth.currentUser!.uid;

    yield* firestore
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.data() ??
          {}; // Mengembalikan Map kosong jika data tidak ada
    });
  }

    Stream<QuerySnapshot<Map<String, dynamic>>> streamParkingMulti() {
    String uid = auth.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('parking')
        .orderBy('entryTime', descending: true)
        .snapshots();
  }
}
