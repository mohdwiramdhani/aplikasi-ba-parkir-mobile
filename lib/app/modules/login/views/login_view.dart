import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:skripsi_ba_parkir/app/routes/app_pages.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/bg/bg-login.jpg"), // Ganti dengan path gambar yang sesuai
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5),
                BlendMode.darken), // Redupkan background image
          ),
        ),
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 50, top: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/logo/logo.png", // Sesuaikan dengan path file gambar di folder assets
                      width:
                          250, // Sesuaikan dengan lebar gambar yang diinginkan
                    ),
                  ],
                ),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: controller.emailC,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                  floatingLabelBehavior: FloatingLabelBehavior
                      .never, // Sembunyikan label text saat input
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Obx(
                () => TextField(
                  obscureText: controller.isPasswordHidden.isTrue,
                  controller: controller.passwordC,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        controller.isPasswordHidden.toggle();
                      },
                      icon: Icon(
                        controller.isPasswordHidden.isTrue
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Obx(
                () => ElevatedButton(
                  onPressed: () {
                    if (controller.isLoading.isFalse) {
                      controller.login();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(15)), // Tambahkan padding
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Tambahkan border radius
                      ),
                    ),
                  ),
                  child: Text(
                    controller.isLoading.isFalse ? "MASUK" : "LOADING",
                    style: TextStyle(
                      fontSize: 16, // Besarkan teks
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // TextButton(
              //   onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD),
              //   style: TextButton.styleFrom(
              //     padding: EdgeInsets.zero,
              //   ),
              //   child: Text(
              //     "Lupa password?",
              //     style: TextStyle(
              //       color: Colors.blue,
              //       fontSize: 16,
              //     ),
              //   ),
              // ),
              Divider(
                thickness: 2,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Belum punya akun? ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: "Daftar disini",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.toNamed(Routes.REGISTER);
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
