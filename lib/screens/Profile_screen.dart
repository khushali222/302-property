import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/Model/profile.dart';

import '../repository/profile_repository.dart';

class Profile_screen extends StatefulWidget {
  const Profile_screen({Key? key}) : super(key: key);

  @override
  State<Profile_screen> createState() => _Profile_screenState();
}

class _Profile_screenState extends State<Profile_screen> {
   TextEditingController _firstNameController = TextEditingController();
   TextEditingController _lastNameController= TextEditingController();
   TextEditingController _emailController= TextEditingController();
   TextEditingController _phoneNumberController= TextEditingController();
   TextEditingController _companyNameController= TextEditingController();
   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

   @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<profile>(
      future: ProfileRepository().fetchProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {

          final profile = snapshot.data!;
          _firstNameController.text = profile.firstName ?? '';
          _lastNameController.text = profile.lastName ?? '';
          _emailController.text = profile.email ?? '';
          _phoneNumberController.text = profile.phoneNumber?.toString() ?? '';
          _companyNameController.text = profile.companyName ?? '';
          print(snapshot.data!.email);
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    width: MediaQuery.of(context).size.width * .9,
                    child: Card(
                      color: Colors.white,
                      elevation: 4.0,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 70,
                                height: 70,
                                color: Color.fromRGBO(21, 43, 81, 1),
                                child: Center(
                                  child: Text(
                                    '${profile.firstName?[0].toUpperCase()}${profile.lastName?[0].toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
              
                            SizedBox(height: 8.0),
                            Text(
                              '${profile.firstName} ${profile.lastName}',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '${profile.email}',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '${profile.adminId}',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Material(
                    elevation: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: Container(
                                  height: 50.0,
                                  padding: EdgeInsets.only(top: 8, left: 10),
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.only(
                                      bottom: 6.0), //Same as `blurRadius` i guess
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    "My Account",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Text("User information",style: TextStyle(
                                fontSize: 16
                              ),),
                              SizedBox(height: 16.0),
                              Text('First Name'),
                              buildTextField('First Name', _firstNameController, _validateFirstName),
                              SizedBox(height: 16.0),
                              Text('Last Name'),
                              buildTextField('Last Name', _lastNameController, _validateFirstName),
                              SizedBox(height: 16.0),
                              Text('Email Address'),
                              buildTextField('Email Address', _emailController, _validateFirstName),
                              SizedBox(height: 16.0),
                              Text('Phone Number'),
                              buildTextField('Phone Number', _phoneNumberController, _validateFirstName),
                              SizedBox(height: 16.0),
                              Text('Company Name'),
                              buildTextField('Company Name', _companyNameController, _validateFirstName),
                              SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // If the form is valid, proceed with form submission
                                    _formKey.currentState!.save();
                                    ProfileRepository().Edit_profile({
                                      "first_name": _firstNameController.text,
                                      "last_name": _lastNameController.text,
                                      "email": _emailController.text,
                                      "company_name": _companyNameController.text,
                                      "phone_number": int.parse(_phoneNumberController.text),
                                    });
                                  }
                                  // Implement save functionality
                                },
                                child: Text('Update'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: Text('No data available'),
          );
        }
      },
    ));
  }
   Widget buildTextField(String label, TextEditingController controller,String? Function(String?)? validator) {
     return Material(
       elevation: 3,
       borderRadius: BorderRadius.circular(5),
       child: Container(
         padding: EdgeInsets.only(left: 10),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(5),
         ),
         child: TextFormField(
           controller: controller,
           validator: validator,
           decoration: InputDecoration(
             border: InputBorder.none,
             hintText: label,

           ),
         ),
       ),
     );
   }
   String? _validateFirstName(String? value) {
     if (value == null || value.isEmpty) {
       return 'Please enter your first name';
     }
     return null;
   }
}
