import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:skripsi_ba_parkir/app/controllers/page_index_controller.dart';
import 'package:skripsi_ba_parkir/firebase_options.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_pages.dart';

void main() async {
// Inisialisasi data lokal untuk bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ignore: unused_local_variable
  final pageC = Get.put(PageIndexController(), permanent: true);

  runApp(
    StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          print(snapshot.data);
          return GetMaterialApp(
            title: "Application",
            // initialRoute: Routes.HOME,
            initialRoute: snapshot.data != null ? Routes.HOME : Routes.LOGIN,
            getPages: AppPages.routes,
            debugShowCheckedModeBanner: false,
          );
        }),
  );
}
