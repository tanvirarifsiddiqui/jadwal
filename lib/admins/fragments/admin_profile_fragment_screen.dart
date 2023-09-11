import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/admins/adminPreferences/adminPreferences.dart';
import 'package:jadwal/admins/adminPreferences/current_admin.dart';
import 'package:jadwal/admins/authentication/login_screen.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/mosquePreferences/mosquePreferences.dart';

class AdminProfileFragmentScreen extends StatelessWidget {

  // Widget adminInfoItemProfile(IconData iconData, String adminData){
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       color: Colors.brown[300],
  //     ),
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 16,
  //       vertical: 8,
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(iconData,size: 30,color: Colors.black,),
  //         const SizedBox(width: 16,),
  //         Text(
  //           adminData,
  //           style: const TextStyle(
  //             fontSize: 15,
  //
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
  Widget adminInfoItemProfile(IconData iconData, String adminData) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.brown[300],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 30,
            color: Colors.black,
          ),
          const SizedBox(width: 16,),
          Expanded(
            child: Text(
              adminData,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final CurrentAdmin _currentAdmin = Get.put(CurrentAdmin());

  logOutAdmin() async{
    var resultResponse = await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.brown[300],
        title: const Text(
          "logout",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
        content: const Text(
          "Are you sure?\nYou want to logout from app?"
        ),
        actions: [
          TextButton(onPressed: (){
            Get.back();
          }, child: const Text(
                "No",
                style: TextStyle(
                  color: Colors.black
                ),
              )
          ),

          TextButton(onPressed: (){
            Get.back(result: "loggedOut");
          }, child: const Text(
            "Yes",
            style: TextStyle(
                color: Colors.black
            ),
          )
          )
        ],
      )
    );
    if(resultResponse == "loggedOut"){
      //delete mosque data from local storage
      await RememberMosquePrefs.removeMosqueInfo();

      //delete admin data from local storage
      RememberAdminPrefs.removeAdminInfo().then((value){
        Get.offAll(AdminLoginScreen());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        //profile image
        Center(
            child: ClipOval(child:Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage("${API.adminImage}${_currentAdmin.admin.admin_image}")
                  ),
                )
            ),
            )
        ),

        const SizedBox(height: 20,),

        adminInfoItemProfile(Icons.person, _currentAdmin.admin.admin_name),
        const SizedBox(height: 20,),
        
        adminInfoItemProfile(Icons.email, _currentAdmin.admin.admin_email),
        const SizedBox(height: 20,),

        adminInfoItemProfile(Icons.phone, _currentAdmin.admin.admin_phone),
        const SizedBox(height: 20,),

        adminInfoItemProfile(Icons.flag, _currentAdmin.admin.admin_country),
        const SizedBox(height: 20,),

        adminInfoItemProfile(Icons.location_city, _currentAdmin.admin.admin_state),
        const SizedBox(height: 20,),

        adminInfoItemProfile(Icons.house, _currentAdmin.admin.admin_city),
        const SizedBox(height: 20,),

        adminInfoItemProfile(Icons.location_pin, _currentAdmin.admin.admin_address),
        const SizedBox(height: 20,),
        
        Center(
          child: Material(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: (){
                logOutAdmin();
              },
              borderRadius: BorderRadius.circular(32),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12
                ),
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
