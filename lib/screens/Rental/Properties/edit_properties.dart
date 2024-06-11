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
import 'package:three_zero_two_property/repository/properties.dart';
import 'package:three_zero_two_property/repository/rental_properties.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../Model/propertytype.dart';
import '../../../constant/constant.dart';
import '../../../model/add_property.dart';
import '../../../model/properties.dart';
import '../../../model/rental_properties.dart';
import '../../../provider/add_property.dart';
import '../../../repository/Property_type.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../widgets/rental_widget.dart';
import 'package:http/http.dart' as http;

import '../../Staff_Member/Edit_staff_member.dart';

class Edit_properties extends StatefulWidget {
  propertytype? property;
  Staffmembers? staff;
  Rentals properties;
  Rentals? rental;

  Edit_properties({super.key, this.property, this.staff,required this.properties , this.rental});

  @override
  State<Edit_properties> createState() => _Edit_propertiesState();
}

class _Edit_propertiesState extends State<Edit_properties> {

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
  Future<List<RentalOwner>>? futureRentalOwner;

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
  Map<String, List<Staffmembers>> groupstaffmemberByType(
      List<Staffmembers> member) {
    Map<String, List<Staffmembers>> groupedmember = {};
    for (var staff in member) {
      if (!groupedmember.containsKey(staff.staffmemberName)) {
        groupedmember[staff.staffmemberName!] = [];
      }
      groupedmember[staff.staffmemberName!]!.add(staff);
    }
    return groupedmember;
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
    final response = await http.get(Uri.parse('${Api_url}/api/rentals/rental-owners/$id'));

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
    // selectedValue = widget.properties?.propertyTypeData?.propertyType!;
    // selectedValue = widget.properties?.propertyTypeData?.propertySubType!;
    selectedpropertytype = widget.properties.propertyTypeData?.propertyType!;
    selectedpropertytype = widget.properties.propertyTypeData?.propertySubType!;
    address.text = widget.properties.rentalAddress!;
    city.text = widget.properties.rentalCity!;
    state.text = widget.properties.rentalState!;
    postalcode.text = widget.properties.rentalPostcode!;
    country.text = widget.properties.rentalCountry!;
    selectedProperty = widget.properties.propertyTypeData!.propertySubType;
    Ownersdetails = RentalOwner(
      // rentalOwnerFirstName: firstname.text,
      rentalOwnerLastName: widget.properties.rentalOwnerData!
          .rentalOwnerLastName,
      rentalOwnerPhoneNumber: widget.properties.rentalOwnerData!
          .rentalOwnerPhoneNumber,
      rentalOwnerFirstName: widget.properties.rentalOwnerData!
          .rentalOwnerFirstName,
    );
    firstname.text = widget.properties.rentalOwnerData!.rentalOwnerFirstName!;
    lastname.text = widget.properties.rentalOwnerData!.rentalOwnerLastName!;
    comname.text = widget.properties.rentalOwnerData!.rentalOwnerCompanyName!;
    primaryemail.text =
    widget.properties.rentalOwnerData!.rentalOwnerPrimaryEmail!;
    alternativeemail.text =
    widget.properties.rentalOwnerData!.rentalOwnerAlternativeEmail!;
    print(alternativeemail);
    phonenum.text = widget.properties.rentalOwnerData!.rentalOwnerPhoneNumber!;
    print(phonenum);
    homenum.text = widget.properties.rentalOwnerData!.rentalOwnerHomeNumber!;
    print(homenum);
    businessnum.text =
    widget.properties.rentalOwnerData!.rentalOwnerBuisinessNumber!;
    print(widget.properties.rentalOwnerData!.rentalOwnerBuisinessNumber);
    street2.text = widget.properties.rentalOwnerData!.Address!;
    city2.text = widget.properties.rentalOwnerData!.city!;
    state2.text = widget.properties.rentalOwnerData!.state!;
    county2.text = widget.properties.rentalOwnerData!.country!;
    code2.text = widget.properties.rentalOwnerData!.postalCode!;
     selectedStaffmember = widget.properties.staffMemberData!.staffmemberName!;

   //print( widget.properties.staffMemberData!.staffmemberName!);
   print(selectedStaff);
   // selectedStaff = widget.properties.staffMemberData!.staffmemberName;
    // proid.text = widget.properties!.rentalOwnerData!.processorList!.map((
    //     processor) => processor.processorId).join(', ');
    // for (Processor processor in selectedOwner!.processorList) {
    //   _processorGroups.add(ProcessorGroup(isChecked: false, controller: TextEditingController(text: processor.processorId)));
    // }
    //  futureStaffMembers = widget.properties.staffMemberData!.staffmemberName! as Future<List<Staffmembers>>;

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
  // void removerental(){
  //   setState(() {
  //     OwnersdetailsGroups.removeAt();
  //   });
  // }
  //  void addPropertyGroup() {
  //    print("hello");
  //    List<Widget> fields = [];
  //    List<Widget> photos = [];
  //    List<TextEditingController> controllers = [];
  //    List<File?> propertyGroupImages = [];
  //    print(selectedpropertytype);
  //   if(selectedpropertytype == 'Commercial' && selectedIsMultiUnit == true){
  //     var unitController = TextEditingController();
  //     var unitAddressController = TextEditingController();
  //     var sqftController = TextEditingController();
  //
  //     fields = [
  //
  //        customTextField('Unit',unitController),
  //        customTextField('Unit Address',unitAddressController),
  //        customTextField('SQft',sqftController),
  //
  //        SizedBox(height: 20,),
  //        photo(),
  //      ];
  //     controllers = [unitController, unitAddressController, sqftController];
  //
  //    }else if(selectedpropertytype == 'Residential' && selectedIsMultiUnit == true){
  //
  //     var unitController = TextEditingController();
  //     var unitAddressController = TextEditingController();
  //     var sqftController = TextEditingController();
  //     var bathController = TextEditingController();
  //     var bedController = TextEditingController();
  //
  //     fields = [
  //       customTextField('Unit', unitController),
  //       customTextField('Unit Address', unitAddressController),
  //       customTextField('SQft', sqftController),
  //       customTextField('Bath', bathController),
  //       customTextField('Bed', bedController),
  //
  //       SizedBox(height: 20,),
  //       photo(),
  //     ];
  //
  //     controllers = [unitController, unitAddressController, sqftController, bathController, bedController];
  //
  //
  //   } else if (selectedpropertytype == 'Residential') {
  //     var sqftController = TextEditingController();
  //     var bathController = TextEditingController();
  //     var bedController = TextEditingController();
  //
  //     fields = [
  //       customTextField('SQft', sqftController),
  //       customTextField('Bath', bathController),
  //       customTextField('Bed', bedController),
  //
  //       SizedBox(height: 20,),
  //       photo(),
  //     ];
  //
  //     controllers = [sqftController, bathController, bedController];
  //
  //
  //   } else if (selectedpropertytype == 'Commercial') {
  //     var sqftController = TextEditingController();
  //
  //     fields = [
  //       customTextField('SQft', sqftController),
  //
  //       SizedBox(height: 20,),
  //       photo(),
  //     ];
  //
  //     controllers = [sqftController];
  //
  //    }
  //    setState(() {
  //      propertyGroups.add(fields);
  //      propertyGroupControllers.add(controllers);
  //    });
  //  }

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
      //}
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
      request.files.add(
          await http.MultipartFile.fromPath('files', imageFile!.path));
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
            borderSide: BorderSide(color: Color(0xFF8A95A8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(color: Color(0xFF8A95A8), width: 2),
          ),
          contentPadding:
          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }

  Widget photo(int index) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            Row(
              children: [
                Text(
                  'Photo',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    getImage(index).then((_) {
                      setState(
                              () {}); // Rebuild the widget after selecting the image
                    });
                  },
                  child: Text(
                    '+ Add',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (propertyGroupImages[index] != null)
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            propertyGroupImages[index] =
                            null; // Clear the selected image
                          });
                        },
                        child: Icon(
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

        SizedBox(
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

        SizedBox(
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

        SizedBox(
          height: 10,
        ),
        photo(propertyGroups.length), // Pass the index
      ];

      controllers = [sqftController, bathController, bedController];
    } else if (selectedpropertytype == 'Commercial') {
      var sqftController = TextEditingController();

      fields = [
        customTextField('SQft', sqftController),

        SizedBox(
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
      List<TextEditingController> firstControllers = propertyGroupControllers[0];
      bool isFirstBlank = firstControllers.every((controller) => controller.text.isEmpty);

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
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  FaIcon(
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
                    padding: EdgeInsets.only(top: 8, left: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color.fromRGBO(21, 43, 81, 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Text(
                      "Edit Property",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                //dropdown
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "New Property ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontSize: 15),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Property Information",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "What is the property type?",
                                style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              FutureBuilder<List<propertytype>>(
                                future: futureProperties,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Text('No properties found');
                                  } else {
                                    Map<String, List<propertytype>>
                                    groupedProperties =
                                    groupPropertiesByType(snapshot.data!);
                                    return Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        height:
                                        MediaQuery.of(context).size.height *
                                            .05,
                                        width:
                                        MediaQuery.of(context).size.width *
                                            .5,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFF8A95A8),
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(5),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedProperty,
                                            hint: Text(
                                              'Add Property Type',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    .027,
                                                color: Color(0xFF8A95A8),
                                              ),
                                            ),
                                            onChanged: (String? newValue) {
                                              if (newValue ==
                                                  'Edit_properties') {
                                                // Prevent the dropdown from changing the selected item
                                                setState(() {
                                                  selectedProperty = null;
                                                });
                                                // Show the dialog
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    bool isChecked =
                                                    false; // Moved isChecked inside the StatefulBuilder
                                                    return StatefulBuilder(
                                                      builder:
                                                          (BuildContext context,
                                                          StateSetter
                                                          setState) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                          Colors.white,
                                                          surfaceTintColor:
                                                          Colors.white,
                                                          // title: Text(
                                                          //   "Add Rental Owner",
                                                          //   style: TextStyle(
                                                          //       fontWeight:
                                                          //           FontWeight
                                                          //               .bold,
                                                          //       color: Color
                                                          //           .fromRGBO(
                                                          //               21,
                                                          //               43,
                                                          //               81,
                                                          //               1),
                                                          //       fontSize: 15),
                                                          // ),
                                                          content:
                                                          SingleChildScrollView(
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                      "Add Property Type",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                          fontSize:
                                                                          18),
                                                                    ),
                                                                    Spacer(),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                      Container(
                                                                        //    color: Colors.redAccent,
                                                                        padding:
                                                                        EdgeInsets.zero,
                                                                        child:
                                                                        FaIcon(
                                                                          FontAwesomeIcons
                                                                              .xmark,
                                                                          size:
                                                                          15,
                                                                          color:
                                                                          Color(0xFF8A95A8),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Text(
                                                                      "Property Type*",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                          14),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    DropdownButtonHideUnderline(
                                                                      child: DropdownButton2<
                                                                          String>(
                                                                        isExpanded:
                                                                        true,
                                                                        hint:
                                                                        const Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 4,
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                'Type',
                                                                                style: TextStyle(
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Colors.black,
                                                                                ),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        items: items
                                                                            .map((String item) => DropdownMenuItem<String>(
                                                                          value: item,
                                                                          child: Text(
                                                                            item,
                                                                            style: const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ))
                                                                            .toList(),
                                                                        value:
                                                                        selectedValue,
                                                                        onChanged:
                                                                            (value) {
                                                                          setState(
                                                                                  () {
                                                                                selectedValue =
                                                                                    value;
                                                                              });
                                                                        },
                                                                        buttonStyleData:
                                                                        ButtonStyleData(
                                                                          height:
                                                                          50,
                                                                          width:
                                                                          160,
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 14,
                                                                              right: 14),
                                                                          decoration:
                                                                          BoxDecoration(
                                                                            borderRadius:
                                                                            BorderRadius.circular(10),
                                                                            border:
                                                                            Border.all(
                                                                              color: Colors.black26,
                                                                            ),
                                                                            color:
                                                                            Colors.white,
                                                                          ),
                                                                          elevation:
                                                                          3,
                                                                        ),
                                                                        dropdownStyleData:
                                                                        DropdownStyleData(
                                                                          maxHeight:
                                                                          200,
                                                                          width:
                                                                          200,
                                                                          decoration:
                                                                          BoxDecoration(
                                                                            borderRadius:
                                                                            BorderRadius.circular(14),
                                                                            //color: Colors.redAccent,
                                                                          ),
                                                                          offset: const Offset(
                                                                              -20,
                                                                              0),
                                                                          scrollbarTheme:
                                                                          ScrollbarThemeData(
                                                                            radius:
                                                                            const Radius.circular(40),
                                                                            thickness:
                                                                            MaterialStateProperty.all(6),
                                                                            thumbVisibility:
                                                                            MaterialStateProperty.all(true),
                                                                          ),
                                                                        ),
                                                                        menuItemStyleData:
                                                                        const MenuItemStyleData(
                                                                          height:
                                                                          40,
                                                                          padding: EdgeInsets.only(
                                                                              left: 14,
                                                                              right: 14),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Text(
                                                                      "Property SubType*",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                          12),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Material(
                                                                      elevation:
                                                                      2,
                                                                      borderRadius:
                                                                      BorderRadius.circular(
                                                                          10),
                                                                      child:
                                                                      Container(
                                                                        width:
                                                                        150,
                                                                        padding:
                                                                        EdgeInsets.only(left: 10),
                                                                        decoration:
                                                                        BoxDecoration(
                                                                          color:
                                                                          Colors.white,
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                        ),
                                                                        child:
                                                                        TextFormField(
                                                                          controller:
                                                                          subtype,
                                                                          decoration: InputDecoration(
                                                                              border: InputBorder.none,
                                                                              hintText: "Townhome"),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.05),
                                                                    Container(
                                                                      height: MediaQuery.of(context)
                                                                          .size
                                                                          .height *
                                                                          0.02,
                                                                      width: MediaQuery.of(context)
                                                                          .size
                                                                          .height *
                                                                          0.02,
                                                                      decoration:
                                                                      BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                        BorderRadius.circular(5),
                                                                      ),
                                                                      child:
                                                                      Checkbox(
                                                                        activeColor: isChecked
                                                                            ? Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1)
                                                                            : Colors.white,
                                                                        checkColor:
                                                                        Colors.white,
                                                                        value:
                                                                        isChecked, // assuming _isChecked is a boolean variable indicating whether the checkbox is checked or not
                                                                        onChanged:
                                                                            (value) {
                                                                          setState(
                                                                                  () {
                                                                                isChecked =
                                                                                    value ?? false; // ensure value is not null
                                                                              });
                                                                        },
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.02),
                                                                    Text(
                                                                      "Multi unit",
                                                                      style:
                                                                      TextStyle(
                                                                        fontSize:
                                                                        MediaQuery.of(context).size.width *
                                                                            0.03,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.05),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.05),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        if (selectedValue ==
                                                                            null ||
                                                                            subtype.text.isEmpty) {
                                                                          setState(
                                                                                  () {
                                                                                iserror =
                                                                                true;
                                                                              });
                                                                        } else {
                                                                          setState(
                                                                                  () {
                                                                                isLoading =
                                                                                true;
                                                                                iserror =
                                                                                false;
                                                                              });
                                                                          SharedPreferences
                                                                          prefs =
                                                                          await SharedPreferences.getInstance();

                                                                          String?
                                                                          id =
                                                                          prefs.getString("adminId");
                                                                          PropertyTypeRepository()
                                                                              .addPropertyType(
                                                                            adminId:
                                                                            id!,
                                                                            propertyType:
                                                                            selectedValue,
                                                                            propertySubType:
                                                                            subtype.text,
                                                                            isMultiUnit:
                                                                            isChecked,
                                                                          )
                                                                              .then((value) {
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                            Navigator.pop(context,
                                                                                true);
                                                                          }).catchError((e) {
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                          });
                                                                        }
                                                                        print(
                                                                            selectedValue);
                                                                      },
                                                                      child:
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                        BorderRadius.circular(5.0),
                                                                        child:
                                                                        Container(
                                                                          height:
                                                                          33.0,
                                                                          width:
                                                                          MediaQuery.of(context).size.width * .4,
                                                                          decoration:
                                                                          BoxDecoration(
                                                                            borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                            color: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: Colors.grey,
                                                                                offset: Offset(0.0, 1.0), //(x,y)
                                                                                blurRadius: 6.0,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child:
                                                                          Center(
                                                                            child: isLoading
                                                                                ? SpinKitFadingCircle(
                                                                              color: Colors.white,
                                                                              size: 25.0,
                                                                            )
                                                                                : Text(
                                                                              "Add Property Type",
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                if (iserror)
                                                                  Text(
                                                                    "Please fill in all fields correctly.",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .redAccent),
                                                                  )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              } else {
                                                setState(() {
                                                  //  print(snapshot.data!.where((element) => element.propertysubType == newValue ).first.isMultiunit);
                                                  //  selectedpropertytype = snapshot.data!.where((element)
                                                  //  => element.propertysubType == newValue ).first;
                                                  //  print(selectedProperty);
                                                  //  selectedProperty = newValue;
                                                  // // selectedPropertyType = newValue;
                                                  //  // selectedIsMultiUnit = snapshot.data!.where((element) => element.isMultiunit == newValue ).first;
                                                  //  propertyGroups = [];
                                                  //    addPropertyGroup();
                                                  //    print(addPropertyGroup);
                                                  print(snapshot.data!
                                                      .where((element) =>
                                                  element
                                                      .propertysubType ==
                                                      newValue)
                                                      .first
                                                      .isMultiunit);
                                                  // selectedIsMultiUnit = snapshot.data!.where((element) => element.isMultiunit == newValue ).first;
                                                  selectedpropertytypedata =
                                                      snapshot.data!
                                                          .where((element) =>
                                                      element
                                                          .propertysubType ==
                                                          newValue)
                                                          .first;
                                                  print(selectedProperty);
                                                  selectedProperty = newValue;
                                                  propertyGroups = [];
                                                  // Call the method here
                                                  selectedpropertytype =
                                                      selectedpropertytypedata!
                                                          .propertyType;
                                                  selectedIsMultiUnit =
                                                  selectedpropertytypedata!
                                                      .isMultiunit!;
                                                });
                                                propertyGroups.clear();
                                                addPropertyGroup();
                                                propertyTypeError = false;
                                              }
                                            },
                                            items: [
                                              ...groupedProperties.entries
                                                  .expand((entry) {
                                                return [
                                                  DropdownMenuItem<String>(
                                                    enabled: false,
                                                    child: Text(
                                                      entry.key,
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              21, 43, 81, 1)),
                                                    ),
                                                  ),
                                                  ...entry.value.map((item) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value:
                                                      item.propertysubType,
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(
                                                            left: 16.0),
                                                        child: Text(
                                                          item.propertysubType ??
                                                              '',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                            FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ];
                                              }).toList(),
                                              DropdownMenuItem<String>(
                                                value: 'Edit_properties',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.add,
                                                        size:
                                                        15), // Adjusted icon size
                                                    SizedBox(width: 6),
                                                    Text('Add New properties',
                                                        style: TextStyle(
                                                            fontSize:
                                                            16 //MediaQuery.of(context).size.width * .03
                                                        )), // Adjusted text size
                                                  ],
                                                ),
                                              ),
                                            ],
                                            isExpanded: true,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          propertyTypeError
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                propertyTypeErrorMessage,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: MediaQuery.of(context)
                                        .size
                                        .width *
                                        .03),
                              ),
                            ],
                          )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "What is the street  address?",
                                style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Address",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
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
                                      border:
                                      Border.all(color: Color(0xFF8A95A8)),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                addresserror = false;
                                              });
                                            },
                                            controller: address,
                                            //  keyboardType: TextInputType.emailAddress,
                                            cursorColor:
                                            Color.fromRGBO(21, 43, 81, 1),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              enabledBorder: addresserror
                                                  ? OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    5),
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .red), // Set border color here
                                              )
                                                  : InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  top: 12.5,
                                                  bottom: 12.5,
                                                  left: 15),
                                              // prefixIcon: Padding(
                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                              //   child: FaIcon(
                                              //     FontAwesomeIcons.envelope,
                                              //     size: 18,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              hintText: "Enter address",
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
                                width: 15,
                              ),
                            ],
                          ),
                          addresserror
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                addressmessage,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: MediaQuery.of(context)
                                        .size
                                        .width *
                                        .04),
                              ),
                            ],
                          )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .043,
                              ),
                              Text(
                                "City",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .29,
                              ),
                              Text(
                                "State",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 9,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
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
                                      border:
                                      Border.all(color: Color(0xFF8A95A8)),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                cityerror = false;
                                              });
                                            },
                                            controller: city,
                                            //  keyboardType: TextInputType.emailAddress,
                                            cursorColor:
                                            Color.fromRGBO(21, 43, 81, 1),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              enabledBorder: cityerror
                                                  ? OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    5),
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .red), // Set border color here
                                              )
                                                  : InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  top: 12.5,
                                                  bottom: 12.5,
                                                  left: 15),
                                              // prefixIcon: Padding(
                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                              //   child: FaIcon(
                                              //     FontAwesomeIcons.envelope,
                                              //     size: 18,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              hintText: "Enter city",
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
                                width: 5,
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
                                      border:
                                      Border.all(color: Color(0xFF8A95A8)),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                stateerror = false;
                                              });
                                            },
                                            controller: state,
                                            //  keyboardType: TextInputType.emailAddress,
                                            cursorColor:
                                            Color.fromRGBO(21, 43, 81, 1),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              enabledBorder: stateerror
                                                  ? OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    5),
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .red), // Set border color here
                                              )
                                                  : InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  top: 12.5,
                                                  bottom: 12.5,
                                                  left: 15),
                                              // prefixIcon: Padding(
                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                              //   child: FaIcon(
                                              //     FontAwesomeIcons.envelope,
                                              //     size: 18,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              hintText: "Enter state",
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
                                width: 15,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              cityerror
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    citymessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: MediaQuery.of(context)
                                            .size
                                            .width *
                                            .04),
                                  ),
                                ],
                              )
                                  : Container(),
                              SizedBox(
                                width: 64,
                              ),
                              stateerror
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    statemessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: MediaQuery.of(context)
                                            .size
                                            .width *
                                            .04),
                                  ),
                                ],
                              )
                                  : Container(),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .043,
                              ),
                              Text(
                                "Country",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .23,
                              ),
                              Text(
                                "Postal Code",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 9,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
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
                                      border:
                                      Border.all(color: Color(0xFF8A95A8)),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                countryerror = false;
                                              });
                                            },
                                            controller: country,
                                            //  keyboardType: TextInputType.emailAddress,
                                            cursorColor:
                                            Color.fromRGBO(21, 43, 81, 1),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              enabledBorder: countryerror
                                                  ? OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    5),
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .red), // Set border color here
                                              )
                                                  : InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  top: 12.5,
                                                  bottom: 12.5,
                                                  left: 15),
                                              // prefixIcon: Padding(
                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                              //   child: FaIcon(
                                              //     FontAwesomeIcons.envelope,
                                              //     size: 18,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              hintText: "Enter country",
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
                                width: 5,
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
                                      border:
                                      Border.all(color: Color(0xFF8A95A8)),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                postalcodeerror = false;
                                              });
                                            },
                                            controller: postalcode,
                                            //  keyboardType: TextInputType.emailAddress,
                                            cursorColor:
                                            Color.fromRGBO(21, 43, 81, 1),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              enabledBorder: postalcodeerror
                                                  ? OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    5),
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .red), // Set border color here
                                              )
                                                  : InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  top: 12.5,
                                                  bottom: 12.5,
                                                  left: 15),
                                              // prefixIcon: Padding(
                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                              //   child: FaIcon(
                                              //     FontAwesomeIcons.envelope,
                                              //     size: 18,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              hintText: "Enter postal code",
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
                                width: 15,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              countryerror
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    countrymessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: MediaQuery.of(context)
                                            .size
                                            .width *
                                            .04),
                                  ),
                                ],
                              )
                                  : Container(),
                              SizedBox(
                                width: 64,
                              ),
                              postalcodeerror
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    postalcodemessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: MediaQuery.of(context)
                                            .size
                                            .width *
                                            .04),
                                  ),
                                ],
                              )
                                  : Container(),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                //rental
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            Row(
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
                            SizedBox(
                              height: 10,
                            ),
                            Row(
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
                            SizedBox(
                              height: 10,
                            ),
                            Row(
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
                            SizedBox(
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
                                          title: Text(
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
                                                            ? Color.fromRGBO(
                                                            21, 43, 81, 1)
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Expanded(
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
                                                    SizedBox(
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
                                                                    Color(0xFF8A95A8)),
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
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
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
                                                    SizedBox(
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
                                                      child:
                                                      DataTable(
                                                        columnSpacing: 10,
                                                        headingRowHeight:
                                                        29,
                                                        dataRowHeight: 30,
                                                        // horizontalMargin: 10,
                                                        columns: [
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
                                                                      style: TextStyle(
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
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                          10),
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
                                                                              print(alternativeemail);
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
                                                                        activeColor: Color.fromRGBO(
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
                                                    SizedBox(
                                                        height: 16.0),
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () async {
                                                            if (!isChecked2) {
                                                              print(!isChecked2);
                                                              var response =  await Rental_PropertiesRepository().checkIfRentalOwnerExists(
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
                                                              if(response == true){
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
                                                              Ownersdetails = RentalOwner(
                                                                // rentalOwnerFirstName: firstname.text,
                                                                rentalOwnerLastName: lastname.text,
                                                                rentalOwnerPhoneNumber: phonenum.text,
                                                                rentalOwnerFirstName: firstname.text,
                                                              );
                                                              context.read<OwnerDetailsProvider>().setOwnerDetails(Ownersdetails!);
                                                              Navigator.of(context).pop();
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
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    81,
                                                                    1),
                                                                boxShadow: [
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
                                                                    ? SpinKitFadingCircle(
                                                                  color: Colors.white,
                                                                  size: 25.0,
                                                                )
                                                                    : Text(
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
                                                                    ? SpinKitFadingCircle(
                                                                  color: Colors.white,
                                                                  size: 25.0,
                                                                )
                                                                    : Text(
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
                                                    :
                                                Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 25,
                                                    ),
                                                    Row(
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
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    //firstname
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      firstname,
                                                                      //  keyboardType: TextInputType.emailAddress,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                        // prefixIcon: Padding(
                                                                        //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                        //   child: FaIcon(
                                                                        //     FontAwesomeIcons.envelope,
                                                                        //     size: 18,
                                                                        //     color: Color(0xFF8A95A8),
                                                                        //   ),
                                                                        // ),
                                                                        hintText: "Enter first name",
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
                                                    firstnameerror
                                                        ? Center(
                                                        child: Text(
                                                          firstnamemessage,
                                                          style: TextStyle(
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          lastnameerror = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      lastname,
                                                                      //  keyboardType: TextInputType.emailAddress,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: lastnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                        // prefixIcon: Padding(
                                                                        //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                        //   child: FaIcon(
                                                                        //     FontAwesomeIcons.envelope,
                                                                        //     size: 18,
                                                                        //     color: Color(0xFF8A95A8),
                                                                        //   ),
                                                                        // ),
                                                                        hintText: "Enter last name ",
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
                                                    lastnameerror
                                                        ? Center(
                                                        child: Text(
                                                          lastnamemessage,
                                                          style: TextStyle(
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
                                                    Row(
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
                                                    SizedBox(
                                                      height: 5,
                                                    ),
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          comnameerror = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      comname,
                                                                      //keyboardType: TextInputType.emailAddress,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: comnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                        // prefixIcon: Padding(
                                                                        //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                        //   child: FaIcon(
                                                                        //     FontAwesomeIcons.envelope,
                                                                        //     size: 18,
                                                                        //     color: Color(0xFF8A95A8),
                                                                        //   ),
                                                                        // ),
                                                                        hintText: "Enter company name",
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
                                                    comnameerror
                                                        ? Center(
                                                        child: Text(
                                                          comnamemessage,
                                                          style: TextStyle(
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
                                                    Row(
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
                                                    SizedBox(
                                                      height: 5,
                                                    ),
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          primaryemailerror = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      primaryemail,
                                                                      keyboardType:
                                                                      TextInputType.emailAddress,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: primaryemailerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                        prefixIcon: Padding(
                                                                          padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                          child: FaIcon(
                                                                            FontAwesomeIcons.envelope,
                                                                            size: 18,
                                                                            color: Color(0xFF8A95A8),
                                                                          ),
                                                                        ),
                                                                        hintText: "Enter primery email",
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
                                                    primaryemailerror
                                                        ? Center(
                                                        child: Text(
                                                          primaryemailmessage,
                                                          style: TextStyle(
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
                                                    Row(
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
                                                    SizedBox(
                                                      height: 5,
                                                    ),
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
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
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: alternativeerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                        prefixIcon: Padding(
                                                                          padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                          child: FaIcon(
                                                                            FontAwesomeIcons.envelope,
                                                                            size: 18,
                                                                            color: Color(0xFF8A95A8),
                                                                          ),
                                                                        ),
                                                                        hintText: "Enter alternative email",
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
                                                    alternativeerror
                                                        ? Center(
                                                        child: Text(
                                                          alternativemessage,
                                                          style: TextStyle(
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
                                                    Row(
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
                                                    SizedBox(
                                                      height: 5,
                                                    ),
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          phonenumerror = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      phonenum,
                                                                      keyboardType:
                                                                      TextInputType.phone,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: phonenumerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                        prefixIcon: Padding(
                                                                          padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                          child: FaIcon(
                                                                            FontAwesomeIcons.phone,
                                                                            size: 18,
                                                                            color: Color(0xFF8A95A8),
                                                                          ),
                                                                        ),
                                                                        hintText: "Enter phone number",
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
                                                    phonenumerror
                                                        ? Center(
                                                        child: Text(
                                                          phonenummessage,
                                                          style: TextStyle(
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          homenumerror = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      homenum,
                                                                      keyboardType:
                                                                      TextInputType.phone,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: homenumerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                        prefixIcon: Padding(
                                                                          padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                          child: FaIcon(
                                                                            FontAwesomeIcons.home,
                                                                            size: 18,
                                                                            color: Color(0xFF8A95A8),
                                                                          ),
                                                                        ),
                                                                        hintText: "Enter home number",
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
                                                    homenumerror
                                                        ? Center(
                                                        child: Text(
                                                          homenummessage,
                                                          style: TextStyle(
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          businessnumerror = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      businessnum,
                                                                      keyboardType:
                                                                      TextInputType.phone,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: businessnumerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                        prefixIcon: Padding(
                                                                          padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                          child: FaIcon(
                                                                            FontAwesomeIcons.businessTime,
                                                                            size: 18,
                                                                            color: Color(0xFF8A95A8),
                                                                          ),
                                                                        ),
                                                                        hintText: "Enter business number",
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
                                                    businessnumerror
                                                        ? Center(
                                                        child: Text(
                                                          businessnummessage,
                                                          style: TextStyle(
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
                                                    Row(
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
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    //Street Address
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          street2error = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      street2,
                                                                      //  keyboardType: TextInputType.emailAddress,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: street2error
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                        // prefixIcon: Padding(
                                                                        //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                        //   child: FaIcon(
                                                                        //     FontAwesomeIcons.envelope,
                                                                        //     size: 18,
                                                                        //     color: Color(0xFF8A95A8),
                                                                        //   ),
                                                                        // ),
                                                                        hintText: "Enter street address",
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
                                                    street2error
                                                        ? Center(
                                                        child: Text(
                                                          street2message,
                                                          style: TextStyle(
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          city2error = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      city2,
                                                                      //  keyboardType: TextInputType.emailAddress,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: city2error
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                        // prefixIcon: Padding(
                                                                        //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                        //   child: FaIcon(
                                                                        //     FontAwesomeIcons.envelope,
                                                                        //     size: 18,
                                                                        //     color: Color(0xFF8A95A8),
                                                                        //   ),
                                                                        // ),
                                                                        hintText: "Enter city here",
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
                                                          width: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .width *
                                                              .03,
                                                        ),
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          state2error = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      state2,
                                                                      // keyboardType: TextInputType.emailAddress,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: state2error
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                        // prefixIcon: Padding(
                                                                        //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                        //   child: FaIcon(
                                                                        //     FontAwesomeIcons.envelope,
                                                                        //     size: 18,
                                                                        //     color: Color(0xFF8A95A8),
                                                                        //   ),
                                                                        // ),
                                                                        hintText: "Enter state",
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
                                                              style: TextStyle(
                                                                  color:
                                                                  Colors.red),
                                                            ))
                                                            : Container(),
                                                        SizedBox(
                                                          width: 70,
                                                        ),
                                                        state2error
                                                            ? Center(
                                                            child:
                                                            Text(
                                                              state2message,
                                                              style: TextStyle(
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          county2error = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      county2,
                                                                      // keyboardType: TextInputType.emailAddress,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: county2error
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                        // prefixIcon: Padding(
                                                                        //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                        //   child: FaIcon(
                                                                        //     FontAwesomeIcons.envelope,
                                                                        //     size: 18,
                                                                        //     color: Color(0xFF8A95A8),
                                                                        //   ),
                                                                        // ),
                                                                        hintText: "Enter country",
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
                                                          width: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .width *
                                                              .03,
                                                        ),
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
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color:
                                                                    Color(0xFF8A95A8)),
                                                              ),
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          code2error = false;
                                                                        });
                                                                      },
                                                                      controller:
                                                                      code2,
                                                                      //  keyboardType: TextInputType.emailAddress,
                                                                      cursorColor: Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      decoration:
                                                                      InputDecoration(
                                                                        border: InputBorder.none,
                                                                        enabledBorder: code2error
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(5),
                                                                          borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                        // prefixIcon: Padding(
                                                                        //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                        //   child: FaIcon(
                                                                        //     FontAwesomeIcons.envelope,
                                                                        //     size: 18,
                                                                        //     color: Color(0xFF8A95A8),
                                                                        //   ),
                                                                        // ),
                                                                        hintText: "Enter postal code",
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
                                                              style: TextStyle(
                                                                  color:
                                                                  Colors.red),
                                                            ))
                                                            : Container(),
                                                        SizedBox(
                                                          width: 70,
                                                        ),
                                                        code2error
                                                            ? Center(
                                                            child:
                                                            Text(
                                                              code2message,
                                                              style: TextStyle(
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
                                                    //merchant id
                                                    // Row(
                                                    //   children: [
                                                    //     Text(
                                                    //       "Merchant Id",
                                                    //       style: TextStyle(
                                                    //           fontWeight:
                                                    //               FontWeight
                                                    //                   .bold,
                                                    //           color: Color(
                                                    //               0xFF8A95A8),
                                                    //           fontSize:
                                                    //               14),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    // SizedBox(
                                                    //   height: 5,
                                                    // ),
                                                    // Row(
                                                    //   children: [
                                                    //     SizedBox(
                                                    //       width:
                                                    //           20.0, // Standard width for checkbox
                                                    //       height: 20.0,
                                                    //       child: Checkbox(
                                                    //         value:
                                                    //             isChecked2,
                                                    //         onChanged:
                                                    //             (value) {
                                                    //           setState(
                                                    //               () {
                                                    //             isChecked2 =
                                                    //                 value ??
                                                    //                     false;
                                                    //           });
                                                    //         },
                                                    //         activeColor: isChecked2
                                                    //             ? Color.fromRGBO(
                                                    //                 21,
                                                    //                 43,
                                                    //                 81,
                                                    //                 1)
                                                    //             : Colors
                                                    //                 .black,
                                                    //       ),
                                                    //     ),
                                                    //     SizedBox(
                                                    //       width: MediaQuery.of(
                                                    //                   context)
                                                    //               .size
                                                    //               .width *
                                                    //           .02,
                                                    //     ),
                                                    //     Expanded(
                                                    //       child: Material(
                                                    //         elevation: 3,
                                                    //         borderRadius:
                                                    //             BorderRadius
                                                    //                 .circular(
                                                    //                     5),
                                                    //         child:
                                                    //             Container(
                                                    //           height: 50,
                                                    //           decoration:
                                                    //               BoxDecoration(
                                                    //             borderRadius:
                                                    //                 BorderRadius.circular(
                                                    //                     5),
                                                    //             color: Colors
                                                    //                 .white,
                                                    //             border: Border.all(
                                                    //                 color:
                                                    //                     Color(0xFF8A95A8)),
                                                    //           ),
                                                    //           child:
                                                    //               Stack(
                                                    //             children: [
                                                    //               Positioned
                                                    //                   .fill(
                                                    //                 child:
                                                    //                     TextField(
                                                    //                   onChanged:
                                                    //                       (value) {
                                                    //                     setState(() {
                                                    //                       proiderror = false;
                                                    //                     });
                                                    //                   },
                                                    //                   controller:
                                                    //                    proid
                                                    //                       ,
                                                    //                   // keyboardType: TextInputType.emailAddress,
                                                    //                   cursorColor: Color.fromRGBO(
                                                    //                       21,
                                                    //                       43,
                                                    //                       81,
                                                    //                       1),
                                                    //                   decoration:
                                                    //                       InputDecoration(
                                                    //                     border: InputBorder.none,
                                                    //                     enabledBorder: proiderror
                                                    //                         ? OutlineInputBorder(
                                                    //                             borderRadius: BorderRadius.circular(5),
                                                    //                             borderSide: BorderSide(color: Colors.red), // Set border color here
                                                    //                           )
                                                    //                         : InputBorder.none,
                                                    //                     contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                    //                     // prefixIcon: Padding(
                                                    //                     //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                    //                     //   child: FaIcon(
                                                    //                     //     FontAwesomeIcons.envelope,
                                                    //                     //     size: 18,
                                                    //                     //     color: Color(0xFF8A95A8),
                                                    //                     //   ),
                                                    //                     // ),
                                                    //                     hintText: "Enter proccesor",
                                                    //                     hintStyle: TextStyle(
                                                    //                       color: Color(0xFF8A95A8),
                                                    //                       fontSize: 13,
                                                    //                     ),
                                                    //                   ),
                                                    //                 ),
                                                    //               ),
                                                    //             ],
                                                    //           ),
                                                    //         ),
                                                    //       ),
                                                    //     ),
                                                    //     SizedBox(
                                                    //       width: MediaQuery.of(
                                                    //                   context)
                                                    //               .size
                                                    //               .width *
                                                    //           .02,
                                                    //     ),
                                                    //     InkWell(
                                                    //       onTap: () {
                                                    //         // onDelete(property);
                                                    //       },
                                                    //       child:
                                                    //           Container(
                                                    //         //    color: Colors.redAccent,
                                                    //         padding:
                                                    //             EdgeInsets
                                                    //                 .zero,
                                                    //         child: FaIcon(
                                                    //           FontAwesomeIcons
                                                    //               .trashCan,
                                                    //           size: 20,
                                                    //           color: Color
                                                    //               .fromRGBO(
                                                    //                   21,
                                                    //                   43,
                                                    //                   81,
                                                    //                   1),
                                                    //         ),
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    // SizedBox(
                                                    //     height: MediaQuery.of(
                                                    //                 context)
                                                    //             .size
                                                    //             .height *
                                                    //         0.01),
                                                    // Row(
                                                    //   children: [
                                                    //     proiderror
                                                    //         ? Center(
                                                    //             child:
                                                    //                 Text(
                                                    //             proidmessage,
                                                    //             style: TextStyle(
                                                    //                 color:
                                                    //                     Colors.red),
                                                    //           ))
                                                    //         : Container(),
                                                    //   ],
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
                                                            Row(
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
                                                            SizedBox(
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
                                                                                activeColor: Color.fromRGBO(21, 43, 81, 1),
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
                                                                                    border: Border.all(color: Color(0xFF8A95A8)),
                                                                                  ),
                                                                                  child: Stack(
                                                                                    children: [
                                                                                      Positioned.fill(
                                                                                        child: TextField(
                                                                                          controller: group.controller,
                                                                                          cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                                          decoration: InputDecoration(
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
                                                                                child: FaIcon(
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
                                                            Row(
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
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    81,
                                                                    1),
                                                                boxShadow: [
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
                                                                    ? SpinKitFadingCircle(
                                                                  color: Colors.white,
                                                                  size: 25.0,
                                                                )
                                                                    : Text(
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
                                                        //                       GestureDetector(
                                                        //                         // onTap: () async {
                                                        //                         //   if (selectedValue == null || subtype.text.isEmpty) {
                                                        //                         //     setState(() {
                                                        //                         //       iserror = true;
                                                        //                         //     });
                                                        //                         //   } else {
                                                        //                         //     setState(() {
                                                        //                         //       isLoading = true;
                                                        //                         //       iserror = false;
                                                        //                         //     });
                                                        //                         //     SharedPreferences prefs =
                                                        //                         //     await SharedPreferences.getInstance();
                                                        //                         //
                                                        //                         //     String? id = prefs.getString("adminId");
                                                        //                         //     PropertyTypeRepository()
                                                        //                         //         .addPropertyType(
                                                        //                         //       adminId: id!,
                                                        //                         //       propertyType: selectedValue,
                                                        //                         //       propertySubType: subtype.text,
                                                        //                         //       isMultiUnit: isChecked,
                                                        //                         //     )
                                                        //                         //         .then((value) {
                                                        //                         //       setState(() {
                                                        //                         //         isLoading = false;
                                                        //                         //       });
                                                        //                         //     }).catchError((e) {
                                                        //                         //       setState(() {
                                                        //                         //         isLoading = false;
                                                        //                         //       });
                                                        //                         //     });
                                                        //                         //   }
                                                        //                         //   print(selectedValue);
                                                        //                         // },
                                                        //                         onTap:()async{
                                                        //                          if(isChecked2 == false){
                                                        //                            Rental_PropertiesRepository().
                                                        //                            checkIfRentalOwnerExists(
                                                        //                              rentalowner_id: rentalOwnerId!.rentalOwnerId,
                                                        //                              rentalOwner_firstName: firstname.text,
                                                        //                              rentalOwner_lastName: lastname.text,
                                                        //                              rentalOwner_companyName: comname.text,
                                                        //                              rentalOwner_primaryEmail: primaryemail.text,
                                                        //                              rentalOwner_alternativeEmail: alternativeemail.text,
                                                        //                              rentalOwner_phoneNumber: phonenum.text,
                                                        //                              rentalOwner_homeNumber: homenum.text,
                                                        //                              rentalOwner_businessNumber: businessnum.text,
                                                        //                            ) ;
                                                        //                          }
                                                        //                           else {
                                                        //                             // setSelectedRentalOwnerData(values);
                                                        //                             // setshowRentalOwnerTable(false);
                                                        //                           // handleAddrentalOwner();
                                                        //                            // handleClose();
                                                        //                            Fluttertoast.showToast(
                                                        //                                msg: "Rental Owner Added Successfully!",
                                                        //                                toastLength: Toast.LENGTH_SHORT,
                                                        //                                gravity: ToastGravity.TOP,
                                                        //                                timeInSecForIosWeb: 1,
                                                        //                                backgroundColor: Colors.red,
                                                        //                                textColor: Colors.white,
                                                        //                                fontSize: 16.0
                                                        //                            );
                                                        //                            Navigator.pop(context);
                                                        //                           }
                                                        //
                                                        // },
                                                        //                         child:
                                                        //                             ClipRRect(
                                                        //                           borderRadius:
                                                        //                               BorderRadius
                                                        //                                   .circular(
                                                        //                                       5.0),
                                                        //                           child:
                                                        //                               Container(
                                                        //                             height:
                                                        //                                 30.0,
                                                        //                             width: 50,
                                                        //                             decoration:
                                                        //                                 BoxDecoration(
                                                        //                               borderRadius:
                                                        //                                   BorderRadius.circular(
                                                        //                                       5.0),
                                                        //                               color: Color
                                                        //                                   .fromRGBO(
                                                        //                                       21,
                                                        //                                       43,
                                                        //                                       81,
                                                        //                                       1),
                                                        //                               boxShadow: [
                                                        //                                 BoxShadow(
                                                        //                                   color:
                                                        //                                       Colors.grey,
                                                        //                                   offset: Offset(
                                                        //                                       0.0,
                                                        //                                       1.0), //(x,y)
                                                        //                                   blurRadius:
                                                        //                                       6.0,
                                                        //                                 ),
                                                        //                               ],
                                                        //                             ),
                                                        //                             child:
                                                        //                                 Center(
                                                        //                               child: isLoading
                                                        //                                   ? SpinKitFadingCircle(
                                                        //                                       color: Colors.white,
                                                        //                                       size: 25.0,
                                                        //                                     )
                                                        //                                   : Text(
                                                        //                                       "Add",
                                                        //                                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                                        //                                     ),
                                                        //                             ),
                                                        //                           ),
                                                        //                         ),
                                                        //                       ),
                                                        GestureDetector(
                                                          // onTap:
                                                          //     () async {
                                                          //   if (!isChecked) {
                                                          //     await Rental_PropertiesRepository().checkIfRentalOwnerExists(
                                                          //       rentalowner_id: rentalOwnerId!.rentalOwnerId,
                                                          //       rentalOwner_firstName: firstname.text,
                                                          //       rentalOwner_lastName: lastname.text,
                                                          //       rentalOwner_companyName: comname.text,
                                                          //       rentalOwner_primaryEmail: primaryemail.text,
                                                          //       rentalOwner_alternativeEmail: alternativeemail.text,
                                                          //       rentalOwner_phoneNumber: phonenum.text,
                                                          //       rentalOwner_homeNumber: homenum.text,
                                                          //       rentalOwner_businessNumber: businessnum.text,
                                                          //     )
                                                          //         .then((value) {
                                                          //       setState(() {
                                                          //         isLoading = false;
                                                          //       });
                                                          //       Navigator.pop(context,true);
                                                          //     }).catchError((e) {
                                                          //       setState(() {
                                                          //         isLoading = false;
                                                          //       });
                                                          //     });
                                                          //   } else {
                                                          //     Fluttertoast
                                                          //         .showToast(
                                                          //       msg:
                                                          //           "Rental Owner Added Successfully!",
                                                          //       toastLength:
                                                          //           Toast
                                                          //               .LENGTH_SHORT,
                                                          //       gravity:
                                                          //           ToastGravity
                                                          //               .TOP,
                                                          //       timeInSecForIosWeb:
                                                          //           1,
                                                          //       backgroundColor:
                                                          //           Colors
                                                          //               .green,
                                                          //       textColor:
                                                          //           Colors
                                                          //               .white,
                                                          //       fontSize:
                                                          //           16.0,
                                                          //     );
                                                          //   }
                                                          // },
                                                          onTap: () async {
                                                            if (!isChecked2) {
                                                              print(!isChecked2);
                                                              var response =  await Rental_PropertiesRepository().checkIfRentalOwnerExists(
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
                                                              if(response == true){
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
                                                              Ownersdetails = RentalOwner(
                                                                // rentalOwnerFirstName: firstname.text,
                                                                rentalOwnerLastName: lastname.text,
                                                                rentalOwnerPhoneNumber: phonenum.text,
                                                                rentalOwnerFirstName: firstname.text,
                                                              );

                                                              context.read<OwnerDetailsProvider>().setOwnerDetails(Ownersdetails!);
                                                              Navigator.pop(context);
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
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    81,
                                                                    1),
                                                                boxShadow: [
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
                                                                    ? SpinKitFadingCircle(
                                                                  color: Colors.white,
                                                                  size: 25.0,
                                                                )
                                                                    : Text(
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
                                                            Navigator.pop(context);
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
                                                                    ? SpinKitFadingCircle(
                                                                  color: Colors.white,
                                                                  size: 25.0,
                                                                )
                                                                    : Text(
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
                                  SizedBox(width: 15),
                                  Icon(Icons.add,
                                      size: 20, color: Colors.green[400]),
                                  SizedBox(width: 9),
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
                            SizedBox(
                              height: 5,
                            ),
                            if (hasError && Provider.of<OwnerDetailsProvider>(context).OwnerDetails == null )
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'required',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 5,
                            ),
                            // Ownersdetails != null
                            //     ? Column(
                            //       children: [
                            //         SizedBox(
                            //           height: 10,
                            //         ),
                            //         Row(
                            //           children: [
                            //             SizedBox(width: 20,),
                            //             Text("Owners Information",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),),
                            //           ],
                            //         ),
                            //         SizedBox(
                            //           height: 10,
                            //         ),
                            //         Container(
                            //                                       decoration:
                            //                                       BoxDecoration(
                            //         borderRadius:
                            //         BorderRadius
                            //             .circular(
                            //             5),
                            //         border: Border.all(
                            //             color: Colors
                            //                 .grey),
                            //                                       ),
                            //                                       child: DataTable(
                            //             columnSpacing: 10,
                            //             headingRowHeight:
                            //             29,
                            //             dataRowHeight: 30,
                            //             // horizontalMargin: 10,
                            //             columns: [
                            //               DataColumn(
                            //                   label:
                            //                   Expanded(
                            //                     child: Text(
                            //                       'FirstName',
                            //                       style: TextStyle(
                            //                           fontSize:
                            //                           10,
                            //                           fontWeight:
                            //                           FontWeight.bold),
                            //                     ),
                            //                   )),
                            //               DataColumn(
                            //                   label:
                            //                   Expanded(
                            //                     child: Text(
                            //                       'LastName',
                            //                       style: TextStyle(
                            //                           fontSize:
                            //                           11,
                            //                           fontWeight:
                            //                           FontWeight.bold),
                            //                     ),
                            //                   )),
                            //               DataColumn(
                            //                   label:
                            //                   Expanded(
                            //                     child: Text(
                            //                       'PhoneNumber',
                            //                       style: TextStyle(
                            //                           fontSize:
                            //                           11,
                            //                           fontWeight:
                            //                           FontWeight.bold),
                            //                     ),
                            //                   )),
                            //               DataColumn(
                            //                   label:
                            //                   Expanded(
                            //                     child: Text(
                            //                       'Action',
                            //                       style: TextStyle(
                            //                           fontSize:
                            //                           11,
                            //                           fontWeight:
                            //                           FontWeight.bold),
                            //                     ),
                            //                   )),
                            //             ],
                            //             rows: [
                            //               DataRow(
                            //                 cells: [
                            //                   DataCell(
                            //                     Text(
                            //                       Ownersdetails!.rentalOwnerFirstName ?? 'N/A',
                            //                       style: TextStyle(
                            //                           fontSize:
                            //                           10),
                            //                     ),
                            //                   ),
                            //                   DataCell(
                            //                     Text(
                            //                       Ownersdetails!.rentalOwnerLastName ?? 'N/A',
                            //                       style: TextStyle(
                            //                           fontSize:
                            //                           10),
                            //                     ),
                            //                   ),
                            //                   DataCell(
                            //                     Text(
                            //                       Ownersdetails!.rentalOwnerPhoneNumber ?? 'N/A' ,// Join processor IDs with newline
                            //                       style: TextStyle(
                            //                           fontSize:
                            //                           10),
                            //                     ),
                            //                   ),
                            //                   DataCell(Row(
                            //                     children: [
                            //                       InkWell(
                            //                         onTap: () {
                            //                           //  onEdit(rental);
                            //                         },
                            //                         child: Container(
                            //                           //  color: Colors.redAccent,
                            //                           padding: EdgeInsets.zero,
                            //                           child: FaIcon(
                            //                             FontAwesomeIcons.edit,
                            //                             size: 15,
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       SizedBox(
                            //                         width: 4,
                            //                       ),
                            //                       InkWell(
                            //                         onTap: () {
                            //
                            //                           //  handleDelete(rental);
                            //                         },
                            //                         child: Container(
                            //                           //    color: Colors.redAccent,
                            //                           padding: EdgeInsets.zero,
                            //                           child: FaIcon(
                            //                             FontAwesomeIcons.trashCan,
                            //                             size: 15,
                            //                           ),
                            //                         ),
                            //                       ),
                            //
                            //                     ],
                            //                   )),
                            //                 ],
                            //               ),
                            //             ]
                            //           ),
                            //
                            //                                     ),
                            //       ],
                            //     ):  Text('No owner details available'),
                            Consumer<OwnerDetailsProvider>(
                              builder: (context, provider, child) {
                                //  final ownersdetails = provider.OwnerDetails;
                                return Ownersdetails != null
                                    ? Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text(
                                          "Owners Information",
                                          style: TextStyle(
                                              fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: DataTable(
                                        columnSpacing: 10,
                                        headingRowHeight: 29,
                                        dataRowHeight: 30,
                                        columns: [
                                          DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'FirstName',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'LastName',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'PhoneNumber',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Action',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: [
                                          DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  Ownersdetails!.rentalOwnerFirstName ?? 'N/A',

                                                  // Ownersdetails!.rentalOwnerFirstName ?? "",
                                                  style: TextStyle(fontSize: 10),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  Ownersdetails!.rentalOwnerLastName ?? 'N/A',
                                                  style: TextStyle(fontSize: 10),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  Ownersdetails!.rentalOwnerPhoneNumber ?? 'N/A',
                                                  style: TextStyle(fontSize: 10),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    InkWell(
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
                                                                  title: Text(
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
                                                                                    ? Color.fromRGBO(
                                                                                    21, 43, 81, 1)
                                                                                    : Colors.black,
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            Expanded(
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
                                                                            SizedBox(
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
                                                                                            Color(0xFF8A95A8)),
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
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
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
                                                                            SizedBox(
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
                                                                              child:
                                                                              DataTable(
                                                                                columnSpacing: 10,
                                                                                headingRowHeight:
                                                                                29,
                                                                                dataRowHeight: 30,
                                                                                // horizontalMargin: 10,
                                                                                columns: [
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
                                                                                              style: TextStyle(
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
                                                                                              style: TextStyle(
                                                                                                  fontSize:
                                                                                                  10),
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
                                                                                                    isChecked = false;
                                                                                                    _processorGroups.clear();
                                                                                                    for (Processor processor in selectedOwner!.processorList) {
                                                                                                      _processorGroups.add(ProcessorGroup(isChecked: false, controller: TextEditingController(text: processor.processorId)));
                                                                                                    }
                                                                                                  });
                                                                                                },
                                                                                                activeColor: Color.fromRGBO(
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
                                                                            SizedBox(
                                                                                height: 16.0),
                                                                            Row(
                                                                              mainAxisAlignment:
                                                                              MainAxisAlignment
                                                                                  .start,
                                                                              children: [
                                                                                GestureDetector(
                                                                                  onTap: () async {
                                                                                    if (!isChecked2) {
                                                                                      print(!isChecked2);
                                                                                      var response =  await Rental_PropertiesRepository().checkIfRentalOwnerExists(
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
                                                                                      if(response == true){
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
                                                                                        color: Color
                                                                                            .fromRGBO(
                                                                                            21,
                                                                                            43,
                                                                                            81,
                                                                                            1),
                                                                                        boxShadow: [
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
                                                                                            ? SpinKitFadingCircle(
                                                                                          color: Colors.white,
                                                                                          size: 25.0,
                                                                                        )
                                                                                            : Text(
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
                                                                                            ? SpinKitFadingCircle(
                                                                                          color: Colors.white,
                                                                                          size: 25.0,
                                                                                        )
                                                                                            : Text(
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
                                                                            :
                                                                        Column(
                                                                          children: [
                                                                            SizedBox(
                                                                              height: 25,
                                                                            ),
                                                                            Row(
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
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            //firstname
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  firstnameerror = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              firstname,
                                                                                              //  keyboardType: TextInputType.emailAddress,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: firstnameerror
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                // prefixIcon: Padding(
                                                                                                //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                //   child: FaIcon(
                                                                                                //     FontAwesomeIcons.envelope,
                                                                                                //     size: 18,
                                                                                                //     color: Color(0xFF8A95A8),
                                                                                                //   ),
                                                                                                // ),
                                                                                                hintText: "Enter first name",
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
                                                                            firstnameerror
                                                                                ? Center(
                                                                                child: Text(
                                                                                  firstnamemessage,
                                                                                  style: TextStyle(
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  lastnameerror = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              lastname,
                                                                                              //  keyboardType: TextInputType.emailAddress,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: lastnameerror
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                // prefixIcon: Padding(
                                                                                                //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                //   child: FaIcon(
                                                                                                //     FontAwesomeIcons.envelope,
                                                                                                //     size: 18,
                                                                                                //     color: Color(0xFF8A95A8),
                                                                                                //   ),
                                                                                                // ),
                                                                                                hintText: "Enter last name ",
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
                                                                            lastnameerror
                                                                                ? Center(
                                                                                child: Text(
                                                                                  lastnamemessage,
                                                                                  style: TextStyle(
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
                                                                            Row(
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
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  comnameerror = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              comname,
                                                                                              //keyboardType: TextInputType.emailAddress,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: comnameerror
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                // prefixIcon: Padding(
                                                                                                //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                //   child: FaIcon(
                                                                                                //     FontAwesomeIcons.envelope,
                                                                                                //     size: 18,
                                                                                                //     color: Color(0xFF8A95A8),
                                                                                                //   ),
                                                                                                // ),
                                                                                                hintText: "Enter company name",
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
                                                                            comnameerror
                                                                                ? Center(
                                                                                child: Text(
                                                                                  comnamemessage,
                                                                                  style: TextStyle(
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
                                                                            Row(
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
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  primaryemailerror = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              primaryemail,
                                                                                              keyboardType:
                                                                                              TextInputType.emailAddress,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: primaryemailerror
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                                                prefixIcon: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                                  child: FaIcon(
                                                                                                    FontAwesomeIcons.envelope,
                                                                                                    size: 18,
                                                                                                    color: Color(0xFF8A95A8),
                                                                                                  ),
                                                                                                ),
                                                                                                hintText: "Enter primery email",
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
                                                                            primaryemailerror
                                                                                ? Center(
                                                                                child: Text(
                                                                                  primaryemailmessage,
                                                                                  style: TextStyle(
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
                                                                            Row(
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
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
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
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: alternativeerror
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                                                prefixIcon: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                                  child: FaIcon(
                                                                                                    FontAwesomeIcons.envelope,
                                                                                                    size: 18,
                                                                                                    color: Color(0xFF8A95A8),
                                                                                                  ),
                                                                                                ),
                                                                                                hintText: "Enter alternative email",
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
                                                                            alternativeerror
                                                                                ? Center(
                                                                                child: Text(
                                                                                  alternativemessage,
                                                                                  style: TextStyle(
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
                                                                            Row(
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
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  phonenumerror = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              phonenum,
                                                                                              keyboardType:
                                                                                              TextInputType.phone,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: phonenumerror
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                                                prefixIcon: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                                  child: FaIcon(
                                                                                                    FontAwesomeIcons.phone,
                                                                                                    size: 18,
                                                                                                    color: Color(0xFF8A95A8),
                                                                                                  ),
                                                                                                ),
                                                                                                hintText: "Enter phone number",
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
                                                                            phonenumerror
                                                                                ? Center(
                                                                                child: Text(
                                                                                  phonenummessage,
                                                                                  style: TextStyle(
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  homenumerror = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              homenum,
                                                                                              keyboardType:
                                                                                              TextInputType.phone,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: homenumerror
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                                                prefixIcon: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                                  child: FaIcon(
                                                                                                    FontAwesomeIcons.home,
                                                                                                    size: 18,
                                                                                                    color: Color(0xFF8A95A8),
                                                                                                  ),
                                                                                                ),
                                                                                                hintText: "Enter home number",
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
                                                                            homenumerror
                                                                                ? Center(
                                                                                child: Text(
                                                                                  homenummessage,
                                                                                  style: TextStyle(
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  businessnumerror = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              businessnum,
                                                                                              keyboardType:
                                                                                              TextInputType.phone,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: businessnumerror
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                                                prefixIcon: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                                  child: FaIcon(
                                                                                                    FontAwesomeIcons.businessTime,
                                                                                                    size: 18,
                                                                                                    color: Color(0xFF8A95A8),
                                                                                                  ),
                                                                                                ),
                                                                                                hintText: "Enter business number",
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
                                                                            businessnumerror
                                                                                ? Center(
                                                                                child: Text(
                                                                                  businessnummessage,
                                                                                  style: TextStyle(
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
                                                                            Row(
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
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            //Street Address
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  street2error = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              street2,
                                                                                              //  keyboardType: TextInputType.emailAddress,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: street2error
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                // prefixIcon: Padding(
                                                                                                //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                //   child: FaIcon(
                                                                                                //     FontAwesomeIcons.envelope,
                                                                                                //     size: 18,
                                                                                                //     color: Color(0xFF8A95A8),
                                                                                                //   ),
                                                                                                // ),
                                                                                                hintText: "Enter street address",
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
                                                                            street2error
                                                                                ? Center(
                                                                                child: Text(
                                                                                  street2message,
                                                                                  style: TextStyle(
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  city2error = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              city2,
                                                                                              //  keyboardType: TextInputType.emailAddress,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: city2error
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                // prefixIcon: Padding(
                                                                                                //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                //   child: FaIcon(
                                                                                                //     FontAwesomeIcons.envelope,
                                                                                                //     size: 18,
                                                                                                //     color: Color(0xFF8A95A8),
                                                                                                //   ),
                                                                                                // ),
                                                                                                hintText: "Enter city here",
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
                                                                                  width: MediaQuery.of(
                                                                                      context)
                                                                                      .size
                                                                                      .width *
                                                                                      .03,
                                                                                ),
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  state2error = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              state2,
                                                                                              // keyboardType: TextInputType.emailAddress,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: state2error
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                // prefixIcon: Padding(
                                                                                                //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                //   child: FaIcon(
                                                                                                //     FontAwesomeIcons.envelope,
                                                                                                //     size: 18,
                                                                                                //     color: Color(0xFF8A95A8),
                                                                                                //   ),
                                                                                                // ),
                                                                                                hintText: "Enter state",
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
                                                                                      style: TextStyle(
                                                                                          color:
                                                                                          Colors.red),
                                                                                    ))
                                                                                    : Container(),
                                                                                SizedBox(
                                                                                  width: 70,
                                                                                ),
                                                                                state2error
                                                                                    ? Center(
                                                                                    child:
                                                                                    Text(
                                                                                      state2message,
                                                                                      style: TextStyle(
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  county2error = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              county2,
                                                                                              // keyboardType: TextInputType.emailAddress,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: county2error
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                // prefixIcon: Padding(
                                                                                                //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                //   child: FaIcon(
                                                                                                //     FontAwesomeIcons.envelope,
                                                                                                //     size: 18,
                                                                                                //     color: Color(0xFF8A95A8),
                                                                                                //   ),
                                                                                                // ),
                                                                                                hintText: "Enter country",
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
                                                                                  width: MediaQuery.of(
                                                                                      context)
                                                                                      .size
                                                                                      .width *
                                                                                      .03,
                                                                                ),
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
                                                                                        color: Colors
                                                                                            .white,
                                                                                        border: Border.all(
                                                                                            color:
                                                                                            Color(0xFF8A95A8)),
                                                                                      ),
                                                                                      child:
                                                                                      Stack(
                                                                                        children: [
                                                                                          Positioned
                                                                                              .fill(
                                                                                            child:
                                                                                            TextField(
                                                                                              onChanged:
                                                                                                  (value) {
                                                                                                setState(() {
                                                                                                  code2error = false;
                                                                                                });
                                                                                              },
                                                                                              controller:
                                                                                              code2,
                                                                                              //  keyboardType: TextInputType.emailAddress,
                                                                                              cursorColor: Color.fromRGBO(
                                                                                                  21,
                                                                                                  43,
                                                                                                  81,
                                                                                                  1),
                                                                                              decoration:
                                                                                              InputDecoration(
                                                                                                border: InputBorder.none,
                                                                                                enabledBorder: code2error
                                                                                                    ? OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                                )
                                                                                                    : InputBorder.none,
                                                                                                contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                                                // prefixIcon: Padding(
                                                                                                //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                                                //   child: FaIcon(
                                                                                                //     FontAwesomeIcons.envelope,
                                                                                                //     size: 18,
                                                                                                //     color: Color(0xFF8A95A8),
                                                                                                //   ),
                                                                                                // ),
                                                                                                hintText: "Enter postal code",
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
                                                                                      style: TextStyle(
                                                                                          color:
                                                                                          Colors.red),
                                                                                    ))
                                                                                    : Container(),
                                                                                SizedBox(
                                                                                  width: 70,
                                                                                ),
                                                                                code2error
                                                                                    ? Center(
                                                                                    child:
                                                                                    Text(
                                                                                      code2message,
                                                                                      style: TextStyle(
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
                                                                            //merchant id
                                                                            // Row(
                                                                            //   children: [
                                                                            //     Text(
                                                                            //       "Merchant Id",
                                                                            //       style: TextStyle(
                                                                            //           fontWeight:
                                                                            //               FontWeight
                                                                            //                   .bold,
                                                                            //           color: Color(
                                                                            //               0xFF8A95A8),
                                                                            //           fontSize:
                                                                            //               14),
                                                                            //     ),
                                                                            //   ],
                                                                            // ),
                                                                            // SizedBox(
                                                                            //   height: 5,
                                                                            // ),
                                                                            // Row(
                                                                            //   children: [
                                                                            //     SizedBox(
                                                                            //       width:
                                                                            //           20.0, // Standard width for checkbox
                                                                            //       height: 20.0,
                                                                            //       child: Checkbox(
                                                                            //         value:
                                                                            //             isChecked2,
                                                                            //         onChanged:
                                                                            //             (value) {
                                                                            //           setState(
                                                                            //               () {
                                                                            //             isChecked2 =
                                                                            //                 value ??
                                                                            //                     false;
                                                                            //           });
                                                                            //         },
                                                                            //         activeColor: isChecked2
                                                                            //             ? Color.fromRGBO(
                                                                            //                 21,
                                                                            //                 43,
                                                                            //                 81,
                                                                            //                 1)
                                                                            //             : Colors
                                                                            //                 .black,
                                                                            //       ),
                                                                            //     ),
                                                                            //     SizedBox(
                                                                            //       width: MediaQuery.of(
                                                                            //                   context)
                                                                            //               .size
                                                                            //               .width *
                                                                            //           .02,
                                                                            //     ),
                                                                            //     Expanded(
                                                                            //       child: Material(
                                                                            //         elevation: 3,
                                                                            //         borderRadius:
                                                                            //             BorderRadius
                                                                            //                 .circular(
                                                                            //                     5),
                                                                            //         child:
                                                                            //             Container(
                                                                            //           height: 50,
                                                                            //           decoration:
                                                                            //               BoxDecoration(
                                                                            //             borderRadius:
                                                                            //                 BorderRadius.circular(
                                                                            //                     5),
                                                                            //             color: Colors
                                                                            //                 .white,
                                                                            //             border: Border.all(
                                                                            //                 color:
                                                                            //                     Color(0xFF8A95A8)),
                                                                            //           ),
                                                                            //           child:
                                                                            //               Stack(
                                                                            //             children: [
                                                                            //               Positioned
                                                                            //                   .fill(
                                                                            //                 child:
                                                                            //                     TextField(
                                                                            //                   onChanged:
                                                                            //                       (value) {
                                                                            //                     setState(() {
                                                                            //                       proiderror = false;
                                                                            //                     });
                                                                            //                   },
                                                                            //                   controller:
                                                                            //                    proid
                                                                            //                       ,
                                                                            //                   // keyboardType: TextInputType.emailAddress,
                                                                            //                   cursorColor: Color.fromRGBO(
                                                                            //                       21,
                                                                            //                       43,
                                                                            //                       81,
                                                                            //                       1),
                                                                            //                   decoration:
                                                                            //                       InputDecoration(
                                                                            //                     border: InputBorder.none,
                                                                            //                     enabledBorder: proiderror
                                                                            //                         ? OutlineInputBorder(
                                                                            //                             borderRadius: BorderRadius.circular(5),
                                                                            //                             borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                            //                           )
                                                                            //                         : InputBorder.none,
                                                                            //                     contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                            //                     // prefixIcon: Padding(
                                                                            //                     //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                            //                     //   child: FaIcon(
                                                                            //                     //     FontAwesomeIcons.envelope,
                                                                            //                     //     size: 18,
                                                                            //                     //     color: Color(0xFF8A95A8),
                                                                            //                     //   ),
                                                                            //                     // ),
                                                                            //                     hintText: "Enter proccesor",
                                                                            //                     hintStyle: TextStyle(
                                                                            //                       color: Color(0xFF8A95A8),
                                                                            //                       fontSize: 13,
                                                                            //                     ),
                                                                            //                   ),
                                                                            //                 ),
                                                                            //               ),
                                                                            //             ],
                                                                            //           ),
                                                                            //         ),
                                                                            //       ),
                                                                            //     ),
                                                                            //     SizedBox(
                                                                            //       width: MediaQuery.of(
                                                                            //                   context)
                                                                            //               .size
                                                                            //               .width *
                                                                            //           .02,
                                                                            //     ),
                                                                            //     InkWell(
                                                                            //       onTap: () {
                                                                            //         // onDelete(property);
                                                                            //       },
                                                                            //       child:
                                                                            //           Container(
                                                                            //         //    color: Colors.redAccent,
                                                                            //         padding:
                                                                            //             EdgeInsets
                                                                            //                 .zero,
                                                                            //         child: FaIcon(
                                                                            //           FontAwesomeIcons
                                                                            //               .trashCan,
                                                                            //           size: 20,
                                                                            //           color: Color
                                                                            //               .fromRGBO(
                                                                            //                   21,
                                                                            //                   43,
                                                                            //                   81,
                                                                            //                   1),
                                                                            //         ),
                                                                            //       ),
                                                                            //     ),
                                                                            //   ],
                                                                            // ),
                                                                            // SizedBox(
                                                                            //     height: MediaQuery.of(
                                                                            //                 context)
                                                                            //             .size
                                                                            //             .height *
                                                                            //         0.01),
                                                                            // Row(
                                                                            //   children: [
                                                                            //     proiderror
                                                                            //         ? Center(
                                                                            //             child:
                                                                            //                 Text(
                                                                            //             proidmessage,
                                                                            //             style: TextStyle(
                                                                            //                 color:
                                                                            //                     Colors.red),
                                                                            //           ))
                                                                            //         : Container(),
                                                                            //   ],
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
                                                                                    Row(
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
                                                                                    SizedBox(
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
                                                                                                        activeColor: Color.fromRGBO(21, 43, 81, 1),
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
                                                                                                            border: Border.all(color: Color(0xFF8A95A8)),
                                                                                                          ),
                                                                                                          child: Stack(
                                                                                                            children: [
                                                                                                              Positioned.fill(
                                                                                                                child: TextField(
                                                                                                                  controller: group.controller,
                                                                                                                  cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                                                                  decoration: InputDecoration(
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
                                                                                                        child: FaIcon(
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
                                                                                    Row(
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
                                                                                        color: Color
                                                                                            .fromRGBO(
                                                                                            21,
                                                                                            43,
                                                                                            81,
                                                                                            1),
                                                                                        boxShadow: [
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
                                                                                            ? SpinKitFadingCircle(
                                                                                          color: Colors.white,
                                                                                          size: 25.0,
                                                                                        )
                                                                                            : Text(
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
                                                                                //                       GestureDetector(
                                                                                //                         // onTap: () async {
                                                                                //                         //   if (selectedValue == null || subtype.text.isEmpty) {
                                                                                //                         //     setState(() {
                                                                                //                         //       iserror = true;
                                                                                //                         //     });
                                                                                //                         //   } else {
                                                                                //                         //     setState(() {
                                                                                //                         //       isLoading = true;
                                                                                //                         //       iserror = false;
                                                                                //                         //     });
                                                                                //                         //     SharedPreferences prefs =
                                                                                //                         //     await SharedPreferences.getInstance();
                                                                                //                         //
                                                                                //                         //     String? id = prefs.getString("adminId");
                                                                                //                         //     PropertyTypeRepository()
                                                                                //                         //         .addPropertyType(
                                                                                //                         //       adminId: id!,
                                                                                //                         //       propertyType: selectedValue,
                                                                                //                         //       propertySubType: subtype.text,
                                                                                //                         //       isMultiUnit: isChecked,
                                                                                //                         //     )
                                                                                //                         //         .then((value) {
                                                                                //                         //       setState(() {
                                                                                //                         //         isLoading = false;
                                                                                //                         //       });
                                                                                //                         //     }).catchError((e) {
                                                                                //                         //       setState(() {
                                                                                //                         //         isLoading = false;
                                                                                //                         //       });
                                                                                //                         //     });
                                                                                //                         //   }
                                                                                //                         //   print(selectedValue);
                                                                                //                         // },
                                                                                //                         onTap:()async{
                                                                                //                          if(isChecked2 == false){
                                                                                //                            Rental_PropertiesRepository().
                                                                                //                            checkIfRentalOwnerExists(
                                                                                //                              rentalowner_id: rentalOwnerId!.rentalOwnerId,
                                                                                //                              rentalOwner_firstName: firstname.text,
                                                                                //                              rentalOwner_lastName: lastname.text,
                                                                                //                              rentalOwner_companyName: comname.text,
                                                                                //                              rentalOwner_primaryEmail: primaryemail.text,
                                                                                //                              rentalOwner_alternativeEmail: alternativeemail.text,
                                                                                //                              rentalOwner_phoneNumber: phonenum.text,
                                                                                //                              rentalOwner_homeNumber: homenum.text,
                                                                                //                              rentalOwner_businessNumber: businessnum.text,
                                                                                //                            ) ;
                                                                                //                          }
                                                                                //                           else {
                                                                                //                             // setSelectedRentalOwnerData(values);
                                                                                //                             // setshowRentalOwnerTable(false);
                                                                                //                           // handleAddrentalOwner();
                                                                                //                            // handleClose();
                                                                                //                            Fluttertoast.showToast(
                                                                                //                                msg: "Rental Owner Added Successfully!",
                                                                                //                                toastLength: Toast.LENGTH_SHORT,
                                                                                //                                gravity: ToastGravity.TOP,
                                                                                //                                timeInSecForIosWeb: 1,
                                                                                //                                backgroundColor: Colors.red,
                                                                                //                                textColor: Colors.white,
                                                                                //                                fontSize: 16.0
                                                                                //                            );
                                                                                //                            Navigator.pop(context);
                                                                                //                           }
                                                                                //
                                                                                // },
                                                                                //                         child:
                                                                                //                             ClipRRect(
                                                                                //                           borderRadius:
                                                                                //                               BorderRadius
                                                                                //                                   .circular(
                                                                                //                                       5.0),
                                                                                //                           child:
                                                                                //                               Container(
                                                                                //                             height:
                                                                                //                                 30.0,
                                                                                //                             width: 50,
                                                                                //                             decoration:
                                                                                //                                 BoxDecoration(
                                                                                //                               borderRadius:
                                                                                //                                   BorderRadius.circular(
                                                                                //                                       5.0),
                                                                                //                               color: Color
                                                                                //                                   .fromRGBO(
                                                                                //                                       21,
                                                                                //                                       43,
                                                                                //                                       81,
                                                                                //                                       1),
                                                                                //                               boxShadow: [
                                                                                //                                 BoxShadow(
                                                                                //                                   color:
                                                                                //                                       Colors.grey,
                                                                                //                                   offset: Offset(
                                                                                //                                       0.0,
                                                                                //                                       1.0), //(x,y)
                                                                                //                                   blurRadius:
                                                                                //                                       6.0,
                                                                                //                                 ),
                                                                                //                               ],
                                                                                //                             ),
                                                                                //                             child:
                                                                                //                                 Center(
                                                                                //                               child: isLoading
                                                                                //                                   ? SpinKitFadingCircle(
                                                                                //                                       color: Colors.white,
                                                                                //                                       size: 25.0,
                                                                                //                                     )
                                                                                //                                   : Text(
                                                                                //                                       "Add",
                                                                                //                                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                                                                //                                     ),
                                                                                //                             ),
                                                                                //                           ),
                                                                                //                         ),
                                                                                //                       ),
                                                                                GestureDetector(
                                                                                  // onTap:
                                                                                  //     () async {
                                                                                  //   if (!isChecked) {
                                                                                  //     await Rental_PropertiesRepository().checkIfRentalOwnerExists(
                                                                                  //       rentalowner_id: rentalOwnerId!.rentalOwnerId,
                                                                                  //       rentalOwner_firstName: firstname.text,
                                                                                  //       rentalOwner_lastName: lastname.text,
                                                                                  //       rentalOwner_companyName: comname.text,
                                                                                  //       rentalOwner_primaryEmail: primaryemail.text,
                                                                                  //       rentalOwner_alternativeEmail: alternativeemail.text,
                                                                                  //       rentalOwner_phoneNumber: phonenum.text,
                                                                                  //       rentalOwner_homeNumber: homenum.text,
                                                                                  //       rentalOwner_businessNumber: businessnum.text,
                                                                                  //     )
                                                                                  //         .then((value) {
                                                                                  //       setState(() {
                                                                                  //         isLoading = false;
                                                                                  //       });
                                                                                  //       Navigator.pop(context,true);
                                                                                  //     }).catchError((e) {
                                                                                  //       setState(() {
                                                                                  //         isLoading = false;
                                                                                  //       });
                                                                                  //     });
                                                                                  //   } else {
                                                                                  //     Fluttertoast
                                                                                  //         .showToast(
                                                                                  //       msg:
                                                                                  //           "Rental Owner Added Successfully!",
                                                                                  //       toastLength:
                                                                                  //           Toast
                                                                                  //               .LENGTH_SHORT,
                                                                                  //       gravity:
                                                                                  //           ToastGravity
                                                                                  //               .TOP,
                                                                                  //       timeInSecForIosWeb:
                                                                                  //           1,
                                                                                  //       backgroundColor:
                                                                                  //           Colors
                                                                                  //               .green,
                                                                                  //       textColor:
                                                                                  //           Colors
                                                                                  //               .white,
                                                                                  //       fontSize:
                                                                                  //           16.0,
                                                                                  //     );
                                                                                  //   }
                                                                                  // },
                                                                                  onTap: () async {
                                                                                    if (!isChecked2) {
                                                                                      print(!isChecked2);
                                                                                      var response =  await Rental_PropertiesRepository().checkIfRentalOwnerExists(
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
                                                                                      if(response == true){
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
                                                                                        color: Color
                                                                                            .fromRGBO(
                                                                                            21,
                                                                                            43,
                                                                                            81,
                                                                                            1),
                                                                                        boxShadow: [
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
                                                                                            ? SpinKitFadingCircle(
                                                                                          color: Colors.white,
                                                                                          size: 25.0,
                                                                                        )
                                                                                            : Text(
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
                                                                                    Navigator.pop(context);
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
                                                                                            ? SpinKitFadingCircle(
                                                                                          color: Colors.white,
                                                                                          size: 25.0,
                                                                                        )
                                                                                            : Text(
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
                                                        padding: EdgeInsets.zero,
                                                        child: FaIcon(
                                                          FontAwesomeIcons.edit,
                                                          size: 13,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
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
                                                          RentalOwner? owner  ;
                                                          Ownersdetails  = owner;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.zero,
                                                        child: FaIcon(
                                                          FontAwesomeIcons.trashCan,
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
                                    : Text('');
                              },
                            ),
                          ],
                        )),
                  ),
                ),
                SizedBox(height: 25),
                //staff
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Who will be primary manager of this Property ?",
                                  style: TextStyle(
                                      color: Color(0xFF8A95A8),
                                      //  fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "If staff member has not yet been added as user in your account ,they can be added to the account"
                                        ",than as the manager later through the property's summary details.",
                                    style: TextStyle(
                                        color: Color(0xFF8A95A8),
                                        //  fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Manage (Optional)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // Row(
                            //   children: [
                            //     FutureBuilder<List<Staffmembers>>(
                            //       future: futureStaffMembers,
                            //       builder: (context, snapshot) {
                            //         if (snapshot.connectionState ==
                            //             ConnectionState.waiting) {
                            //           return CircularProgressIndicator();
                            //         } else if (snapshot.hasError) {
                            //           return Text('Error: ${snapshot.error}');
                            //         } else if (!snapshot.hasData ||
                            //             snapshot.data!.isEmpty) {
                            //           return Text('No staff members found');
                            //         } else {
                            //           List<Staffmembers> staffMembers =
                            //           snapshot.data!;
                            //           List<DropdownMenuItem<String>>
                            //           dropdownItems = staffMembers
                            //               .map<DropdownMenuItem<String>>(
                            //                   (Staffmembers staffMember) {
                            //                 return DropdownMenuItem<String>(
                            //                   value: staffMember.staffmemberName,
                            //                   onTap:(){
                            //                     setState(() {
                            //                       sid = staffMember.staffmemberId;
                            //                     });
                            //                   },
                            //                   child: Text(
                            //                     staffMember.staffmemberName ?? '',
                            //                     style: TextStyle(fontSize: 14),
                            //                   ),
                            //                 );
                            //               }).toList();
                            //
                            //           // Add the special "Add new property" item
                            //           dropdownItems.add(
                            //             DropdownMenuItem<String>(
                            //               value: 'add_new_property',
                            //               child: GestureDetector(
                            //                 onTap: () {
                            //                   showDialog(
                            //                     context: context,
                            //                     builder:
                            //                         (BuildContext context) {
                            //                       bool isChecked =
                            //                       false; // Moved isChecked inside the StatefulBuilder
                            //                       return StatefulBuilder(
                            //                         builder: (BuildContext
                            //                         context,
                            //                             StateSetter setState) {
                            //                           return AlertDialog(
                            //                             backgroundColor:
                            //                             Colors.white,
                            //                             surfaceTintColor:
                            //                             Colors.white,
                            //                             content:
                            //                             SingleChildScrollView(
                            //                               child: Column(
                            //                                 children: [
                            //                                   SizedBox(
                            //                                       height: 15),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width: 15,
                            //                                       ),
                            //                                       Text(
                            //                                         "New Staff Member",
                            //                                         style: TextStyle(
                            //                                             color: Color.fromRGBO(
                            //                                                 21,
                            //                                                 43,
                            //                                                 81,
                            //                                                 1),
                            //                                             fontWeight:
                            //                                             FontWeight
                            //                                                 .bold,
                            //                                             fontSize:
                            //                                             18),
                            //                                       ),
                            //                                       Spacer(),
                            //                                       InkWell(
                            //                                         onTap: () {
                            //                                           Navigator.pop(
                            //                                               context);
                            //                                         },
                            //                                         child:
                            //                                         Container(
                            //                                           //    color: Colors.redAccent,
                            //                                           padding:
                            //                                           EdgeInsets
                            //                                               .zero,
                            //                                           child:
                            //                                           FaIcon(
                            //                                             FontAwesomeIcons
                            //                                                 .xmark,
                            //                                             size:
                            //                                             15,
                            //                                             color: Color(
                            //                                                 0xFF8A95A8),
                            //                                           ),
                            //                                         ),
                            //                                       ),
                            //                                       SizedBox(
                            //                                         width: 5,
                            //                                       ),
                            //                                     ],
                            //                                   ),
                            //                                   SizedBox(
                            //                                     height: 10,
                            //                                   ),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width: 15,
                            //                                       ),
                            //                                       Text(
                            //                                         "Staff member name..*",
                            //                                         style: TextStyle(
                            //                                             color: Color(
                            //                                                 0xFF8A95A8),
                            //                                             fontWeight:
                            //                                             FontWeight
                            //                                                 .bold,
                            //                                             fontSize:
                            //                                             13),
                            //                                       ),
                            //                                     ],
                            //                                   ),
                            //                                   SizedBox(
                            //                                     height: 5,
                            //                                   ),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                           width:
                            //                                           15),
                            //                                       Material(
                            //                                         elevation:
                            //                                         4,
                            //                                         child:
                            //                                         Container(
                            //                                           height:
                            //                                           50,
                            //                                           width: MediaQuery.of(context)
                            //                                               .size
                            //                                               .width *
                            //                                               .54,
                            //                                           decoration:
                            //                                           BoxDecoration(
                            //                                             borderRadius:
                            //                                             BorderRadius.circular(2),
                            //                                             border:
                            //                                             Border.all(
                            //                                               color:
                            //                                               Color(0xFF8A95A8),
                            //                                             ),
                            //                                           ),
                            //                                           child:
                            //                                           Stack(
                            //                                             children: [
                            //                                               Positioned
                            //                                                   .fill(
                            //                                                 child:
                            //                                                 TextField(
                            //                                                   onChanged: (value) {
                            //                                                     setState(() {
                            //                                                       nameerror = false;
                            //                                                     });
                            //                                                   },
                            //                                                   controller: name,
                            //                                                   cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                                                   decoration: InputDecoration(
                            //                                                     hintText: "Enter a staff member name here..*",
                            //                                                     hintStyle: TextStyle(
                            //                                                       fontSize: 13,
                            //                                                       color: Color(0xFF8A95A8),
                            //                                                     ),
                            //                                                     enabledBorder: nameerror
                            //                                                         ? OutlineInputBorder(
                            //                                                       borderRadius: BorderRadius.circular(2),
                            //                                                       borderSide: BorderSide(
                            //                                                         color: Colors.red,
                            //                                                       ),
                            //                                                     )
                            //                                                         : InputBorder.none,
                            //                                                     border: InputBorder.none,
                            //                                                     contentPadding: EdgeInsets.all(12),
                            //                                                   ),
                            //                                                 ),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                         ),
                            //                                       ),
                            //                                       SizedBox(
                            //                                           width:
                            //                                           20),
                            //                                     ],
                            //                                   ),
                            //                                   nameerror
                            //                                       ? Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width:
                            //                                         117,
                            //                                       ),
                            //                                       Text(
                            //                                         namemessage,
                            //                                         style:
                            //                                         TextStyle(color: Colors.red),
                            //                                       ),
                            //                                     ],
                            //                                   )
                            //                                       : Container(),
                            //                                   SizedBox(
                            //                                     height: 10,
                            //                                   ),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width: 15,
                            //                                       ),
                            //                                       Text(
                            //                                         "Designation...*",
                            //                                         style: TextStyle(
                            //                                           // color: Colors.grey,
                            //                                             color: Color(0xFF8A95A8),
                            //                                             fontWeight: FontWeight.bold,
                            //                                             fontSize: 13),
                            //                                       ),
                            //                                     ],
                            //                                   ),
                            //                                   SizedBox(
                            //                                     height: 5,
                            //                                   ),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                           width:
                            //                                           15),
                            //                                       Material(
                            //                                         elevation:
                            //                                         4,
                            //                                         child:
                            //                                         Container(
                            //                                           height:
                            //                                           50,
                            //                                           width: MediaQuery.of(context)
                            //                                               .size
                            //                                               .width *
                            //                                               .54,
                            //                                           decoration:
                            //                                           BoxDecoration(
                            //                                             borderRadius:
                            //                                             BorderRadius.circular(2),
                            //                                             border:
                            //                                             Border.all(
                            //                                               color:
                            //                                               Color(0xFF8A95A8),
                            //                                             ),
                            //                                           ),
                            //                                           child:
                            //                                           Stack(
                            //                                             children: [
                            //                                               Positioned
                            //                                                   .fill(
                            //                                                 child:
                            //                                                 TextField(
                            //                                                   onChanged: (value) {
                            //                                                     setState(() {
                            //                                                       designationerror = false;
                            //                                                     });
                            //                                                   },
                            //                                                   controller: designation,
                            //                                                   cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                                                   decoration: InputDecoration(
                            //                                                     hintText: "Enter Designation here..*",
                            //                                                     hintStyle: TextStyle(
                            //                                                       fontSize: 13,
                            //                                                       color: Color(0xFF8A95A8),
                            //                                                     ),
                            //                                                     enabledBorder: designationerror
                            //                                                         ? OutlineInputBorder(
                            //                                                       borderRadius: BorderRadius.circular(2),
                            //                                                       borderSide: BorderSide(
                            //                                                         color: Colors.red,
                            //                                                       ),
                            //                                                     )
                            //                                                         : InputBorder.none,
                            //                                                     border: InputBorder.none,
                            //                                                     contentPadding: EdgeInsets.all(12),
                            //                                                   ),
                            //                                                 ),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                         ),
                            //                                       ),
                            //                                       SizedBox(
                            //                                           width:
                            //                                           20),
                            //                                     ],
                            //                                   ),
                            //                                   designationerror
                            //                                       ? Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width:
                            //                                         117,
                            //                                       ),
                            //                                       Text(
                            //                                         designationmessage,
                            //                                         style:
                            //                                         TextStyle(color: Colors.red),
                            //                                       ),
                            //                                     ],
                            //                                   )
                            //                                       : Container(),
                            //                                   SizedBox(
                            //                                     height: 10,
                            //                                   ),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width: 15,
                            //                                       ),
                            //                                       Text(
                            //                                         "Phone Number...",
                            //                                         style: TextStyle(
                            //                                           // color: Colors.grey,
                            //                                             color: Color(0xFF8A95A8),
                            //                                             fontWeight: FontWeight.bold,
                            //                                             fontSize: 13),
                            //                                       ),
                            //                                     ],
                            //                                   ),
                            //                                   SizedBox(
                            //                                     height: 5,
                            //                                   ),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                           width:
                            //                                           15),
                            //                                       Material(
                            //                                         elevation:
                            //                                         4,
                            //                                         child:
                            //                                         Container(
                            //                                           height:
                            //                                           50,
                            //                                           width: MediaQuery.of(context)
                            //                                               .size
                            //                                               .width *
                            //                                               .54,
                            //                                           decoration:
                            //                                           BoxDecoration(
                            //                                             borderRadius:
                            //                                             BorderRadius.circular(2),
                            //                                             border:
                            //                                             Border.all(
                            //                                               color:
                            //                                               Color(0xFF8A95A8),
                            //                                             ),
                            //                                           ),
                            //                                           child:
                            //                                           Stack(
                            //                                             children: [
                            //                                               Positioned
                            //                                                   .fill(
                            //                                                 child:
                            //                                                 TextField(
                            //                                                   onChanged: (value) {
                            //                                                     setState(() {
                            //                                                       phonenumbererror = false;
                            //                                                     });
                            //                                                   },
                            //                                                   controller: phonenumber,
                            //                                                   cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                                                   decoration: InputDecoration(
                            //                                                     hintText: "Enter Phone Number here..*",
                            //                                                     hintStyle: TextStyle(
                            //                                                       fontSize: 13,
                            //                                                       color: Color(0xFF8A95A8),
                            //                                                     ),
                            //                                                     enabledBorder: phonenumbererror
                            //                                                         ? OutlineInputBorder(
                            //                                                       borderRadius: BorderRadius.circular(2),
                            //                                                       borderSide: BorderSide(
                            //                                                         color: Colors.red,
                            //                                                       ),
                            //                                                     )
                            //                                                         : InputBorder.none,
                            //                                                     border: InputBorder.none,
                            //                                                     contentPadding: EdgeInsets.all(12),
                            //                                                   ),
                            //                                                 ),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                         ),
                            //                                       ),
                            //                                       SizedBox(
                            //                                           width:
                            //                                           20),
                            //                                     ],
                            //                                   ),
                            //                                   phonenumbererror
                            //                                       ? Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width:
                            //                                         117,
                            //                                       ),
                            //                                       Text(
                            //                                         phonenumbermessage,
                            //                                         style:
                            //                                         TextStyle(color: Colors.red),
                            //                                       ),
                            //                                     ],
                            //                                   )
                            //                                       : Container(),
                            //                                   SizedBox(
                            //                                     height: 10,
                            //                                   ),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width: 15,
                            //                                       ),
                            //                                       Text(
                            //                                         "Email...*",
                            //                                         style: TextStyle(
                            //                                           // color: Colors.grey,
                            //                                             color: Color(0xFF8A95A8),
                            //                                             fontWeight: FontWeight.bold,
                            //                                             fontSize: 13),
                            //                                       ),
                            //                                     ],
                            //                                   ),
                            //                                   SizedBox(
                            //                                     height: 5,
                            //                                   ),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                           width:
                            //                                           15),
                            //                                       Material(
                            //                                         elevation:
                            //                                         4,
                            //                                         child:
                            //                                         Container(
                            //                                           height:
                            //                                           50,
                            //                                           width: MediaQuery.of(context)
                            //                                               .size
                            //                                               .width *
                            //                                               .54,
                            //                                           decoration:
                            //                                           BoxDecoration(
                            //                                             borderRadius:
                            //                                             BorderRadius.circular(2),
                            //                                             border:
                            //                                             Border.all(
                            //                                               color:
                            //                                               Color(0xFF8A95A8),
                            //                                             ),
                            //                                           ),
                            //                                           child:
                            //                                           Stack(
                            //                                             children: [
                            //                                               Positioned
                            //                                                   .fill(
                            //                                                 child:
                            //                                                 TextField(
                            //                                                   onChanged: (value) {
                            //                                                     setState(() {
                            //                                                       emailerror = false;
                            //                                                     });
                            //                                                   },
                            //                                                   controller: email,
                            //                                                   cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                                                   decoration: InputDecoration(
                            //                                                     hintText: "Enter Email here..*",
                            //                                                     hintStyle: TextStyle(
                            //                                                       fontSize: 13,
                            //                                                       color: Color(0xFF8A95A8),
                            //                                                     ),
                            //                                                     enabledBorder: emailerror
                            //                                                         ? OutlineInputBorder(
                            //                                                       borderRadius: BorderRadius.circular(2),
                            //                                                       borderSide: BorderSide(
                            //                                                         color: Colors.red,
                            //                                                       ),
                            //                                                     )
                            //                                                         : InputBorder.none,
                            //                                                     border: InputBorder.none,
                            //                                                     contentPadding: EdgeInsets.all(12),
                            //                                                   ),
                            //                                                 ),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                         ),
                            //                                       ),
                            //                                       SizedBox(
                            //                                           width:
                            //                                           20),
                            //                                     ],
                            //                                   ),
                            //                                   emailerror
                            //                                       ? Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width:
                            //                                         117,
                            //                                       ),
                            //                                       Text(
                            //                                         emailmessage,
                            //                                         style:
                            //                                         TextStyle(color: Colors.red),
                            //                                       ),
                            //                                     ],
                            //                                   )
                            //                                       : Container(),
                            //                                   SizedBox(
                            //                                     height: 10,
                            //                                   ),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width: 15,
                            //                                       ),
                            //                                       Text(
                            //                                         "Password...*",
                            //                                         style: TextStyle(
                            //                                           // color: Colors.grey,
                            //                                             color: Color(0xFF8A95A8),
                            //                                             fontWeight: FontWeight.bold,
                            //                                             fontSize: 13),
                            //                                       ),
                            //                                     ],
                            //                                   ),
                            //                                   SizedBox(
                            //                                     height: 5,
                            //                                   ),
                            //                                   Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                           width:
                            //                                           15),
                            //                                       Material(
                            //                                         elevation:
                            //                                         4,
                            //                                         child:
                            //                                         Container(
                            //                                           height:
                            //                                           50,
                            //                                           width: MediaQuery.of(context)
                            //                                               .size
                            //                                               .width *
                            //                                               .54,
                            //                                           decoration:
                            //                                           BoxDecoration(
                            //                                             borderRadius:
                            //                                             BorderRadius.circular(2),
                            //                                             border:
                            //                                             Border.all(
                            //                                               color:
                            //                                               Color(0xFF8A95A8),
                            //                                             ),
                            //                                           ),
                            //                                           child:
                            //                                           Stack(
                            //                                             children: [
                            //                                               Positioned
                            //                                                   .fill(
                            //                                                 child:
                            //                                                 TextField(
                            //                                                   onChanged: (value) {
                            //                                                     setState(() {
                            //                                                       passworderror = false;
                            //                                                     });
                            //                                                   },
                            //                                                   controller: password,
                            //                                                   cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                                                   decoration: InputDecoration(
                            //                                                     hintText: "Enter Password here..*",
                            //                                                     hintStyle: TextStyle(
                            //                                                       fontSize: 13,
                            //                                                       color: Color(0xFF8A95A8),
                            //                                                     ),
                            //                                                     enabledBorder: passworderror
                            //                                                         ? OutlineInputBorder(
                            //                                                       borderRadius: BorderRadius.circular(2),
                            //                                                       borderSide: BorderSide(
                            //                                                         color: Colors.red,
                            //                                                       ),
                            //                                                     )
                            //                                                         : InputBorder.none,
                            //                                                     border: InputBorder.none,
                            //                                                     contentPadding: EdgeInsets.all(12),
                            //                                                   ),
                            //                                                 ),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                         ),
                            //                                       ),
                            //                                       SizedBox(
                            //                                           width:
                            //                                           20),
                            //                                     ],
                            //                                   ),
                            //                                   passworderror
                            //                                       ? Row(
                            //                                     children: [
                            //                                       SizedBox(
                            //                                         width:
                            //                                         117,
                            //                                       ),
                            //                                       Text(
                            //                                         passwordmessage,
                            //                                         style:
                            //                                         TextStyle(color: Colors.red),
                            //                                       ),
                            //                                     ],
                            //                                   )
                            //                                       : Container(),
                            //                                   SizedBox(
                            //                                     height: 20,
                            //                                   ),
                            //                                   GestureDetector(
                            //                                     onTap:
                            //                                         () async {
                            //                                       if (name.text
                            //                                           .isEmpty) {
                            //                                         setState(
                            //                                                 () {
                            //                                               nameerror =
                            //                                               true;
                            //                                               namemessage =
                            //                                               "name is required";
                            //                                             });
                            //                                       } else {
                            //                                         setState(
                            //                                                 () {
                            //                                               nameerror =
                            //                                               false;
                            //                                             });
                            //                                       }
                            //                                       if (designation
                            //                                           .text
                            //                                           .isEmpty) {
                            //                                         setState(
                            //                                                 () {
                            //                                               designationerror =
                            //                                               true;
                            //                                               designationmessage =
                            //                                               "designation is required";
                            //                                             });
                            //                                       } else {
                            //                                         setState(
                            //                                                 () {
                            //                                               designationerror =
                            //                                               false;
                            //                                             });
                            //                                       }
                            //                                       if (phonenumber
                            //                                           .text
                            //                                           .isEmpty) {
                            //                                         setState(
                            //                                                 () {
                            //                                               phonenumbererror =
                            //                                               true;
                            //                                               phonenumbermessage =
                            //                                               "number is required";
                            //                                             });
                            //                                       } else {
                            //                                         setState(
                            //                                                 () {
                            //                                               phonenumbererror =
                            //                                               false;
                            //                                             });
                            //                                       }
                            //                                       if (email.text
                            //                                           .isEmpty) {
                            //                                         setState(
                            //                                                 () {
                            //                                               emailerror =
                            //                                               true;
                            //                                               emailmessage =
                            //                                               "email is required";
                            //                                             });
                            //                                       } else {
                            //                                         setState(
                            //                                                 () {
                            //                                               emailerror =
                            //                                               false;
                            //                                             });
                            //                                       }
                            //                                       if (password
                            //                                           .text
                            //                                           .isEmpty) {
                            //                                         setState(
                            //                                                 () {
                            //                                               passworderror =
                            //                                               true;
                            //                                               passwordmessage =
                            //                                               "password is required";
                            //                                             });
                            //                                       } else {
                            //                                         setState(
                            //                                                 () {
                            //                                               passworderror =
                            //                                               false;
                            //                                             });
                            //                                       }
                            //                                       if (!nameerror &&
                            //                                           !designationerror &&
                            //                                           !phonenumbererror &&
                            //                                           !emailerror &&
                            //                                           !phonenumbererror) {
                            //                                         setState(
                            //                                                 () {
                            //                                               loading =
                            //                                               true;
                            //                                             });
                            //                                       }
                            //                                       SharedPreferences
                            //                                       prefs =
                            //                                       await SharedPreferences
                            //                                           .getInstance();
                            //                                       String?
                            //                                       adminId =
                            //                                       prefs.getString(
                            //                                           "adminId");
                            //                                       if (adminId !=
                            //                                           null) {
                            //                                         try {
                            //                                           await StaffMemberRepository()
                            //                                               .addStaffMember(
                            //                                             adminId:
                            //                                             adminId,
                            //                                             staffmemberName:
                            //                                             name.text,
                            //                                             staffmemberDesignation:
                            //                                             designation.text,
                            //                                             staffmemberPhoneNumber:
                            //                                             phonenumber.text,
                            //                                             staffmemberEmail:
                            //                                             email.text,
                            //                                             staffmemberPassword:
                            //                                             password.text,
                            //                                           );
                            //                                           setState(
                            //                                                   () {
                            //                                                 loading =
                            //                                                 false;
                            //                                               });
                            //                                           Navigator.of(
                            //                                               context)
                            //                                               .pop(
                            //                                               true);
                            //                                         } catch (e) {
                            //                                           setState(
                            //                                                   () {
                            //                                                 loading =
                            //                                                 false;
                            //                                               });
                            //                                           // Handle error
                            //                                         }
                            //                                       }
                            //                                     },
                            //                                     child: Row(
                            //                                       children: [
                            //                                         SizedBox(
                            //                                             width: MediaQuery.of(context).size.width *
                            //                                                 0.05),
                            //                                         ClipRRect(
                            //                                           borderRadius:
                            //                                           BorderRadius.circular(
                            //                                               5.0),
                            //                                           child:
                            //                                           Container(
                            //                                             height:
                            //                                             30.0,
                            //                                             width: MediaQuery.of(context).size.width *
                            //                                                 .36,
                            //                                             decoration:
                            //                                             BoxDecoration(
                            //                                               borderRadius:
                            //                                               BorderRadius.circular(5.0),
                            //                                               color: Color.fromRGBO(
                            //                                                   21,
                            //                                                   43,
                            //                                                   81,
                            //                                                   1),
                            //                                               boxShadow: [
                            //                                                 BoxShadow(
                            //                                                   color: Colors.grey,
                            //                                                   offset: Offset(0.0, 1.0), //(x,y)
                            //                                                   blurRadius: 6.0,
                            //                                                 ),
                            //                                               ],
                            //                                             ),
                            //                                             child:
                            //                                             Center(
                            //                                               child:
                            //                                               Text(
                            //                                                 "Add staff Member",
                            //                                                 style: TextStyle(
                            //                                                     color: Colors.white,
                            //                                                     fontWeight: FontWeight.bold,
                            //                                                     fontSize: 13),
                            //                                               ),
                            //                                             ),
                            //                                           ),
                            //                                         ),
                            //                                         SizedBox(
                            //                                           width: 15,
                            //                                         ),
                            //                                         Text(
                            //                                             "Cancel"),
                            //                                       ],
                            //                                     ),
                            //                                   ),
                            //                                 ],
                            //                               ),
                            //                             ),
                            //                           );
                            //                         },
                            //                       );
                            //                     },
                            //                   );
                            //                 },
                            //                 child: Row(
                            //                   children: [
                            //                     Icon(
                            //                       Icons.add,
                            //                       size: 16,
                            //                     ),
                            //                     SizedBox(width: 4),
                            //                     Text(
                            //                       'Add New Staffmember',
                            //                       style: TextStyle(
                            //                           fontSize:
                            //                           MediaQuery.of(context)
                            //                               .size
                            //                               .width *
                            //                               .027),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ),
                            //             ),
                            //           );
                            //           if (selectedStaff == null && staffMembers.isNotEmpty) {
                            //             selectedStaff = widget.properties.staffMemberData!.staffmemberName;
                            //           }
                            //           return Padding(
                            //             padding: const EdgeInsets.all(10.0),
                            //             child: Container(
                            //               height: MediaQuery.of(context)
                            //                   .size
                            //                   .height *
                            //                   .05,
                            //               width: MediaQuery.of(context)
                            //                   .size
                            //                   .width *
                            //                   .36,
                            //               padding: EdgeInsets.symmetric(
                            //                   horizontal: 8, vertical: 4),
                            //               decoration: BoxDecoration(
                            //                 border: Border.all(
                            //                   color: Color(0xFF8A95A8),
                            //                 ),
                            //                 borderRadius:
                            //                 BorderRadius.circular(5),
                            //               ),
                            //               child: DropdownButtonHideUnderline(
                            //                 child: DropdownButton<String>(
                            //                   value: selectedStaff,
                            //                   hint: Text(
                            //                     'Select',
                            //                     style: TextStyle(
                            //                       fontSize:
                            //                       MediaQuery.of(context)
                            //                           .size
                            //                           .width *
                            //                           .04,
                            //                       color: Color(0xFF8A95A8),
                            //                     ),
                            //                   ),
                            //                   onChanged: (String? newValue) {
                            //                     if (newValue ==
                            //                         'add_new_property') {
                            //                       // Prevent the dropdown from changing the selected item
                            //                       setState(() {
                            //                         selectedStaff = null;
                            //                       });
                            //                       // Show the dialog
                            //                       showDialog(
                            //                         context: context,
                            //                         builder:
                            //                             (BuildContext context) {
                            //                           //  bool isChecked = false; // Moved isChecked inside the StatefulBuilder
                            //                           return StatefulBuilder(
                            //                             builder: (BuildContext
                            //                             context,
                            //                                 StateSetter
                            //                                 setState) {
                            //                               return AlertDialog(
                            //                                 backgroundColor:
                            //                                 Colors.white,
                            //                                 surfaceTintColor:
                            //                                 Colors.white,
                            //                                 title: Text(
                            //                                   "Add Rental Owner",
                            //                                   style: TextStyle(
                            //                                       fontWeight:
                            //                                       FontWeight
                            //                                           .bold,
                            //                                       color: Color
                            //                                           .fromRGBO(
                            //                                           21,
                            //                                           43,
                            //                                           81,
                            //                                           1),
                            //                                       fontSize: 15),
                            //                                 ),
                            //                                 content:
                            //                                 SingleChildScrollView(
                            //                                     child:
                            //                                     Column(
                            //                                       children: [],
                            //                                     )),
                            //                               );
                            //                             },
                            //                           );
                            //                         },
                            //                       );
                            //                     } else {
                            //                       setState(() {
                            //                         selectedStaff = newValue;
                            //                       });
                            //                     }
                            //                   },
                            //                   items: dropdownItems,
                            //                   isExpanded: true,
                            //                 ),
                            //               ),
                            //             ),
                            //           );
                            //         }
                            //       },
                            //     ),
                            //   ],
                            // ),
                          ],
                        )),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (selectedpropertytypedata != null &&
                    selectedpropertytypedata!.propertyType == "Residential")
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                        Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'RECIDENTIAL UNIT',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Enter Recidential Units',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            // Column(
                            //   children: [
                            //     Row(
                            //       children: [
                            //         Spacer(),
                            //         IconButton(
                            //           icon: Icon(Icons.close),
                            //           onPressed: () {
                            //             setState(() {});
                            //           },
                            //         ),
                            //         SizedBox(
                            //           width: 10,
                            //         ),
                            //       ],
                            //     ),
                            //     SizedBox(height: 5.0),
                            //     Row(
                            //       children: [
                            //         SizedBox(
                            //           width: 10,
                            //         ),
                            //         Expanded(
                            //           child: Container(
                            //             height: 45,
                            //             child: TextFormField(
                            //               decoration: InputDecoration(
                            //                 labelText: 'SQFT *',
                            //                 border: OutlineInputBorder(),
                            //               ),
                            //               validator: (value) {
                            //                 if (value == null ||
                            //                     value.isEmpty) {
                            //                   return 'Please enter the square footage';
                            //                 }
                            //                 return null;
                            //               },
                            //             ),
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           width: 10,
                            //         ),
                            //       ],
                            //     ),
                            //     SizedBox(height: 16.0),
                            //     Row(
                            //       children: [
                            //         SizedBox(
                            //           width: 10,
                            //         ),
                            //         Expanded(
                            //           child: Container(
                            //             height: 45,
                            //             child: TextFormField(
                            //               decoration: InputDecoration(
                            //                 labelText: 'Bath',
                            //                 border: OutlineInputBorder(),
                            //               ),
                            //               validator: (value) {
                            //                 if (value == null ||
                            //                     value.isEmpty) {
                            //                   return 'Please enter the unit address';
                            //                 }
                            //                 return null;
                            //               },
                            //             ),
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           width: 10,
                            //         ),
                            //       ],
                            //     ),
                            //     SizedBox(height: 16.0),
                            //     Row(
                            //       children: [
                            //         SizedBox(
                            //           width: 10,
                            //         ),
                            //         Expanded(
                            //           child: Container(
                            //             height: 45,
                            //             child: TextFormField(
                            //               decoration: InputDecoration(
                            //                 labelText: 'Bed',
                            //                 border: OutlineInputBorder(),
                            //               ),
                            //               validator: (value) {
                            //                 if (value == null ||
                            //                     value.isEmpty) {
                            //                   return 'Please enter the square footage';
                            //                 }
                            //                 return null;
                            //               },
                            //             ),
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           width: 10,
                            //         ),
                            //       ],
                            //     ),
                            //     if (propertyGroups.isNotEmpty)
                            //       Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //           SingleChildScrollView(
                            //             child: Column(
                            //               children: propertyGroups.map((group) {
                            //                 int index = propertyGroups.indexOf(group);
                            //                 return Padding(
                            //                   padding: const EdgeInsets.all(16.0),
                            //                   child: Column(
                            //                     crossAxisAlignment: CrossAxisAlignment.start,
                            //                     children: [
                            //                       Align(
                            //                         alignment: Alignment.centerRight,
                            //                         child: InkWell(
                            //                           onTap: () => removePropertyGroup(index),
                            //                           child: Icon(Icons.close, color: Colors.black),
                            //                         ),
                            //                       ),
                            //                       SizedBox(height: 5),
                            //                       ...group,
                            //                     ],
                            //                   ),
                            //                 );
                            //               }).toList(),
                            //             ),
                            //           ),
                            //           SizedBox(height: 10),
                            //           Align(
                            //             alignment: Alignment.centerRight,
                            //             child: ElevatedButton(
                            //               onPressed: addPropertyGroup,
                            //               child: Text('Add More'),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //
                            //
                            //   ],
                            // ),
                            if (propertyGroups.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SingleChildScrollView(
                                    child:
                                    Column(
                                      children: propertyGroups.map((group) {
                                        int index =
                                        propertyGroups.indexOf(group);
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 16,right: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment:
                                                Alignment.centerRight,
                                                child: InkWell(
                                                  onTap: () =>
                                                      removePropertyGroup(
                                                          index),
                                                  child: Icon(Icons.close,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              ...group,
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            // SizedBox(height: 16.0),
                            // if (selectedpropertytypedata != null &&
                            //     selectedpropertytypedata!.propertyType ==
                            //         "Residential" &&
                            //     selectedpropertytypedata!.isMultiunit == true)
                            //   if (propertyGroups.isNotEmpty)
                            //     Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         SingleChildScrollView(
                            //           child: Column(
                            //             children: propertyGroups.map((group) {
                            //               int index = propertyGroups.indexOf(group);
                            //               return Padding(
                            //                 padding: const EdgeInsets.all(16.0),
                            //                 child: Column(
                            //                   crossAxisAlignment: CrossAxisAlignment.start,
                            //                   children: [
                            //                     Align(
                            //                       alignment: Alignment.centerRight,
                            //                       child: InkWell(
                            //                         onTap: () => removePropertyGroup(index),
                            //                         child: Icon(Icons.close, color: Colors.black),
                            //                       ),
                            //                     ),
                            //                     SizedBox(height: 5),
                            //                     ...group,
                            //                   ],
                            //                 ),
                            //               );
                            //             }).toList(),
                            //           ),
                            //         ),
                            //         SizedBox(height: 10),
                            //         Align(
                            //           alignment: Alignment.centerRight,
                            //           child: ElevatedButton(
                            //             onPressed: addPropertyGroup,
                            //             child: Text('Add More'),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            // Column(
                            //   children: [
                            //     Row(
                            //       children: [
                            //         SizedBox(
                            //           width: 10,
                            //         ),
                            //         IconButton(
                            //           icon: Icon(Icons.close),
                            //           onPressed: () {
                            //             // setState(() {
                            //             //   units.removeAt(index);
                            //             // });
                            //           },
                            //         ),
                            //       ],
                            //     ),
                            //     SizedBox(height: 10.0),
                            //     Row(
                            //       children: [
                            //         Expanded(
                            //           child: Container(
                            //             child: TextFormField(
                            //               decoration: InputDecoration(
                            //                 labelText: 'Unit *',
                            //                 border: OutlineInputBorder(),
                            //               ),
                            //               validator: (value) {
                            //                 if (value == null ||
                            //                     value.isEmpty) {
                            //                   return 'Please enter the unit';
                            //                 }
                            //                 return null;
                            //               },
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //     SizedBox(height: 16.0),
                            //     Row(
                            //       children: [
                            //         Expanded(
                            //           child: Container(
                            //             child: TextFormField(
                            //               decoration: InputDecoration(
                            //                 labelText: 'Unit Address',
                            //                 border: OutlineInputBorder(),
                            //               ),
                            //               validator: (value) {
                            //                 if (value == null ||
                            //                     value.isEmpty) {
                            //                   return 'Please enter the unit address';
                            //                 }
                            //                 return null;
                            //               },
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ],
                            // ),
                            // Row(
                            //   children: [
                            //     SizedBox(
                            //       width: 10,
                            //     ),
                            //     Column(
                            //       children: [
                            //         Text(
                            //           'Photo',
                            //           style: TextStyle(color: Colors.black),
                            //         ),
                            //         SizedBox(height: 8.0),
                            //         GestureDetector(
                            //           onTap: () {
                            //             // Add photo action
                            //           },
                            //           child: Text(
                            //             '+ Add',
                            //             style: TextStyle(color: Colors.green),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ],
                            // ),
                            GestureDetector(
                              onTap: () {
                                // if (selectedProperty != null) {
                                //   addPropertyGroup();
                                // }
                                addPropertyGroup();
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.02),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    //  border: Border.all(color:  Color.fromRGBO(21, 43, 81, 1)),
                                    child: Container(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width *
                                          .3,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        // borderRadius: BorderRadius.circular(3),
                                        borderRadius:
                                        BorderRadius.circular(5.0),
                                        border: Border.all(
                                            color:
                                            Color.fromRGBO(21, 43, 81, 1)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Add another unit",
                                          style: TextStyle(
                                              color:
                                              Color.fromRGBO(21, 43, 81, 1),
                                              // fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (selectedpropertytypedata != null &&
                    selectedpropertytypedata!.propertyType == "Commercial")
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                        Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'COMMERCIAL UNIT',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Enter Commercial Units',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              //SizedBox(height: 16.0),
                              // Column(
                              //   children: [
                              //     Row(
                              //       children: [
                              //         Spacer(),
                              //         IconButton(
                              //           icon: Icon(Icons.close),
                              //           onPressed: () {
                              //             // setState(() {
                              //             //   units.removeAt(index);
                              //             // });
                              //           },
                              //         ),
                              //         SizedBox(
                              //           width: 10,
                              //         ),
                              //       ],
                              //     ),
                              //     Row(
                              //       children: [
                              //         SizedBox(
                              //           width: 10,
                              //         ),
                              //         Expanded(
                              //           child: TextFormField(
                              //             decoration: InputDecoration(
                              //               labelText: 'SQft *',
                              //               border: OutlineInputBorder(),
                              //             ),
                              //             validator: (value) {
                              //               if (value == null ||
                              //                   value.isEmpty) {
                              //                 return 'Please enter the unit';
                              //               }
                              //               return null;
                              //             },
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           width: 10,
                              //         ),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              //SizedBox(height: 16.0),
                              //  if (selectedIsMultiUnit?.isMultiunit == true)
                              //   Visibility(
                              //     visible: selectedIsMultiUnit == true,
                              //     child: Row(
                              //       children: [
                              //         Expanded(
                              //           child: TextFormField(
                              //             decoration: InputDecoration(
                              //               labelText: 'Unit Address',
                              //               border: OutlineInputBorder(),
                              //             ),
                              //             validator: (value) {
                              //               if (value == null || value.isEmpty) {
                              //                 return 'Please enter the unit address';
                              //               }
                              //               return null;
                              //             },
                              //           ),
                              //         ),
                              //         SizedBox(width: 16.0),
                              //         Expanded(
                              //           child: TextFormField(
                              //             decoration: InputDecoration(
                              //               labelText: 'SQFT *',
                              //               border: OutlineInputBorder(),
                              //             ),
                              //             validator: (value) {
                              //               if (value == null || value.isEmpty) {
                              //                 return 'Please enter the square footage';
                              //               }
                              //               return null;
                              //             },
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              if (propertyGroups.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SingleChildScrollView(
                                      child: Column(
                                        children: propertyGroups.map((group) {
                                          int index =
                                          propertyGroups.indexOf(group);
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 16,right: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Align(
                                                  alignment:
                                                  Alignment.centerRight,
                                                  child: InkWell(
                                                    onTap: () =>
                                                        removePropertyGroup(
                                                            index),
                                                    child: Icon(Icons.close,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                ...group,
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              // if (selectedpropertytypedata != null &&
                              //     selectedpropertytypedata!.propertyType ==
                              //         "Commercial" &&
                              //     selectedpropertytypedata!.isMultiunit == true)
                              //   if (propertyGroups.isNotEmpty)
                              //     Column(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       children: [
                              //         SingleChildScrollView(
                              //           child: Column(
                              //             children: propertyGroups.map((group) {
                              //               int index = propertyGroups.indexOf(group);
                              //               return Padding(
                              //                 padding: const EdgeInsets.all(16.0),
                              //                 child: Column(
                              //                   crossAxisAlignment: CrossAxisAlignment.start,
                              //                   children: [
                              //                     Align(
                              //                       alignment: Alignment.centerRight,
                              //                       child: InkWell(
                              //                         onTap: () => removePropertyGroup(index),
                              //                         child: Icon(Icons.close, color: Colors.black),
                              //                       ),
                              //                     ),
                              //                     SizedBox(height: 5),
                              //                     ...group,
                              //                   ],
                              //                 ),
                              //               );
                              //             }).toList(),
                              //           ),
                              //         ),
                              //         SizedBox(height: 10),
                              //         Align(
                              //           alignment: Alignment.centerRight,
                              //           child: ElevatedButton(
                              //             onPressed: addPropertyGroup,
                              //             child: Text('Add More'),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              // Column(
                              //   children: [
                              //     SizedBox(height: 10.0),
                              //     Row(
                              //       children: [
                              //         SizedBox(
                              //           width: 10,
                              //         ),
                              //         Expanded(
                              //           child: TextFormField(
                              //             decoration: InputDecoration(
                              //               labelText: 'Unit *',
                              //               border: OutlineInputBorder(),
                              //             ),
                              //             validator: (value) {
                              //               if (value == null ||
                              //                   value.isEmpty) {
                              //                 return 'Please enter the unit';
                              //               }
                              //               return null;
                              //             },
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           width: 10,
                              //         ),
                              //       ],
                              //     ),
                              //     SizedBox(height: 16.0),
                              //     Row(
                              //       children: [
                              //         SizedBox(
                              //           width: 10,
                              //         ),
                              //         Expanded(
                              //           child: TextFormField(
                              //             decoration: InputDecoration(
                              //               labelText: 'Unit Address',
                              //               border: OutlineInputBorder(),
                              //             ),
                              //             validator: (value) {
                              //               if (value == null ||
                              //                   value.isEmpty) {
                              //                 return 'Please enter the unit address';
                              //               }
                              //               return null;
                              //             },
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           width: 10,
                              //         ),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              /*  Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Unit Address',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the unit address';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'SQFT *',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the square footage';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),*/
                              // SizedBox(height: 20),
                              // Row(
                              //   children: [
                              //     SizedBox(
                              //       width: 10,
                              //     ),
                              //     Column(
                              //       children: [
                              //         Text(
                              //           'Photo',
                              //           style: TextStyle(color: Colors.black),
                              //         ),
                              //         SizedBox(height: 8.0),
                              //         GestureDetector(
                              //           onTap: () {
                              //             // Add photo action
                              //           },
                              //           child: Text(
                              //             '+ Add',
                              //             style: TextStyle(color: Colors.green),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  addPropertyGroup();
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.01),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      //  border: Border.all(color:  Color.fromRGBO(21, 43, 81, 1)),
                                      child: Container(
                                        height: 30,
                                        width:
                                        MediaQuery.of(context).size.width *
                                            .3,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          // borderRadius: BorderRadius.circular(3),
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          border: Border.all(
                                              color: Color.fromRGBO(
                                                  21, 43, 81, 1)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Add another unit",
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                // fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                if (iserror2)
                  Text(
                    "required",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                SizedBox(height: 10),
                // GestureDetector(
                //   onTap: () async {
                //     if (selectedProperty == null) {
                //       setState(() {
                //         propertyTypeError = true;
                //         propertyTypeErrorMessage = "required";
                //       });
                //     } else {
                //       setState(() {
                //         propertyTypeError = false;
                //       });
                //     }
                //     if (address.text.isEmpty) {
                //       setState(() {
                //         addresserror = true;
                //         addressmessage = "required";
                //       });
                //     } else {
                //       setState(() {
                //         addresserror = false;
                //       });
                //     }
                //     if (city.text.isEmpty) {
                //       setState(() {
                //         cityerror = true;
                //         citymessage = "required";
                //       });
                //     } else {
                //       setState(() {
                //         cityerror = false;
                //       });
                //     }
                //     if (state.text.isEmpty) {
                //       setState(() {
                //         stateerror = true;
                //         statemessage = "required";
                //       });
                //     } else {
                //       setState(() {
                //         stateerror = false;
                //       });
                //     }
                //     if (country.text.isEmpty) {
                //       setState(() {
                //         countryerror = true;
                //         countrymessage = "required";
                //       });
                //     } else {
                //       setState(() {
                //         countryerror = false;
                //       });
                //     }
                //     if (postalcode.text.isEmpty) {
                //       setState(() {
                //         postalcodeerror = true;
                //         postalcodemessage = "required";
                //       });
                //     } else {
                //       setState(() {
                //         postalcodeerror = false;
                //       });
                //     }
                //     if (addresserror &&
                //         cityerror &&
                //         stateerror &&
                //         countryerror &&
                //         postalcodeerror) {
                //       setState(() {
                //         loading = true;
                //       });
                //     }
                //
                //     SharedPreferences prefs =
                //         await SharedPreferences.getInstance();
                //
                //     String? id = prefs.getString("adminId");
                //     Rental_PropertiesRepository()
                //         .addProperties(
                //       adminId: id!,
                //       property_id: widget.property?.propertyId,
                //       rental_adress: address.text,
                //       rental_city: city.text,
                //       rental_state: state.text,
                //       rental_country: country.text,
                //       rental_postcode: postalcode.text,
                //       staffmember_id: widget.staff!.staffmemberId,
                //       processor_id: proid.text,
                //     )
                //         .then((value) {
                //       setState(() {
                //         isLoading = false;
                //       });
                //       Navigator.of(context).pop(true);
                //     }).catchError((e) {
                //       setState(() {
                //         isLoading = false;
                //       });
                //     });
                //   },
                //   child: Row(
                //     children: [
                //       SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                //       ClipRRect(
                //         borderRadius: BorderRadius.circular(5.0),
                //         child: Container(
                //           height: 30,
                //           width: MediaQuery.of(context).size.width * .3,
                //           decoration: BoxDecoration(
                //             // borderRadius: BorderRadius.circular(3),
                //             color: Color.fromRGBO(21, 43, 81, 1),
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Colors.grey,
                //                 offset: Offset(0.0, 1.0), //(x,y)
                //                 blurRadius: 6.0,
                //               ),
                //             ],
                //           ),
                //           child: Center(
                //             child: Text(
                //               "Create Property",
                //               style: TextStyle(
                //                   color: Colors.white,
                //                   // fontWeight: FontWeight.bold,
                //                   fontSize: 10),
                //             ),
                //           ),
                //         ),
                //       ),
                //       SizedBox(
                //         width: 15,
                //       ),
                //       Text("Cancel"),
                //     ],
                //   ),
                // ),
                //create property
                Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                    GestureDetector(
                      onTap: () async {
                        if (address.text.isEmpty) {
                            setState(() {
                              addresserror = true;
                              addressmessage = "required";

                            });
                          } else {
                            setState(() {
                              addresserror = false;
                            });
                          }
                          if (city.text.isEmpty) {
                            setState(() {
                              cityerror = true;
                              citymessage = "required";
                            });
                          } else {
                            setState(() {
                              cityerror = false;
                            });
                          }
                          if (state.text.isEmpty) {
                            setState(() {
                              stateerror = true;
                              statemessage = "required";

                            });
                          } else {
                            setState(() {
                              stateerror = false;
                            });
                          }
                          if (country.text.isEmpty) {
                            setState(() {
                              countryerror = true;
                              countrymessage = "required";

                            });
                          } else {
                            setState(() {
                              countryerror = false;
                            });
                          }
                          if (postalcode.text.isEmpty) {
                            setState(() {
                              postalcodeerror = true;
                              postalcodemessage = "required";

                            });
                          } else {
                            setState(() {
                              postalcodeerror = false;
                            });
                          }
                          if (Ownersdetails == null) {
                            setState(() {
                              hasError = true;
                              postalcodemessage = "required";
                            });
                          } else {
                            setState(() {
                              hasError = false;
                            });
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            String? id = prefs.getString("adminId");
                          PropertiesRepository().updateRental(widget.properties).then((value) {
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.of(context).pop(true);
                          }).catchError((e) {
                            setState(() {
                              isLoading = false;
                            });
                          });
                        }
                        print(selectedValue);
                      },
//                       onTap: () async {
//                         // if (unit.text.isEmpty || unitaddress.text.isEmpty || bath.text.isEmpty || bed.text.isEmpty || sqft.text.isEmpty) {
//                         //   iserror2 = true;
//                         //
//                         // } else {
//                         //   iserror2 = false;
//                         // }
//                         if (address.text.isEmpty) {
//                           setState(() {
//                             addresserror = true;
//                             addressmessage = "required";
//
//                           });
//                         } else {
//                           setState(() {
//                             addresserror = false;
//                           });
//                         }
//                         if (city.text.isEmpty) {
//                           setState(() {
//                             cityerror = true;
//                             citymessage = "required";
//                           });
//                         } else {
//                           setState(() {
//                             cityerror = false;
//                           });
//                         }
//                         if (state.text.isEmpty) {
//                           setState(() {
//                             stateerror = true;
//                             statemessage = "required";
//
//                           });
//                         } else {
//                           setState(() {
//                             stateerror = false;
//                           });
//                         }
//                         if (country.text.isEmpty) {
//                           setState(() {
//                             countryerror = true;
//                             countrymessage = "required";
//
//                           });
//                         } else {
//                           setState(() {
//                             countryerror = false;
//                           });
//                         }
//                         if (postalcode.text.isEmpty) {
//                           setState(() {
//                             postalcodeerror = true;
//                             postalcodemessage = "required";
//
//                           });
//                         } else {
//                           setState(() {
//                             postalcodeerror = false;
//                           });
//                         }
//                         if (Ownersdetails == null) {
//                           setState(() {
//                             hasError = true;
//                             postalcodemessage = "required";
//                           });
//                         } else {
//                           setState(() {
//                             hasError = false;
//                           });
//                         }
//                         if (!addresserror &&
//                             !cityerror &&
//                             !stateerror &&
//                             !countryerror &&
//                             !postalcodeerror
//                         ) {
//                           setState(() {
//                             loading = true;
//                           });
//                         }
//                         SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                         String? adminId = prefs.getString("adminId");
//                         if (adminId != null) {
//                           //  try {
//                           RentalOwners owners =  RentalOwners(
//                             firstName: firstname.text,
//                             lastName: lastname.text,
//                             companyName: comname.text,
//                             primaryEmail: primaryemail.text,
//                             phoneNumber: phonenum.text,
//                             city:city2.text,
//                             state:state2.text,
//                             country:county2.text,
//                             postalCode:code2.text,
//                           );
//                           Rental rentals = Rental(
//                             adminId: adminId,
//                             propertyId: selectedpropertytypedata!.propertyId,
//                             address: address.text,
//                             city: city.text,
//                             state: state.text,
//                             country: country.text,
//                             postcode: postalcode.text,
//                             staffMemberId: sid,
//                           );
//                           List<Unit> units = [];
//                           if (propertyGroupControllers.isNotEmpty) {
//                             List<TextEditingController> firstControllers = propertyGroupControllers[0];
//                             bool isFirstBlank = firstControllers.every((controller) => controller.text.isEmpty);
//
//                             if (isFirstBlank) {
//                               propertyGroupControllers.removeAt(0);
//                             }
//                           }
//                           if (selectedpropertytype == 'Commercial' && selectedIsMultiUnit == true) {
//                             for (int i = 0; i <
//                                 propertyGroupControllers.length; i++) {
//                               if (units.length <= i) {
//                                 units.add(Unit());
//                               }
//                               List<
//                                   TextEditingController> controllers = propertyGroupControllers[i];
//                               units[i].unit = controllers[0].text;
//                               units[i].address = controllers[1].text;
//                               units[i].sqft = controllers[2].text;
//                               units[i].Image = propertyGroupImagenames[i];
//                               //      units[i].bath = controllers[3].text;
//                               //     units[i].bed = controllers[4].text;
//
// //                                  units[i].unit = controllers[0].text;
//
//                             }
//                           }
//                           else if (selectedpropertytype == 'Residential' &&
//                               selectedIsMultiUnit == true) {
//                             for (int i = 0; i <
//                                 propertyGroupControllers.length; i++) {
//                               if (units.length <= i) {
//                                 units.add(Unit());
//                               }
//                               List<
//                                   TextEditingController> controllers = propertyGroupControllers[i];
//                               units[i].unit = controllers[0].text;
//                               units[i].address = controllers[1].text;
//                               units[i].sqft = controllers[2].text;
//                               units[i].bath = controllers[3].text;
//                               units[i].bed = controllers[4].text;
//                               units[i].Image = propertyGroupImagenames[i];
// //                                  units[i].unit = controllers[0].text;
//
//                             }
//                           }
//                           else if (selectedpropertytype == 'Residential') {
//
//                             for (int i = 0; i <
//                                 propertyGroupControllers.length; i++) {
//                               if (units.length <= i) {
//                                 units.add(Unit());
//                               }
//                               List<
//                                   TextEditingController> controllers = propertyGroupControllers[i];
//                               print(controllers.length);
//                               units[i].sqft= controllers[0].text;
//                               units[i].bath = controllers[1].text;
//                               units[i].bed = controllers[2].text;
//                               units[i].Image = propertyGroupImagenames[i];
// //                                  units[i].unit = controllers[0].text;
//
//                             }
//                           }
//                           else if (selectedpropertytype == 'Commercial') {
//
//                             for (int i = 0; i <
//                                 propertyGroupControllers.length; i++) {
//                               if (units.length <= i) {
//                                 units.add(Unit());
//                               }
//                               List<
//                                   TextEditingController> controllers = propertyGroupControllers[i];
//                               units[i].sqft = controllers[0].text;
//                               units[i].Image = propertyGroupImagenames[i];
//                               //units[i].address = controllers[1].text;
//                               //units[i].sqft = controllers[2].text;
// //                                  units[i].unit = controllers[0].text;
//
//                             }
//                           }
//                           print(units.first.Image);
//
//                           RentalRequest rentalrequest = RentalRequest(
//                               rentalOwner: owners,
//                               rental: rentals,
//                               units: units
//                           );
//                           Rental_PropertiesRepository().createRental(rentalrequest);
//
//                           // await  Rental_PropertiesRepository().addProperties(
//                           //   adminId: adminId!,
//                           //   property_id: widget.property?.propertyId,
//                           //   rental_adress: address.text,
//                           //   rental_city: city.text,
//                           //   rental_state: state.text,
//                           //   rental_country: country.text,
//                           //   rental_postcode: postalcode.text,
//                           //   staffmember_id: widget.staff!.staffmemberId,
//                           //   processor_id: proid.text,
//                           // );
//                           setState(() {
//                             loading = false;
//                           });
//                           // Navigator.of(context).pop(true);
//                           //  } catch (e) {
//                           //   print(e);
//
//
//                         }
//                       },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width * .3,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Center(
                            child:
                            loading
                                ? SpinKitFadingCircle(
                              color: Colors.white,
                              size: 25.0,
                            ) :Text(
                              "Create Property",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    InkWell(
                        onTap: () {
                          // displayPropertyData();
                          Navigator.pop(context);
                        },
                        child: Text("Cancel")),
                  ],
                ),
                Column(
                  children: [
                    //SetshowRentalOwnerTable(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> checkIfRentalOwnerExists() async {
  //
  //     await Rental_PropertiesRepository().checkIfRentalOwnerExists(
  //       rentalowner_id: rentalOwnerId!.rentalOwnerId,
  //       rentalOwner_firstName: firstname.text,
  //       rentalOwner_lastName: lastname.text,
  //       rentalOwner_companyName: comname.text,
  //       rentalOwner_primaryEmail: primaryemail.text,
  //       rentalOwner_alternativeEmail: alternativeemail.text,
  //       rentalOwner_phoneNumber: phonenum.text,
  //       rentalOwner_homeNumber: homenum.text,
  //       rentalOwner_businessNumber: businessnum.text,
  //     )
  //         .then((value) {
  //   setState(() {
  //   isLoading = false;
  //   });
  //   Navigator.pop(context,true);
  //   }).catchError((e) {
  //   setState(() {
  //   isLoading = false;
  //   });
  //   });
  // }

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
              activeColor: Color.fromRGBO(21, 43, 81, 1),
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
                  border: Border.all(color: Color(0xFF8A95A8)),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: TextField(
                        controller: group.controller,
                        cursorColor: Color.fromRGBO(21, 43, 81, 1),
                        decoration: InputDecoration(
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
              child: FaIcon(
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

  SetshowRentalOwnerTable(){

    Row(
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
            Row(
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
            SizedBox(height: 5),
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
                                activeColor: Color.fromRGBO(21, 43, 81, 1),
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
                                    border:
                                    Border.all(color: Color(0xFF8A95A8)),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: TextField(
                                          controller: group.controller,
                                          cursorColor:
                                          Color.fromRGBO(21, 43, 81, 1),
                                          decoration: InputDecoration(
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
                                child: FaIcon(
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
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addNewGroup,
                  child: Text("Add Processor Group"),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
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
      rentalOwnerId: json['rentalowner_id']??"",
      adminId: json['admin_id']??"",
      firstName: json['rentalOwner_firstName']??"",
      lastName: json['rentalOwner_lastName']??"",
      companyName: json['rentalOwner_companyName']??"",
      primaryEmail: json['rentalOwner_primaryEmail']??"",
      alternateEmail: json['rentalOwner_alternateEmail']??"",
      phoneNumber: json['rentalOwner_phoneNumber']??"",
      homeNumber: json['rentalOwner_homeNumber']??"", // Nullable field
      businessNumber: json['rentalOwner_businessNumber']??"", // Nullable field
      birthDate: json['birth_date']??"",
      startDate: json['start_date']??"",
      endDate: json['end_date']??"",
      taxpayerId: json['texpayer_id']??"",
      identityType: json['text_identityType']??"",
      streetAddress: json['street_address']??"",
      city: json['city']??"",
      state: json['state']??"",
      country: json['country']??"",
      postalCode: json['postal_code']??"",
      createdAt: json['createdAt']??"",
      updatedAt: json['updatedAt']??"",
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
class OwnersDetails{
  RentalOwner? Ownersdetails;
  OwnersDetails({required this.Ownersdetails,});

}

class RentalOwnerSource extends DataTableSource {
  final List<RentalOwner> rentalowner;
  final Function(RentalOwner) onEdit;
  final Function(RentalOwner) onDelete;

  RentalOwnerSource(this.rentalowner, {required this.onEdit, required this.onDelete});

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
              child: FaIcon(
                FontAwesomeIcons.edit,
                size: 20,
              ),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          InkWell(
            onTap: () {
              onDelete(rental);
            },
            child: Container(
              //    color: Colors.redAccent,
              padding: EdgeInsets.zero,
              child: FaIcon(
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
