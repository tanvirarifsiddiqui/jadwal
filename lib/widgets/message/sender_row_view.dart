import 'package:flutter/material.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'global_members.dart';

class SenderRowView extends StatelessWidget {
  const SenderRowView({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final announcement = announcements.elementAt(index);

    return ListTile(
      leading: Container(
        width: 50,
      ),
      visualDensity: VisualDensity.comfortable,
      title: Wrap(
        alignment: WrapAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color(0xff6c3923),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              announcement.announcementText,
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.white),
              softWrap: true,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(right: 8, top: 4),
        child: Text(
          '${announcement.announcementDate!.hour}:${announcement.announcementDate!.minute} ${announcement.announcementDate!.hour >= 12 ? "PM" : "AM"}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ),
      trailing: CircleAvatar(
        backgroundImage: NetworkImage(API.adminImage+announcement.adminImage),
      ),
    );
  }
}

