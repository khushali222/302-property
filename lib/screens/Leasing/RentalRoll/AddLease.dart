// ignore_for_file: non_constant_identifier_names, deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/staffmember.dart';
import 'package:three_zero_two_property/repository/Staffmember.dart';
import 'package:three_zero_two_property/repository/rental_properties.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../Model/propertytype.dart';
import '../../../constant/constant.dart';
import '../../../model/add_property.dart';
import '../../../model/rental_properties.dart';
import '../../../provider/add_property.dart';
import '../../../repository/Property_type.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../widgets/rental_widget.dart';
import 'package:http/http.dart' as http;

import '../../Staff_Member/Edit_staff_member.dart';

class AddLease extends StatefulWidget {
  propertytype? property;
  Staffmembers? staff;

  AddLease({super.key, this.property, this.staff});

  @override
  State<AddLease> createState() => _AddLeaseState();
}

class _AddLeaseState extends State<AddLease> {
  List<String> months = ['Residential', "Commercial"];
  List<Widget> fields = [];
  int? selectedIndex;
  List<ProcessorGroup> _processorGroups = [];

  final List<String> items = [
    'Residential',
    "Commercial",
  ];
  String? selectedStaff;
  List<String> staffMembers = ['Mansi Patel', 'jadeja yash', 'Bob Smith'];
  bool isLoading = false;
  String? selectedValue;
  bool isChecked = false;
  bool isChecked2 = false;
  bool showproperty = false;
  String selectedMonth = 'Residential';

  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController postalcode = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController subtype = TextEditingController();

  bool addresserror = false;
  bool cityerror = false;
  bool stateerror = false;
  bool countryerror = false;
  bool postalcodeerror = false;
  bool subtypeerror = false;
  bool propertyTypeError = false;

  String addressmessage = "";
  String citymessage = "";
  String statemessage = "";
  String countrymessage = "";
  String postalcodemessage = "";
  String subtypemessage = "";
  String propertyTypeErrorMessage = "";
  //add rental owner

  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController comname = TextEditingController();
  TextEditingController primaryemail = TextEditingController();
  TextEditingController alternativeemail = TextEditingController();
  TextEditingController phonenum = TextEditingController();
  TextEditingController homenum = TextEditingController();
  TextEditingController businessnum = TextEditingController();
  TextEditingController street2 = TextEditingController();
  TextEditingController city2 = TextEditingController();
  TextEditingController state2 = TextEditingController();
  TextEditingController county2 = TextEditingController();
  TextEditingController code2 = TextEditingController();
  TextEditingController proid = TextEditingController();

  bool firstnameerror = false;
  bool lastnameerror = false;
  bool comnameerror = false;
  bool primaryemailerror = false;
  bool alternativeerror = false;
  bool phonenumerror = false;
  bool homenumerror = false;
  bool businessnumerror = false;
  bool street2error = false;
  bool city2error = false;
  bool state2error = false;
  bool county2error = false;
  bool code2error = false;
  bool proiderror = false;

  String firstnamemessage = "";
  String lastnamemessage = "";
  String comnamemessage = "";
  String primaryemailmessage = "";
  String alternativemessage = "";
  String phonenummessage = "";
  String homenummessage = "";
  String businessnummessage = "";
  String street2message = "";
  String city2message = "";
  String state2message = "";
  String county2message = "";
  String code2message = "";
  String proidmessage = "";

  TextEditingController searchController = TextEditingController();

  late Future<List<Staffmembers>> futureStaffMembers;
  String? selectedStaffmember;

  Future<List<propertytype>>? futureProperties;
  String? selectedProperty;
  Future<List<RentalOwners>>? futureRentalOwner;

  Map<String, List<propertytype>> groupPropertiesByType(
      List<propertytype> properties) {
    Map<String, List<propertytype>> groupedProperties = {};
    for (var property in properties) {
      if (!groupedProperties.containsKey(property.propertyType)) {
        groupedProperties[property.propertyType!] = [];
      }
      groupedProperties[property.propertyType!]!.add(property);
    }
    return groupedProperties;
  }

  List<Owner> owners = [];
  List<Owner> filteredOwners = [];
  List<bool> selected = [];

