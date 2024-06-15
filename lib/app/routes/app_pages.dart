import 'package:get/get.dart';

import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/parking/bindings/parking_binding.dart';
import '../modules/parking/views/parking_view.dart';
import '../modules/parking_detail/bindings/parking_detail_binding.dart';
import '../modules/parking_detail/views/parking_detail_view.dart';
import '../modules/parking_history/bindings/parking_history_binding.dart';
import '../modules/parking_history/views/parking_history_view.dart';
import '../modules/parking_location/bindings/parking_location_binding.dart';
import '../modules/parking_location/views/parking_location_view.dart';
import '../modules/parking_slot/bindings/parking_slot_binding.dart';
import '../modules/parking_slot/views/parking_slot_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile_update/bindings/profile_update_binding.dart';
import '../modules/profile_update/views/profile_update_view.dart';
import '../modules/profile_update_password/bindings/profile_update_password_binding.dart';
import '../modules/profile_update_password/views/profile_update_password_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.PARKING,
      page: () => ParkingView(),
      binding: ParkingBinding(),
    ),
    GetPage(
      name: _Paths.PARKING_HISTORY,
      page: () => ParkingHistoryView(),
      binding: ParkingHistoryBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.PARKING_DETAIL,
      page: () => ParkingDetailView(),
      binding: ParkingDetailBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_UPDATE,
      page: () => ProfileUpdateView(),
      binding: ProfileUpdateBinding(),
    ),
    GetPage(
      name: _Paths.PARKING_LOCATION,
      page: () => const ParkingLocationView(),
      binding: ParkingLocationBinding(),
    ),
    GetPage(
      name: _Paths.PARKING_SLOT,
      page: () => ParkingSlotView(),
      binding: ParkingSlotBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_UPDATE_PASSWORD,
      page: () => const ProfileUpdatePasswordView(),
      binding: ProfileUpdatePasswordBinding(),
    ),
  ];
}
