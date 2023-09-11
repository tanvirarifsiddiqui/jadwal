import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:jadwal/world_info/model/city.dart';
import 'package:jadwal/world_info/model/country.dart';
import 'package:jadwal/world_info/model/state.dart';

class FetchAddressInfo{
  // Function to fetch countries
  static Future<List<Country>> fetchCountries() async {
    List<Country> countries = [];
    try {
      var res = await http.get(Uri.parse(API.getCountries));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          // Parse the list of countries
          List<dynamic> countryList = data['countries'];
          countries = countryList.map((countryData) {

            return Country.fromJson(countryData);
          }).toList();
        } else {
          Fluttertoast.showToast(msg: "Failed to fetch countries");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return countries;
  }

  //Function to fetch States
static Future<List<StateOfCountry>> fetchStates(int countryId) async {
  List<StateOfCountry> states = [];
  try {
    var response = await http.post(Uri.parse(API.getStates),
        body: {
          'country_id': countryId.toString(),
        });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['success']) {
        // Parse the list of countries
        List<dynamic> stateList = data['states'];
        states = stateList.map((stateData) {
          return StateOfCountry.fromJson(stateData);
        }).toList();
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch states");
      }
    }
  }
  catch (e) {
    Fluttertoast.showToast(msg: e.toString());
  }
  return states;
}

  //Function to fetch Cities
  static Future<List<CityOfState>> fetchCities(int stateId) async {
    List<CityOfState> cities = [];
    try {
      final response = await http.post(Uri.parse(API.getCities),
          body: {
            'state_id': stateId.toString(),
          });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success']) {
          // Parse the list of countries
          List<dynamic> cityList = data['cities'];
          cities = cityList.map((cityData) {
            return CityOfState.fromJson(cityData);
          }).toList();
        } else {
          Fluttertoast.showToast(msg: "No Cities Available in Database");

          cities = [CityOfState(id: 0, name: 'Null')];
          Fluttertoast.showToast(msg: "Select 'Null'");
        }
      }
    }
    catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    // print(cities);
    return cities;
  }

}
