import 'package:flutter/material.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'global_members.dart';
import 'package:intl/intl.dart'; // Import the intl package for time formatting

class ReceiverRowView extends StatelessWidget {
  const ReceiverRowView({Key? key, required this.index, required this.mosqueId}) : super(key: key);

  final int index;
  final int mosqueId;

  @override
  Widget build(BuildContext context) {
    final announcement = mosqueAnnouncements[mosqueId]![index]; // Get the announcement from mosqueAnnouncements

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
      crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 75),
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
            alignment: WrapAlignment.start, // Align text to the left
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Color(0xff965129),
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
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 15),
            child: Text(
              '$dateLabel at $formattedTime', // Include date label and formatted time
              textAlign: TextAlign.left, // Align time to the left
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(API.adminImage + announcement.adminImage),
          ),
        ),
      ],
    );
  }
}
