import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skripsi_ba_parkir/app/controllers/page_index_controller.dart';
import 'package:skripsi_ba_parkir/app/routes/app_pages.dart';
import 'package:skripsi_ba_parkir/app/widgets/abc.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final pageC = Get.find<PageIndexController>();
  HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: controller.streamUser(),
          builder: (context, snapUser) {
            if (snapUser.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            Map<String, dynamic> user = snapUser.data!.data()!;

            return Row(
              children: [
                Icon(Icons.person_2_outlined),
                SizedBox(
                  width: 10,
                ),
                RichText(
                  text: TextSpan(
                    text: "Hai, ",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 17,
                    ),
                    children: [
                      TextSpan(
                        text: user["name"].toString().length > 12
                            ? user["name"].toString().substring(0, 12) + '...'
                            : user["name"],
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // pageC.abc();
            },
            icon: Icon(Icons.notifications_none_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          // Bagian Informasi Parkir
          buildParkingInfo(),
          SizedBox(
            height: 20,
          ),
          // Bagian Informasi Kendaraan
          buildVehicleInfo(),
          SizedBox(
            height: 20,
          ),
          // Bagian Notifikasi
          buildNotificationSection(),
          SizedBox(
            height: 20,
          ),
          // Bagian Isi Saldo
          // buildTopUpSection(),
          SizedBox(
            height: 20,
          ),
          // Bagian Riwayat Parkir
          buildParkingHistorySection(),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.local_parking, title: 'Parkir'),
          TabItem(icon: Icons.payment, title: 'Add'),
          TabItem(icon: Icons.history, title: 'Riwayat'),
          TabItem(icon: Icons.people, title: 'Profile'),
        ],
        initialActiveIndex: pageC.pageIndex.value,
        onTap: (int i) => pageC.changePage(i),
      ),
    );
  }

  // Metode untuk membangun bagian informasi parkir
  Widget buildParkingInfo() {
    return Container(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.streamParking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            List<DocumentSnapshot<Map<String, dynamic>>> parkingDataList =
                snapshot.data!.docs;

            // Check if there are any documents
            if (parkingDataList.isNotEmpty) {
              Map<String, dynamic> parkingData =
                  parkingDataList.first.data() ?? {};

              // Check if the parking status is 'Masuk'
              if (parkingData['status'] == 'Masuk') {
                // Extract vehicle and plate information
                String location = parkingData['location'] ?? "-";
                String address = parkingData['address'] ?? "-";
                String slot = parkingData['slot'] ?? "-";
                String floor = parkingData['floor'] ?? "-";

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth: 200), // Set your maximum width
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          constraints: BoxConstraints(
                              maxWidth: 200), // Set your maximum width
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth: 200), // Set your maximum width
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: Colors.grey,
                          width: 150,
                          height: 1,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          constraints: BoxConstraints(
                              maxWidth: 200), // Set your maximum width
                          child: Text(
                            floor,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Jika status parkir bukan 'Masuk', tampilkan sesuatu yang sesuai
                return SizedBox();
              }
            } else {
              // Handle the case when parkingDataList is empty
              return SizedBox();
            }
          }

          return SizedBox();
        },
      ),
    );
  }

// Metode untuk membangun bagian informasi kendaraan
  Widget buildVehicleInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300],
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.streamParking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            List<DocumentSnapshot<Map<String, dynamic>>> parkingDataList =
                snapshot.data!.docs;

            // Check if there are any documents
            if (parkingDataList.isNotEmpty) {
              Map<String, dynamic> parkingData =
                  parkingDataList.first.data() ?? {};

              // Check if the parking status is 'Masuk'
              if (parkingData['status'] == 'Masuk') {
                // Extract vehicle and plate information
                String vehicle = parkingData['vehicle'] ?? "Jenis Kosong";
                String plate = parkingData['plate'] ?? "Plat Kosong";
                String price =
                    "Rp. ${NumberFormat.decimalPattern().format(parkingData['priceDefault'])}";

                String entryTime = parkingData['entryTime'] ?? "";

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            vehicle.isNotEmpty ? vehicle : "Kendaraan Kosong",
                            style: TextStyle(
                              fontSize: vehicle.isNotEmpty ? 20 : 14,
                              fontWeight: FontWeight.bold,
                              fontStyle: vehicle.isNotEmpty
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              color: vehicle.isNotEmpty
                                  ? Colors.black
                                  : const Color.fromARGB(120, 0, 0, 0),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            plate.isNotEmpty ? plate : "Plat Kosong",
                            style: TextStyle(
                              fontSize: plate.isNotEmpty ? 20 : 14,
                              fontWeight: FontWeight.bold,
                              fontStyle: plate.isNotEmpty
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              color: plate.isNotEmpty
                                  ? Colors.black
                                  : const Color.fromARGB(120, 0, 0, 0),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
// Use StopwatchWidget here
                          RunningTimeWidget(
                            entryTime: DateTime.parse(entryTime),
                          ),

                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            color: Colors.grey,
                            width: 150,
                            height: 1,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "$price",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Text(
                          //   "$price / hari",
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                // Jika status parkir bukan 'Masuk', tampilkan sesuatu yang sesuai
                return Container(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 150,
                        child: Text(
                          "Mulai parkir dengan memindai kode QR.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.grey,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          pageC.handleParking();
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          minimumSize: MaterialStateProperty.all(Size(70, 70)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue.withOpacity(0.7),
                          ),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 40,
                        ),
                      )
                    ],
                  ),
                );
              }
            } else {
              // Jika status parkir bukan 'Masuk', tampilkan sesuatu yang sesuai
              return Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 150,
                      child: Text(
                        "Mulai parkir dengan memindai kode QR.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        pageC.handleParking();
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all(Size(70, 70)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue
                              .withOpacity(0.7), // Blue color with 0.5 opacity
                        ),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 40,
                      ),
                    )
                  ],
                ),
              );
            }
          } else {
            print("object");
          }

          return SizedBox();
        },
      ),
    );
  }

