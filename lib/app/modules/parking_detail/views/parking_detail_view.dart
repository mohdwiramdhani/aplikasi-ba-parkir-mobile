import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/parking_detail_controller.dart';

class ParkingDetailView extends GetView<ParkingDetailController> {
  ParkingDetailView({Key? key}) : super(key: key);
  final Map<String, dynamic> data = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Parkir'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "${DateFormat.yMMMMEEEEd('id_ID').format(DateTime.parse(data['entryTime']))}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildColumn("Masuk", data['entryTime']),
                    _buildColumn("Keluar", data['exitTime']),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.blue, // Ubah warna ikon
                    ),
                    SizedBox(width: 5),
                    Text(
                      data["location"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (data['slot'] != null)
                      _buildDetailBox(
                        "Slot",
                        data['slot'],
                      ),
                    if (data['floor'] != null)
                      _buildDetailBox(
                        "Lantai",
                        data['floor'],
                      ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (data['total'] != null)
                      _buildDetailBox(
                        "Durasi",
                        "${data['total']['hours'].toString().padLeft(2, '0')}:${data['total']['minutes'].toString().padLeft(2, '0')}:${data['total']['seconds'].toString().padLeft(2, '0')}",
                      ),
                    if (data['price'] != null)
                      _buildDetailBox(
                        "Harga",
                        "Rp. ${NumberFormat.decimalPattern().format(data['price'])}",
                      ),
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String title, String? time) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          time == null
              ? "-"
              : "${DateFormat('HH:mm:ss').format(DateTime.parse(time))}",
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDetailBox(String label, String text) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
