import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:jadwal/mosques/model/search_mosque_model.dart';

class FetchSearchInfo{
  // Function to fetch mosques
  static Future<List<SearchedMosque>> fetchMosques() async {
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

  //Function to fetch States

  //Function to fetch Cities

}
