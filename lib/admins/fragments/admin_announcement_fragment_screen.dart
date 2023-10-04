import 'dart:convert';

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

  var controller = TextEditingController();
  var scrollController = ScrollController();
  bool _dataFetched = false;
  int currentPage = 1; // Track the current page of messages
  bool isLoadingMore = false;
  late String announcementText;//solved the problem of showing the new announcements in a real-time

  @override
  void initState() {
    super.initState();
    announcements.clear();
    _setGlobalMember();
    _fetchAnnouncements();
    _setupScrollListener();
  }

  //mosques list
  // List<AnnouncementModel> _announcements = [];
  Future<void> _setGlobalMember() async{
     mosqueImageUrl = "${API.mosqueImage}${currentMosque.mosque.mosque_image}";
  }

  Future<void> _fetchAnnouncements() async {
    //fetch messages for current page
    final announcementsForMosque = announcements;
      await AnnouncementOperation.fetchAnnouncements(
              currentAdmin.admin.mosque_id, page: currentPage)
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
          'admin_id' : currentAdmin.admin.admin_id.toString(),
          'mosque_id' : currentMosque.mosque.mosque_id.toString(),
          'announcement_text' : controller.text,
          'announcement_date' : DateTime.now().toString(),
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
            announcements.insert(0, newAnnouncement); // Insert at the beginning for reverse order
            animateList();
          });

          Fluttertoast.showToast(msg: "Successfully Sent Announcement");
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to send Announcement");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
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
      backgroundColor: const Color(0xff682404),
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
                ? CircleAvatar(
              backgroundImage: NetworkImage(mosqueImageUrl),
            )
                : const CircleAvatar();
            return ListTile(
              leading: imageWidget,
              title: Text(
                mosqueName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  const Center(
                    child: CircularProgressIndicator(),
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
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12.0, left: 8),
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          color: Color(0xffD11C2D),
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
                            color: Color(0xffD11C2D),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          announcementText = controller.text;
                          setState(() {
                            if(controller.text.isNotEmpty){
                          _sendAnnouncement();
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
                            backgroundColor: Color(0xffD11C2D),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
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
