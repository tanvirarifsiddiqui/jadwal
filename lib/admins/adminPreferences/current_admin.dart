import 'package:get/get.dart';
import 'package:jadwal/admins/adminPreferences/adminPreferences.dart';
import 'package:jadwal/admins/model/admin.dart';

class CurrentAdmin extends GetxController{
  final Rx<Admin> _currentAdmin = Admin(0, '', '', '', '', '', '','','','','',0).obs;

  Admin get admin=> _currentAdmin.value;

  getAdminInfo() async{
    Admin? getAdminInfoFromLocalStorage = await RememberAdminPrefs.readAdminInfo();
    _currentAdmin.value = getAdminInfoFromLocalStorage!;
  }
}