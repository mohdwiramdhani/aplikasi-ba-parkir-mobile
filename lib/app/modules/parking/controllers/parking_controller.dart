import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch data from the "mitras" collection
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamMitra() async* {
    String uid = "h08P4LepcqgAy0OmVROZxI0ppIw1";
    yield* firestore.collection("mitras").doc(uid).snapshots();
  }

  // Fetch data from the "slot" sub-collection and count the documents
  Future<int> countSlots() async {
    String uid = "h08P4LepcqgAy0OmVROZxI0ppIw1";
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection("mitras").doc(uid).collection("slot").get();

    return snapshot.size;
  }
}
