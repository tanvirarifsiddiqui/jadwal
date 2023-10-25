import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/admins/adminPreferences/adminPreferences.dart';
import 'package:jadwal/admins/fragments/adminDashboard_of_fragments.dart';
import 'package:jadwal/admins/model/admin.dart';
import 'package:jadwal/users/authentication/login_screen.dart';
import 'package:jadwal/users/fragments/dashboard_of_fragments.dart';
import 'package:jadwal/users/model/user.dart';
import 'package:jadwal/users/userPreferences/userPreferences.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

//background notification Handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  Firebase.initializeApp();
  print(message.notification!.title.toString());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jadwal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.brown
      ),
      home: FutureBuilder(
          future: Future.wait([
            RememberUserPrefs.readUserInfo(),
            RememberAdminPrefs.readAdminInfo(),
            // RememberMosquePrefs.readMosqueInfo(),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>>snapshot){

            if(snapshot.connectionState == ConnectionState.waiting){
              return const CircularProgressIndicator();
            }
            else if(snapshot.data == null){
              return LoginScreen();
            }
            else{
              final userInfo = snapshot.data![0] as User?;
              final adminInfo = snapshot.data![1] as Admin?;
              if(userInfo != null){
                return DashboardOfFragments();
              }
              else if(adminInfo!=null){
                return AdminDashboardOfFragments();
              }
              else{
                return LoginScreen();
              }
            }
          }
      ),
    );
  }
}

