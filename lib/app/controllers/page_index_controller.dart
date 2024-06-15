import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:skripsi_ba_parkir/app/routes/app_pages.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;
  final Rx<Duration> stopwatch = Rx<Duration>(Duration.zero);
  final RxBool isRunning = RxBool(false);
  late Timer timer; // Timer untuk peningkatan waktu

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    print('click index=$i');

    switch (i) {
      case 1:
        pageIndex.value = i;
        Get.offNamed(Routes.PARKING);
      case 2:
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse["error"] != true) {
          Position position = dataResponse["position"];
          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          String address =
              "${placemarks[0].street} , ${placemarks[0].subLocality}, ${placemarks[0].locality}";
          await updatePosition(position, address);

          //cek jarak distance area jangkauan antara 2 koordinat

          //parkirg
          await handleExitParking();
        } else {
          Get.snackbar("Terjadi kesalahan", dataResponse["message"]);
        }
        break;
      case 3:
        pageIndex.value = i;
        Get.offNamed(Routes.PARKING_HISTORY);
      case 4:
        pageIndex.value = i;
        Get.offNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offNamed(Routes.HOME);
    }
  }

  Future<void> handleParking() async {
    try {
      // Lakukan scanning QR code mitra
      String mitraUID = await FlutterBarcodeScanner.scanBarcode(
          "#000000", "Batal", true, ScanMode.QR);

      // Periksa apakah mitra dengan UID tersebut ada di Firestore
      bool isMitraExist = await checkMitraExistInFirestore(mitraUID);

      if (isMitraExist) {
        // Periksa apakah pengguna sudah melakukan parkir keluar sebelumnya
        bool hasExited = await checkUserExited();

        if (hasExited) {
          // Mitra ditemukan dan pengguna sudah keluar, lanjutkan dengan operasi parkir

          // Periksa status slot parkir yang akan digunakan
          bool isSlotAvailable = await checkSlotParking(
              mitraUID); // Anda perlu mengganti ini sesuai dengan implementasi Anda

          if (isSlotAvailable) {
            // Slot parkir tersedia, lanjutkan dengan operasi parkir
            autoEntranceGate(mitraUID);
            await sendParkingDataToFirestore(mitraUID);
            print("Parkir selesai");
          } else {
            // Slot parkir sudah penuh, tampilkan konfirmasi
            bool confirmParking = await showParkingConfirmationDialog();
            if (confirmParking) {
              // Pengguna memilih untuk melanjutkan parkir
              autoEntranceGate(mitraUID);
              await sendParkingDataToFirestore(mitraUID);
              print("Parkir selesai");
            } else {
              // Pengguna memilih untuk membatalkan parkir
              Get.snackbar("Notifkasi", "Parkir dibatalkan.");
              print("Parkir dibatalkan");
            }
          }
        } else {
          // Pengguna belum keluar dari parkir sebelumnya, tampilkan snackbar
          Get.snackbar(
              "Peringatan", "Anda belum keluar dari parkir sebelumnya");
          print("Pengguna belum keluar dari parkir sebelumnya");
        }
      } else {
        // Mitra tidak ditemukan, tampilkan snackbar
        Get.snackbar("Peringatan",
            "Lokasi parkir tidak ditemukan. QR Code tidak valid atau tidak sesuai.");
        print("Mitra tidak ditemukan");
      }
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat memproses parkir: $e");
      Get.snackbar("Gagal", "Terjadi kesalahan saat memproses parkir");
    }
  }

