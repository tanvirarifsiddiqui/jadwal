import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jadwal/admins/adminPreferences/current_admin.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/mosquePreferences/current_mosque.dart';
import 'package:jadwal/widgets/message/announcement_model.dart';
import '../../controllers/announcement_fetch_and_save.dart';
import '../../widgets/message/sender_row_view.dart';
import '../../widgets/message/global_members.dart';
import 'package:http/http.dart' as http;

class AdminAnnouncementFragmentScreen extends StatefulWidget {
  const AdminAnnouncementFragmentScreen({Key? key}) : super(key: key);

  @override
  MyChatUIState createState() => MyChatUIState();
}

class MyChatUIState extends State<AdminAnnouncementFragmentScreen> {
  CurrentAdmin currentAdmin = Get.put(CurrentAdmin());
  CurrentMosque currentMosque = Get.put(CurrentMosque());
  late List<String> listOfTokens;

  var controller = TextEditingController();
  var scrollController = ScrollController();
  bool _dataFetched = false;
  int currentPage = 1; // Track the current page of messages
  bool isLoadingMore = false;
  late String
      announcementText; //solved the problem of showing the new announcements in a real-time

  @override
  void initState() {
    super.initState();
    announcements.clear();
    _setGlobalMember();
    _fetchAnnouncements();
    _setupScrollListener();
    _fetchUserTokens();
  }

  //mosques list
  // List<AnnouncementModel> _announcements = [];
  Future<void> _setGlobalMember() async {
    mosqueImageUrl = "${API.mosqueImage}${currentMosque.mosque.mosque_image}";
  }

  Future<void> _fetchAnnouncements() async {
    //fetch messages for current page
    final announcementsForMosque = announcements;
    await AnnouncementOperation.fetchAnnouncements(currentAdmin.admin.mosque_id,
            page: currentPage)
        .then((announcementList) {
      setState(() {
        announcementsForMosque.addAll(announcementList);
        announcements = announcementsForMosque;
        _dataFetched = true;
      });
    }).catchError((error) {});
  }

  Future<void> _sendAnnouncement() async {
    try {
      final res = await http.post(
        Uri.parse(API.sendAnnouncements),
        body: {
          'admin_id': currentAdmin.admin.admin_id.toString(),
          'mosque_id': currentMosque.mosque.mosque_id.toString(),
          'announcement_text': controller.text,
          'announcement_date': DateTime.now().toString(),
        },
      );
      //fetching mosque data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          // Create the new AnnouncementModel
          AnnouncementModel newAnnouncement = AnnouncementModel(
            announcementId: 0,
            announcementDate: DateTime.now(),
            adminId: currentAdmin.admin.admin_id,
            adminName: currentAdmin.admin.admin_name,
            adminImage: currentAdmin.admin.admin_image,
            announcementText: announcementText,
          );
          // Add the new announcement to the list
          setState(() {
            announcements.insert(0,
                newAnnouncement); // Insert at the beginning for reverse order
            animateList();
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to send Announcement");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  ///sending Announcements to the connected users
  Future<void> sendAnnouncementsToConnectedUsers() async {
    // Define the notification data
    var notification = {
      'title': 'An announcement from ${currentMosque.mosque.mosque_name}',
      'body': '${currentAdmin.admin.admin_name}: $announcementText',
      'notification_count': 23,
    };

    var data = {
      'notification': notification,
      'data': {
        'type': 'announcement',
        'mosqueId': '${currentMosque.mosque.mosque_id}',
        'mosqueName': currentMosque.mosque.mosque_name,
        'mosqueImage': currentMosque.mosque.mosque_image,
      }
    };

    // Define the FCM server URL
    var fcmUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Define your FCM server key
    var fcmServerKey =
        'AAAALPXowd4:APA91bGXQ7jXzw5KXMQ97gRCvslUfvuDGHQiDyCSa1HmlDSyvzw6abYLZFvcZ6n_E0kc3H-cFHL_L9A0i7hSK5BmaSjr7tzl6JQX7j_oUg3M7Ul7oDWnLjDyLVcol3NT-wzCv038oyW1';

    for (var token in listOfTokens) {
      // Send the notification to the current token
      try {
        final response = await http.post(
          fcmUrl,
          body: jsonEncode({
            'to': token,
            'notification': notification,
            'data': data['data'],
          }),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'key=$fcmServerKey',
          },
        );

        if (kDebugMode) {
          print(response.body.toString());
        }
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    }
  }

  void animateList() {
    scrollController.jumpTo(scrollController.position.minScrollExtent);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.offset !=
          scrollController.position.minScrollExtent) {
        animateList();
      }
    });
  }

  //fetching user tokens
  void _fetchUserTokens() async {
    final res = await http.post(Uri.parse(API.fetchUserToken), body: {
      "mosque_id": currentMosque.mosque.mosque_id.toString(),
    });
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      List<String> tokens =
          (data["tokens"] as List).map((token) => token.toString()).toList();
      listOfTokens = tokens;
      print(listOfTokens);
    } else {
      throw Exception('Failed to fetch tokens');
    }
  }

