import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jadwal/admins/fragments/adminDashboard_of_fragments.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/controllers/circular_profile_picture.dart';
import 'package:jadwal/mosques/model/mosque.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AddAdminSignUpScreen extends StatefulWidget {

  final Mosque mosque;

  const AddAdminSignUpScreen({required this.mosque}) : super();


  @override
  State<AddAdminSignUpScreen> createState() => _AddAdminSignUpScreenState(mosque: mosque);
}

class _AddAdminSignUpScreenState extends State<AddAdminSignUpScreen> {
  late Mosque _mosque;

  _AddAdminSignUpScreenState({required Mosque mosque}) {
    _mosque = mosque;
  }

  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var ageController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var addressController = TextEditingController();
  var passwordController = TextEditingController();
  var confPasswordController = TextEditingController();
  var isObscure1 = true.obs;
  var isObscure2 = true.obs;

  //image uploading function
  File? defaultImageFile;
  File? imageFile;
  XFile? xFileImage;

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    xFileImage = await picker.pickImage(source: ImageSource.gallery);
    Directory? tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.absolute.path}/temp.jpg';
    if (xFileImage != null) {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        xFileImage!.path,
        targetPath,
        minHeight: 720,
        minWidth: 720,
        quality: 80,
      );

      if (compressedFile != null) {
        setState(() {
          imageFile = File(compressedFile.path);
        });
      }
    }
  }

  Future<void> _loadDefaultImage() async {
    try {
      final ByteData data = await rootBundle.load('images/admin.png');
      final List<int> bytes = data.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/admin.png');
      await tempFile.writeAsBytes(bytes);
      setState(() {
        defaultImageFile = tempFile;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  //setting up for refreshing registration page
  @override
  void initState() {
    super.initState();
    _loadDefaultImage();
  }

  validateAdminEmail() async {
    try{
      var res = await http.post(Uri.parse(API.validateAdminEmail),
          body: {
            'admin_email': emailController.text.trim(),
          });
      if(res.statusCode == 200){ //connection with api to server - Successful
        var resBodyOfValidateEmail = jsonDecode(res.body);

        if(resBodyOfValidateEmail['emailFound']){
          Fluttertoast.showToast(msg: "Email is already in someone else use. Try another email.");
        }
        else{
          //validate phone
          validateAdminPhone();
        }
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  validateAdminPhone() async {
    try{
      var res = await http.post(Uri.parse(API.validateAdminPhone),
          body: {
            'admin_phone': phoneController.text.trim(),
          });

      if(res.statusCode == 200){ //connection with api to server - Successful
        var resBodyOfValidateEmail = jsonDecode(res.body);

        if(resBodyOfValidateEmail['phoneFound']){
          Fluttertoast.showToast(msg: "Phone number is already in someone else use. Try another phone number.");
        }
        else{
          //register & save new user record to database
          registerAndSaveAdminRecord();
        }
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  registerAndSaveAdminRecord() async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(API.signUpAdmin),
      );
// Add text fields to the request
      request.fields['admin_name'] = nameController.text.trim();
      request.fields['admin_age'] = nameController.text.trim();
      request.fields['admin_country'] = _mosque.mosque_country;
      request.fields['admin_state'] = _mosque.mosque_state;
      request.fields['admin_city'] = _mosque.mosque_city;
      request.fields['admin_email'] = emailController.text.trim();
      request.fields['admin_address'] = addressController.text.trim();
      request.fields['admin_phone'] = phoneController.text.trim();
      request.fields['mosque_id'] = _mosque.mosque_id.toString();
      request.fields['admin_password'] = passwordController.text.trim();

      // Add the image file to the request
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'admin_image',
            imageFile!.path,
            contentType:
            MediaType('image', 'jpg'), // Adjust the content type as needed
          ),
        );
      } else {
        request.fields['admin_image'] = '';
      }

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          // Handle the response here
          final responseBody = await response.stream
              .bytesToString(); // Convert response stream to a string

          final parsedResponse = json.decode(responseBody);

          if (parsedResponse.containsKey('success')) {
            Fluttertoast.showToast(
                msg: "You have successfully Registered your Admin Account.");
            Get.offAll(AdminDashboardOfFragments());
          } else {
            // 'yourField' is not present in the response
            Fluttertoast.showToast(
                msg: "An Error occurred. Please try again later");
          }
        } else {
          Fluttertoast.showToast(
              msg: "Server not Responding, Please Try Again later");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    } catch (e) {
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
                      child: Image.asset("images/adminRegistration.jpg"),
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
                          padding: const EdgeInsets.fromLTRB(30, 30, 30, 8),
                          child: Column(
                            children: [
                              //Title
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Admin Registration",style: TextStyle(color: Colors.white,fontSize: 18),)
                                ],
                              ),
                              const Divider(color: Colors.white70),
                              const SizedBox(height: 25,),

                              //name-age-address-email-password-confirmPassword || signUp-button
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    //Admin Profile Picture
                                    CircularProfilePicture(
                                        radius: 80,
                                        imageFile:
                                        imageFile ?? defaultImageFile,
                                        onPressed: () {
                                          _uploadImage();
                                        }),
                                    const SizedBox(
                                      height: 18,
                                    ),

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
                                          Icons.calendar_month,
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

                                    //phone
                                    TextFormField(
                                      controller: phoneController,
                                      validator: (val) => val == "" ? "Please write Phone" : null,
                                      decoration: InputDecoration(
                                        prefixIcon:const Icon(
                                          Icons.phone,
                                          color: Colors.black,
                                        ),
                                        hintText: "phone...",
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
                                              validateAdminEmail();
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