// Metode untuk membangun bagian notifikasi
  Widget buildNotificationSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300],
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.streamEntranceInformation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            List<DocumentSnapshot<Map<String, dynamic>>> parkingDataList =
                snapshot.data!.docs;

            print(parkingDataList);

            if (parkingDataList.isEmpty) {
              print("List kosong");
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Colors.black,
                        size: 30.0, // Ganti ukuran ikon sesuai kebutuhan
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        width: 250,
                        child: Text(
                          "Anda belum parkir. Silakan pindai QR code untuk memulai.",
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text("-"),
                        ],
                      ),
                      Container(
                        width: 2,
                        height: 25,
                        color: Colors.grey,
                      ),
                      Column(
                        children: [
                          Text("-"),
                        ],
                      )
                    ],
                  ),
                ],
              );
            }

            return Column(
              children: parkingDataList
                  .map((DocumentSnapshot<Map<String, dynamic>> parkingData) {
                Map<String, dynamic> data = parkingData.data() ?? {};

                // Access the 'location' field
                String message = data['message'] ??
                    "Pesan belum ada. Mohon periksa kembali nanti. Terima kasih.";
                String phoneMitra = data['phoneMitra'] ?? "";

                // Here, you can create UI components based on the 'location' data
                // For example, you can return a ListTile with the location
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: Colors.black,
                            size: 30.0, // Ganti ukuran ikon sesuai kebutuhan
                          ),

                          SizedBox(width: 20), // Jarak antara ikon dan teks
                          Expanded(
                            child: Text(
                              '$message',
                              overflow: TextOverflow
                                  .ellipsis, // Menambahkan elipsis (...) jika teks terlalu panjang
                              maxLines: 2, // Hanya menampilkan satu baris teks
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            // Tambahkan logika ketika "Detail" diklik
                            Get.defaultDialog(
                              title: "Informasi",
                              content: Column(
                                children: [
                                  Icon(
                                    Icons.settings,
                                    color: Colors.blue,
                                    size: 60,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              confirm: ElevatedButton(
                                onPressed: () {
                                  // Tutup dialog jika tombol "OK" ditekan
                                  Get.back();
                                },
                                child: Text("OK"),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Text("Detail"),
                            ],
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 25,
                          color: Colors.grey,
                        ),
                        InkWell(
                          onTap: () {
                            // Tambahkan logika ketika "Panggil" diklik
                            controller.call(phoneMitra);
                          },
                          child: Column(
                            children: [
                              Text("Panggil"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            );
          } else {
            print("object");
          }

          print("afafasfasfas");
          return SizedBox();
        },
      ),
    );
  }

// Metode untuk membangun bagian isi saldo
  Widget buildTopUpSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300],
      ),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: controller.streamUser(),
        builder: (context, snapUser) {
          if (snapUser.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          Map<String, dynamic>? user = snapUser.data?.data();
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Memunculkan dialog "ISI SALDO"
                        Get.dialog(
                          Dialog(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Tambah Saldo',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .black, // Ganti warna teks jika diinginkan
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  TextField(
                                    controller: controller.saldoC,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    style: TextStyle(
                                        fontSize:
                                            18), // Ganti ukuran teks jika diinginkan
                                    decoration: InputDecoration(
                                      labelText: 'Jumlah Saldo',
                                      labelStyle: TextStyle(
                                          color: Colors
                                              .black), // Ganti warna label jika diinginkan
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Get.back(); // Tutup dialog
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.grey),
                                        ),
                                        child: Text(
                                          'Batal',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          controller.topUpSaldo();
                                          Get.back(); // Tutup dialog setelah top-up
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.blue),
                                        ),
                                        child: Text(
                                          'Ya',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.add_circle_outline),
                      label: Text('Isi Saldo'),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    Text(
                      "Rp ${user?["balance"] != null ? NumberFormat.decimalPattern("id_ID").format(user?["balance"]) : "0"}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    Text(
                      '${user?['points'] ?? 0} Poin',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

// Metode untuk membangun bagian riwayat parkir
  Widget buildParkingHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Riwayat parkir terakhir",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: controller.streamLastParking(),
          builder: (context, snapParking) {
            if (snapParking.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapParking.data?.docs.length == 0 ||
                snapParking.data?.docs == null) {
              return SizedBox(
                height: 150,
                child: Center(
                  child: Text("Belum ada riwayat parkir"),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapParking.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    snapParking.data!.docs[index].data();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Get.toNamed(
                        Routes.PARKING_DETAIL,
                        arguments: data,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Masuk",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${DateFormat.yMMMEd('id_ID').format(DateTime.parse(data['entryTime']))}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(data['entryTime'] == null
                                ? "-"
                                : "${DateFormat('HH:mm:ss').format(DateTime.parse(data['entryTime']))}"),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Keluar",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data['location'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(data['exitTime'] == null
                                ? "-"
                                : "${DateFormat('HH:mm:ss').format(DateTime.parse(data['exitTime']))}"),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