  Future<void> fetchOwners() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    final response =
        await http.get(Uri.parse('${Api_url}/api/rentals/rental-owners/$id'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      owners = data.map((item) => Owner.fromJson(item)).toList();
      filteredOwners = List.from(owners);
      selected = List<bool>.filled(owners.length, false);
    } else {
      // Handle error
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterOwners(String query) {
    setState(() {
      filteredOwners = owners.where((owner) {
        final fullName = '${owner.firstName} ${owner.lastName}'.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    filteredOwners = owners;
    selected = List<bool>.generate(owners.length, (index) => false);
    // searchController.addListener(() { });
    // futureMember = StaffMemberRepository().fetchStaffmembers();
    futureProperties = PropertyTypeRepository().fetchPropertyTypes();
    futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
    propertyGroups = [];
    // Add property group based on selected subproperty type
    addPropertyGroup();
    fetchOwners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Owner? selectedOwner;
  Owner? rentalOwnerId;
  Owner? getSelectedOwner() {
    for (int i = 0; i < selected.length; i++) {
      if (selected[i]) {
        return filteredOwners[i];
      }
    }
    return null;
  }

  void onAddButtonTapped() {
    for (int i = 0; i < selected.length; i++) {
      if (selected[i]) {
        setState(() {
          selectedOwner = filteredOwners[i];
        });
        return;
      }
    }
    // Show a message to select an owner
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Please select an owner.'),
    ));
  }

  List<List<TextEditingController>> propertyGroupControllers = [];

  bool iserror = false;
  bool iserror2 = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController designation = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool nameerror = false;
  bool designationerror = false;
  bool phonenumbererror = false;
  bool emailerror = false;
  bool passworderror = false;
  propertytype? selectedpropertytypedata = propertytype();
  propertytype? id = propertytype();
  String? sid = "";
  String? showdata;

//  propertytype? selectedpropertytype = propertytype();
  String? selectedpropertytype;
  //propertytype? selectedIsMultiUnit;
  bool selectedIsMultiUnit = false;
  String namemessage = "";
  String designationmessage = "";
  String phonenumbermessage = "";
  String emailmessage = "";
  String passwordmessage = "";

  bool loading = false;
  List<Widget> units = [];

  void removePropertyGroup(int index) {
    setState(() {
      propertyGroups.removeAt(index);
    });
  }

  Future<void> getImage(int index) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // try {
      String? filename = await uploadImage(File(pickedFile.path));
      print(index);
      print(filename);
      setState(() {
        propertyGroupImagenames[index] = filename!;
        //  _uploadedFilename = filename;
      });
      // } catch (e) {
      // print('Error uploading image: $e');
      //}09
    }
    setState(() {
      if (pickedFile != null) {
        print('Image selected: ${pickedFile.path}');
        print('Before: ${propertyGroupImages.length}');
        propertyGroupImages[index] = File(pickedFile.path);
        print('After : ${propertyGroupImages.length}');
      } else {
        print('No image selected.');
      }
    });
  }

  List<List<Widget>> propertyGroups = [];
//  List<List<TextEditingController>> propertyGroupControllers = [];
  List<File?> propertyGroupImages = [];
  List<String?> propertyGroupImagenames = [];
  File? _image;
  Future<String?> uploadImage(File imageFile) async {
    print(imageFile.path!);
    // API URL
    //   final String uploadUrl = 'http://192.168.1.17:4000/api/images/upload';
    final String uploadUrl = '${Api_url}/api/images/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('files', imageFile!.path));
    }
    // Create a multipart request
//    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

    // Attach the file in the 'image' field
    // var multipartFile = await http.MultipartFile.fromPath(
    //   'files',
    //   imageFile.path,
    // //  contentType: MediaType('image', 'jpeg'), // Adjust based on your file type
    // );
    //
    // // Add the file to the request
    // request.files.add(multipartFile);

    // Send the request
    var response = await request.send();
    // Parse the response
    var responseData = await http.Response.fromStream(response);
    print(responseData.body);
    var responseBody = json.decode(responseData.body);

    // Extract the filename from the response
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      print(file.first["filename"]);
      print(file.first.runtimeType);
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  Widget customTextField(String label, TextEditingController Controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: TextFormField(
        controller: Controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: label,
          // labelText: label,
          // labelStyle: TextStyle(color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: const BorderSide(color: Color(0xFF8A95A8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: const BorderSide(color: Color(0xFF8A95A8), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }

  Widget photo(int index) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            const Row(
              children: [
                Text(
                  'Photo',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    getImage(index).then((_) {
                      setState(
                          () {}); // Rebuild the widget after selecting the image
                    });
                  },
                  child: const Text(
                    '+ Add',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (propertyGroupImages[index] != null)
              Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            propertyGroupImages[index] =
                                null; // Clear the selected image
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Image.file(
                          propertyGroupImages[index]!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  void addPropertyGroup() {
    print("hello");
    List<Widget> fields = [];
    List<TextEditingController> controllers = [];

    print(selectedpropertytype);

    if (selectedpropertytype == 'Commercial' && selectedIsMultiUnit == true) {
      var unitController = TextEditingController();
      var unitAddressController = TextEditingController();
      var sqftController = TextEditingController();

      fields = [
        customTextField('Unit', unitController),
        customTextField('Unit Address', unitAddressController),
        customTextField('SQft', sqftController),

        const SizedBox(
          height: 10,
        ),
        photo(propertyGroups.length), // Pass the index
      ];

      controllers = [unitController, unitAddressController, sqftController];
    } else if (selectedpropertytype == 'Residential' &&
        selectedIsMultiUnit == true) {
      var unitController = TextEditingController();
      var unitAddressController = TextEditingController();
      var sqftController = TextEditingController();
      var bathController = TextEditingController();
      var bedController = TextEditingController();

      fields = [
        customTextField('Unit', unitController),
        customTextField('Unit Address', unitAddressController),
        customTextField('SQft', sqftController),
        customTextField('Bath', bathController),
        customTextField('Bed', bedController),

        const SizedBox(
          height: 10,
        ),
        photo(propertyGroups.length), // Pass the index
      ];

      controllers = [
        unitController,
        unitAddressController,
        sqftController,
        bathController,
        bedController
      ];
    } else if (selectedpropertytype == 'Residential') {
      var sqftController = TextEditingController();
      var bathController = TextEditingController();
      var bedController = TextEditingController();

      fields = [
        customTextField('SQft', sqftController),
        customTextField('Bath', bathController),
        customTextField('Bed', bedController),

        const SizedBox(
          height: 10,
        ),
        photo(propertyGroups.length), // Pass the index
      ];

      controllers = [sqftController, bathController, bedController];
    } else if (selectedpropertytype == 'Commercial') {
      var sqftController = TextEditingController();

      fields = [
        customTextField('SQft', sqftController),

        const SizedBox(
          height: 10,
        ),
        photo(propertyGroups.length), // Pass the index
      ];

      controllers = [sqftController];
    }

    setState(() {
      propertyGroups.add(fields);
      propertyGroupControllers.add(controllers);
      propertyGroupImages.add(null);
      propertyGroupImagenames.add(null);
      // Initialize with null for the new group
    });
  }

  void displayPropertyData() {
    // Check if the first element is blank and remove it if it is
    if (propertyGroupControllers.isNotEmpty) {
      List<TextEditingController> firstControllers =
          propertyGroupControllers[0];
      bool isFirstBlank =
          firstControllers.every((controller) => controller.text.isEmpty);

      if (isFirstBlank) {
        propertyGroupControllers.removeAt(0);
      }
    }

    print(propertyGroupControllers.length);

    for (int i = 0; i < propertyGroupControllers.length; i++) {
      List<TextEditingController> controllers = propertyGroupControllers[i];
      for (int j = 0; j < controllers.length; j++) {
        print(controllers[j].text);
      }
    }
  }

  void handleEdit(RentalOwner rental) async {
    // Handle edit action
    // print('Edit ${rental.sId}');
    // // final result = await Navigator.push(
    // //     context,
    // //     MaterialPageRoute(
    // //         builder: (context) => Edit_staff_member(
    // //           staff: rental,
    // //         )));
    // if (result == true) {
    //   setState(() {
    //     futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
    //   });
    // }
  }
  RentalOwner? Ownersdetails;
  List<OwnersDetails> OwnersdetailsGroups = [];
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    // print(selectedIsMultiUnit);
    // print(selectedProperty);
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    height: 50.0,
                    padding: const EdgeInsets.only(top: 8, left: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color.fromRGBO(21, 43, 81, 1),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: const Text(
                      "Add Property",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                //dropdown

                const SizedBox(height: 25),
                //rental
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Owner Information",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Who is the property owner ? (Required)",
                                  style: TextStyle(
                                      color: Color(0xFF8A95A8),
                                      //  fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "This information will be used to help prepare owner drawns and 1099s",
                                    style: TextStyle(
                                        color: Color(0xFF8A95A8),
                                        //  fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    bool isChecked =
                                        false; // Moved isChecked inside the StatefulBuilder
                                    return StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter setState) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          surfaceTintColor: Colors.white,
                                          title: const Text(
                                            "Add Rental Owner",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontSize: 15),
                                          ),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    // SizedBox(width: 5,),
                                                    SizedBox(
                                                      width:
                                                          24.0, // Standard width for checkbox
                                                      height: 24.0,
                                                      child: Checkbox(
                                                        value: isChecked,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            isChecked =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: isChecked
                                                            ? const Color
                                                                .fromRGBO(
                                                                21, 43, 81, 1)
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    const Expanded(
                                                      child: Text(
                                                        "choose an existing rental owner",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                isChecked
                                                    ? Column(
                                                        children: [
                                                          const SizedBox(
                                                              height: 16.0),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  child:
                                                                      Container(
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      // color: Colors
                                                                      //     .white,
                                                                      border: Border.all(
                                                                          color:
                                                                              const Color(0xFF8A95A8)),
                                                                    ),
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        Positioned
                                                                            .fill(
                                                                          child:
                                                                              TextField(
                                                                            controller:
                                                                                searchController,
                                                                            //keyboardType: TextInputType.emailAddress,
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                if (value != "") filteredOwners = owners.where((element) => element.firstName.toLowerCase().contains(value.toLowerCase())).toList();
                                                                                if (value == "") {
                                                                                  filteredOwners = owners;
                                                                                }
                                                                              });
                                                                            },
                                                                            cursorColor: const Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              border: InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              hintText: "Search by first and last name",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 16.0),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                            child: DataTable(
                                                              columnSpacing: 10,
                                                              headingRowHeight:
                                                                  29,
                                                              dataRowHeight: 30,
                                                              // horizontalMargin: 10,
                                                              columns: const [
                                                                DataColumn(
                                                                    label:
                                                                        Expanded(
                                                                  child: Text(
                                                                    'Rentalowner \nName',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                )),
                                                                DataColumn(
                                                                    label:
                                                                        Expanded(
                                                                  child: Text(
                                                                    'Processor \nID',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                )),
                                                                DataColumn(
                                                                    label:
                                                                        Expanded(
                                                                  child: Text(
                                                                    'Select \n',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                )),
                                                              ],
                                                              rows: List<
                                                                  DataRow>.generate(
                                                                filteredOwners
                                                                    .length,
                                                                (index) =>
                                                                    DataRow(
                                                                  cells: [
                                                                    DataCell(
                                                                      Text(
                                                                        '${filteredOwners[index].firstName} '
                                                                        '(${filteredOwners[index].phoneNumber})',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                10),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      Text(
                                                                        filteredOwners[index]
                                                                            .processorList
                                                                            .map((processor) =>
                                                                                processor.processorId)
                                                                            .join('\n'), // Join processor IDs with newline
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                10),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                        width:
                                                                            10,
                                                                        child:
                                                                            Checkbox(
                                                                          value:
                                                                              selectedIndex == index,
                                                                          onChanged:
                                                                              (bool? value) {
                                                                            setState(() {
                                                                              if (value != null && value) {
                                                                                selectedIndex = index;
                                                                                selectedOwner = filteredOwners[index];
                                                                                firstname.text = selectedOwner!.firstName;
                                                                                lastname.text = selectedOwner!.lastName;
                                                                                comname.text = selectedOwner!.companyName;
                                                                                primaryemail.text = selectedOwner!.primaryEmail;
                                                                                alternativeemail.text = selectedOwner!.alternateEmail;
                                                                                homenum.text = selectedOwner!.homeNumber ?? '';
                                                                                phonenum.text = selectedOwner!.phoneNumber;
                                                                                businessnum.text = selectedOwner!.businessNumber ?? '';
                                                                                street2.text = selectedOwner!.streetAddress;
                                                                                city2.text = selectedOwner!.city;
                                                                                state2.text = selectedOwner!.state;
                                                                                county2.text = selectedOwner!.country;
                                                                                code2.text = selectedOwner!.postalCode;
                                                                                proid.text = selectedOwner!.processorList.map((processor) => processor.processorId).join(', ');
                                                                              } else {
                                                                                selectedIndex = null;
                                                                              }
                                                                              isChecked2 = true;
                                                                              isChecked = false;
                                                                              _processorGroups.clear();
                                                                              for (Processor processor in selectedOwner!.processorList) {
                                                                                _processorGroups.add(ProcessorGroup(isChecked: false, controller: TextEditingController(text: processor.processorId)));
                                                                              }
                                                                            });
                                                                          },
                                                                          activeColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16.0),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (!isChecked2) {
                                                                    print(
                                                                        !isChecked2);
                                                                    var response =
                                                                        await Rental_PropertiesRepository()
                                                                            .checkIfRentalOwnerExists(
                                                                      rentalOwner_firstName:
                                                                          firstname
                                                                              .text,
                                                                      rentalOwner_lastName:
                                                                          lastname
                                                                              .text,
                                                                      rentalOwner_companyName:
                                                                          comname
                                                                              .text,
                                                                      rentalOwner_primaryEmail:
                                                                          primaryemail
                                                                              .text,
                                                                      rentalOwner_alternativeEmail:
                                                                          alternativeemail
                                                                              .text,
                                                                      rentalOwner_phoneNumber:
                                                                          phonenum
                                                                              .text,
                                                                      rentalOwner_homeNumber:
                                                                          homenum
                                                                              .text,
                                                                      rentalOwner_businessNumber:
                                                                          businessnum
                                                                              .text,
                                                                      // rentalowner_id: rentalOwnerId != null ? rentalOwnerId!.rentalOwnerId : "", // Providing a default value if rentalOwnerId is null
                                                                    );
                                                                    if (response ==
                                                                        true) {
                                                                      print(
                                                                          "check true");

                                                                      Ownersdetails =
                                                                          RentalOwner(
                                                                        // rentalOwnerFirstName: firstname.text,
                                                                        rentalOwnerLastName:
                                                                            lastname.text,
                                                                        rentalOwnerPhoneNumber:
                                                                            phonenum.text,
                                                                        rentalOwnerFirstName:
                                                                            firstname.text,
                                                                      );
                                                                      context
                                                                          .read<
                                                                              OwnerDetailsProvider>()
                                                                          .setOwnerDetails(
                                                                              Ownersdetails!);
                                                                      //  Provider.of<OwnerDetailsProvider>(context,listen: false).setOwnerDetails(Ownersdetails!);

                                                                      Fluttertoast
                                                                          .showToast(
                                                                        msg:
                                                                            "Rental Owner Added Successfully!",
                                                                        toastLength:
                                                                            Toast.LENGTH_SHORT,
                                                                        gravity:
                                                                            ToastGravity.TOP,
                                                                        timeInSecForIosWeb:
                                                                            1,
                                                                        backgroundColor:
                                                                            Colors.green,
                                                                        textColor:
                                                                            Colors.white,
                                                                        fontSize:
                                                                            16.0,
                                                                      );
                                                                      setState(
                                                                          () {
                                                                        hasError =
                                                                            false; // Set error state if the response is not true
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                      // SetshowRentalOwnerTable();
                                                                    }
                                                                  } else {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                      msg:
                                                                          "Rental Owner Successfully!",
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_SHORT,
                                                                      gravity:
                                                                          ToastGravity
                                                                              .TOP,
                                                                      timeInSecForIosWeb:
                                                                          1,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                      fontSize:
                                                                          16.0,
                                                                    );
                                                                    Ownersdetails =
                                                                        RentalOwner(
                                                                      // rentalOwnerFirstName: firstname.text,
                                                                      rentalOwnerLastName:
                                                                          lastname
                                                                              .text,
                                                                      rentalOwnerPhoneNumber:
                                                                          phonenum
                                                                              .text,
                                                                      rentalOwnerFirstName:
                                                                          firstname
                                                                              .text,
                                                                    );
                                                                    context
                                                                        .read<
                                                                            OwnerDetailsProvider>()
                                                                        .setOwnerDetails(
                                                                            Ownersdetails!);
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  }
                                                                },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        30.0,
                                                                    width: 50,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      color: const Color
                                                                          .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0), //(x,y)
                                                                          blurRadius:
                                                                              6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child: isLoading
                                                                          ? const SpinKitFadingCircle(
                                                                              color: Colors.white,
                                                                              size: 25.0,
                                                                            )
                                                                          : const Text(
                                                                              "Add",
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.03),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        30.0,
                                                                    width: 50,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      color: Colors
                                                                          .white,
                                                                      boxShadow: [
                                                                        const BoxShadow(
                                                                          color:
                                                                              Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0), //(x,y)
                                                                          blurRadius:
                                                                              6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child: isLoading
                                                                          ? const SpinKitFadingCircle(
                                                                              color: Colors.white,
                                                                              size: 25.0,
                                                                            )
                                                                          : const Text(
                                                                              "Cancel",
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold, fontSize: 10),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    : Column(
                                                        children: [
                                                          const SizedBox(
                                                            height: 25,
                                                          ),
                                                          const Row(
                                                            children: [
                                                              Text(
                                                                "Name",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          //firstname
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              firstnameerror = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              firstname,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: firstnameerror
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter first name",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          firstnameerror
                                                              ? Center(
                                                                  child: Text(
                                                                  firstnamemessage,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //lastname
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              lastnameerror = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              lastname,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: lastnameerror
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            hintText:
                                                                                "Enter last name",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          lastnameerror
                                                              ? Center(
                                                                  child: Text(
                                                                  lastnamemessage,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //company name
                                                          const Row(
                                                            children: [
                                                              Text(
                                                                "Company Name",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              comnameerror = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              comname,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: comnameerror
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter company name",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          comnameerror
                                                              ? Center(
                                                                  child: Text(
                                                                  comnamemessage,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //primary email
                                                          const Row(
                                                            children: [
                                                              Text(
                                                                "Primary Email",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              primaryemailerror = false;
                                                                            });
                                                                          },
                                                                          keyboardType:
                                                                              TextInputType.emailAddress,
                                                                          controller:
                                                                              primaryemail,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: primaryemailerror
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter  primary email",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          primaryemailerror
                                                              ? Center(
                                                                  child: Text(
                                                                  primaryemailmessage,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //Alternative Email
                                                          const Row(
                                                            children: [
                                                              Text(
                                                                "Alternative Email",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              alternativeerror = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              alternativeemail,
                                                                          keyboardType:
                                                                              TextInputType.emailAddress,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: alternativeerror
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter alternative email",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          alternativeerror
                                                              ? Center(
                                                                  child: Text(
                                                                  alternativemessage,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //Phone Numbers
                                                          const Row(
                                                            children: [
                                                              Text(
                                                                "Phone Numbers",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              phonenumerror = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              phonenum,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: phonenumerror
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter phone numbers",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          phonenumerror
                                                              ? Center(
                                                                  child: Text(
                                                                  phonenummessage,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          //homenumber
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              homenumerror = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              homenum,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: homenumerror
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter home number",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          homenumerror
                                                              ? Center(
                                                                  child: Text(
                                                                  homenummessage,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              businessnumerror = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              businessnum,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: businessnumerror
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            hintText:
                                                                                "Enter business number",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          businessnumerror
                                                              ? Center(
                                                                  child: Text(
                                                                  businessnummessage,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //Address information
                                                          const Row(
                                                            children: [
                                                              Text(
                                                                "Address Information",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          //Street Address
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              street2error = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              street2,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: street2error
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter street address",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          street2error
                                                              ? Center(
                                                                  child: Text(
                                                                  street2message,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          //city and state
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              city2error = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              city2,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: city2error
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter city",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .03,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              state2error = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              state2,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: state2error
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter state",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          Row(
                                                            children: [
                                                              city2error
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                      city2message,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ))
                                                                  : Container(),
                                                              const SizedBox(
                                                                width: 70,
                                                              ),
                                                              state2error
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                      state2message,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ))
                                                                  : Container(),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          // counrty and postal code
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              county2error = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              county2,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: county2error
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter country",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .03,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: const Color(
                                                                            0xFF8A95A8)),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned
                                                                          .fill(
                                                                        child:
                                                                            TextField(
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              street2error = false;
                                                                            });
                                                                          },
                                                                          controller:
                                                                              code2,
                                                                          cursorColor: const Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            enabledBorder: code2error
                                                                                ? OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                  )
                                                                                : InputBorder.none,
                                                                            border:
                                                                                InputBorder.none,
                                                                            contentPadding:
                                                                                const EdgeInsets.all(11),
                                                                            // prefixIcon: Container(
                                                                            //   height: 20,
                                                                            //   width: 20,
                                                                            //   padding: EdgeInsets.all(13),
                                                                            //   child: FaIcon(
                                                                            //     FontAwesomeIcons.envelope,
                                                                            //     size: 20,
                                                                            //     color: Colors.grey[600],
                                                                            //   ),
                                                                            // ),
                                                                            hintText:
                                                                                "Enter postal code",
                                                                            hintStyle:
                                                                                const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          Row(
                                                            children: [
                                                              county2error
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                      county2message,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ))
                                                                  : Container(),
                                                              const SizedBox(
                                                                width: 70,
                                                              ),
                                                              code2error
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                      code2message,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ))
                                                                  : Container(),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),

                                                          if (selectedOwner !=
                                                              null)
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                if (selectedOwner!
                                                                    .processorList
                                                                    .isNotEmpty) ...[
                                                                  const Row(
                                                                    children: [
                                                                      Text(
                                                                        "Merchant Id",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Color(0xFF8A95A8),
                                                                            fontSize: 14),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Column(
                                                                    children: [
                                                                      Column(
                                                                          children:
                                                                              _processorGroups.map((group) {
                                                                        return Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              vertical: 8.0),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              SizedBox(
                                                                                width: 20.0,
                                                                                height: 20.0,
                                                                                child: Checkbox(
                                                                                  value: group?.isChecked,
                                                                                  onChanged: (value) {
                                                                                    setState(() {
                                                                                      group?.isChecked = value ?? false;
                                                                                    });
                                                                                  },
                                                                                  activeColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: MediaQuery.of(context).size.width * .02),
                                                                              Expanded(
                                                                                child: Material(
                                                                                  elevation: 3,
                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                  child: Container(
                                                                                    height: 50,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      color: Colors.white,
                                                                                      border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                    ),
                                                                                    child: Stack(
                                                                                      children: [
                                                                                        Positioned.fill(
                                                                                          child: TextField(
                                                                                            controller: group.controller,
                                                                                            cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                            decoration: const InputDecoration(
                                                                                              border: InputBorder.none,
                                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                              hintText: "Enter processor",
                                                                                              hintStyle: TextStyle(
                                                                                                color: Color(0xFF8A95A8),
                                                                                                fontSize: 13,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: MediaQuery.of(context).size.width * .02),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    _processorGroups.remove(group);
                                                                                  });
                                                                                },
                                                                                child: Container(
                                                                                  padding: EdgeInsets.zero,
                                                                                  child: const FaIcon(
                                                                                    FontAwesomeIcons.trashCan,
                                                                                    size: 20,
                                                                                    color: Color.fromRGBO(21, 43, 81, 1),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }).toList())
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.01),
                                                                  const Row(
                                                                    children: [
                                                                      // Handle error display here if needed
                                                                    ],
                                                                  ),
                                                                ],
                                                              ],
                                                            ),

                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _processorGroups.add(ProcessorGroup(
                                                                        isChecked:
                                                                            false,
                                                                        controller:
                                                                            TextEditingController()));
                                                                  });
                                                                },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        30.0,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        .3,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      color: const Color
                                                                          .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      boxShadow: [
                                                                        const BoxShadow(
                                                                          color:
                                                                              Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0), //(x,y)
                                                                          blurRadius:
                                                                              6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child: isLoading
                                                                          ? const SpinKitFadingCircle(
                                                                              color: Colors.white,
                                                                              size: 25.0,
                                                                            )
                                                                          : const Text(
                                                                              "Add another",
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.05),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (!isChecked2) {
                                                                    print(
                                                                        !isChecked2);
                                                                    var response =
                                                                        await Rental_PropertiesRepository()
                                                                            .checkIfRentalOwnerExists(
                                                                      rentalOwner_firstName:
                                                                          firstname
                                                                              .text,
                                                                      rentalOwner_lastName:
                                                                          lastname
                                                                              .text,
                                                                      rentalOwner_companyName:
                                                                          comname
                                                                              .text,
                                                                      rentalOwner_primaryEmail:
                                                                          primaryemail
                                                                              .text,
                                                                      rentalOwner_alternativeEmail:
                                                                          alternativeemail
                                                                              .text,
                                                                      rentalOwner_phoneNumber:
                                                                          phonenum
                                                                              .text,
                                                                      rentalOwner_homeNumber:
                                                                          homenum
                                                                              .text,
                                                                      rentalOwner_businessNumber:
                                                                          businessnum
                                                                              .text,
                                                                      // rentalowner_id: rentalOwnerId != null ? rentalOwnerId!.rentalOwnerId : "", // Providing a default value if rentalOwnerId is null
                                                                    );
                                                                    if (response ==
                                                                        true) {
                                                                      print(
                                                                          "check true");

                                                                      Ownersdetails =
                                                                          RentalOwner(
                                                                        // rentalOwnerFirstName: firstname.text,
                                                                        rentalOwnerLastName:
                                                                            lastname.text,
                                                                        rentalOwnerPhoneNumber:
                                                                            phonenum.text,
                                                                        rentalOwnerFirstName:
                                                                            firstname.text,
                                                                      );

                                                                      context
                                                                          .read<
                                                                              OwnerDetailsProvider>()
                                                                          .setOwnerDetails(
                                                                              Ownersdetails!);
                                                                      //  Provider.of<OwnerDetailsProvider>(context,listen: false).setOwnerDetails(Ownersdetails!);

                                                                      Fluttertoast
                                                                          .showToast(
                                                                        msg:
                                                                            "Rental Owner Added Successfully!",
                                                                        toastLength:
                                                                            Toast.LENGTH_SHORT,
                                                                        gravity:
                                                                            ToastGravity.TOP,
                                                                        timeInSecForIosWeb:
                                                                            1,
                                                                        backgroundColor:
                                                                            Colors.green,
                                                                        textColor:
                                                                            Colors.white,
                                                                        fontSize:
                                                                            16.0,
                                                                      );
                                                                      setState(
                                                                          () {
                                                                        hasError =
                                                                            false; // Set error state if the response is not true
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                      // SetshowRentalOwnerTable();
                                                                    }
                                                                  } else {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                      msg:
                                                                          "Rental Owner Successfully!",
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_SHORT,
                                                                      gravity:
                                                                          ToastGravity
                                                                              .TOP,
                                                                      timeInSecForIosWeb:
                                                                          1,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                      fontSize:
                                                                          16.0,
                                                                    );
                                                                    Ownersdetails =
                                                                        RentalOwner(
                                                                      // rentalOwnerFirstName: firstname.text,
                                                                      rentalOwnerLastName:
                                                                          lastname
                                                                              .text,
                                                                      rentalOwnerPhoneNumber:
                                                                          phonenum
                                                                              .text,
                                                                      rentalOwnerFirstName:
                                                                          firstname
                                                                              .text,
                                                                    );

                                                                    context
                                                                        .read<
                                                                            OwnerDetailsProvider>()
                                                                        .setOwnerDetails(
                                                                            Ownersdetails!);
                                                                    Navigator.pop(
                                                                        context);
                                                                  }
                                                                },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        30.0,
                                                                    width: 50,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      color: const Color
                                                                          .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0), // (x,y)
                                                                          blurRadius:
                                                                              6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child: isLoading
                                                                          ? const SpinKitFadingCircle(
                                                                              color: Colors.white,
                                                                              size: 25.0,
                                                                            )
                                                                          : const Text(
                                                                              "Add",
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 10,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.03),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        30.0,
                                                                    width: 50,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      color: Colors
                                                                          .white,
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0), //(x,y)
                                                                          blurRadius:
                                                                              6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child: isLoading
                                                                          ? const SpinKitFadingCircle(
                                                                              color: Colors.white,
                                                                              size: 25.0,
                                                                            )
                                                                          : const Text(
                                                                              "Cancel",
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold, fontSize: 10),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  const SizedBox(width: 15),
                                  Icon(Icons.add,
                                      size: 20, color: Colors.green[400]),
                                  const SizedBox(width: 9),
                                  Text(
                                    "Add Rental Owner",
                                    style: TextStyle(
                                      color: Colors.green[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            if (hasError &&
                                Provider.of<OwnerDetailsProvider>(context)
                                        .OwnerDetails ==
                                    null)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'required',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(
                              height: 5,
                            ),
                            Consumer<OwnerDetailsProvider>(
                              builder: (context, provider, child) {
                                //  final ownersdetails = provider.OwnerDetails;
                                return Ownersdetails != null
                                    ? Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          const Row(
                                            children: [
                                              SizedBox(width: 20),
                                              Text(
                                                "Owners Information",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: DataTable(
                                              columnSpacing: 10,
                                              headingRowHeight: 29,
                                              dataRowHeight: 30,
                                              columns: const [
                                                DataColumn(
                                                  label: Expanded(
                                                    child: Text(
                                                      'FirstName',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Expanded(
                                                    child: Text(
                                                      'LastName',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Expanded(
                                                    child: Text(
                                                      'PhoneNumber',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Expanded(
                                                    child: Text(
                                                      'Action',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              rows: [
                                                DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Text(
                                                        Ownersdetails!
                                                                .rentalOwnerFirstName ??
                                                            'N/A',

                                                        // Ownersdetails!.rentalOwnerFirstName ?? "",
                                                        style: const TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        Ownersdetails!
                                                                .rentalOwnerLastName ??
                                                            'N/A',
                                                        style: const TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        Ownersdetails!
                                                                .rentalOwnerPhoneNumber ??
                                                            'N/A',
                                                        style: const TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  bool
                                                                      isChecked =
                                                                      false; // Moved isChecked inside the StatefulBuilder
                                                                  return StatefulBuilder(
                                                                    builder: (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            setState) {
                                                                      return AlertDialog(
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        surfaceTintColor:
                                                                            Colors.white,
                                                                        title:
                                                                            const Text(
                                                                          "Add Rental Owner",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Color.fromRGBO(21, 43, 81, 1),
                                                                              fontSize: 15),
                                                                        ),
                                                                        content:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  // SizedBox(width: 5,),
                                                                                  SizedBox(
                                                                                    width: 24.0, // Standard width for checkbox
                                                                                    height: 24.0,
                                                                                    child: Checkbox(
                                                                                      value: isChecked,
                                                                                      onChanged: (value) {
                                                                                        setState(() {
                                                                                          isChecked = value ?? false;
                                                                                        });
                                                                                      },
                                                                                      activeColor: isChecked ? const Color.fromRGBO(21, 43, 81, 1) : Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  const Expanded(
                                                                                    child: Text(
                                                                                      "choose an existing rental owner",
                                                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A95A8), fontSize: 12),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              isChecked
                                                                                  ? Column(
                                                                                      children: [
                                                                                        const SizedBox(height: 16.0),
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    // color: Colors
                                                                                                    //     .white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          controller: searchController,
                                                                                                          //keyboardType: TextInputType.emailAddress,
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              if (value != "") filteredOwners = owners.where((element) => element.firstName.toLowerCase().contains(value.toLowerCase())).toList();
                                                                                                              if (value == "") {
                                                                                                                filteredOwners = owners;
                                                                                                              }
                                                                                                            });
                                                                                                          },
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: const InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                            hintText: "Search by first and last name",
                                                                                                            hintStyle: TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        const SizedBox(height: 16.0),
                                                                                        Container(
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(5),
                                                                                            border: Border.all(color: Colors.grey),
                                                                                          ),
                                                                                          child: DataTable(
                                                                                            columnSpacing: 10,
                                                                                            headingRowHeight: 29,
                                                                                            dataRowHeight: 30,
                                                                                            // horizontalMargin: 10,
                                                                                            columns: const [
                                                                                              DataColumn(
                                                                                                  label: Expanded(
                                                                                                child: Text(
                                                                                                  'Rentalowner \nName',
                                                                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                                                                ),
                                                                                              )),
                                                                                              DataColumn(
                                                                                                  label: Expanded(
                                                                                                child: Text(
                                                                                                  'Processor \nID',
                                                                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                                                                ),
                                                                                              )),
                                                                                              DataColumn(
                                                                                                  label: Expanded(
                                                                                                child: Text(
                                                                                                  'Select \n',
                                                                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                                                                ),
                                                                                              )),
                                                                                            ],
                                                                                            rows: List<DataRow>.generate(
                                                                                              filteredOwners.length,
                                                                                              (index) => DataRow(
                                                                                                cells: [
                                                                                                  DataCell(
                                                                                                    Text(
                                                                                                      '${filteredOwners[index].firstName} '
                                                                                                      '(${filteredOwners[index].phoneNumber})',
                                                                                                      style: const TextStyle(fontSize: 10),
                                                                                                    ),
                                                                                                  ),
                                                                                                  DataCell(
                                                                                                    Text(
                                                                                                      filteredOwners[index].processorList.map((processor) => processor.processorId).join('\n'), // Join processor IDs with newline
                                                                                                      style: const TextStyle(fontSize: 10),
                                                                                                    ),
                                                                                                  ),
                                                                                                  // DataCell(
                                                                                                  //   SizedBox(
                                                                                                  //     height:
                                                                                                  //         10,
                                                                                                  //     width:
                                                                                                  //         10,
                                                                                                  //     child:
                                                                                                  //         Checkbox(
                                                                                                  //       value:
                                                                                                  //           selectedIndex == index,
                                                                                                  //       onChanged:
                                                                                                  //           (bool? value) {
                                                                                                  //         setState(() {
                                                                                                  //           if (value != null && value) {
                                                                                                  //             selectedIndex = index;
                                                                                                  //             selectedOwner = filteredOwners[index];
                                                                                                  //             firstname.text = selectedOwner!.firstName;
                                                                                                  //             lastname.text = selectedOwner!.lastName;
                                                                                                  //             comname.text = selectedOwner!.companyName;
                                                                                                  //             primaryemail.text = selectedOwner!.primaryEmail;
                                                                                                  //             alternativeemail.text = selectedOwner!.alternateEmail;
                                                                                                  //             homenum.text = selectedOwner!.homeNumber ?? '';
                                                                                                  //             phonenum.text = selectedOwner!.phoneNumber;
                                                                                                  //             businessnum.text = selectedOwner!.businessNumber ?? '';
                                                                                                  //             street2.text = selectedOwner!.streetAddress;
                                                                                                  //             city2.text = selectedOwner!.city;
                                                                                                  //             state2.text = selectedOwner!.state;
                                                                                                  //             county2.text = selectedOwner!.country;
                                                                                                  //             code2.text = selectedOwner!.postalCode;
                                                                                                  //             proid.text = selectedOwner!.processorList.map((processor) => processor.processorId).join(', ');
                                                                                                  //           } else {
                                                                                                  //             selectedIndex = null;
                                                                                                  //           }
                                                                                                  //           isChecked = false;
                                                                                                  //         });
                                                                                                  //       },
                                                                                                  //       activeColor: Color.fromRGBO(
                                                                                                  //           21,
                                                                                                  //           43,
                                                                                                  //           81,
                                                                                                  //           1),
                                                                                                  //     ),
                                                                                                  //   ),
                                                                                                  // ),
                                                                                                  DataCell(
                                                                                                    SizedBox(
                                                                                                      height: 10,
                                                                                                      width: 10,
                                                                                                      child: Checkbox(
                                                                                                        value: selectedIndex == index,
                                                                                                        onChanged: (bool? value) {
                                                                                                          setState(() {
                                                                                                            if (value != null && value) {
                                                                                                              selectedIndex = index;
                                                                                                              selectedOwner = filteredOwners[index];
                                                                                                              firstname.text = selectedOwner!.firstName;
                                                                                                              lastname.text = selectedOwner!.lastName;
                                                                                                              comname.text = selectedOwner!.companyName;
                                                                                                              primaryemail.text = selectedOwner!.primaryEmail;
                                                                                                              alternativeemail.text = selectedOwner!.alternateEmail;
                                                                                                              homenum.text = selectedOwner!.homeNumber ?? '';
                                                                                                              phonenum.text = selectedOwner!.phoneNumber;
                                                                                                              businessnum.text = selectedOwner!.businessNumber ?? '';
                                                                                                              street2.text = selectedOwner!.streetAddress;
                                                                                                              city2.text = selectedOwner!.city;
                                                                                                              state2.text = selectedOwner!.state;
                                                                                                              county2.text = selectedOwner!.country;
                                                                                                              code2.text = selectedOwner!.postalCode;
                                                                                                              proid.text = selectedOwner!.processorList.map((processor) => processor.processorId).join(', ');
                                                                                                            } else {
                                                                                                              selectedIndex = null;
                                                                                                            }
                                                                                                            isChecked = false;
                                                                                                            _processorGroups.clear();
                                                                                                            for (Processor processor in selectedOwner!.processorList) {
                                                                                                              _processorGroups.add(ProcessorGroup(isChecked: false, controller: TextEditingController(text: processor.processorId)));
                                                                                                            }
                                                                                                          });
                                                                                                        },
                                                                                                        activeColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        const SizedBox(height: 16.0),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            GestureDetector(
                                                                                              onTap: () async {
                                                                                                if (!isChecked2) {
                                                                                                  print(!isChecked2);
                                                                                                  var response = await Rental_PropertiesRepository().checkIfRentalOwnerExists(
                                                                                                    rentalOwner_firstName: firstname.text,
                                                                                                    rentalOwner_lastName: lastname.text,
                                                                                                    rentalOwner_companyName: comname.text,
                                                                                                    rentalOwner_primaryEmail: primaryemail.text,
                                                                                                    rentalOwner_alternativeEmail: alternativeemail.text,
                                                                                                    rentalOwner_phoneNumber: phonenum.text,
                                                                                                    rentalOwner_homeNumber: homenum.text,
                                                                                                    rentalOwner_businessNumber: businessnum.text,
                                                                                                    // rentalowner_id: rentalOwnerId != null ? rentalOwnerId!.rentalOwnerId : "", // Providing a default value if rentalOwnerId is null
                                                                                                  );
                                                                                                  if (response == true) {
                                                                                                    print("check true");

                                                                                                    Ownersdetails = RentalOwner(
                                                                                                      // rentalOwnerFirstName: firstname.text,
                                                                                                      rentalOwnerLastName: lastname.text,
                                                                                                      rentalOwnerPhoneNumber: phonenum.text,
                                                                                                      rentalOwnerFirstName: firstname.text,
                                                                                                    );
                                                                                                    context.read<OwnerDetailsProvider>().setOwnerDetails(Ownersdetails!);
                                                                                                    //  Provider.of<OwnerDetailsProvider>(context,listen: false).setOwnerDetails(Ownersdetails!);

                                                                                                    Fluttertoast.showToast(
                                                                                                      msg: "Rental Owner Added Successfully!",
                                                                                                      toastLength: Toast.LENGTH_SHORT,
                                                                                                      gravity: ToastGravity.TOP,
                                                                                                      timeInSecForIosWeb: 1,
                                                                                                      backgroundColor: Colors.green,
                                                                                                      textColor: Colors.white,
                                                                                                      fontSize: 16.0,
                                                                                                    );
                                                                                                    setState(() {
                                                                                                      hasError = false; // Set error state if the response is not true
                                                                                                    });
                                                                                                    Navigator.pop(context);
                                                                                                    // SetshowRentalOwnerTable();
                                                                                                  }
                                                                                                } else {
                                                                                                  Fluttertoast.showToast(
                                                                                                    msg: "Rental Owner Successfully!",
                                                                                                    toastLength: Toast.LENGTH_SHORT,
                                                                                                    gravity: ToastGravity.TOP,
                                                                                                    timeInSecForIosWeb: 1,
                                                                                                    backgroundColor: Colors.red,
                                                                                                    textColor: Colors.white,
                                                                                                    fontSize: 16.0,
                                                                                                  );
                                                                                                }
                                                                                              },
                                                                                              child: ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                child: Container(
                                                                                                  height: 30.0,
                                                                                                  width: 50,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                                    color: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                    boxShadow: [
                                                                                                      const BoxShadow(
                                                                                                        color: Colors.grey,
                                                                                                        offset: Offset(0.0, 1.0), //(x,y)
                                                                                                        blurRadius: 6.0,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  child: Center(
                                                                                                    child: isLoading
                                                                                                        ? const SpinKitFadingCircle(
                                                                                                            color: Colors.white,
                                                                                                            size: 25.0,
                                                                                                          )
                                                                                                        : const Text(
                                                                                                            "Add",
                                                                                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                                                                                          ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                                                                                            GestureDetector(
                                                                                              onTap: () {
                                                                                                Navigator.pop(context);
                                                                                              },
                                                                                              child: ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                child: Container(
                                                                                                  height: 30.0,
                                                                                                  width: 50,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                                    color: Colors.white,
                                                                                                    boxShadow: [
                                                                                                      const BoxShadow(
                                                                                                        color: Colors.grey,
                                                                                                        offset: Offset(0.0, 1.0), //(x,y)
                                                                                                        blurRadius: 6.0,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  child: Center(
                                                                                                    child: isLoading
                                                                                                        ? const SpinKitFadingCircle(
                                                                                                            color: Colors.white,
                                                                                                            size: 25.0,
                                                                                                          )
                                                                                                        : const Text(
                                                                                                            "Cancel",
                                                                                                            style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold, fontSize: 10),
                                                                                                          ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : Column(
                                                                                      children: [
                                                                                        const SizedBox(
                                                                                          height: 25,
                                                                                        ),
                                                                                        const Row(
                                                                                          children: [
                                                                                            Text(
                                                                                              "Name",
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A95A8), fontSize: 14),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        const SizedBox(
                                                                                          height: 5,
                                                                                        ),
                                                                                        //firstname
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              firstnameerror = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: firstname,
                                                                                                          //  keyboardType: TextInputType.emailAddress,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: firstnameerror
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                            // prefixIcon: Padding(
                                                                                                            //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                            //   child: FaIcon(
                                                                                                            //     FontAwesomeIcons.envelope,
                                                                                                            //     size: 18,
                                                                                                            //     color: Color(0xFF8A95A8),
                                                                                                            //   ),
                                                                                                            // ),
                                                                                                            hintText: "Enter first name",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        firstnameerror
                                                                                            ? Center(
                                                                                                child: Text(
                                                                                                firstnamemessage,
                                                                                                style: const TextStyle(color: Colors.red),
                                                                                              ))
                                                                                            : Container(),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                                        //lastname
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              lastnameerror = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: lastname,
                                                                                                          //  keyboardType: TextInputType.emailAddress,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: lastnameerror
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                            // prefixIcon: Padding(
                                                                                                            //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                            //   child: FaIcon(
                                                                                                            //     FontAwesomeIcons.envelope,
                                                                                                            //     size: 18,
                                                                                                            //     color: Color(0xFF8A95A8),
                                                                                                            //   ),
                                                                                                            // ),
                                                                                                            hintText: "Enter last name ",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        lastnameerror
                                                                                            ? Center(
                                                                                                child: Text(
                                                                                                lastnamemessage,
                                                                                                style: const TextStyle(color: Colors.red),
                                                                                              ))
                                                                                            : Container(),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                                        //company name
                                                                                        const Row(
                                                                                          children: [
                                                                                            Text(
                                                                                              "Company Name",
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A95A8), fontSize: 14),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        const SizedBox(
                                                                                          height: 5,
                                                                                        ),
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              comnameerror = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: comname,
                                                                                                          //keyboardType: TextInputType.emailAddress,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: comnameerror
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                            // prefixIcon: Padding(
                                                                                                            //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                            //   child: FaIcon(
                                                                                                            //     FontAwesomeIcons.envelope,
                                                                                                            //     size: 18,
                                                                                                            //     color: Color(0xFF8A95A8),
                                                                                                            //   ),
                                                                                                            // ),
                                                                                                            hintText: "Enter company name",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        comnameerror
                                                                                            ? Center(
                                                                                                child: Text(
                                                                                                comnamemessage,
                                                                                                style: const TextStyle(color: Colors.red),
                                                                                              ))
                                                                                            : Container(),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                                        //primary email
                                                                                        const Row(
                                                                                          children: [
                                                                                            Text(
                                                                                              "Primary Email",
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A95A8), fontSize: 14),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        const SizedBox(
                                                                                          height: 5,
                                                                                        ),
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              primaryemailerror = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: primaryemail,
                                                                                                          keyboardType: TextInputType.emailAddress,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: primaryemailerror
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                                                            prefixIcon: const Padding(
                                                                                                              padding: EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                                              child: FaIcon(
                                                                                                                FontAwesomeIcons.envelope,
                                                                                                                size: 18,
                                                                                                                color: Color(0xFF8A95A8),
                                                                                                              ),
                                                                                                            ),
                                                                                                            hintText: "Enter primery email",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        primaryemailerror
                                                                                            ? Center(
                                                                                                child: Text(
                                                                                                primaryemailmessage,
                                                                                                style: const TextStyle(color: Colors.red),
                                                                                              ))
                                                                                            : Container(),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                                        //Alternative Email
                                                                                        const Row(
                                                                                          children: [
                                                                                            Text(
                                                                                              "Alternative Email",
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A95A8), fontSize: 14),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        const SizedBox(
                                                                                          height: 5,
                                                                                        ),
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              alternativeerror = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: alternativeemail,
                                                                                                          keyboardType: TextInputType.emailAddress,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: alternativeerror
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                                                            prefixIcon: const Padding(
                                                                                                              padding: EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                                              child: FaIcon(
                                                                                                                FontAwesomeIcons.envelope,
                                                                                                                size: 18,
                                                                                                                color: Color(0xFF8A95A8),
                                                                                                              ),
                                                                                                            ),
                                                                                                            hintText: "Enter alternative email",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        alternativeerror
                                                                                            ? Center(
                                                                                                child: Text(
                                                                                                alternativemessage,
                                                                                                style: const TextStyle(color: Colors.red),
                                                                                              ))
                                                                                            : Container(),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                                        //Phone Numbers
                                                                                        const Row(
                                                                                          children: [
                                                                                            Text(
                                                                                              "Phone Numbers",
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A95A8), fontSize: 14),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        const SizedBox(
                                                                                          height: 5,
                                                                                        ),
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              phonenumerror = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: phonenum,
                                                                                                          keyboardType: TextInputType.phone,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: phonenumerror
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                                                            prefixIcon: const Padding(
                                                                                                              padding: EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                                              child: FaIcon(
                                                                                                                FontAwesomeIcons.phone,
                                                                                                                size: 18,
                                                                                                                color: Color(0xFF8A95A8),
                                                                                                              ),
                                                                                                            ),
                                                                                                            hintText: "Enter phone number",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        phonenumerror
                                                                                            ? Center(
                                                                                                child: Text(
                                                                                                phonenummessage,
                                                                                                style: const TextStyle(color: Colors.red),
                                                                                              ))
                                                                                            : Container(),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                                                        //homenumber
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              homenumerror = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: homenum,
                                                                                                          keyboardType: TextInputType.phone,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: homenumerror
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                                                            prefixIcon: const Padding(
                                                                                                              padding: EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                                              child: FaIcon(
                                                                                                                FontAwesomeIcons.home,
                                                                                                                size: 18,
                                                                                                                color: Color(0xFF8A95A8),
                                                                                                              ),
                                                                                                            ),
                                                                                                            hintText: "Enter home number",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        homenumerror
                                                                                            ? Center(
                                                                                                child: Text(
                                                                                                homenummessage,
                                                                                                style: const TextStyle(color: Colors.red),
                                                                                              ))
                                                                                            : Container(),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              businessnumerror = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: businessnum,
                                                                                                          keyboardType: TextInputType.phone,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: businessnumerror
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                                                            prefixIcon: const Padding(
                                                                                                              padding: EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                                              child: FaIcon(
                                                                                                                FontAwesomeIcons.businessTime,
                                                                                                                size: 18,
                                                                                                                color: Color(0xFF8A95A8),
                                                                                                              ),
                                                                                                            ),
                                                                                                            hintText: "Enter business number",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        businessnumerror
                                                                                            ? Center(
                                                                                                child: Text(
                                                                                                businessnummessage,
                                                                                                style: const TextStyle(color: Colors.red),
                                                                                              ))
                                                                                            : Container(),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                                        //Address information
                                                                                        const Row(
                                                                                          children: [
                                                                                            Text(
                                                                                              "Address Information",
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A95A8), fontSize: 14),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        const SizedBox(
                                                                                          height: 5,
                                                                                        ),
                                                                                        //Street Address
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              street2error = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: street2,
                                                                                                          //  keyboardType: TextInputType.emailAddress,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: street2error
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                            // prefixIcon: Padding(
                                                                                                            //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                            //   child: FaIcon(
                                                                                                            //     FontAwesomeIcons.envelope,
                                                                                                            //     size: 18,
                                                                                                            //     color: Color(0xFF8A95A8),
                                                                                                            //   ),
                                                                                                            // ),
                                                                                                            hintText: "Enter street address",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        street2error
                                                                                            ? Center(
                                                                                                child: Text(
                                                                                                street2message,
                                                                                                style: const TextStyle(color: Colors.red),
                                                                                              ))
                                                                                            : Container(),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                                                        //city and state
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              city2error = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: city2,
                                                                                                          //  keyboardType: TextInputType.emailAddress,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: city2error
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                            // prefixIcon: Padding(
                                                                                                            //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                            //   child: FaIcon(
                                                                                                            //     FontAwesomeIcons.envelope,
                                                                                                            //     size: 18,
                                                                                                            //     color: Color(0xFF8A95A8),
                                                                                                            //   ),
                                                                                                            // ),
                                                                                                            hintText: "Enter city here",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: MediaQuery.of(context).size.width * .03,
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              state2error = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: state2,
                                                                                                          // keyboardType: TextInputType.emailAddress,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: state2error
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                            // prefixIcon: Padding(
                                                                                                            //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                            //   child: FaIcon(
                                                                                                            //     FontAwesomeIcons.envelope,
                                                                                                            //     size: 18,
                                                                                                            //     color: Color(0xFF8A95A8),
                                                                                                            //   ),
                                                                                                            // ),
                                                                                                            hintText: "Enter state",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                                                        Row(
                                                                                          children: [
                                                                                            city2error
                                                                                                ? Center(
                                                                                                    child: Text(
                                                                                                    city2message,
                                                                                                    style: const TextStyle(color: Colors.red),
                                                                                                  ))
                                                                                                : Container(),
                                                                                            const SizedBox(
                                                                                              width: 70,
                                                                                            ),
                                                                                            state2error
                                                                                                ? Center(
                                                                                                    child: Text(
                                                                                                    state2message,
                                                                                                    style: const TextStyle(color: Colors.red),
                                                                                                  ))
                                                                                                : Container(),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                                                        // counrty and postal code
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              county2error = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: county2,
                                                                                                          // keyboardType: TextInputType.emailAddress,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: county2error
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                            hintText: "Enter country",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: MediaQuery.of(context).size.width * .03,
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Material(
                                                                                                elevation: 3,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                child: Container(
                                                                                                  height: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Colors.white,
                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                  ),
                                                                                                  child: Stack(
                                                                                                    children: [
                                                                                                      Positioned.fill(
                                                                                                        child: TextField(
                                                                                                          onChanged: (value) {
                                                                                                            setState(() {
                                                                                                              code2error = false;
                                                                                                            });
                                                                                                          },
                                                                                                          controller: code2,
                                                                                                          //  keyboardType: TextInputType.emailAddress,
                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                          decoration: InputDecoration(
                                                                                                            border: InputBorder.none,
                                                                                                            enabledBorder: code2error
                                                                                                                ? OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    borderSide: const BorderSide(color: Colors.red), // Set border color here
                                                                                                                  )
                                                                                                                : InputBorder.none,
                                                                                                            contentPadding: const EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                            // prefixIcon: Padding(
                                                                                                            //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                            //   child: FaIcon(
                                                                                                            //     FontAwesomeIcons.envelope,
                                                                                                            //     size: 18,
                                                                                                            //     color: Color(0xFF8A95A8),
                                                                                                            //   ),
                                                                                                            // ),
                                                                                                            hintText: "Enter postal code",
                                                                                                            hintStyle: const TextStyle(
                                                                                                              color: Color(0xFF8A95A8),
                                                                                                              fontSize: 13,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                                                        Row(
                                                                                          children: [
                                                                                            county2error
                                                                                                ? Center(
                                                                                                    child: Text(
                                                                                                    county2message,
                                                                                                    style: const TextStyle(color: Colors.red),
                                                                                                  ))
                                                                                                : Container(),
                                                                                            const SizedBox(
                                                                                              width: 70,
                                                                                            ),
                                                                                            code2error
                                                                                                ? Center(
                                                                                                    child: Text(
                                                                                                    code2message,
                                                                                                    style: const TextStyle(color: Colors.red),
                                                                                                  ))
                                                                                                : Container(),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                                                                                        if (selectedOwner != null)
                                                                                          Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              if (selectedOwner!.processorList.isNotEmpty) ...[
                                                                                                const Row(
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      "Merchant Id",
                                                                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A95A8), fontSize: 14),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                const SizedBox(height: 5),
                                                                                                Column(
                                                                                                  children: [
                                                                                                    Column(
                                                                                                        children: _processorGroups.map((group) {
                                                                                                      return Padding(
                                                                                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                                                                        child: Row(
                                                                                                          children: [
                                                                                                            SizedBox(
                                                                                                              width: 20.0,
                                                                                                              height: 20.0,
                                                                                                              child: Checkbox(
                                                                                                                value: group?.isChecked,
                                                                                                                onChanged: (value) {
                                                                                                                  setState(() {
                                                                                                                    group?.isChecked = value ?? false;
                                                                                                                  });
                                                                                                                },
                                                                                                                activeColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                              ),
                                                                                                            ),
                                                                                                            SizedBox(width: MediaQuery.of(context).size.width * .02),
                                                                                                            Expanded(
                                                                                                              child: Material(
                                                                                                                elevation: 3,
                                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                                child: Container(
                                                                                                                  height: 50,
                                                                                                                  decoration: BoxDecoration(
                                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                                    color: Colors.white,
                                                                                                                    border: Border.all(color: const Color(0xFF8A95A8)),
                                                                                                                  ),
                                                                                                                  child: Stack(
                                                                                                                    children: [
                                                                                                                      Positioned.fill(
                                                                                                                        child: TextField(
                                                                                                                          controller: group.controller,
                                                                                                                          cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                                          decoration: const InputDecoration(
                                                                                                                            border: InputBorder.none,
                                                                                                                            contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                                            hintText: "Enter processor",
                                                                                                                            hintStyle: TextStyle(
                                                                                                                              color: Color(0xFF8A95A8),
                                                                                                                              fontSize: 13,
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                            SizedBox(width: MediaQuery.of(context).size.width * .02),
                                                                                                            InkWell(
                                                                                                              onTap: () {
                                                                                                                setState(() {
                                                                                                                  _processorGroups.remove(group);
                                                                                                                });
                                                                                                              },
                                                                                                              child: Container(
                                                                                                                padding: EdgeInsets.zero,
                                                                                                                child: const FaIcon(
                                                                                                                  FontAwesomeIcons.trashCan,
                                                                                                                  size: 20,
                                                                                                                  color: Color.fromRGBO(21, 43, 81, 1),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ],
                                                                                                        ),
                                                                                                      );
                                                                                                    }).toList())
                                                                                                  ],
                                                                                                ),
                                                                                                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                                                                const Row(
                                                                                                  children: [
                                                                                                    // Handle error display here if needed
                                                                                                  ],
                                                                                                ),
                                                                                              ],
                                                                                            ],
                                                                                          ),

                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            GestureDetector(
                                                                                              onTap: () {
                                                                                                setState(() {
                                                                                                  _processorGroups.add(ProcessorGroup(isChecked: false, controller: TextEditingController()));
                                                                                                });
                                                                                              },
                                                                                              child: ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                child: Container(
                                                                                                  height: 30.0,
                                                                                                  width: MediaQuery.of(context).size.width * .3,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                                    color: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                    boxShadow: const [
                                                                                                      BoxShadow(
                                                                                                        color: Colors.grey,
                                                                                                        offset: Offset(0.0, 1.0), //(x,y)
                                                                                                        blurRadius: 6.0,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  child: Center(
                                                                                                    child: isLoading
                                                                                                        ? const SpinKitFadingCircle(
                                                                                                            color: Colors.white,
                                                                                                            size: 25.0,
                                                                                                          )
                                                                                                        : const Text(
                                                                                                            "Add another",
                                                                                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                                                                                          ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            GestureDetector(
                                                                                              onTap: () async {
                                                                                                if (!isChecked2) {
                                                                                                  print(!isChecked2);
                                                                                                  var response = await Rental_PropertiesRepository().checkIfRentalOwnerExists(
                                                                                                    rentalOwner_firstName: firstname.text,
                                                                                                    rentalOwner_lastName: lastname.text,
                                                                                                    rentalOwner_companyName: comname.text,
                                                                                                    rentalOwner_primaryEmail: primaryemail.text,
                                                                                                    rentalOwner_alternativeEmail: alternativeemail.text,
                                                                                                    rentalOwner_phoneNumber: phonenum.text,
                                                                                                    rentalOwner_homeNumber: homenum.text,
                                                                                                    rentalOwner_businessNumber: businessnum.text,
                                                                                                    // rentalowner_id: rentalOwnerId != null ? rentalOwnerId!.rentalOwnerId : "", // Providing a default value if rentalOwnerId is null
                                                                                                  );
                                                                                                  if (response == true) {
                                                                                                    print("check true");

                                                                                                    Ownersdetails = RentalOwner(
                                                                                                      // rentalOwnerFirstName: firstname.text,
                                                                                                      rentalOwnerLastName: lastname.text,
                                                                                                      rentalOwnerPhoneNumber: phonenum.text,
                                                                                                      rentalOwnerFirstName: firstname.text,
                                                                                                    );
                                                                                                    context.read<OwnerDetailsProvider>().setOwnerDetails(Ownersdetails!);
                                                                                                    //  Provider.of<OwnerDetailsProvider>(context,listen: false).setOwnerDetails(Ownersdetails!);

                                                                                                    Fluttertoast.showToast(
                                                                                                      msg: "Rental Owner Added Successfully!",
                                                                                                      toastLength: Toast.LENGTH_SHORT,
                                                                                                      gravity: ToastGravity.TOP,
                                                                                                      timeInSecForIosWeb: 1,
                                                                                                      backgroundColor: Colors.green,
                                                                                                      textColor: Colors.white,
                                                                                                      fontSize: 16.0,
                                                                                                    );
                                                                                                    setState(() {
                                                                                                      hasError = false; // Set error state if the response is not true
                                                                                                    });
                                                                                                    Navigator.pop(context);
                                                                                                    // SetshowRentalOwnerTable();
                                                                                                  }
                                                                                                } else {
                                                                                                  Fluttertoast.showToast(
                                                                                                    msg: "Rental Owner Successfully!",
                                                                                                    toastLength: Toast.LENGTH_SHORT,
                                                                                                    gravity: ToastGravity.TOP,
                                                                                                    timeInSecForIosWeb: 1,
                                                                                                    backgroundColor: Colors.red,
                                                                                                    textColor: Colors.white,
                                                                                                    fontSize: 16.0,
                                                                                                  );
                                                                                                }
                                                                                              },
                                                                                              child: ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                child: Container(
                                                                                                  height: 30.0,
                                                                                                  width: 50,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                                    color: const Color.fromRGBO(21, 43, 81, 1),
                                                                                                    boxShadow: const [
                                                                                                      BoxShadow(
                                                                                                        color: Colors.grey,
                                                                                                        offset: Offset(0.0, 1.0), // (x,y)
                                                                                                        blurRadius: 6.0,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  child: Center(
                                                                                                    child: isLoading
                                                                                                        ? const SpinKitFadingCircle(
                                                                                                            color: Colors.white,
                                                                                                            size: 25.0,
                                                                                                          )
                                                                                                        : const Text(
                                                                                                            "Add",
                                                                                                            style: TextStyle(
                                                                                                              color: Colors.white,
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontSize: 10,
                                                                                                            ),
                                                                                                          ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                                                                                            GestureDetector(
                                                                                              onTap: () {
                                                                                                Navigator.pop(context);
                                                                                              },
                                                                                              child: ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                                child: Container(
                                                                                                  height: 30.0,
                                                                                                  width: 50,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                                    color: Colors.white,
                                                                                                    boxShadow: const [
                                                                                                      BoxShadow(
                                                                                                        color: Colors.grey,
                                                                                                        offset: Offset(0.0, 1.0), //(x,y)
                                                                                                        blurRadius: 6.0,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  child: Center(
                                                                                                    child: isLoading
                                                                                                        ? const SpinKitFadingCircle(
                                                                                                            color: Colors.white,
                                                                                                            size: 25.0,
                                                                                                          )
                                                                                                        : const Text(
                                                                                                            "Cancel",
                                                                                                            style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold, fontSize: 10),
                                                                                                          ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              child:
                                                                  const FaIcon(
                                                                FontAwesomeIcons
                                                                    .edit,
                                                                size: 13,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          InkWell(
                                                            onTap: () {
                                                              // Ownersdetails!.rentalOwnerFirstName;
                                                              //  OwnersdetailsGroups.removeAt(index);
                                                              //   Ownersdetails = RentalOwner(
                                                              //     // rentalOwnerFirstName: firstname.text,
                                                              //     rentalOwnerLastName: lastname.text,
                                                              //     rentalOwnerPhoneNumber: phonenum.text,
                                                              //     rentalOwnerFirstName: firstname.text,
                                                              //   );

                                                              print("hello");
                                                              setState(() {
                                                                RentalOwner?
                                                                    owner;
                                                                Ownersdetails =
                                                                    owner;
                                                              });
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              child:
                                                                  const FaIcon(
                                                                FontAwesomeIcons
                                                                    .trashCan,
                                                                size: 15,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text('');
                              },
                            ),
                          ],
                        )),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessorGroup(int index) {
    ProcessorGroup group = _processorGroups[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: Checkbox(
              value: group.isChecked,
              onChanged: (value) {
                setState(() {
                  group.isChecked = value ?? false;
                });
              },
              activeColor: const Color.fromRGBO(21, 43, 81, 1),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * .02),
          Expanded(
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(5),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF8A95A8)),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: TextField(
                        controller: group.controller,
                        cursorColor: const Color.fromRGBO(21, 43, 81, 1),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              top: 12.5, bottom: 12.5, left: 15),
                          hintText: "Enter processor",
                          hintStyle: TextStyle(
                            color: Color(0xFF8A95A8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * .02),
          InkWell(
            onTap: () {
              _removeGroup(index);
            },
            child: Container(
              padding: EdgeInsets.zero,
              child: const FaIcon(
                FontAwesomeIcons.trashCan,
                size: 20,
                color: Color.fromRGBO(21, 43, 81, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SetshowRentalOwnerTable() {
    const Row(
      children: [
        Text("Hello"),
      ],
    );
  }

  void _addNewGroup() {
    setState(() {
      _processorGroups.add(ProcessorGroup(
          isChecked: false, controller: TextEditingController()));
    });
  }

  void _removeGroup(int index) {
    setState(() {
      _processorGroups.removeAt(index);
    });
  }

  List<Widget> generateOwnerWidgets(
      List<Owner> filteredOwners, BuildContext context) {
    return List<Widget>.generate(filteredOwners.length, (index) {
      Owner owner = filteredOwners[index];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (owner.processorList.isNotEmpty) ...[
            const Row(
              children: [
                Text(
                  "Merchant Id",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8A95A8),
                      fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Column(
              children: [
                Container(
                  height: 150,
                  child: ListView.builder(
                    itemCount: _processorGroups.length,
                    itemBuilder: (context, index) {
                      ProcessorGroup group = _processorGroups[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: Checkbox(
                                value: group.isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    group.isChecked = value ?? false;
                                  });
                                },
                                activeColor:
                                    const Color.fromRGBO(21, 43, 81, 1),
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * .02),
                            Expanded(
                              child: Material(
                                elevation: 3,
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    border: Border.all(
                                        color: const Color(0xFF8A95A8)),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: TextField(
                                          controller: group.controller,
                                          cursorColor: const Color.fromRGBO(
                                              21, 43, 81, 1),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                                top: 12.5,
                                                bottom: 12.5,
                                                left: 15),
                                            hintText: "Enter processor",
                                            hintStyle: TextStyle(
                                              color: Color(0xFF8A95A8),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * .02),
                            InkWell(
                              onTap: () {
                                _removeGroup(index);
                              },
                              child: Container(
                                padding: EdgeInsets.zero,
                                child: const FaIcon(
                                  FontAwesomeIcons.trashCan,
                                  size: 20,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addNewGroup,
                  child: const Text("Add Processor Group"),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            const Row(
              children: [
                // Handle error display here if needed
              ],
            ),
          ],
        ],
      );
    });
  }

  Future<Map<String, dynamic>> addRentals({
    required String? adminId,
    required String? rentalowner_id,
    required String? processor_list,
    required String? rentalOwner_firstName,
    required String? rentalOwner_lastName,
    required String? rentalOwner_companyName,
    required String? rentalOwner_primaryEmail,
    required String? rentalOwner_phoneNumber,
    required String? rentalOwner_businessNumber,
  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'rentalowner_id': rentalowner_id,
      'processor_list': processor_list,
      'rentalOwner_firstName': rentalOwner_firstName,
      'rentalOwner_lastName': rentalOwner_lastName,
      ' rentalOwner_companyName': rentalOwner_companyName,
      '  rentalOwner_primaryEmail': rentalOwner_primaryEmail,
      ' rentalOwner_phoneNumber': rentalOwner_phoneNumber,
      ' rentalOwner_businessNumber': rentalOwner_businessNumber,
    };

    final http.Response response = await http.post(
      Uri.parse('${Api_url}/api/rentals/rentals'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rental_id = prefs.getString("adminId");
    var responseData = json.decode(response.body);

    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add property type');
    }
  }

  void handleAddrentalOwner() {
    print(rentalOwnerId);
    if (rentalOwnerId != null) {
      print(rentalOwnerId);
      Fluttertoast.showToast(
          msg: "Rental Owner Added Successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    // setDisplay(false);
  }
}

class Owner {
  final String id;
  final String rentalOwnerId;
  final String adminId;
  final String firstName;
  final String lastName;
  final String companyName;
  final String primaryEmail;
  final String alternateEmail;
  final String phoneNumber;
  final String? homeNumber;
  final String? businessNumber;
  final String birthDate;
  final String startDate;
  final String endDate;
  final String taxpayerId;
  final String identityType;
  final String streetAddress;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String createdAt;
  final String updatedAt;
  final bool isDelete;
  final List<Processor> processorList;

  Owner({
    required this.id,
    required this.rentalOwnerId,
    required this.adminId,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.primaryEmail,
    required this.alternateEmail,
    required this.phoneNumber,
    required this.homeNumber,
    required this.businessNumber,
    required this.birthDate,
    required this.startDate,
    required this.endDate,
    required this.taxpayerId,
    required this.identityType,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.createdAt,
    required this.updatedAt,
    required this.isDelete,
    required this.processorList,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    var list = json['processor_list'] as List;
    List<Processor> processorList =
        list.map((i) => Processor.fromJson(i)).toList();

    return Owner(
      id: json['_id'],
      rentalOwnerId: json['rentalowner_id'] ?? "",
      adminId: json['admin_id'] ?? "",
      firstName: json['rentalOwner_firstName'] ?? "",
      lastName: json['rentalOwner_lastName'] ?? "",
      companyName: json['rentalOwner_companyName'] ?? "",
      primaryEmail: json['rentalOwner_primaryEmail'] ?? "",
      alternateEmail: json['rentalOwner_alternateEmail'] ?? "",
      phoneNumber: json['rentalOwner_phoneNumber'] ?? "",
      homeNumber: json['rentalOwner_homeNumber'] ?? "", // Nullable field
      businessNumber:
          json['rentalOwner_businessNumber'] ?? "", // Nullable field
      birthDate: json['birth_date'] ?? "",
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      taxpayerId: json['texpayer_id'] ?? "",
      identityType: json['text_identityType'] ?? "",
      streetAddress: json['street_address'] ?? "",
      city: json['city'] ?? "",
      state: json['state'] ?? "",
      country: json['country'] ?? "",
      postalCode: json['postal_code'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      isDelete: json['is_delete'],
      processorList: processorList,
    );
  }
}

// class Processor {
//   final String processorId;
//   final String id;
//
//   Processor({required this.processorId, required this.id});
//
//   factory Processor.fromJson(Map<String, dynamic> json) {
//     return Processor(
//       processorId: json['processor_id'],
//       id: json['_id'],
//     );
//   }
// }
class Processor {
  final String processorId;
  final String id;

  Processor({required this.processorId, required this.id});

  factory Processor.fromJson(Map<String, dynamic> json) {
    return Processor(
      processorId: json['processor_id'],
      id: json['_id'],
    );
  }
}

class ProcessorGroup {
  bool isChecked;
  TextEditingController controller;

  ProcessorGroup({required this.isChecked, required this.controller});
}

class OwnersDetails {
  RentalOwner? Ownersdetails;
  OwnersDetails({
    required this.Ownersdetails,
  });
}

class RentalOwnerSource extends DataTableSource {
  final List<RentalOwner> rentalowner;
  final Function(RentalOwner) onEdit;
  final Function(RentalOwner) onDelete;

  RentalOwnerSource(this.rentalowner,
      {required this.onEdit, required this.onDelete});

  @override
  DataRow getRow(int index) {
    final rental = rentalowner[index];
    return DataRow(cells: [
      DataCell(Text(rental.rentalOwnerFirstName!)),
      DataCell(Text(rental.rentalOwnerLastName!)),
      DataCell(Text(rental.rentalOwnerPhoneNumber!)),
      DataCell(Row(
        children: [
          InkWell(
            onTap: () {
              onEdit(rental);
            },
            child: Container(
              //  color: Colors.redAccent,
              padding: EdgeInsets.zero,
              child: const FaIcon(
                FontAwesomeIcons.edit,
                size: 20,
              ),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          InkWell(
            onTap: () {
              onDelete(rental);
            },
            child: Container(
              //    color: Colors.redAccent,
              padding: EdgeInsets.zero,
              child: const FaIcon(
                FontAwesomeIcons.trashCan,
                size: 20,
              ),
            ),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rentalowner.length;

  @override
  int get selectedRowCount => 0;
}
