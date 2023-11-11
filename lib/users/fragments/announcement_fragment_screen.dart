import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/model/user_announcement_mosque_model.dart';
import 'package:jadwal/users/announcements/user_received_announcements.dart';
import 'package:jadwal/users/userPreferences/current_user.dart';

import '../../controllers/users_fetch_info.dart';

class AnnouncementFragmentScreen extends StatefulWidget {
  @override
  State<AnnouncementFragmentScreen> createState() =>
      _AnnouncementFragmentScreenState();
}

class _AnnouncementFragmentScreenState
    extends State<AnnouncementFragmentScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  bool _dataFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchUserMosqueInfo();
  }

  Future<void> _fetchUserMosqueInfo() async {
    await _currentUser.getUserInfo();
    await _fetchConnectedMosqueAnnouncements();
    setState(() {
      _dataFetched = true;
    });
  }

  List<MosqueChatModel> _connectedMosques = [];

  Future<void> _fetchConnectedMosqueAnnouncements() async {
    if (_connectedMosques.isEmpty) {
      await UsersServerOperation.fetchMosquesForAnnouncement(
          _currentUser.user.user_id)
          .then((mosqueList) {
        setState(() {
          _connectedMosques = mosqueList;
          // Sort the list by announcementDate in ascending order
          _connectedMosques.sort((a, b) =>
              b.announcementDate.compareTo(a.announcementDate));
        });
      }).catchError((error) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: const Center(
          child: Text('Announcements',
              style: TextStyle(color: Colors.white70, fontSize: 28)),
        ),
      ),
      body: _dataFetched
          ? Container(
        color: Colors.grey.shade900,
        child: _connectedMosques.isNotEmpty
            ? ListView.builder(
          itemCount: _connectedMosques.length,
          itemBuilder: (context, index) {
            return mosqueComponent(mosque: _connectedMosques[index]);
          },
        )
            : const Center(
            child: Text("No mosque found",
                style: TextStyle(color: Colors.white))),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget mosqueComponent({required MosqueChatModel mosque}) {
    // Format the time using intl package
    final formattedTime = DateFormat.jm().format(mosque.announcementDate);

    // Calculate the difference in days between the message date and the current date
    final now = DateTime.now();
    final messageDate = mosque.announcementDate.toLocal(); // Convert to local time

    String dateLabel;

    if (now.year == messageDate.year &&
        now.month == messageDate.month &&
        now.day - messageDate.day == 1) {
      dateLabel = 'Yesterday';
    } else if (now.year == messageDate.year &&
        now.month == messageDate.month &&
        now.day == messageDate.day) {
      dateLabel = 'Today';
    } else {
      dateLabel = DateFormat('dd MMM, yy').format(messageDate);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: InkWell(
        onTap: () {
          Get.to(() => UserAnnouncementScreen(mosque: mosque));
        },
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: ClipOval(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white60, // Adjust the border color
                      width: 2.5, // Adjust the border width
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(API.mosqueImage + mosque.mosque_image),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mosque.mosque_name,
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${mosque.last_admin_name}: ${mosque.last_announcement_text}",
                    softWrap: true,
                    style: TextStyle(color: Colors.brown[200]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
