import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/admins/adminPreferences/current_admin.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/mosquePreferences/current_mosque.dart';
import '../../controllers/announcement_fetch_and_save.dart';
import '../../widgets/message/announcement_model.dart';
import '../../widgets/message/sender_row_view.dart';
import '../../widgets/message/global_members.dart';


const urlTwo =
    'https://sguru.org/wp-content/uploads/2017/03/cute-n-stylish-boys-fb-dp-2016.jpg';
const url =
    'https://sguru.org/wp-content/uploads/2017/03/cute-n-stylish-boys-fb-dp-2016.jpg';

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
  var message = '';
  String title = "Mosque name";
  bool _dataFetched = false;
  @override
  void initState() {
    super.initState();
    _setGlobalMember();
    _fetchAnnouncements();
    setState(() {
      _dataFetched = true;
    }); // Trigger a rebuild after fetching the data
  }

  //mosques list
  // List<AnnouncementModel> _announcements = [];
  Future<void> _setGlobalMember() async{
     mosqueImageUrl = "${API.mosqueImage}${currentMosque.mosque.mosque_image}";
  }

  Future<void> _fetchAnnouncements() async {
    if (announcements.isEmpty) {
      //fetching country list
      await AnnouncementOperation.fetchAnnouncements(
              currentAdmin.admin.mosque_id)
          .then((announcementList) {
        setState(() {
          announcements = announcementList;
        });
      }).catchError((error) {});
    }
  }

  void animateList() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.offset !=
          scrollController.position.maxScrollExtent) {
        animateList();
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
                Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: announcements.isEmpty
                        ? const Center(
                            child: Text("No Announcements Found"),
                          )
                        : ListView.builder(
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
                          // final newAnnouncement = AnnouncementModel(
                          //   adminId: currentAdmin.admin.admin_id,
                          //   adminName: currentAdmin.admin.admin_name,
                          //   adminImage: currentAdmin.admin.admin_image,
                          //   announcementText: controller.text,
                          //   announcementDate: DateTime
                          //       .now(), // Set the announcement date to the current timestamp
                          // );
                          setState(() {
                          AnnouncementOperation.sendAnnouncement(currentAdmin.admin.admin_id, controller.text);
                            // announcements.add(newAnnouncement);
                            animateList();
                            controller.clear();
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
