import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/admins/authentication/signup_screen_from_admin.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/mosquePreferences/current_mosque.dart';
import 'package:jadwal/widgets/qr_section/mosque_generated_QR.dart';

class MosqueFragmentScreen extends StatelessWidget {
  Widget mosqueInfoItemProfile(IconData iconData, String adminData) {
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


  final CurrentMosque _currentMosque = Get.put(CurrentMosque());

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade900,
      child: ListView(
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
                        image: NetworkImage("${API.mosqueImage}${_currentMosque.mosque.mosque_image}")
                    ),
                  )
              ),
              )
          ),

          const SizedBox(height: 20,),

          Center(
            child: Material(
              color: Colors.amber[700],
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: (){
                  Get.to(QRMosqueGenerated(mosqueId: _currentMosque.mosque.mosque_id));
                },
                borderRadius: BorderRadius.circular(32),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12
                  ),
                  child: Text(
                    "Get QR Code",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20,),

          mosqueInfoItemProfile(Icons.mosque, _currentMosque.mosque.mosque_name),
          const SizedBox(height: 20,),

          mosqueInfoItemProfile(Icons.connect_without_contact, "${_currentMosque.mosque.connectors} Connectors"),
          const SizedBox(height: 20,),

          mosqueInfoItemProfile(Icons.email, _currentMosque.mosque.mosque_email),
          const SizedBox(height: 20,),

          mosqueInfoItemProfile(Icons.flag, _currentMosque.mosque.mosque_country),
          const SizedBox(height: 20,),

          mosqueInfoItemProfile(Icons.location_city, _currentMosque.mosque.mosque_state),
          const SizedBox(height: 20,),

          mosqueInfoItemProfile(Icons.house, _currentMosque.mosque.mosque_city),
          const SizedBox(height: 20,),

          mosqueInfoItemProfile(Icons.location_pin, _currentMosque.mosque.mosque_address),
          const SizedBox(height: 20,),

          Center(
            child: Material(
              color: Colors.amber[700],
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: (){
                  Get.to(AddAdminSignUpScreen(mosque: _currentMosque.mosque));
                },
                borderRadius: BorderRadius.circular(32),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12
                  ),
                  child: Text(
                    "Add an Admin",
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
      ),
    );
  }
}
