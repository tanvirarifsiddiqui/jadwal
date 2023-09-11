import 'package:flutter/material.dart';

class Mosque{
  int mosque_id;
  String mosque_name;
  String mosque_email;
  String mosque_image;
  String mosque_country;
  String mosque_state;
  String mosque_city;
  String mosque_address;
  TimeOfDay fajr;
  TimeOfDay zuhr;
  TimeOfDay asr;
  TimeOfDay maghrib;
  TimeOfDay isha;
  TimeOfDay jumuah;

  Mosque(
      this.mosque_id,
      this.mosque_name,
      this.mosque_email,
      this.mosque_image,
      this.mosque_country,
      this.mosque_state,
      this.mosque_city,
      this.mosque_address,
      this.fajr,
      this.zuhr,
      this.asr,
      this.maghrib,
      this.isha,
      this.jumuah
      );

  factory Mosque.fromJson( Map<String,dynamic> json)=> Mosque(
      int.parse(json["mosque_id"]),
      json["mosque_name"],
      json["mosque_email"],
      json["mosque_image"],
      json["mosque_country"],
      json["mosque_state"],
      json["mosque_city"],
      json["mosque_address"],
    _parseTimeOfDay(json["fajr"]), // Use a helper function to parse TimeOfDay
    _parseTimeOfDay(json["zuhr"]),
    _parseTimeOfDay(json["asr"]),
    _parseTimeOfDay(json["maghrib"]),
    _parseTimeOfDay(json["isha"]),
    _parseTimeOfDay(json["jumuah"]),
  );

  Map<String,dynamic> toJson() =>{
    'mosque_id' : mosque_id.toString(),
    'mosque_name' : mosque_name,
    'mosque_email' : mosque_email,
    'mosque_image' : mosque_image,
    'mosque_country' : mosque_country,
    'mosque_state' : mosque_state,
    'mosque_city' : mosque_city,
    'mosque_address' : mosque_address,
    "fajr": _formatTimeOfDay(fajr), // Use a helper function to format TimeOfDay
    "zuhr": _formatTimeOfDay(zuhr),
    "asr": _formatTimeOfDay(asr),
    "maghrib": _formatTimeOfDay(maghrib),
    "isha": _formatTimeOfDay(isha),
    "jumuah": _formatTimeOfDay(jumuah),
  };

  static TimeOfDay _parseTimeOfDay(String timeStr) {
    List<int> parts = timeStr.split(':').map(int.parse).toList();
    return TimeOfDay(hour: parts[0], minute: parts[1]);
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    return "${time.hour}:${time.minute}";
  }
}