// Fungsi untuk menampilkan dialog konfirmasi parkir
  Future<bool> showParkingConfirmationDialog() async {
    return await Get.defaultDialog(
          title: "Peringatan",
          content: Text(
            "Maaf, slot parkir sudah penuh. Yakin ingin masuk?",
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Pengguna memilih untuk membatalkan parkir
                Get.back(result: false);
              },
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                // Pengguna memilih untuk melanjutkan parkir
                Get.back(result: true);
              },
              child: Text("Ya"),
            ),
          ],
        ) ??
        false; // Nilai default jika dialog ditutup tanpa memilih
  }

  Future<void> handleExitParking() async {
    try {
      String uid = auth.currentUser!.uid;
      print("Memulai keluar parkir");

      CollectionReference<Map<String, dynamic>> parkingCollection =
          firestore.collection('users').doc(uid).collection('parking');

      // Check if the user has entered parking
      bool hasEnteredParking = await checkUserEntered();

      if (!hasEnteredParking) {
        // If the user hasn't entered parking, show a snackbar
        Get.snackbar("Peringatan",
            "Anda belum memulai sesi parkir. Silakan masuk parkir terlebih dahulu.");
        print("Belum masuk parkir");
        return; // Exit the method without further execution
      }

      // Mengecek apakah dokumen parkir sebelumnya sudah ada
      QuerySnapshot<Map<String, dynamic>> lastParkingSnapshot =
          await parkingCollection
              .orderBy('entryTime', descending: true)
              .limit(1)
              .get();

      if (lastParkingSnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> lastParkingDoc =
            lastParkingSnapshot.docs.first;
        Map<String, dynamic> lastParkingData = lastParkingDoc.data() ?? {};

        if (lastParkingData['status'] == 'Keluar') {
          Get.snackbar("Peringatan",
              "Anda belum memulai sesi parkir. Silakan masuk parkir terlebih dahulu.");
          print("gagal");
        } else {
          String exitQR = await FlutterBarcodeScanner.scanBarcode(
              "#000000", "Batal", true, ScanMode.QR);

          String mitraUID = exitQR;
          bool isMitraExist = await checkMitraExistInFirestore(mitraUID);

          if (isMitraExist) {
            await sendExitDataToFirestore(
                parkingCollection, lastParkingDoc.id, mitraUID);
          } else {
            Get.snackbar("Peringatan",
                "Lokasi parkir tidak ditemukan. QR Code tidak valid atau tidak sesuai.");
          }
        }
      } else {
        // Jika belum ada entri parkir, tampilkan snackbar
        Get.snackbar("Peringatan",
            "Anda belum memulai sesi parkir. Silakan masuk parkir terlebih dahulu.");
      }
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat memproses keluar parkir: $e");
      Get.snackbar("Gagal", "Terjadi kesalahan saat memproses keluar parkir");
    }
  }

  Future<bool> checkUserExited() async {
    try {
      String uid = auth.currentUser!.uid;
      CollectionReference<Map<String, dynamic>> parkingCollection =
          firestore.collection('users').doc(uid).collection('parking');

      // Mengecek apakah ada dokumen parkir untuk pengguna tertentu
      QuerySnapshot<Map<String, dynamic>> parkingSnapshot =
          await parkingCollection.limit(1).get();

      // Jika dokumen parkir ada, cek status parkir terakhir
      if (parkingSnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> lastParkingDoc =
            parkingSnapshot.docs.first;
        Map<String, dynamic> lastParkingData = lastParkingDoc.data() ?? {};

        // Jika sudah keluar, return true
        return lastParkingData['status'] == 'Keluar';
      }

      // Jika tidak ada dokumen parkir, anggap pengguna belum pernah keluar
      return true;
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat memeriksa keluar parkir sebelumnya: $e");
      return false;
    }
  }

  Future<bool> checkMitraExistInFirestore(String mitraUID) async {
    try {
      // Lakukan pengecekan apakah mitra dengan UID tersebut ada di Firestore
      DocumentSnapshot<Map<String, dynamic>> mitraSnapshot =
          await firestore.collection('mitras').doc(mitraUID).get();

      // Jika mitra ditemukan, return true
      return mitraSnapshot.exists;
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat memeriksa mitra di Firestore: $e");
      return false;
    }
  }

  Future<void> sendParkingDataToFirestore(String mitraUID) async {
    try {
      String uid = auth.currentUser!.uid;
      CollectionReference<Map<String, dynamic>> parkingCollection =
          firestore.collection('users').doc(uid).collection('parking');

      CollectionReference<Map<String, dynamic>> parkingMitraCollection =
          firestore.collection('mitras').doc(mitraUID).collection('parking');

      // Dapatkan waktu masuk parkir
      String entryTime = DateTime.now().toIso8601String();

      // Mendapatkan koleksi parkir untuk pengguna tertentu
      DocumentReference<Map<String, dynamic>> userInformation =
          FirebaseFirestore.instance.collection('users').doc(uid);

      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await userInformation.get();

      // Mendapatkan koleksi parkir untuk pengguna tertentu setelah pembuatan koleksi
      userSnapshot = await userInformation.get();

      // Gunakan data tersebut sesuai kebutuhan
      String userName = userSnapshot.data()?['name'];
      String userEmail = userSnapshot.data()?['email'];
      String userPhone = userSnapshot.data()?['phone'];
      String userPlate = userSnapshot.data()?['plate'] ?? "";
      String userVehicle = userSnapshot.data()?['vehicle'] ?? "";

      // Mendapatkan koleksi parkir untuk mitra tertentu
      DocumentReference<Map<String, dynamic>> mitraInformation =
          FirebaseFirestore.instance.collection('mitras').doc(mitraUID);

      DocumentSnapshot<Map<String, dynamic>> mitraSnapshot =
          await mitraInformation.get();

      String location = mitraSnapshot.data()?['name'];
      String address = mitraSnapshot.data()?['address'];
      String phoneMitra = mitraSnapshot.data()?['phone'];
      int priceDefault = mitraSnapshot.data()?['price'];

      // Simpan data parkir ke Firestore pada koleksi user
      DocumentReference<Map<String, dynamic>> newParkingDoc =
          await parkingCollection.add({
        'entryTime': entryTime,
        'status': 'Masuk',
        'location': location,
        'address': address,
        'phoneMitra': phoneMitra,
        'uid': uid,
        'name': userName,
        'email': userEmail,
        'phone': userPhone,
        'vehicle': userVehicle,
        'plate': userPlate,
        'priceDefault': priceDefault,
        'mitraUID': mitraUID,
        // Informasi lain yang diperlukan
      });

      // Simpan data parkir ke Firestore pada koleksi mitra
      await parkingMitraCollection.add({
        'entryTime': entryTime,
        'status': 'Masuk',
        'location': location,
        'address': address,
        'uid': mitraUID,
        'name': userName,
        'email': userEmail,
        'phone': userPhone,
        'vehicle': userVehicle,
        'plate': userPlate,
        'priceDefault': priceDefault,
        'userUID': uid,
        // Informasi lain yang diperlukan
      });

      // Tampilkan snackbar atau pesan sukses jika diperlukan
      Get.snackbar(
        "Sukses",
        "Selamat, parkir masuk berhasil!",
      );
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat memproses parkir: $e");
      Get.snackbar("Gagal", "ini yang muncul");
    }
  }

  Future<void> sendExitDataToFirestore(
    CollectionReference<Map<String, dynamic>> parkingCollection,
    String parkingDocId,
    String mitraUID,
  ) async {
    try {
      // Dapatkan waktu keluar parkir
      DateTime exitTime = DateTime.now();
      String exitTimeIso = exitTime.toIso8601String();

      // Dapatkan data parkir yang keluar
      DocumentSnapshot<Map<String, dynamic>> exitedParkingSnapshot =
          await parkingCollection.doc(parkingDocId).get();
      Map<String, dynamic> exitedParkingData =
          exitedParkingSnapshot.data() ?? {};
      DateTime entryTime = DateTime.parse(exitedParkingData['entryTime']);

      // Hitung durasi parkir dalam jam
      Duration parkDuration = exitTime.difference(entryTime);

      // Tentukan harga dasar parkir
      double basePrice = await getBasePriceFromMitra(mitraUID);

      // Periksa apakah melewati tengah malam
      bool pastMidnight = exitTime.hour < entryTime.hour;

      // Tentukan harga parkir
      double totalPrice = basePrice;
      if (pastMidnight) {
        // Harga berlipat ganda jika melewati tengah malam
        totalPrice = basePrice * 2;
      }

      // Periksa saldo pengguna sebelum melanjutkan
      double userBalance = await getUserBalance(auth.currentUser!.uid);

      double mitraBalance = await getMitraBalance(mitraUID);

      if (userBalance >= totalPrice) {
        autoExitGate(mitraUID);

        // Tampilkan dialog berhasil pembayaran
        Get.defaultDialog(
          title: "Pembayaran Berhasil",
          titlePadding: EdgeInsets.only(top: 20),
          titleStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
          content: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 20),
              Text(
                "Terima kasih!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Total Harga: Rp. ${NumberFormat.decimalPattern().format(totalPrice)}",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                "Durasi Parkir: ${parkDuration.inHours} jam, ${parkDuration.inMinutes % 60} menit",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          contentPadding: EdgeInsets.all(20),
          radius: 20.0,
          buttonColor: Colors.green,
          cancel: ElevatedButton(
            onPressed: () {
              // Tutup dialog jika tombol "OK" ditekan
              Get.back();
            },
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        // Kurangi saldo pengguna
        await updateUserBalance(
            auth.currentUser!.uid, userBalance - totalPrice);

        // Transfer saldo ke mitra
        await updateMitraBalance(mitraUID, mitraBalance + totalPrice);

        // Tambahkan poin pengguna
        int pointsToAdd = calculatePoints(totalPrice);
        await updateUserPoints(auth.currentUser!.uid, pointsToAdd);

        // Update data parkir ke Firestore pada koleksi user
        await parkingCollection.doc(parkingDocId).update({
          'status': 'Keluar',
          'exitTime': exitTimeIso,
          'total': {
            'hours': parkDuration.inHours,
            'minutes': parkDuration.inMinutes % 60,
            'seconds': parkDuration.inSeconds % 60,
          },
          'price': totalPrice,
          'points': pointsToAdd
          // Informasi lain yang diperlukan
        });

        // Simpan data parkir keluar ke Firestore pada koleksi mitra
        CollectionReference<Map<String, dynamic>> parkingMitraCollection =
            firestore.collection('mitras').doc(mitraUID).collection('parking');

        // Cari dokumen di koleksi mitra yang sesuai dengan userUID
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
            'status': 'Keluar',
            'exitTime': exitTimeIso,
            'total': {
              'hours': parkDuration.inHours,
              'minutes': parkDuration.inMinutes % 60,
              'seconds': parkDuration.inSeconds % 60,
            },
            'price': totalPrice,
            'points': pointsToAdd
            // Informasi lain yang diperlukan
          });

          // Tampilkan snackbar atau pesan sukses jika diperlukan
          Get.snackbar("Sukses", "Parkir keluar berhasil! Terima kasih.");
        } else {
          // Jika tidak ada dokumen yang sesuai, tampilkan pesan kesalahan
          Get.snackbar("Gagal", "Maaf, data parkir user tidak ditemukan.");
        }
      } else {
        // Jika saldo tidak mencukupi, tampilkan pesan kesalahan
        Get.snackbar(
            "Gagal", "Maaf, saldo Anda tidak mencukupi untuk keluar parkir.");
      }
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat memproses keluar parkir: $e");
      Get.snackbar("Gagal", "Terjadi kesalahan saat memproses keluar parkir");
    }
  }

  Future<double> getBasePriceFromMitra(String mitraUID) async {
    try {
      // Ambil harga base dari mitra
      DocumentSnapshot<Map<String, dynamic>> mitraSnapshot =
          await firestore.collection('mitras').doc(mitraUID).get();
      if (mitraSnapshot.exists) {
        dynamic basePrice = mitraSnapshot.data()?['price'] ??
            5000; // Ganti dengan field yang sesuai
        return basePrice.toDouble();
      } else {
        // Jika mitra tidak ditemukan, return harga default
        return 5000.0;
      }
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat mengambil harga base dari mitra: $e");
      return 5000.0; // Harga default jika terjadi kesalahan
    }
  }

  Future<double> getUserBalance(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userSnapshot.exists) {
        // Ambil nilai saldo dari dokumen pengguna
        dynamic balance = userSnapshot.data()?['balance'] ?? 0.0;

        // Konversi ke double sebelum mengembalikan nilai
        if (balance is int) {
          return balance.toDouble();
        } else if (balance is double) {
          return balance;
        } else {
          return 0.0;
        }
      } else {
        // Pengguna tidak ditemukan
        return 0.0;
      }
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat mengambil saldo pengguna: $e");
      return 0.0;
    }
  }

  Future<double> getMitraBalance(String mitraUID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> mitraSnapshot =
          await FirebaseFirestore.instance
              .collection('mitras')
              .doc(mitraUID)
              .get();

      if (mitraSnapshot.exists) {
        // Ambil nilai saldo dari dokumen pengguna
        dynamic balance = mitraSnapshot.data()?['balance'] ?? 0.0;

        // Konversi ke double sebelum mengembalikan nilai
        if (balance is int) {
          return balance.toDouble();
        } else if (balance is double) {
          return balance;
        } else {
          return 0.0;
        }
      } else {
        // Pengguna tidak ditemukan
        return 0.0;
      }
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saatE transfer saldo pengguna: $e");
      return 0.0;
    }
  }

  Future<void> updateUserBalance(String userId, double newBalance) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'balance': newBalance,
      });
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat mengupdate saldo pengguna: $e");
    }
  }

  Future<void> updateMitraBalance(String mitraUID, double newBalance) async {
    try {
      await FirebaseFirestore.instance
          .collection('mitras')
          .doc(mitraUID)
          .update({
        'balance': newBalance,
      });
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat mentransfer saldo pengguna: $e");
    }
  }

  Future<void> updateUserPoints(String userId, int pointsToAdd) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        int currentPoints =
            (userSnapshot.data() as Map<String, dynamic>?)?['points'] ?? 0;

        await transaction
            .update(userRef, {'points': currentPoints + pointsToAdd});
      });
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saatA memperbarui poin pengguna: $e");
    }
  }

  int calculatePoints(double totalPrice) {
    // Atur aturan berapa poin yang akan ditambahkan per 1000 unit totalPrice
    int pointsPer1000 = 10;
    int pointsToAdd = (totalPrice / 1000).floor() * pointsPer1000;
    return pointsToAdd;
  }

  Future<bool> checkUserEntered() async {
    try {
      String uid = auth.currentUser!.uid;
      CollectionReference<Map<String, dynamic>> parkingCollection =
          firestore.collection('users').doc(uid).collection('parking');

      // Check if there is at least one document in the parking collection
      QuerySnapshot<Map<String, dynamic>> parkingSnapshot =
          await parkingCollection.limit(1).get();

      return parkingSnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle errors
      print("Error saat memeriksa masuk parkir: $e");
      return false;
    }
  }

  Future<bool> checkSlotParking(String mitraUID) async {
    try {
      // Lakukan pengecekan apakah mitra dengan UID tersebut ada di Firestore
      DocumentSnapshot<Map<String, dynamic>> mitraSnapshot =
          await firestore.collection('mitras').doc(mitraUID).get();

      // Jika mitra ditemukan, lanjutkan dengan pengecekan slot parkir
      if (mitraSnapshot.exists) {
        // Dapatkan referensi ke subcollection 'parking'
        CollectionReference<Map<String, dynamic>> parkingCollection =
            firestore.collection('mitras').doc(mitraUID).collection('parking');

        CollectionReference<Map<String, dynamic>> parkingSlotCollection =
            firestore.collection('mitras').doc(mitraUID).collection('slot');

        // Dapatkan snapshot untuk subcollection 'parking'
        QuerySnapshot<Map<String, dynamic>> parkingSnapshot =
            await parkingCollection.get();

        // Dapatkan snapshot untuk subcollection 'parking'
        QuerySnapshot<Map<String, dynamic>> parkingSlotSnapshot =
            await parkingSlotCollection.get();

        // Jika subcollection 'parking' tidak ada, dianggap slot parkir tersedia
        if (parkingSnapshot.size == 0) {
          return true;
        }

        // Hitung jumlah slot yang memiliki status 'Masuk'
        int occupiedSlotCount = 0;
        for (QueryDocumentSnapshot<Map<String, dynamic>> parkingDocument
            in parkingSnapshot.docs) {
          if (parkingDocument['status'] == 'Masuk') {
            occupiedSlotCount++;
            // print("ini total masuk $occupiedSlotCount");
          }
        }

        // Hitung jumlah total slot di subcollection 'parking'
        int totalSlotCount = parkingSlotSnapshot.size;
        // print("in jumlah slot $totalSlotCount");

        // Jika jumlah slot yang status 'Masuk' sama dengan total slot, berarti penuh
        return occupiedSlotCount < totalSlotCount;
      } else {
        // Mitra tidak ditemukan, return false
        return false;
      }
    } catch (e) {
      // Tangani kesalahan, misalnya, jika ada error koneksi
      print("Error saat memeriksa mitra di Firestore: $e");
      return false;
    }
  }

  void updateStopwatch() async {
    String uid = auth.currentUser!.uid;
    // Mendapatkan koleksi parkir untuk pengguna tertentu
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

    if (lastParkingSnapshot.docs.isNotEmpty) {
      // Mendapatkan dokumen parkir terakhir
      DocumentSnapshot<Map<String, dynamic>> lastParkingDoc =
          lastParkingSnapshot.docs.first;
      Map<String, dynamic> lastParkingData = lastParkingDoc.data() ?? {};

      // Mengambil entry time dari dokumen parkir terakhir
      String entryTime = lastParkingData['entryTime'];

      // Menampilkan entry time di print
      print('Entry Time Dokumen Parkir Terakhir: $entryTime');

      final masukDate = DateTime.parse(entryTime);
      final initialTime = DateTime.now().difference(masukDate);
      stopwatch.value = Duration(milliseconds: initialTime.inMilliseconds);

      isRunning.value = true; // Memulai stopwatch
      print(masukDate);

      // Memulai timer untuk peningkatan waktu
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        if (!isRunning.value) {
          t.cancel(); // Hentikan timer saat isRunning = false
        } else {
          stopwatch.value += Duration(seconds: 1);
        }
      });
    }
  }

  void stopStopwatch(Timer timer) {
    isRunning.value = false; // Menghentikan stopwatch
    timer.cancel(); // Hentikan timer
  }

  // Future<Map<String, dynamic>> getMitraById(String barcode) async {
  //   try {
  //     var hasil = await firestore.collection("mitras").doc(barcode).get();

  //     CollectionReference<Map<String, dynamic>> colParkingMitra =
  //         await firestore
  //             .collection("mitras")
  //             .doc(barcode)
  //             .collection("parking");

  //     QuerySnapshot<Map<String, dynamic>> snapParkingMitra =
  //         await colParkingMitra.get();

  //     if (hasil.data() == null) {
  //       Get.snackbar("Warning", "Mitra parkir tidak ditemukan, QR CODE SALAH");
  //       return {
  //         "error": true,
  //         "message": "Tidak ada mitra parkir ini yang terdaftar"
  //       };
  //     }

  //     Get.snackbar("Warning", "Mitra parkir ADA, QR CODE BENAR");
  //     return {"error": false, "message": "berhasil"};
  //   } catch (e) {
  //     Get.snackbar(
  //         "Warning", "Mitra parkir tidak ditemukan, QR CODE SALAH (DATA)");
  //     print("tidak ada data guys");
  //     return {"error": true, "message": "Tidak ada mitra parkir ini"};
  //   }
  // }

  Future<void> updatePosition(Position position, String address) async {
    String uid = auth.currentUser!.uid;

    await firestore.collection("users").doc(uid).update({
      "position": {
        "lat": position.latitude,
        "long": position.longitude,
      },
      "address": address,
    });
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
      return {
        "message": "Tidak dapat mengambil lokasi",
        "error": true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
        return {
          "message": "Izin lokasi ditolak",
          "error": true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        "message": "Settingan lokasi belum aktif",
        "error": true,
      };
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return {
      "position": position,
      "message": "Berhasil mendapatkan posisi device",
      "error": false
    };
  }

  void autoEntranceGate(String mitraID) async {
    String uid = auth.currentUser!.uid;

    // Mendapatkan koleksi parkir untuk pengguna tertentu
    DocumentReference<Map<String, dynamic>> userInformation =
        FirebaseFirestore.instance.collection('users').doc(uid);

    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await userInformation.get(); // Gunakan data tersebut sesuai kebutuhan
    String userName = userSnapshot.data()?['name'];
    String userVehicle = userSnapshot.data()?['vehicle'];
    String userPlate = userSnapshot.data()?['plate'];

    Uri url = Uri.parse(
        "https://skripsi-ba-parkir-99-default-rtdb.asia-southeast1.firebasedatabase.app/entranceGate.json");

    Map<String, dynamic> data = {
      mitraID: {
        "value": 1,
        "status": "Masuk",
        "userName": userName,
        "userVehicle": userVehicle,
        "userPlate": userPlate,
        "userID": uid,
        "mitraID": mitraID
      },
    };

    await http.put(url, body: json.encode(data));
  }

  void autoExitGate(String mitraID) async {
    String uid = auth.currentUser!.uid;

    // Mendapatkan koleksi parkir untuk pengguna tertentu
    DocumentReference<Map<String, dynamic>> userInformation =
        FirebaseFirestore.instance.collection('users').doc(uid);

    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await userInformation.get(); // Gunakan data tersebut sesuai kebutuhan
    String userName = userSnapshot.data()?['name'];
    String userVehicle = userSnapshot.data()?['vehicle'];
    String userPlate = userSnapshot.data()?['plate'];

    Uri url = Uri.parse(
        "https://skripsi-ba-parkir-99-default-rtdb.asia-southeast1.firebasedatabase.app/exitGate.json");

    Map<String, dynamic> data = {
      mitraID: {
        "value": 90,
        "status": "Keluar",
        "userName": userName,
        "userVehicle": userVehicle,
        "userPlate": userPlate,
        "userID": uid,
        "mitraID": mitraID
      },
    };

    await http.put(url, body: json.encode(data));
  }
}
