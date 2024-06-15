import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/bg/bg-login.jpg",
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(40),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60, bottom: 40),
                child: Image.asset(
                  'assets/logo/logo.png',
                  // fit: BoxFit.cover,
                  width: 250,
                ),
              ),
              _buildTextField(
                "Nama Lengkap",
                Icons.person,
                controller.nameC,
              ),
              _buildTextField(
                "Nomor HP",
                Icons.phone,
                controller.phoneC,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                "Email",
                Icons.email,
                controller.emailC,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildPasswordTextField(
                "Password",
                Icons.lock,
                controller.passwordC,
              ),
              _buildPasswordTextField(
                "Konfirmasi Password",
                Icons.lock,
                controller.confirmPasswordC,
              ),
              SizedBox(
                height: 20,
              ),
              Obx(
                () => ElevatedButton(
                  onPressed: () {
                    if (controller.isLoading.isFalse) {
                      controller.register();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.all(15),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: Text(
                    controller.isLoading.isFalse ? "DAFTAR" : "LOADING",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String labelText,
    IconData icon,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField(
    String labelText,
    IconData icon,
    TextEditingController controllerText,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Obx(() => TextField(
            controller: controllerText,
            obscureText: controller.isHidden.isTrue,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(icon, color: Colors.white),
              suffixIcon: IconButton(
                onPressed: () {
                  controller.togglePasswordVisibility();
                },
                icon: Icon(
                  controller.isHidden.isTrue
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          )),
    );
  }
}
