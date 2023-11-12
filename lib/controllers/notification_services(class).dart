
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jadwal/admins/fragments/mosque_fragment_screen.dart';
import 'package:jadwal/users/announcements/user_received_announcements.dart';
import 'package:jadwal/users/fragments/dashboard_of_fragments.dart';

class NotificationServices{
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission()async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("user granted permission");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print("user granted provisional permission");
    }
    else{
      print("user denied permission");
    }
  }

  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(BuildContext context, RemoteMessage message)async{
    var androidInitializationSettings = const AndroidInitializationSettings('@drawable/icon');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings ,
        iOS: iosInitializationSettings
    );

    await _flutterLocalNotificationsPlugin.initialize(
        initializationSetting,
        onDidReceiveNotificationResponse: (payload){
          // handle interaction when app is active for android
          handleMessage(context, message);
        }
    );
  }

  void firebaseInit(BuildContext context){

    FirebaseMessaging.onMessage.listen((message) {

      RemoteNotification? notification = message.notification ;
      AndroidNotification? android = message.notification!.android ;

      if (kDebugMode) {
        print("notifications title:${notification!.title}");
        print("notifications body:${notification.body}");
        print('count:${android!.count}');
        print('data:${message.data.toString()}');
      }

      // if(Platform.isIOS){
      //   forgroundMessage();
      // }

      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message)async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(1000).toString(),
        "high_importance_channel" ,
        importance: Importance.max  ,
        showBadge: true ,
        playSound: true,
        // sound: const RawResourceAndroidNotificationSound('jetsons_doorbell')
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString() ,
        channelDescription: 'your channel description',
        importance: Importance.high,
        priority: Priority.high ,
        playSound: true,
        ticker: 'ticker' ,
        sound: channel.sound,
        color: Colors.brown[700],
      //     sound: RawResourceAndroidNotificationSound('jetsons_doorbell')
       icon: '@drawable/icon',
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true ,
        presentBadge: true ,
        presentSound: true
    ) ;

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero , (){
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails ,
      );
    });

  }

  Future<String?>getDeviceToken()async{
    return await messaging.getToken();
  }

  //refreshing token if it expired.
  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }

  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context)async {
    // when app is terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  //here handling the notification after clicking what will happen!
  void handleMessage(BuildContext context, RemoteMessage message){
    if(message.data['type']== 'schedule'){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardOfFragments()));
    }else if(message.data['type']== 'announcement'){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>UserAnnouncementScreen(
          mosqueId: int.parse(message.data['mosqueId']),
          mosqueImage: message.data['mosqueImage'],
          mosqueName: message.data['mosqueName'])
      ));
    }else if(message.data['type']== 'connection'){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>MosqueFragmentScreen()));
    }
  }

  //another method
  // Future<String>getDeviceToken()async{
  //   String? token = await messaging.getToken();
  //   return token!;
  // }
}