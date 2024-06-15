import 'package:skripsi_ba_parkir/app/controllers/page_index_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:skripsi_ba_parkir/app/routes/app_pages.dart';

import '../controllers/parking_history_controller.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ParkingHistoryView extends GetView<ParkingHistoryController> {
  ParkingHistoryView({Key? key}) : super(key: key);
  final pageC = Get.find<PageIndexController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Parkir'),
        centerTitle: true,
      ),
      body: GetBuilder<ParkingHistoryController>(
        builder: (c) => FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: controller.getAllParking(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data?.docs.length == 0 ||
                  snapshot.data?.docs == null) {
                return SizedBox(
                  height: 150,
                  child: Center(
                    child: Text("Belum ada riwayat parkir"),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = snapshot.data!.docs[index].data();
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
            }),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(Dialog(
            child: Container(
              padding: EdgeInsets.all(20),
              height: 400,
              child: SfDateRangePicker(
                monthViewSettings:
                    DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
                selectionMode: DateRangePickerSelectionMode.range,
                showActionButtons: true,
                onCancel: () => Get.back(),
                onSubmit: (p0) {
                  if (p0 != null) {
                    if ((p0 as PickerDateRange).endDate != null) {
                      controller.pickDate(p0.startDate!, p0.endDate!);
                    }
                  }
                },
              ),
            ),
          ));
        },
        child: Icon(Icons.format_list_numbered_rounded),
      ),
    );
  }
}
