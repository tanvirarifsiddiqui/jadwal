import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  final List<UserNotificationModel> _userNotifications = [];

  @override
  void initState() {
    super.initState();
    _fetchUserMosqueInfo();
    _setupScrollListener();
  }

  Future<void> _fetchUserMosqueInfo() async {
    await _currentUser.getUserInfo();
    await _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    // Fetch messages for the current page
    await UsersServerOperation.fetchUserNotifications(
      _currentUser.user.user_id,
      page: currentPage,
    ).then((notificationList) {
      setState(() {
        _userNotifications.addAll(notificationList);
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
    return RefreshIndicator(
      onRefresh: ()async{
        _userNotifications.clear();
        currentPage = 1;
        _dataFetched = false;
        await _fetchUserMosqueInfo();
      },
      child: Scaffold(
        backgroundColor: Colors.brown.shade900,
        appBar: AppBar(
          backgroundColor: const Color(0xff2b0c0d),
          title: const Center(
            child: Text('Notifications',
                style: TextStyle(color: Color(0xffbcaaa4), fontSize: 28)),
          ),
        ),
        body: _dataFetched
            ? Column(
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: _userNotifications.isNotEmpty
                        ? ListView.builder(
                            controller: scrollController,
                            itemCount: _userNotifications.length,
                            itemBuilder: (context, index) {
                              return notificationComponent(
                                  notification: _userNotifications[index]);
                            },
                          )
                        : const Center(
                            child: Text("No notification found",
                                style: TextStyle(color: Colors.white))),
                  ),
                  if (isLoadingMore)//todo here i should apply a logic to show no more notification if all notifications are fetched.
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget notificationComponent({required UserNotificationModel notification}) {
    // Calculate the difference in days between the message date and the current date
    final now = DateTime.now();
    final messageDate =
        notification.notificationDate.toLocal(); // Convert to local time

    // Calculate the time difference
    final timeDifference = now.difference(messageDate);

    String timeLabel;
    if (timeDifference.inSeconds < 60) {
      timeLabel = '${timeDifference.inSeconds} s';
    }else if (timeDifference.inMinutes < 60) {
      timeLabel = '${timeDifference.inMinutes} m';
    } else if (timeDifference.inHours < 24) {
      timeLabel = '${timeDifference.inHours} h';
    } else if (timeDifference.inDays < 7) {
      timeLabel = '${timeDifference.inDays} d';
    } else if (timeDifference.inDays < 30) {
      timeLabel = '${(timeDifference.inDays / 7).floor()} w';
    } else if (timeDifference.inDays < 365) {
      timeLabel = '${(timeDifference.inDays / 30).floor()} m';
    } else {
      timeLabel = '${(timeDifference.inDays / 365).floor()} y';
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
              width: 40,
              height: 40,
              child: ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white60, // Adjust the border color
                      width: 2, // Adjust the border width
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          API.adminImage + notification.adminImage),
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
                    notification.notificationText,
                    softWrap: true,
                    style: TextStyle(color: Colors.brown[200]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  timeLabel,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 45,
                  height: 45,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white60, // Adjust the border color
                          width: 3, // Adjust the border width
                        ),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                              API.mosqueImage + notification.mosqueImage),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
