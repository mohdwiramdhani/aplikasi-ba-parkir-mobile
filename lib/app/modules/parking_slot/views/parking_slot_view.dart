import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:dotted_border/dotted_border.dart';

import '../controllers/parking_slot_controller.dart';

class ParkingSlotView extends GetView<ParkingSlotController> {
  ParkingSlotView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slot Parkir'),
        centerTitle: true,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: rx.Rx.combineLatest2(
          controller.positionListStream(),
          controller.streamUser(),
          (positionData, userData) {
            // Di sini, Anda dapat mengakses data positionData dan userData
            // Sesuaikan dengan kebutuhan logika aplikasi Anda
            return {
              "positionData": positionData,
              "userData": userData,
            };
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Dapatkan data position dan user
            Map<int, Map<String, String>> positionData =
                snapshot.data!['positionData'];
            Map<String, dynamic> userData = snapshot.data!['userData'];

            // Dapatkan nilai plat dari data user
            String userPlate = userData['plate'];

            return ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    StreamBuilder<Map<String, dynamic>>(
                      stream: rx.Rx.combineLatest2(
                        controller.totalEntranceStream(),
                        controller.totalSlotStream(),
                        (entranceData, slotData) => {
                          "totalEntrance":
                              entranceData, // Sesuaikan dengan kunci yang benar
                          "totalSlot":
                              slotData, // Sesuaikan dengan kunci yang benar
                        },
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Map<String, dynamic> totalEntrance =
                              snapshot.data!["totalEntrance"];
                          Map<String, dynamic> totalSlot =
                              snapshot.data!["totalSlot"];

                          int jumlahMasuk = totalEntrance["jumlahMasuk"];
                          int jumlahSlot = totalSlot["jumlahSlot"];

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.people,
                                            color: Colors.blue,
                                            size: 30,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Jumlah Pengunjung Masuk : ",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "$jumlahMasuk / $jumlahSlot",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 4.0, right: 4.0, top: 20, bottom: 20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Handle basement selection
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2.0,
                                  ),
                                ),
                                child: Text(
                                  'Basement',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle floor 1 selection
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2.0,
                                  ),
                                ),
                                child: Text(
                                  'Lantai 1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle floor 2 selection
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2.0,
                                  ),
                                ),
                                child: Text(
                                  'Lantai 2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle floor 3 selection
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2.0,
                                  ),
                                ),
                                child: Text(
                                  'Lantai 3',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle floor 4 selection
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2.0,
                                  ),
                                ),
                                child: Text(
                                  'Lantai 4',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          3,
                          (columnIndex) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: List.generate(
                                9,
                                (rowIndex) {
                                  int number =
                                      columnIndex * 9 + (8 - rowIndex) + 1;

                                  // Periksa apakah nomor slot ada dalam data
                                  if (positionData.containsKey(number)) {
                                    String codeSlotText =
                                        positionData[number]!["codeSlot"]
                                            .toString();
                                    String status =
                                        positionData[number]!["status"]
                                            .toString();
                                    String plat = positionData[number]!["plat"]
                                        .toString();

                                    FirebaseAuth auth = FirebaseAuth.instance;

                                    String uid = auth.currentUser!.uid;

                                    // Inside your onTap event or where appropriate
                                    if (plat == userPlate) {
                                      print(
                                          "Updating user parking data for codeSlotText: $codeSlotText");
                                      // Assuming you have the lastParkingDocId and codeSlotText
                                      controller
                                          .updateUserParkingData(codeSlotText);
                                    }

                                    Color boxColor = (status == "on")
                                        ? (plat == userPlate)
                                            ? const Color.fromARGB(80, 244, 67,
                                                54) // Berikan warna biru jika plat sesuai dengan userPlate
                                            : const Color.fromARGB(
                                                80, 244, 67, 54)
                                        : const Color.fromARGB(80, 76, 175, 79);

                                    // Color boxColor = (status == "on")
                                    //     ? (plat == userPlate)
                                    //         ? const Color.fromARGB(110, 33, 149,
                                    //             243) // Berikan warna biru jika plat sesuai dengan userPlate
                                    //         : const Color.fromARGB(
                                    //             80, 244, 67, 54)
                                    //     : const Color.fromARGB(80, 76, 175, 79);

                                    return GestureDetector(
                                      onTap: () {
                                        // Handle slot tap
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    Color.fromARGB(60, 0, 0, 0),
                                                width: 2.0,
                                              ),
                                              color: boxColor,
                                              borderRadius:
                                                  BorderRadius.circular(9.0),
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                AnimatedOpacity(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  opacity: (status == "on")
                                                      ? 1.0
                                                      : 0.0,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      if (status == "on")
                                                        Image.asset(
                                                          'assets/img/car3.png',
                                                          width: 75,
                                                          height: 35,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      if (codeSlotText
                                                          .isNotEmpty)
                                                        SizedBox(
                                                          width: 75,
                                                          height: 50,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  codeSlotText,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      margin: EdgeInsets.all(8.0),
                                      child: DottedBorder(
                                        borderType: BorderType.RRect,
                                        color: Color.fromARGB(40, 0, 0, 0),
                                        strokeWidth: 2.0,
                                        radius: Radius.circular(9.0),
                                        dashPattern: [10, 5],
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 90,
                                                  height: 50,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
