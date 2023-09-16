import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:jadwal/mosques/model/search_mosque_model.dart';
import 'package:jadwal/mosques/model/user_home_mosque_model.dart';

class UsersServerOperation{
  // Function to fetch mosques for user search
  static Future<List<SearchedMosque>> fetchMosquesForSearch() async {
    List<SearchedMosque> mosques = [];
    try {
      var res = await http.get(Uri.parse(API.getSearchedMosqueData));//fetching mosque data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          // Parse the list of mosques
          List<dynamic> mosqueList = data['mosques'];
          mosques = mosqueList.map((mosqueData) {
            return SearchedMosque.fromJson(mosqueData);
          }).toList();
        } else {
          Fluttertoast.showToast(msg: "Failed to fetch mosques");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return mosques;
  }


//Function to fetch Mosques for user Home Screen
  static Future<List<MosqueUserHome>> fetchMosquesForHome(int userId) async {
    List<MosqueUserHome> mosques = [];
    try {
      var res = await http.post(Uri.parse(API.getUserHomeMosqueData),body: {
        'user_id': userId.toString()
      });
      //fetching mosque data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          // Parse the list of mosques
          List<dynamic> mosqueList = data['mosques'];
          mosques = mosqueList.map((mosqueData) {
            return MosqueUserHome.fromJson(mosqueData);
          }).toList();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return mosques;
  }


  //sending reordered data to the server
  static sendMosqueOrder(String mosqueOrder) async {
    try {
      final res = await http.post(
        Uri.parse(API.setUserHomeMosqueOrder),
        body: mosqueOrder,
        headers: {'Content-Type': 'application/json'},
      );
      //fetching mosque data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          }
        } else {
          Fluttertoast.showToast(msg: "Failed send new mosque order to database");
        }

    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

}
