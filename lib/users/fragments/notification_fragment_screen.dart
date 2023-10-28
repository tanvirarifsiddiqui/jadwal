import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/users/userPreferences/current_user.dart';
import 'package:jadwal/widgets/notifications/user_notification_model.dart';

import '../../controllers/users_fetch_info.dart';

class NotificationFragmentScreen extends StatefulWidget {
  @override
  State<NotificationFragmentScreen> createState() =>
      _NotificationFragmentScreenState();
}

class _NotificationFragmentScreenState
    extends State<NotificationFragmentScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  var scrollController = ScrollController();
  bool _dataFetched = false;
  int currentPage = 1; // Track the current page of notifications
  bool isLoadingMore = false; // Track whether more notifications are being loaded

  @override
  void initState() {
    super.initState();
    _fetchUserMosqueInfo();
    _setupScrollListener();
  }

  Future<void> _fetchUserMosqueInfo() async {
    await _currentUser.getUserInfo();
    await _fetchNotifications();
    setState(() {
    });
  }

  List<UserNotificationModel> _userNotifications = [];

  Future<void> _fetchNotifications() async {
    // Fetch messages for the current page
    await UsersServerOperation.fetchUserNotifications(
      _currentUser.user.user_id,
      page: currentPage,
    ).then((notificationList) {
      setState(() {
        _userNotifications = notificationList;
        _dataFetched = true;
      });
    }).catchError((error) {});
  }

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
          _fetchNotifications().whenComplete(() {
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
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: const Center(
          child: Text('Notifications',
              style: TextStyle(color: Colors.white70, fontSize: 28)),
        ),
      ),
      body: _dataFetched
          ? Container(
        color: Colors.grey.shade900,
        child: _userNotifications.isNotEmpty
            ? ListView.builder(
          itemCount: _userNotifications.length,
          itemBuilder: (context, index) {
            return notificationComponent(notification: _userNotifications[index]);
          },
        )
            : const Center(
            child: Text("No mosque found",
                style: TextStyle(color: Colors.white))),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget notificationComponent({required UserNotificationModel notification}) {
    // Format the time using intl package
    final formattedTime = DateFormat.jm().format(notification.notificationDate);

    // Calculate the difference in days between the message date and the current date
    final now = DateTime.now();
    final messageDate = notification.notificationDate.toLocal(); // Convert to local time

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
          // todo Get.to(() => UserAnnouncementScreen(mosque: mosque));
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
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(API.mosqueImage + notification.mosqueImage),
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
                    notification.mosqueName,
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${notification.adminName}: ${notification.adminImage}",
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
