import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/appbar.dart';
import 'package:three_zero_two_property/TenantsModule/repository/workorder.dart';
import 'package:three_zero_two_property/TenantsModule/widgets/drawer_tiles.dart';


import '../../../constant/constant.dart';
import '../../../screens/Maintenance/Vendor/add_vendor.dart';
import '../../../widgets/titleBar.dart';
import 'package:http/http.dart'as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../../widgets/custom_drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageUploadPage(),
    );
  }
}

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  bool isLoading = false;
  List<File> selectedImages = [];
  List<String?> uploaded_images = [];

  Future<String?> uploadImage(File imageFile) async {
    final String uploadUrl = '$image_upload_url/api/images/upload';
    print(uploadUrl);
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('files', imageFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);
    print(responseData.body);
    var responseBody = json.decode(responseData.body);
    print(responseBody);
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  Future<void> selectImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        selectedImages = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Future<void> uploadSelectedImages() async {
    setState(() {
      isLoading = true;
    });

    try {
      for (File image in selectedImages) {
        await uploadImage(image);
      }
      setState(() {
        selectedImages = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Images uploaded successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload images')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Images'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedImages.isNotEmpty)
              Wrap(
                children: selectedImages.map((image) {
                  return Container(
                    margin: EdgeInsets.all(8.0),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: FileImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
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
                onPressed: isLoading
                    ? null
                    : () async {
                  await selectImages();
                },
                child: Text(
                  'Select Images',
                  style: TextStyle(color: Color(0xFFf7f8f9)),
                ),
              ),
            ),
            SizedBox(height: 20),
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
                onPressed: isLoading
                    ? null
                    : () async {
                  await uploadSelectedImages();
                },
                child: isLoading
                    ? Center(
                  child: SpinKitFadingCircle(
                    color: Colors.white,
                    size: 25.0,
                  ),
                )
                    : Text(
                  'Upload here',
                  style: TextStyle(color: Color(0xFFf7f8f9)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Add_Workorder extends StatefulWidget {
  @override
  State<Add_Workorder> createState() => _Add_WorkorderState();
}

class _Add_WorkorderState extends State<Add_Workorder> {
  final TextEditingController subject = TextEditingController();

  final TextEditingController other = TextEditingController();

  final TextEditingController perform = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  bool form_valid = false;
  List<File> selectedImages = [];
  List<String?> uploaded_images = [];
  bool _isLoading = true;
  bool _Loading = false;
  Map<String, String> properties = {}; // Mapping of rental_id to rental_address
  Map<String, String> units = {}; // Mapping of unit_id to rental_unit

  String? _selectedPropertyId;
  String? _selectedProperty;
  String? _selectedUnitId;
  String? _selectedUnit;
  Future<void> selectImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        selectedImages = result.paths.map((path) => File(path!)).toList();
      });
    }
    uploadSelectedImages();
  }

  Future<void> uploadSelectedImages() async {
    setState(() {
    //  isLoading = true;
    });

    try {
      for (File image in selectedImages) {
       var image_name =  await uploadImage(image);
       print(image_name);
       uploaded_images.add(image_name);
      }
      setState(() {
        selectedImages = [];
      });
   //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Images uploaded successfully')));
    } catch (e) {
     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload images')));
    } finally {
      setState(() {
       // isLoading = false;
      });
    }
  }
  Future<String?> uploadImage(File imageFile) async {
    final String uploadUrl = '$image_upload_url/api/images/upload';
    print(uploadUrl);
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('files', imageFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);
    print(responseData.body);
    var responseBody = json.decode(responseData.body);
    print(responseBody);
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }
  Future<void> _loadProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
      await http.get(Uri.parse('${Api_url}/api/tenant/tenant_property/$id'),
          //api/tenant/tenant_property
          headers: {"authorization" : "CRM $token","id":"CRM $id",}
      );
      print('${Api_url}/api/rentals/rentals/$id');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> addresses = {};
        jsonResponse.forEach((data) {
          addresses[data['rental_id'].toString()] =
              data['rental_adress'].toString();
        });

        setState(() {
          properties = addresses;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch properties: $e')),
      );
    }
  }

  Future<void> _loadUnits(String rentalId) async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    try {
      final response =
      await http.get(Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'),headers: {"authorization" : "CRM $token","id":"CRM $id",});
      print('$Api_url/api/unit/rental_unit/$rentalId');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> unitAddresses = {};
        jsonResponse.forEach((data) {
          unitAddresses[data['unit_id'].toString()] =
              data['rental_unit'].toString();
        });

        setState(() {
          units = unitAddresses;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load units');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch units: $e')),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _loadProperties();
  }
  String? _selectedCategory;
  final List<String> _category = ['Complaint', 'Contribution Request', 'Feedback/Suggestion', 'General inquiry','Maintenance Request','Other'];
  String? _selectedEntry;
  final List<String> _entry = ['Yes', 'No', ];
  List<Map<String, dynamic>> rows = [];
  bool _showTextField = false;
  String renderId = '';
  String unitId = '';
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      key: key,
      appBar: widget_302.App_Bar(context: context,onDrawerIconPressed: () {
         // print("calling appbar");
    key.currentState!.openDrawer();
    // Scaffold.of(context).openDrawer();
    }),
      backgroundColor: Colors.white,
      drawer:  CustomDrawer(currentpage: 'Work Order',),
      body: Form(
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
                  title: 'New Work Order',
                ),
                SizedBox(
                  height: 15,
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Subject *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            hintText: 'Add subject',
                            controller: subject,
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
                          Text('Photo ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
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
                              onPressed: () async {
                                await selectImages();
                              },
                              child: isLoading
                                  ? Center(
                                child: SpinKitFadingCircle(
                                  color: Colors.white,
                                  size: 55.0,
                                ),
                              )
                                  : Text(
                                'Upload here',
                                style: TextStyle(color: Color(0xFFf7f8f9)),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: uploaded_images.map((imageUrl) {
                              return Container(
                                width:  uploaded_images.length == 1
                                    ? MediaQuery.of(context).size.width / 4
                                    : (MediaQuery.of(context).size.width / 4) - 10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onLongPress: (){
                                    setState(() {
                                      uploaded_images.remove(imageUrl);
                                    });
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: "$image_url$imageUrl",
                                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error){
                                        print(error);
                                        return Container();
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Property *',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          _isLoading
                              ? const Center(
                            child: SpinKitFadingCircle(
                              color: Colors.black,
                              size: 50.0,
                            ),
                          )
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonHideUnderline(
                                child: DropdownButtonFormField2<String>(
                                  decoration: InputDecoration(
                                      border: InputBorder.none),
                                  isExpanded: true,
                                  hint: const Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Select Property',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFFb0b6c3),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  items: properties.keys.map((rentalId) {
                                    return DropdownMenuItem<String>(
                                      value: rentalId,
                                      child: Text(
                                        properties[rentalId]!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  value: _selectedPropertyId,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUnitId = null;
                                      _selectedPropertyId = value;
                                      _selectedProperty = properties[
                                      value]; // Store selected rental_adress

                                      renderId = value.toString();
                                      print(
                                          'Selected Property: $_selectedProperty');
                                      _loadUnits(
                                          value!); // Fetch units for the selected property
                                    });
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 45,
                                    width: 160,
                                    padding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(6),
                                      color: Colors.white,
                                    ),
                                    elevation: 2,
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                    iconSize: 24,
                                    iconEnabledColor: Color(0xFFb0b6c3),
                                    iconDisabledColor: Colors.grey,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(6),
                                      color: Colors.white,
                                    ),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(6),
                                      thickness:
                                      MaterialStateProperty.all(6),
                                      thumbVisibility:
                                      MaterialStateProperty.all(true),
                                    ),
                                  ),
                                  menuItemStyleData:
                                  const MenuItemStyleData(
                                    height: 40,
                                    padding: EdgeInsets.only(
                                        left: 14, right: 14),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select an option';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              units.isNotEmpty
                                  ? const Text('Unit',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))
                                  : Container(),
                              const SizedBox(height: 0),
                              units.isNotEmpty
                                  ? DropdownButtonHideUnderline(
                                child:
                                DropdownButtonFormField2<String>(
                                  decoration: InputDecoration(
                                      border: InputBorder.none),
                                  isExpanded: true,
                                  hint: const Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Select Unit',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.w400,
                                            color: Color(0xFFb0b6c3),
                                          ),
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  items: units.keys.map((unitId) {
                                    return DropdownMenuItem<String>(
                                      value: unitId,
                                      child: Text(
                                        units[unitId]!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black87,
                                        ),
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  value: _selectedUnitId,
                                  onChanged: (value) {
                                    setState(() {
                                      unitId = value.toString();
                                      _selectedUnitId = value;
                                      _selectedUnit = units[
                                      value]; // Store selected rental_unit

                                      print(
                                          'Selected Unit: $_selectedUnit');
                                    });
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 45,
                                    width: 160,
                                    padding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(6),
                                      color: Colors.white,
                                    ),
                                    elevation: 2,
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    iconEnabledColor:
                                    Color(0xFFb0b6c3),
                                    iconDisabledColor: Colors.grey,
                                  ),
                                  dropdownStyleData:
                                  DropdownStyleData(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(6),
                                      color: Colors.white,
                                    ),
                                    scrollbarTheme:
                                    ScrollbarThemeData(
                                      radius:
                                      const Radius.circular(6),
                                      thickness:
                                      MaterialStateProperty.all(
                                          6),
                                      thumbVisibility:
                                      MaterialStateProperty.all(
                                          true),
                                    ),
                                  ),
                                  menuItemStyleData:
                                  const MenuItemStyleData(
                                    height: 40,
                                    padding: EdgeInsets.only(
                                        left: 14, right: 14),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty) {
                                      return 'Please select an option';
                                    }
                                    return null;
                                  },
                                ),
                              )
                                  : Container(),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Category',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Text('Select Category'),
                              value: _selectedCategory,
                              items: _category.map((method) {
                                return DropdownMenuItem<String>(
                                  value: method,
                                  child: Text(method),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue;
                                  _showTextField = _selectedCategory == 'Other';

                                });
                                print('Selected category: $_selectedCategory');
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                              //  width: 250,
                                padding: const EdgeInsets.only(left: 1, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                ),
                                iconSize: 24,
                                iconEnabledColor: Color(0xFFb0b6c3),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(6),
                                  thickness: MaterialStateProperty.all(6),
                                  thumbVisibility: MaterialStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                          _showTextField
                              ? Padding(
                                padding: const EdgeInsets.only(top: 10,bottom: 10),
                                child: buildTextField('Other Category', 'Enter Other Category',other),
                              )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Entery allowed ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Text('Select'),
                              value: _selectedEntry,
                              items: _entry.map((method) {
                                return DropdownMenuItem<String>(
                                  value: method,
                                  child: Text(method),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedEntry = newValue;
                                  //_selectedPaymentMethod = addRow();
                                  // if(_selectedCategory == 'Other')
                                  // addRow();

                                });
                                print('Selected category: $_selectedEntry');
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                              //  width: 200,
                                padding: const EdgeInsets.only(left: 1, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                ),
                                iconSize: 24,
                                iconEnabledColor: Color(0xFFb0b6c3),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(6),
                                  thickness: MaterialStateProperty.all(6),
                                  thumbVisibility: MaterialStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Welcome To Be Performed',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'Enter here',
                            controller: perform,
                          ),
                          SizedBox(
                            height: 10,
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
                          onPressed: _submitForm,
                          child: isLoading
                              ? Center(
                            child: SpinKitFadingCircle(
                              color: Colors.white,
                              size: 55.0,
                            ),
                          )
                              : Text(
                            'Add Work Order',
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
      ),
    );
  }
  Widget buildTextField(String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey)),
        SizedBox(height: 8.0),
        Material(
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
              focusNode: FocusNode(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
              ),
            ),
          ),
        ),
      ],
    );
  }
  bool isLoading = false;
  bool formValid = true;

  void _submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstName = prefs.getString("first_name");
    String? lastName = prefs.getString("last_name");
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
      String? admin_id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      String? rentalId = _selectedPropertyId;
      String? unitId = _selectedUnitId;

      try {
        final workOrder = await WorkOrderRepository().addWorkOrder(
          adminId: admin_id,
          workOrder_images: uploaded_images,
          workSubject: subject.text,

          workCategory: _selectedCategory!,
          workPerformed: perform.text,
          status: 'Pending',
          rentalAddress: properties[_selectedPropertyId]!,
          rentalUnit: units[_selectedUnitId]!,
          tenant: "${firstName} ${lastName}(Tenant)",
          rentalid: rentalId,
          unitid: unitId,
          entry: _selectedEntry == 'Yes',
        );

        Fluttertoast.showToast(
            msg: "Work order added successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.pop(context, true);
        // Handle success: Maybe navigate to another screen or reset the form
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Failed to add work order: $e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

        // Handle error: Log the error, show a dialog, etc.
        print(e);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        formValid = false;
      });
      print('Form is invalid');
    }
  }

}


