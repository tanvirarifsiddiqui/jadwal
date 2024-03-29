import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/admins/authentication/signup_screen_from_admin.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/mosquePreferences/current_mosque.dart';
import 'package:jadwal/mosques/total_connectors.dart';
import 'package:jadwal/widgets/qr_section/mosque_generated_QR.dart';

class MosqueFragmentScreen extends StatelessWidget {
  Widget mosqueInfoItemProfile(IconData iconData, String adminData) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white54, // Adjust the border color
          width: 2, // Adjust the border width
        ),
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
          const SizedBox(
            width: 16,
          ),
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
    return Scaffold(
      backgroundColor: Colors.brown.shade900,
      appBar: AppBar(
        backgroundColor: const Color(0xff2b0c0d),
        title: const Center(
          child: Text(
            "My Mosque",
            style: TextStyle(color: Color(0xffbcaaa4), fontSize: 28),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          //profile image
          Center(
              child: ClipOval(
            child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white60, // Adjust the border color
                    width: 4, // Adjust the border width
                  ),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          "${API.mosqueImage}${_currentMosque.mosque.mosque_image}")),
                )),
          )),

          const SizedBox(
            height: 20,
          ),

          Center(
            child: Material(
              color: Colors.amber[700],
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  Get.to(QRMosqueGenerated(
                      mosqueId: _currentMosque.mosque.mosque_id));
                },
                borderRadius: BorderRadius.circular(32),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
          const SizedBox(
            height: 20,
          ),

          mosqueInfoItemProfile(
              Icons.mosque, _currentMosque.mosque.mosque_name),
          const SizedBox(
            height: 20,
          ),

          InkWell(
              onTap: () {
                Get.to(TotalConnectors(
                  mosqueId: _currentMosque.mosque.mosque_id,
                ));
              },
              child: mosqueInfoItemProfile(Icons.connect_without_contact,
                  "${_currentMosque.mosque.connectors} Connectors")),
          const SizedBox(
            height: 20,
          ),

          mosqueInfoItemProfile(
              Icons.email, _currentMosque.mosque.mosque_email),
          const SizedBox(
            height: 20,
          ),

          mosqueInfoItemProfile(
              Icons.flag, _currentMosque.mosque.mosque_country),
          const SizedBox(
            height: 20,
          ),

          mosqueInfoItemProfile(
              Icons.location_city, _currentMosque.mosque.mosque_state),
          const SizedBox(
            height: 20,
          ),

          mosqueInfoItemProfile(Icons.house, _currentMosque.mosque.mosque_city),
          const SizedBox(
            height: 20,
          ),

          mosqueInfoItemProfile(
              Icons.location_pin, _currentMosque.mosque.mosque_address),
          const SizedBox(
            height: 20,
          ),

          Center(
            child: Material(
              color: Colors.amber[700],
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  Get.to(AddAdminSignUpScreen(mosque: _currentMosque.mosque));
                },
                borderRadius: BorderRadius.circular(32),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
