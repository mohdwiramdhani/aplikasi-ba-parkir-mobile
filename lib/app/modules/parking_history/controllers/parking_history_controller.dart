import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ParkingHistoryController extends GetxController {
  DateTime? start;
  DateTime end = DateTime.now();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getAllParking() async {
    String uid = auth.currentUser!.uid;

    if (start == null) {
      // Mendapatkan seluruh data parkir
      return await firestore
          .collection("users")
          .doc(uid)
          .collection("parking")
          .where("entryTime", isLessThan: end.toIso8601String())
          .orderBy("entryTime", descending: true)
          .get();
    } else {
      // Memfilter data berdasarkan rentang waktu entryTime
      return await firestore
          .collection("users")
          .doc(uid)
          .collection("parking")
          .where("entryTime", isGreaterThan: start!.toIso8601String())
          .where("entryTime",
              isLessThan: end.add(Duration(days: 1)).toIso8601String())
          .orderBy("entryTime", descending: true)
          .get();
    }
  }

  void pickDate(DateTime pickStart, DateTime pickEnd) {
    start = pickStart;
    end = pickEnd;
    update();
    Get.back();
  }
}
