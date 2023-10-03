import 'package:flutter/material.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/model/user_announcement_mosque_model.dart';
import 'package:jadwal/widgets/message/receiver_row_view.dart';
import '../../controllers/announcement_fetch_and_save.dart';
import '../../widgets/message/global_members.dart';

class UserAnnouncementScreen extends StatefulWidget {
  final MosqueChatModel mosque;
  const UserAnnouncementScreen({required this.mosque, Key? key}) : super(key: key);

  @override
  MyChatUIState createState() => MyChatUIState();
}

class MyChatUIState extends State<UserAnnouncementScreen> {

  var controller = TextEditingController();
  var scrollController = ScrollController();
  bool _dataFetched = false;
  @override
  void initState() {
    super.initState();
    _setGlobalMember();
    _fetchAnnouncements();
  }

  //mosques list
  // List<AnnouncementModel> _announcements = [];
  Future<void> _setGlobalMember() async{
    mosqueImageUrl = "${API.mosqueImage}${widget.mosque.mosque_image}";
  }

  Future<void> _fetchAnnouncements() async {
    //fetching country list
    await AnnouncementOperation.fetchAnnouncements(
        widget.mosque.mosque_id)
        .then((announcementList) {
      setState(() {
        announcements = announcementList;
        _dataFetched = true;
      });
    }).catchError((error) {});
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
            final mosqueName = widget.mosque.mosque_name;
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
                  itemBuilder: (context, index) => ReceiverRowView(
                    index: index,
                  ))),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
