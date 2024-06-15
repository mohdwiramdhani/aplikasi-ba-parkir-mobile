import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_update_controller.dart';

class ProfileUpdateView extends GetView<ProfileUpdateController> {
  final Map<String, dynamic> user = Get.arguments;
  @override
  Widget build(BuildContext context) {
    controller.nameC.text = user["name"];
    controller.phoneC.text = user["phone"];
    controller.emailC.text = user["email"];
    controller.plateC.text = user["plate"] ?? "";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perbarui Profil'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            keyboardType: TextInputType.name,
            controller: controller.nameC,
            decoration: InputDecoration(
              labelText: "Nama Lengkap",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            keyboardType: TextInputType.phone,
            // readOnly: true,
            controller: controller.phoneC,
            decoration: InputDecoration(
              labelText: "Nomor HP",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
            controller: controller.emailC,
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          DropdownButtonFormField<String>(
            value: controller.selectedVehicle.value,
            onChanged: (newValue) {
              controller.selectedVehicle.value = newValue!;
            },
            items: ["Mobil", "Motor"].map<DropdownMenuItem<String>>(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value == "Motor"
                          ? Colors.grey
                          : null, // Tambahkan warna abu-abu untuk item "Motor"
                    ),
                  ),
                  enabled: value != "Motor",
                );
              },
            ).toList(),
            decoration: InputDecoration(
              labelText: "Jenis Kendaraan",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            keyboardType: TextInputType.name,
            controller: controller.plateC,
            decoration: InputDecoration(
              labelText: "Nomor Plat",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Foto",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // user["profile"] != null && user["profile"] != ""
              //     ? Text("ada data")
              //     : Text("no choosen"),
              GetBuilder<ProfileUpdateController>(
                builder: (c) {
                  if (c.image != null) {
                    return ClipOval(
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Image.file(
                          File(c.image!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    if (user["profile"] != null) {
                      return ClipOval(
                        child: Container(
                          height: 100,
                          width: 100,
                          child: Image.network(
                            user["profile"],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                    {
                      return Text("Belum Ada");
                    }
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  controller.pickImage();
                },
                style: ButtonStyle(
                  side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(
                      color: Color.fromARGB(
                          150, 33, 149, 243), // Set the border color
                      width: 2.0, // Set the border width (tambahan ketebalan)
                    ),
                  ),
                ),
                child: Text(
                  "Pilih File",
                  style: TextStyle(
                    color: const Color.fromARGB(
                        200, 33, 149, 243), // Set the text color
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Obx(() => ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.updateProfile(user["uid"]);
                  }
                },
                // child: Text("send reset password"),
                child:
                    Text(controller.isLoading.isFalse ? "SIMPAN" : "LOADING"),
              )),
        ],
      ),
    );
  }
}
