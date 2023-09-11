import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/controllers/circular_profile_picture.dart';
import 'package:jadwal/users/authentication/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:jadwal/world_info/fetch_info/fetch_address_info.dart';
import 'package:jadwal/world_info/model/city.dart';
import 'package:jadwal/world_info/model/country.dart';
import 'package:jadwal/world_info/model/state.dart';
import 'package:path_provider/path_provider.dart';

class SignUpScreen extends StatefulWidget {

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var ageController = TextEditingController();
  Country? selectedCountry;
  StateOfCountry? selectedState;
  CityOfState? selectedCity;
  var addressController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confPasswordController = TextEditingController();
  var isObscure1 = true.obs;
  var isObscure2 = true.obs;

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
      final ByteData data = await rootBundle.load('images/man1.png');
      final List<int> bytes = data.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/man1.png');
      await tempFile.writeAsBytes(bytes);
      setState(() {
        defaultImageFile = tempFile;
      });
    }
    catch(e) {
      Fluttertoast.showToast(msg: e.toString());
    }
}

  // Registration world information gathering segment
  // gathering country list
  List<Country> _countries = []; // List to store countries
  @override
  void initState() {
    super.initState();
    //fetching default profile image

    _loadDefaultImage();

    //fetching country list
    FetchAddressInfo.fetchCountries().then((countryList) {
      setState(() {
        _countries = countryList;
      });
    }).catchError((error){
    }); // Call this to fetch and populate the list of countries.
  }

  // state list
  List<StateOfCountry> states = [];

  //city list
  List<CityOfState> cities = [];

  //email validation function
  validateUserEmail() async {
    try{
    var res = await http.post(Uri.parse(API.validateEmail),
      body: {
        'user_email': emailController.text.trim(),
      });

    if(res.statusCode == 200){ //connection with api to server - Successful
      var resBodyOfValidateEmail = jsonDecode(res.body);

      if(resBodyOfValidateEmail['emailFound'] == true){
        Fluttertoast.showToast(msg: "Email is already in someone else use. Try another email.");
      }
      else{
        //register & save new user record to database
        registerAndSaveUserRecord();
      }
    }
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  registerAndSaveUserRecord() async {

    try{
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(API.signUp),
        );
// Add text fields to the request
        request.fields['user_name'] = nameController.text.trim();
        request.fields['user_age'] = ageController.text.trim();
        request.fields['user_country'] = selectedCountry!.name;
        request.fields['user_state'] = selectedState!.name;
        request.fields['user_city'] = selectedCity!.name;
        request.fields['user_address'] = addressController.text.trim();
        request.fields['user_email'] = emailController.text.trim();
        request.fields['user_password'] = passwordController.text.trim();

        // Add the image file to the request
      if(imageFile !=null){
        request.files.add(
          await http.MultipartFile.fromPath(
            'user_image',
            imageFile!.path,
            contentType: MediaType('image', 'jpg'), // Adjust the content type as needed
          ),
        );
      }else{
        request.fields['user_image'] = '';
      }

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          // Handle the response here
          final responseBody = await response.stream.bytesToString(); // Convert response stream to a string

          final parsedResponse = json.decode(responseBody);

          if (parsedResponse.containsKey('success')) {
            Fluttertoast.showToast(msg: "You Have successfully Registered your Account");
            Get.offAll(LoginScreen());
            // Access the value of 'yourField' from the response
          } else {
            // 'yourField' is not present in the response
            Fluttertoast.showToast(msg: "Data is not recorded");
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
                      child: Image.asset("images/registration.jpg"),
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
                                  Text("User Registration",style: TextStyle(color: Colors.white,fontSize: 18)),
                                ],
                              ),
                              const Divider(color: Colors.white70,),
                              const SizedBox(height: 18),

                              //profile-pic,name-age-country-state-city-address-email-password-confirmPassword || signUp-button
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    //User Profile Picture
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
                                      validator: (val) => val == "" ? "Please write your name" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.person,
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

                                    //age
                                    TextFormField(
                                      controller: ageController,
                                      validator: (val) => val == "" ? "Please write your age" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.cake,
                                          color: Colors.black,
                                        ),
                                        hintText: "age...",
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
                                      items: _countries.map((country) {
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
                                          selectedCity = null; // Reset selectedCity when the country changes
                                        });
                                        // Fetch states for the selected country here
                                        FetchAddressInfo.fetchStates(selectedCountry!.id).then((stateList) {
                                          setState(() {
                                            states = stateList;
                                          });
                                        });
                                      },
                                      validator: (val) => val == null ? "Please select the your Country" : null,
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
                                          selectedCity = null; // Reset selectedCity when the country changes
                                        });
                                        // Fetch states for the selected country here
                                        FetchAddressInfo.fetchCities(selectedState!.id).then((cityList) {
                                          setState(() {
                                            cities = cityList;
                                          });
                                        });
                                      },
                                      validator: (val) => val == null ? "Please select the your State" : null,
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
                                      validator: (val) => val == null ? "Please select the your City" : null,
                                      decoration: InputDecoration(
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
                                      hint: const Text('Select City'),
                                    ),
                                    const SizedBox(height: 18,),

                                    //address
                                    TextFormField(
                                      controller: addressController,
                                      validator: (val) => val == "" ? "Please write your home address" : null,
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

                                    //email
                                    TextFormField(
                                      controller: emailController,
                                      validator: (val) => val == "" ? "Please write email" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.email,
                                          color: Colors.black,
                                        ),
                                        hintText: "email...",
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

                                    //password
                                    Obx(() => TextFormField(
                                      controller: passwordController,
                                      obscureText: isObscure1.value,
                                      validator: (val) => val == "" ? "Please write password" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.vpn_key_sharp,
                                          color: Colors.black,
                                        ),
                                        suffixIcon: Obx(
                                                () => GestureDetector(
                                              onTap: ()
                                              {
                                                isObscure1.value = !isObscure1.value;
                                              },
                                              child: Icon(
                                                isObscure1.value ? Icons.visibility_off : Icons.visibility,
                                                color: Colors.black,
                                              ),
                                            )
                                        ),
                                        hintText: "password...",
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
                                    ),),
                                    const SizedBox(height: 18,),

                                    //confirm password
                                    Obx(() => TextFormField(
                                      controller: confPasswordController,
                                      obscureText: isObscure2.value,
                                      validator: (val) => val == "" ? "Please confirm your password" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.vpn_key_sharp,
                                          color: Colors.black,
                                        ),
                                        suffixIcon: Obx(
                                                () => GestureDetector(
                                              onTap: ()
                                              {
                                                isObscure2.value = !isObscure2.value;
                                              },
                                              child: Icon(
                                                isObscure2.value ? Icons.visibility_off : Icons.visibility,
                                                color: Colors.black,
                                              ),
                                            )
                                        ),
                                        hintText: "Confirm password...",
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
                                    ),),
                                    const SizedBox(height: 18,),

                                    //button
                                    Material(
                                      color: Colors.brown[600],
                                      borderRadius: BorderRadius.circular(30),
                                      child: InkWell(
                                        onTap: (){
                                          if(formKey.currentState!.validate()){

                                            //password confirmation checking
                                            if(passwordController.text.trim() == confPasswordController.text.trim()){

                                              //validate the email
                                              validateUserEmail();
                                            }
                                            else{
                                              Fluttertoast.showToast(msg: "Wrong password confirmation occurred.");
                                            }

                                          }
                                        },
                                        borderRadius: BorderRadius.circular(30),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 28,
                                          ),
                                          child: Text("SignUp",
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
                                        Get.to(LoginScreen());
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