  // Set up a scroll listener to load more messages when scrolling to the top
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge && !isLoadingMore) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          // Scrolled to the top, load more messages
          setState(() {
            isLoadingMore = true;
          });

          // Load messages for the next page
          currentPage++;
          _fetchAnnouncements().whenComplete(() {
            setState(() {
              isLoadingMore = false;
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E2723),
      appBar: AppBar(
        elevation: 12,
        titleSpacing: 10,
        backgroundColor: const Color(0xff2b0c0d),
        // leading: const Padding(
        //   padding: EdgeInsets.all(8.0),
        //   child: Icon(
        //     Icons.arrow_back_ios_sharp,
        //     color: Colors.white,
        //   ),
        // ),
        // leadingWidth: 20,todo copy it for user fragment
        title: Builder(
          builder: (BuildContext context) {
            final mosqueName = currentMosque.mosque.mosque_name;
            final imageWidget = Uri.tryParse(mosqueImageUrl) != null
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white60, // Adjust the border color
                        width: 2, // Adjust the border width
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(mosqueImageUrl),
                    ),
                  )
                : const CircleAvatar();
            return ListTile(
              leading: imageWidget,
              title: Text(
                mosqueName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'online',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
        // actions: const [
        //   Padding(
        //     padding: EdgeInsets.only(right: 20),
        //     child: Icon(Icons.videocam_rounded),
        //   ),
        //   Padding(
        //     padding: EdgeInsets.only(right: 20),
        //     child: Icon(Icons.call),
        //   ),
        // ],todo kaj jene rakho
      ),
      body: _dataFetched
          ? Column(
              children: [
                if (isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: announcements.isEmpty
                        ? const Center(
                            child: Text("No Announcements Found"),
                          )
                        : ListView.builder(
                            reverse: true,
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: announcements.length,
                            itemBuilder: (context, index) => SenderRowView(
                                  index: index,
                                ))),
                Container(
                  alignment: Alignment.center,
                  color: Colors.white70,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12.0, left: 8),
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          maxLines: 6,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          controller: controller,
                          onFieldSubmitted: (value) {
                            controller.text = value;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(left: 8),
                            border: InputBorder.none,
                            focusColor: Colors.white,
                            hintText: 'Type a message',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, right: 10),
                        child: Transform.rotate(
                          angle: 45,
                          child: const Icon(
                            Icons.attachment_outlined,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          announcementText = controller.text;
                          setState(() {
                            if (controller.text.isNotEmpty) {
                              _sendAnnouncement();
                              //sending push notification
                              if (listOfTokens.isNotEmpty) {
                                sendAnnouncementsToConnectedUsers();
                              }
                              controller.clear();
                            }
                          });
                        },
                        // onLongPress: () {
                        //   setState(() {
                        //     chatModelList.add(AnnouncementModel(controller.text, false));
                        //     animateList();
                        //     controller.clear();
                        //   });
                        // },todo have to know and modify it
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 6, right: 8, top: 6),
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF3E2723),
                            child: Icon(
                              Icons.send,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
