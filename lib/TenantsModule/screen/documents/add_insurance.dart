import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant/constant.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import '../../../widgets/titleBar.dart';
import '../../widgets/appbar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/drawer_tiles.dart';
import 'package:http/http.dart' as http;
class add_insurance extends StatefulWidget {
  const add_insurance({super.key});

  @override
  State<add_insurance> createState() => _add_insuranceState();
}

class _add_insuranceState extends State<add_insurance> {
  TextEditingController provider = TextEditingController();
  TextEditingController policy = TextEditingController();
  TextEditingController effective = TextEditingController();
  TextEditingController expiration = TextEditingController();
  TextEditingController liablity = TextEditingController();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  List<File> _pdfFiles = [];

  List<String> _uploadedFileNames = [];

  Future<void> _pickPdfFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      List<File> files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      if (files.length > 10) {
        Fluttertoast.showToast(msg: 'You can only select up to 10 files.');
        return; // Exit the method if more than 10 files are selected
      }

      setState(() {
        _pdfFiles = files;
      });

      for (var file in _pdfFiles) {
        await _uploadPdf(file);
      }
    }
  }

  Future<void> _uploadPdf(File pdfFile) async {
    try {
      String? fileName = await uploadPdf(pdfFile);
      setState(() {
        if (fileName != null) {
          if(_uploadedFileNames.isNotEmpty){
            _uploadedFileNames.clear();
          }
          _uploadedFileNames.add(fileName);
        }
      });
    } catch (e) {
      print('PDF upload failed: $e');
    }
  }

  Future<String?> uploadPdf(File pdfFile) async {
    print(pdfFile.path);
    final String uploadUrl = '${image_upload_url}/api/images/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('files', pdfFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    var responseBody = json.decode(responseData.body);
    print(responseBody);
    if (responseBody['status'] == 'ok') {
      Fluttertoast.showToast(msg: 'PDF added successfully');
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromRGBO(21, 43, 83, 1), // header background color
              onPrimary: Colors.white, // header text color
              // onSurface: Colors.blue, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                Color.fromRGBO(21, 43, 83, 1), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        effective.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }
  Future<void> _selectDateexpiration(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromRGBO(21, 43, 83, 1), // header background color
              onPrimary: Colors.white, // header text color
              // onSurface: Colors.blue, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                Color.fromRGBO(21, 43, 83, 1), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        expiration.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: widget_302.App_Bar(context: context,onDrawerIconPressed: () {
          key.currentState!.openDrawer();
        },),
        backgroundColor: Colors.white,
        drawer:  CustomDrawer(currentpage: 'Documents',),
      body:Form(
        key: _formkey,
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 25,
                ),
                titleBar(
                  width: MediaQuery.of(context).size.width * .91,
                  title: 'New Insurance',
                  size: 18,
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: double.infinity,
                    // height: !form_valid ? 860 : 830,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Color.fromRGBO(21, 43, 103, 1),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Provider *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            hintText: 'Enter Provider Name',
                             controller: provider,
                         //   label: "",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please enter the subject';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Policy Id *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            hintText: 'Enter Policy Id',
                             controller: policy,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please enter the subject';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Effective Date *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            onTap: (){
                              _selectDate(context);
                            },
                            keyboardType: TextInputType.text,
                            hintText: 'dd-mm-yyyy',

                            label: "Enter effective date",

                             controller: effective,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please enter the subject';
                              }
                              return null;
                            },
                            suffixIcon: Icon(Icons.date_range,color: blueColor,),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Expiration Date *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            onTap: (){
                              _selectDateexpiration(context);
                            },
                            keyboardType: TextInputType.text,
                            hintText: 'dd-mm-yyyy',
                            label: "Enter expiration date",
                             controller: expiration,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please enter the subject';
                              }
                              return null;
                            },
                            suffixIcon: Icon(Icons.date_range,color: blueColor,),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Liability Coverage *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            hintText: '\$0.0',
                             label: "Enter Liability Coverage",
                             controller: liablity,

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please enter the subject';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Upload Insurance Document',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 40,
                            width: 125,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF152b51),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: _pickPdfFiles,
                              child: Text('Choose Files'),
                            ),
                          ),
                          SingleChildScrollView(
                            child: Column(
                              children: _uploadedFileNames.map((fileName) {
                                int index = _uploadedFileNames.indexOf(fileName);
                                return ListTile(
                                  title: Text(
                                    fileName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF748097),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _uploadedFileNames.removeAt(index);
                                      });
                                    },
                                    icon: const FaIcon(
                                      FontAwesomeIcons.remove,
                                      color: Color(0xFF748097),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(21, 43, 83, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: (){
                            //print("calling 111");
                            if(_formkey.currentState!.validate()){
                            //  print("calling 22");
                              addinsurance();
                            }
                          },
                          child: isLoading
                              ? Center(
                            child: SpinKitFadingCircle(
                              color: Colors.white,
                              size: 55.0,
                            ),
                          )
                              : Text(
                            'Save',
                            style: TextStyle(color: Color(0xFFf7f8f9)),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Container(
                          height: 50,
                          width: 120,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFffffff),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8.0))),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Color(0xFF748097)),
                              )))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
  addinsurance()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
  Map<String,dynamic> values =   {
      "admin_id": admin_id!,
    "Provider": provider.text,
    "policy_id": policy.text,
    "EffectiveDate": reverseFormatDate(effective.text),
    "ExpirationDate": reverseFormatDate(expiration.text),
    "LiabilityCoverage": liablity.text,
    "Policy": _uploadedFileNames.length > 0 ?  _uploadedFileNames.first : "" ,
  };



    final http.Response response = await http.post(
      Uri.parse('$Api_url/api/tenantinsurance/tenantinsurance/$id'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $id",
        //'Content-Type': 'application/json; charset=UTF-8',
      },
      body: values,
    );

    print(response.body);
    var responseData = json.decode(response.body);

    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      Navigator.pop(context,true);
      return responseData;
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to Insurance');
    }


  }
}
