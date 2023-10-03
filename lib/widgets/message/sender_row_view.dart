import 'package:flutter/material.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'global_members.dart';
import 'package:intl/intl.dart'; // Import the intl package for time formatting

class SenderRowView extends StatelessWidget {
  const SenderRowView({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final announcement = announcements.elementAt(index);

    // Format the time using intl package
    final formattedTime = DateFormat.jm().format(announcement.announcementDate!);

    // Calculate the difference in days between the message date and the current date
    final now = DateTime.now();
    final messageDate = announcement.announcementDate!.toLocal(); // Convert to local time

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
      dateLabel = DateFormat('MMMM dd, yyyy').format(messageDate);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 80, top: 15),
          child: Text(
            announcement.adminName, // Show admin's name above the message
            style: const TextStyle(
              fontSize: 12, // You can adjust the font size
              color: Colors.white70,
            ),
          ),
        ),
        ListTile(
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
              '$dateLabel at $formattedTime', // Include date label and formatted time
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ),
          trailing: CircleAvatar(
            backgroundImage: NetworkImage(API.adminImage + announcement.adminImage),
          ),
        ),
      ],
    );
  }
}
