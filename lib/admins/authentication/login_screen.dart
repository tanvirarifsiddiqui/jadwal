import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jadwal/admins/adminPreferences/adminPreferences.dart';
import 'package:jadwal/admins/fragments/adminDashboard_of_fragments.dart';
import 'package:jadwal/admins/model/admin.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/model/mosque.dart';
import 'package:jadwal/mosques/mosquePreferences/mosquePreferences.dart';
import 'package:jadwal/mosques/signup_screen.dart';
import 'package:jadwal/users/authentication/login_screen.dart';
import 'package:http/http.dart' as http;

class AdminLoginScreen extends StatefulWidget {

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {

  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var isObscure = true.obs;

  loginAdminNow() async {
    try {
      var res = await http.post(Uri.parse(API.loginAdmin),
          body: {
            'admin_email': emailController.text.trim(),
            'admin_password': passwordController.text.trim(),
          });

      if(res.statusCode == 200){ //connection with api to server - Successful
        var resBodyOfLogin = jsonDecode(res.body);
        if(resBodyOfLogin['success']){
          Admin adminInfo = Admin.fromJson(resBodyOfLogin["adminData"]); //collecting admin data as json format and save as an admin class
          Mosque mosqueInfo = Mosque.fromJson(resBodyOfLogin["mosqueData"]); //collecting mosque data as json format and save as an mosque class
          Fluttertoast.showToast(msg: "You are successfully logged in as as Admin");

          //save admin info to local Storage using Shared Preferences
          await RememberAdminPrefs.storeAdminInfo(adminInfo);

          //save mosque info to local Storage using Shared Preferences
          await RememberMosquePrefs.storeMosqueInfo(mosqueInfo);

          Future.delayed(const Duration(microseconds: 2000),(){
            Get.offAll(AdminDashboardOfFragments());
          });

        }
        else {
          Fluttertoast.showToast(msg: "Incorrect email or password.Please try Again");
        }
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
                    child: Image.asset("images/adminLogin.jpg"),
                  ),

                  //login screen sign-in form
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
                                Text("Admin Login",style: TextStyle(color: Colors.white,fontSize: 18),)
                              ],
                            ),
                            const Divider(color: Colors.white70),
                            const SizedBox(height: 20,),

                            //email-password-login + button
                            Form(
                              key: formKey,
                              child: Column(
                                children: [

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
                                    obscureText: isObscure.value,
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
                                              isObscure.value = !isObscure.value;
                                            },
                                            child: Icon(
                                              isObscure.value ? Icons.visibility_off : Icons.visibility,
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

                                  //button
                                  Material(
                                    color: Colors.brown[600],
                                    borderRadius: BorderRadius.circular(30),
                                    child: InkWell(
                                      onTap: (){
                                        if(formKey.currentState!.validate()){
                                          loginAdminNow();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(30),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 28,
                                        ),
                                        child: Text("Login",
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

                            //don't have an account - button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don,t have an Account?",
                                  style: TextStyle(color: Colors.white60),),
                                TextButton(
                                    onPressed: (){
                                      Get.to(MosqueSignUpScreen());
                                    },
                                    child: const Text(
                                        "Register Now",
                                      style: TextStyle(color: Colors.white70,
                                          fontSize: 16),
                                    )
                                )
                              ],
                            ),

                            const Text("Or",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            ),

                            //admin section - button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Are you a User?",
                                  style: TextStyle(color: Colors.white60),
                                ),
                                TextButton(
                                    onPressed: (){
                                      Get.to(LoginScreen());
                                    },
                                    child: const Text(
                                      "Click Here",
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
