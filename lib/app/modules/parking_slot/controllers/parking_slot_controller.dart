import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ParkingSlotController extends GetxController {
  RxString userPlate = ''.obs;
  List<int> positionList = [];
  List<String> codeList = [];
  List<String> statusList = []; // Tambahkan list status

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> streamUser() async* {
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

  Future<void> fetchUserPlate() async {
    try {
      String uid = auth.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await firestore.collection("users").doc(uid).get();

      if (userSnapshot.exists) {
        userPlate.value = userSnapshot.data()?["plate"] ?? "";
      }
    } catch (e) {
      // Handle error
      print("Error fetching user plate: $e");
    }
  }

  Future<void> fetchDataFromFirestore() async {
    String uid = "h08P4LepcqgAy0OmVROZxI0ppIw1";
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("mitras")
          .doc(uid)
          .collection("slot")
          .get();

      List<int> positionSlotdata = snapshot.docs.map((doc) {
        return int.parse(doc["positionSlot"].toString());
      }).toList();

      List<String> codeSlotData = snapshot.docs.map((doc) {
        return doc["codeSlot"].toString();
      }).toList();

      List<String> statusSlotData = snapshot.docs.map((doc) {
        return doc["status"].toString();
      }).toList();

      positionList = positionSlotdata;
      codeList = codeSlotData;
      statusList = statusSlotData; // Simpan statusSlot dalam statusList
    } catch (e) {
      // Handle error
    }
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

  Stream<Map<String, dynamic>> totalEntranceStream() {
    String uid = "h08P4LepcqgAy0OmVROZxI0ppIw1";
    return FirebaseFirestore.instance
        .collection("mitras")
        .doc(uid)
        .collection("parking")
        .where("status", isEqualTo: "Masuk") // Filter hanya status "Masuk"
        .snapshots()
        .map((snapshot) {
      int entranceData = snapshot.size;
      return {"jumlahMasuk": entranceData}; // Ganti kunci dengan "jumlahMasuk"
    });
  }

  Stream<Map<String, dynamic>> totalSlotStream() {
    String uid = "h08P4LepcqgAy0OmVROZxI0ppIw1";
    return FirebaseFirestore.instance
        .collection("mitras")
        .doc(uid)
        .collection("slot")
        .snapshots()
        .map((snapshot) {
      int slotData = snapshot.size;
      return {"jumlahSlot": slotData}; // Ganti kunci dengan "jumlahSlot"
    });
  }

  Future<void> updateUserParkingData(String codeSlot) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      String uid = auth.currentUser!.uid;

      // Reference to the parking collection for the current user
      CollectionReference<Map<String, dynamic>> parkingCollection =
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('parking');

      // Mengecek apakah dokumen parkir sebelumnya sudah ada
      QuerySnapshot<Map<String, dynamic>> lastParkingSnapshot =
          await parkingCollection
              .orderBy('entryTime', descending: true)
              .limit(1)
              .get();

      DocumentSnapshot<Map<String, dynamic>> lastParkingDoc =
          lastParkingSnapshot.docs.first;
      Map<String, dynamic> lastParkingData = lastParkingDoc.data() ?? {};

      // Update the document with the specified lastParkingDocId
      await parkingCollection.doc(lastParkingDoc.id).update({
        'slot': codeSlot,
        'floor': "Lantai 1",
      });

      String mitraID = "h08P4LepcqgAy0OmVROZxI0ppIw1";

      CollectionReference<Map<String, dynamic>> parkingMitraCollection =
          firestore.collection('mitras').doc(mitraID).collection('parking');

      QuerySnapshot<Map<String, dynamic>> mitraParkingSnapshot =
          await parkingMitraCollection
              .where('userUID', isEqualTo: auth.currentUser!.uid)
              .where('status', isEqualTo: 'Masuk')
              .limit(1)
              .get();

      if (mitraParkingSnapshot.docs.isNotEmpty) {
        // Jika ada dokumen yang sesuai, update dokumen tersebut
        String mitraParkingDocId = mitraParkingSnapshot.docs.first.id;
        await parkingMitraCollection.doc(mitraParkingDocId).update({
          'slot': codeSlot,
          'floor': "Lantai 1",
        });
      }

      print('User parking data updated successfully');
    } catch (e) {
      // Handle error
      print('Error updating user parking data: $e');
    }
  }

  
}
