import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skripsi_ba_parkir/app/controllers/page_index_controller.dart';
import 'package:skripsi_ba_parkir/app/routes/app_pages.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  final pageC = Get.find<PageIndexController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: controller.streamUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                Map<String, dynamic> user = snapshot.data!.data()!;
                String defaultImage =
                    "https://ui-avatars.com/api/?name=${user['name']}";
                return ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Container(
                            height: 100,
                            width: 100,
                            child: Image.network(
                              user["profile"] != null
                                  ? user["profile"] != ""
                                      ? user["profile"]
                                      : defaultImage
                                  : defaultImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "${user['name'].toString().toUpperCase()}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${user['email']}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(),
                    buildTopUpSection(),
                    Divider(),
                    ListTile(
                      onTap: () => Get.toNamed(
                        Routes.PROFILE_UPDATE,
                        arguments: user,
                      ),
                      leading: Icon(Icons.person),
                      title: Text("Ubah Profil"),
                    ),
                    // ListTile(
                    //   onTap: () {
                    //     Get.toNamed(Routes.PROFILE_UPDATE_PASSWORD);
                    //   },
                    //   leading: Icon(Icons.vpn_key),
                    //   title: Text("Ubah Password"),
                    // ),
                    // if (user["role"] == "admin")
                    //   ListTile(
                    //     onTap: () => Get.toNamed(Routes.ADD_PEGAWAI),
                    //     leading: Icon(Icons.person_add),
                    //     title: Text("Add Pegawai"),
                    //   ),
                    ListTile(
                      onTap: () => controller.logout(),
                      leading: Icon(Icons.logout),
                      title: Text("Keluar"),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: Text("Tidak dapa memuat data user"),
                );
              }
            }),
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
        ));
  }

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                                MaterialStateProperty.all<
                                                    Color>(Colors.grey),
                                          ),
                                          child: Text(
                                            'Batal',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.topUpSaldo();
                                            Get.back(); // Tutup dialog setelah top-up
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.blue),
                                          ),
                                          child: Text(
                                            'Ya',
                                            style:
                                                TextStyle(color: Colors.white),
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
            ),
          );
        },
      ),
    );
  }
}
