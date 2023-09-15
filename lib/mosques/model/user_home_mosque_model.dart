import 'package:flutter/material.dart';

class MosqueUserHome {
  int mosque_id;
  String mosque_name;
  String mosque_image;
  String mosque_address;
  TimeOfDay fajr;
  TimeOfDay zuhr;
  TimeOfDay asr;
  TimeOfDay maghrib;
  TimeOfDay isha;
  TimeOfDay jumuah;

  MosqueUserHome({
    required this.mosque_id,
    required this.mosque_name,
    required this.mosque_image,
    required this.mosque_address,
    required this.fajr,
    required this.zuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.jumuah,
  });

  factory MosqueUserHome.fromJson(Map<String, dynamic> json) {
    return MosqueUserHome(
        mosque_id: int.parse(json['mosque_id']),
        mosque_name: json['mosque_name'],
        mosque_image: json['mosque_image'],
        mosque_address: json['mosque_address'],
        fajr: _parseTimeOfDay(json["fajr"]), // Use a helper function to parse TimeOfDay
        zuhr: _parseTimeOfDay(json["zuhr"]),
        asr: _parseTimeOfDay(json["asr"]),
        maghrib: _parseTimeOfDay(json["maghrib"]),
        isha: _parseTimeOfDay(json["isha"]),
        jumuah: _parseTimeOfDay(json["jumuah"]));
  }
  static TimeOfDay _parseTimeOfDay(String timeStr) {
    List<int> parts = timeStr.split(':').map(int.parse).toList();
    return TimeOfDay(hour: parts[0], minute: parts[1]);
  }
}
