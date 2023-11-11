import 'package:flutter/material.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/model/user_announcement_mosque_model.dart';
import 'package:jadwal/widgets/message/receiver_row_view.dart';
import '../../controllers/announcement_fetch_and_save.dart';
import '../../widgets/message/global_members.dart';

class UserAnnouncementScreen extends StatefulWidget {
  final MosqueChatModel mosque;
  const UserAnnouncementScreen({required this.mosque, Key? key})
      : super(key: key);

  @override
  MyChatUIState createState() => MyChatUIState();
}

class MyChatUIState extends State<UserAnnouncementScreen> {
  var controller = TextEditingController();
  var scrollController = ScrollController();
  bool _dataFetched = false;
  int currentPage = 1; // Track the current page of messages
  bool isLoadingMore = false; // Track whether more messages are being loaded

  @override
  void initState() {
    super.initState();
    mosqueAnnouncements[widget.mosque.mosque_id]?.clear();
    _setGlobalMember();
    _fetchAnnouncements();
    _setupScrollListener();
  }

  Future<void> _setGlobalMember() async {
    mosqueImageUrl = "${API.mosqueImage}${widget.mosque.mosque_image}";
  }

  Future<void> _fetchAnnouncements() async {
    // Fetch messages for the current page
    final mosqueId = widget.mosque.mosque_id;
    final announcementsForMosque = mosqueAnnouncements[mosqueId] ?? [];
    await AnnouncementOperation.fetchAnnouncements(
      widget.mosque.mosque_id,
      page: currentPage,
    ).then((announcementList) {
      setState(() {
        // Append the new messages to the existing list for this mosque
        announcementsForMosque.addAll(announcementList);
        mosqueAnnouncements[mosqueId] = announcementsForMosque;
        _dataFetched = true;
      });
    }).catchError((error) {});
  }

  // Set up a scroll listener to load more messages when scrolling to the top
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge && !isLoadingMore) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          // Scrolled to the bottom, load more messages when scrolling up
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
        title: Builder(
          builder: (BuildContext context) {
            final mosqueName = widget.mosque.mosque_name;
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
                  child:
                      mosqueAnnouncements[widget.mosque.mosque_id]?.isEmpty ??
                              true
                          ? const Center(
                              child: Text("No Announcements Found"),
                            )
                          : ListView.builder(
                              reverse: true, // Reverse the list
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  mosqueAnnouncements[widget.mosque.mosque_id]
                                          ?.length ??
                                      0,
                              itemBuilder: (context, index) {
                                return ReceiverRowView(
                                  index: index,
                                  mosqueId: widget.mosque.mosque_id,
                                );
                              },
                            ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
