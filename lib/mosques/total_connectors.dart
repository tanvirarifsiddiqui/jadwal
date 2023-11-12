import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/admins/adminPreferences/current_admin.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/model/connectors_model.dart';

import '../../controllers/users_fetch_info.dart';


class TotalConnectors extends StatefulWidget {
  final int mosqueId;
  TotalConnectors({
    required this.mosqueId,
    Key? key,
  }) : super(key: key);

  @override
  State<TotalConnectors> createState() =>
      _TotalConnectors();
}

class _TotalConnectors
    extends State<TotalConnectors> {

  var scrollController = ScrollController();
  bool _dataFetched = false;
  int currentPage = 1; // Track the current page of notifications
  bool isLoadingMore = false; // Track whether more notifications are being loaded

  final List<ConnectorsModel> _connectors = [];

  @override
  void initState() {
    super.initState();
    _fetchUserMosqueInfo();
    _setupScrollListener();
  }

  Future<void> _fetchUserMosqueInfo() async {
    await _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    // Fetch messages for the current page
    await UsersServerOperation.fetchTotalConnectors(
      widget.mosqueId,
      page: currentPage,
    ).then((connectorList) {
      setState(() {
        _connectors.addAll(connectorList);
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
          ? Column(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: _connectors.isNotEmpty
                ? ListView.builder(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: _connectors.length,
              itemBuilder: (context, index) {
                return connectorComponent(
                    connectors: _connectors[index]);
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
    );
  }

  Widget connectorComponent({required ConnectorsModel connectors}) {
    // Calculate the difference in days between the message date and the current date
    final now = DateTime.now();
    final messageDate =
    connectors.connectedAt.toLocal(); // Convert to local time

    // Calculate the time difference
    final timeDifference = now.difference(messageDate);

    String timeLabel;
    if (timeDifference.inSeconds < 60) {
      timeLabel = '${timeDifference.inSeconds} S';
    }else if (timeDifference.inMinutes < 60) {
      timeLabel = '${timeDifference.inMinutes} M';
    } else if (timeDifference.inHours < 24) {
      timeLabel = '${timeDifference.inHours} H';
    } else if (timeDifference.inDays < 7) {
      timeLabel = '${timeDifference.inDays} Days';
    } else if (timeDifference.inDays < 30) {
      timeLabel = '${(timeDifference.inDays / 7).floor()} Wk';
    } else if (timeDifference.inDays < 365) {
      timeLabel = '${(timeDifference.inDays / 30).floor()} Mon';
    } else {
      timeLabel = '${(timeDifference.inDays / 365).floor()} Years';
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
                      image:
                      NetworkImage(API.userImage + connectors.userImage),
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
                    connectors.userName,
                    softWrap: true,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    connectors.userAddress,
                    softWrap: true,
                    style: const TextStyle(color: Colors.white70),
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
              ],
            )
          ],
        ),
      ),
    );
  }

}
