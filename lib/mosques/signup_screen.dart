import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jadwal/admins/authentication/login_screen.dart';
import 'package:jadwal/admins/authentication/signup_screen.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:jadwal/controllers/circular_profile_picture.dart';
import 'package:jadwal/mosques/model/mosque.dart';
import 'package:jadwal/world_info/fetch_info/fetch_address_info.dart';
import 'package:jadwal/world_info/model/city.dart';
import 'package:jadwal/world_info/model/country.dart';
import 'package:jadwal/world_info/model/state.dart';
import 'package:path_provider/path_provider.dart';

class MosqueSignUpScreen extends StatefulWidget {

  @override
  State<MosqueSignUpScreen> createState() => _MosqueSignUpScreenState();
}

class _MosqueSignUpScreenState extends State<MosqueSignUpScreen> {

  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  Country? selectedCountry;
  StateOfCountry? selectedState;
  CityOfState? selectedCity;
  var addressController = TextEditingController();
  var emailController = TextEditingController();

  //image uploading function
  File? defaultImageFile ;
  File? imageFile ;
  XFile? xFileImage;

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    xFileImage = await picker.pickImage(source: ImageSource.gallery);
    Directory? tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.absolute.path}/temp.jpg';
    if (xFileImage != null) {
      final compressedFile =await FlutterImageCompress.compressAndGetFile(
        xFileImage!.path,
        targetPath,
        minHeight: 720,
        minWidth: 720,
        quality: 80,
      );

      if (compressedFile!= null) {
        setState(() {
          imageFile = File(compressedFile.path);
        });
      }
    }
  }

  Future<void> _loadDefaultImage() async{
    try{
      final ByteData data = await rootBundle.load('images/mosqueDefault.png');
      final List<int> bytes = data.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/mosqueDefault.png');
      await tempFile.writeAsBytes(bytes);
      setState(() {
        defaultImageFile = tempFile;
      });
    }
    catch(e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  validateMosqueEmail() async {
    try{
      var res = await http.post(Uri.parse(API.validateMosqueEmail),
          body: {
            'mosque_email': emailController.text.trim(),
          });

      if(res.statusCode == 200){ //connection with api to server - Successful
        var resBodyOfValidateEmail = jsonDecode(res.body);

        if(resBodyOfValidateEmail['emailFound']){
          Fluttertoast.showToast(msg: "Email is already in someone else use. Try another email.");
        }
        else{
          //saving mosque info
          registerAndSaveMosqueRecord();
        }
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  registerAndSaveMosqueRecord() async {
    try{
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(API.registerMosque),
      );
// Add text fields to the request
      request.fields['mosque_name'] = nameController.text.trim();
      request.fields['mosque_email'] = emailController.text.trim();
      request.fields['mosque_country'] = selectedCountry!.name;
      request.fields['mosque_state'] = selectedState!.name;
      request.fields['mosque_city'] = selectedCity!.name;
      request.fields['mosque_address'] = addressController.text.trim();

      // Add the image file to the request
      if(imageFile!=null){
        request.files.add(
          await http.MultipartFile.fromPath(
            'mosque_image',
            imageFile!.path,
            contentType: MediaType('image', 'jpg'), // Adjust the content type as needed
          ),
        );
      }else{
        request.fields['mosque_image'] = '';
      }


      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          // Handle the response here
          final responseBody = await response.stream.bytesToString(); // Convert response stream to a string

          final parsedResponse = json.decode(responseBody);

          if (parsedResponse.containsKey('success')) {
            Fluttertoast.showToast(msg: "Mosque Information Successfully Stored.");
            passingMosqueInfo(); //passing mosque information to the admin signup screen
            // Access the value of 'yourField' from the response
          } else {
            // 'yourField' is not present in the response
            Fluttertoast.showToast(msg: "An Error occurred. Please try again later");
          }
        }
        else {
          Fluttertoast.showToast(msg: "Server not Responding, Please Try Again later");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  passingMosqueInfo()async {
    try{
      var res = await http.post(Uri.parse(API.getMosqueData),
          body: {
            'mosque_email': emailController.text.trim(),
          });

      if(res.statusCode == 200){ //connection with api to server - Successful
        var resBodyOfMosqueData = jsonDecode(res.body);

        if(resBodyOfMosqueData['success']){
          Mosque  mosqueInfo = Mosque.fromJson(resBodyOfMosqueData["mosqueData"]);
          Get.offAll(AdminSignUpScreen(mosque: mosqueInfo));
        }
        else{
          Fluttertoast.showToast(msg: "Mosque Not found");
        }
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

// Registration world information gathering segment

  // gathering country list
  List<Country> countries = []; // List to store countries
  @override
  void initState() {
    super.initState();
    //fetching default profile image
    _loadDefaultImage();

    FetchAddressInfo.fetchCountries().then((countryList) {
      setState(() {
        countries = countryList;
      });
    }).catchError((error){
    }); // Call this to fetch and populate the list of countries.
  }

  // state list
  List<StateOfCountry> states = [];

  //city list
  List<CityOfState> cities = [];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54,
        body: LayoutBuilder(
          builder: (context, cons){
            return ConstrainedBox(constraints: BoxConstraints(
              minHeight: cons.maxHeight,
            ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 285,
                      child: Image.asset("images/mosqueRegistration.jpg"),
                    ),

                    //signup screen sign-up form
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.all(
                              Radius.circular(60),
                            ),
                            boxShadow: [
                              BoxShadow(blurRadius: 8,
                                color: Colors.black26,
                                offset: Offset(0, -3),
                              )
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 20, 30, 8),
                          child: Column(
                            children: [
                              //Title
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Mosque Registration",style: TextStyle(color: Colors.white,fontSize: 18),)
                                ],
                              ),
                              const Divider(color: Colors.white70),
                              const SizedBox(height: 20,),

                              //name-age-address-email-password-confirmPassword || signUp-button
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    //Mosque Profile Picture
                                    CircularProfilePicture(
                                        radius: 80,
                                        imageFile:imageFile??defaultImageFile,
                                        onPressed:(){
                                          _uploadImage();
                                        }
                                    ),
                                    const SizedBox(height: 18,),

                                    //name
                                    TextFormField(
                                      controller: nameController,
                                      validator: (val) => val == "" ? "Please write Mosque name" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.mosque,
                                          color: Colors.black,
                                        ),
                                        hintText: "name...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.brown[300],
                                        filled: true,
                                      ),
                                    ),
                                    const SizedBox(height: 18,),

                                    //country
                                    DropdownButtonFormField<Country>(
                                      value: selectedCountry,
                                      items: countries.map((country) {
                                        return DropdownMenuItem(
                                          value: country,
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.45,
                                              child: Text(country.name,overflow: TextOverflow.ellipsis,
                                                maxLines: 1,),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (Country? value) {
                                        // Handle country selection,
                                        setState(() {
                                          selectedCountry = value;
                                          selectedState = null; // Reset selectedState when the country changes
                                          selectedCity = null; // Reset selectedState when the country changes
                                        });
                                        // Fetch states for the selected country here
                                        FetchAddressInfo.fetchStates(selectedCountry!.id).then((stateList) {
                                          setState(() {
                                            states = stateList;
                                          });
                                        });
                                      },
                                      validator: (val) => val == null ? "Please select the mosque's Country" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.flag,
                                          color: Colors.black,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.brown[300],
                                        filled: true,
                                      ),
                                      hint: const Text('Select Country'),
                                    ),

                                    const SizedBox(height: 18,),

                                    //state of country
                                    DropdownButtonFormField<StateOfCountry>(
                                      value: selectedState,
                                      items: states.map((state) {
                                        return DropdownMenuItem(
                                          value: state,
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.45,
                                            child: Text(state.name,overflow: TextOverflow.ellipsis,
                                              maxLines: 1,),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (StateOfCountry? value) {
                                        // Handle country selection,
                                        setState(() {
                                          selectedState = value;
                                          selectedCity = null;
                                           // Reset selectedCity when the country changes
                                        });
                                        // Fetch states for the selected country here
                                        FetchAddressInfo.fetchCities(selectedState!.id).then((cityList) {
                                          setState(() {
                                            cities = cityList;
                                          });
                                        });
                                      },
                                      validator: (val) => val == null ? "Please select the mosque's State" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.location_city,
                                          color: Colors.black,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.brown[300],
                                        filled: true,
                                      ),
                                      hint: const Text('Select State'),
                                    ),
                                    const SizedBox(height: 18,),

                                    //city
                                    DropdownButtonFormField<CityOfState>(
                                      value: selectedCity,
                                      items: cities.map((city) {
                                        return DropdownMenuItem(
                                          value: city,
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.45,
                                            child: Text(city.name,overflow: TextOverflow.ellipsis,
                                              maxLines: 1,),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (CityOfState? value) {
                                        // Handle country selection,
                                        setState(() {
                                          selectedCity = value as CityOfState;
                                        });
                                      },
                                      validator: (val) => val == null ? "Please select the mosque's City" : null,                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.house,
                                          color: Colors.black,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.brown[300],
                                        filled: true,
                                      ),
                                      hint: const Text('Select City if Available'),
                                    ),
                                    const SizedBox(height: 18,),

                                    //address
                                    TextFormField(
                                      controller: addressController,
                                      validator: (val) => val == "" ? "Please write your mosque address" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.location_pin,
                                          color: Colors.black,
                                        ),
                                        hintText: "address...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.brown[300],
                                        filled: true,
                                      ),
                                    ),
                                    const SizedBox(height: 18,),

                                    // email
                                    TextFormField(
                                      controller: emailController,
                                      validator: (val) => val == "" ? "Please write your email" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.email,
                                          color: Colors.black,
                                        ),
                                        hintText: "Admin email...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.brown[300],
                                        filled: true,
                                      ),
                                    ),
                                    const SizedBox(height: 18,),

                                    //button
                                    Material(
                                      color: Colors.brown[600],
                                      borderRadius: BorderRadius.circular(30),
                                      child: InkWell(
                                        onTap: (){
                                          if(formKey.currentState!.validate()){

                                              //validate the email
                                              validateMosqueEmail();
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(30),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 28,
                                          ),
                                          child: Text("Next",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),),

                                        ),
                                      ),
                                    )

                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),
                              const Divider(color: Colors.white70),

                              //already have account - button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Already have an Account?",
                                    style: TextStyle(color: Colors.white60),),
                                  TextButton(
                                      onPressed: (){
                                        Get.to(AdminLoginScreen());
                                      },
                                      child: const Text(
                                        "Login Here",
                                        style: TextStyle(color: Colors.white70,
                                            fontSize: 16),
                                      )
                                  )
                                ],
                              ),

                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        )
    );
  }
}
