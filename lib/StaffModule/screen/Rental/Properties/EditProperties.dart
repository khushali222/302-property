import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_item.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/StaffModule/repository/Staffmember.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Properties/Edit_Rentalowners.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Properties/add_rentalowners.dart';
import 'package:three_zero_two_property/model/staffmember.dart';

import 'package:three_zero_two_property/repository/rental_properties.dart';

import '../../../../Model/propertytype.dart';
import '../../../../constant/constant.dart';
import '../../../../model/add_property.dart';
import '../../../../model/properties.dart';
import '../../../../model/rental_properties.dart';
import '../../../../provider/add_property.dart';
import '../../../repository/Property_type.dart';
import '../../../repository/properties.dart';
import '../../../repository/properties_summery.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../../widgets/rental_widget.dart';
import 'package:http/http.dart' as http;
import '../../../../model/unitsummery_propeties.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/appbar.dart';

class Edit_properties extends StatefulWidget {
  propertytype? property;
  Staffmembers? staff;
  Rentals properties;
  RentalRequest? propties;
  final String rentalId;

  Edit_properties({
    super.key,
    this.property,
    this.staff,
    required this.properties,
    required this.rentalId,
  });

  @override
  State<Edit_properties> createState() => _Edit_propertiesState();
}

class _Edit_propertiesState extends State<Edit_properties> {
  List<String> months = ['Residential', "Commercial"];
  List<Widget> fields = [];
  int? selectedIndex;
  List<ProcessorGroup> _processorGroups = [];

  final List<String> items = [
    'Residential',
    "Commercial",
  ];
  String? selectedStaff;

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
  bool showError = false;
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

    // Sort the values (property lists) for each property type and subtype
    groupedProperties.forEach((key, value) {
      value.sort((a, b) => (a.propertysubType ?? '')
          .toLowerCase()
          .compareTo((b.propertysubType ?? '').toLowerCase()));
    });

    // Sort property types alphabetically (A-Z)
    var sortedKeys = groupedProperties.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    Map<String, List<propertytype>> sortedGroupedProperties = {};
    for (var key in sortedKeys) {
      sortedGroupedProperties[key] = groupedProperties[key]!;
    }

    return sortedGroupedProperties;
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
    String? token = prefs.getString('token');
    String? staffid = prefs.getString("staff_id");
    final response = await http
        .get(Uri.parse('${Api_url}/api/rentals/rental-owners/$id'), headers: {
      "id": "CRM $staffid",
      "authorization": "CRM $token",
    });

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
        final fullName = '${owner.rentalOwnername} '.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  String? initialAddress;
  String? initialCity;
  String? initialState;
  String? initialCountry;
  String? initialPostalCode;
  String? initialFirstName;
  String? initialCompanyName;
  String? initialPrimaryEmail;
  String? initialAlternativeEmail;
  String? initialPhoneNumber;
  String? initialHomeNumber;
  String? initialBuisinessNumber;
  String? initialRentalOwnerId;
  String? initialrentalOwnercity;
  String? initialrentalOwnerstate;
  String? initialrentalOwnerAddress;
  String? initialrentalOwnerpostalCode;
  String? initialrentalOwnercountry;
  String? initialselectedpropertytype;
  String? initialselectedselectedStaff;

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
    print(selectedStaff);
    Ownersdetails = RentalOwner(
        rentalOwnerId: widget.properties.rentalOwnerId,
        rentalOwnerName: widget.properties.rentalOwnerData?.rentalOwnerName,
        rentalOwnerPhoneNumber:
            widget.properties.rentalOwnerData?.rentalOwnerPhoneNumber,
        rentalOwnerHomeNumber:
            widget.properties.rentalOwnerData?.rentalOwnerHomeNumber,
        rentalOwnerBusinessNumber:
            widget.properties.rentalOwnerData?.rentalOwnerBuisinessNumber,
        rentalOwnerAlternateEmail:
            widget.properties.rentalOwnerData?.rentalOwnerAlternativeEmail,
        rentalOwnerPrimaryEmail:
            widget.properties.rentalOwnerData?.rentalOwnerPrimaryEmail,
        rentalOwnerCompanyName:
            widget.properties.rentalOwnerData?.rentalOwnerCompanyName,
        city: widget.properties.rentalOwnerData?.city,
        state: widget.properties.rentalOwnerData?.state,
        streetAddress: widget.properties.rentalOwnerData?.Address,
        postalCode: widget.properties.rentalOwnerData?.postalCode,
        country: widget.properties.rentalOwnerData?.country,
        processorList:
            widget.properties.rentalOwnerData?.processorList?.map((item) {
          return ProcessorList.fromJson(item as Map<String, dynamic>);
        }).toList());
    processor_id = widget.properties.processor_id;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          Provider.of<OwnerDetailsProvider>(context, listen: false);
      if (Ownersdetails != null) {
        provider.setOwnerDetails(Ownersdetails!);
      }
    });
    print(widget.rentalId);
    isEditable = false;
    fetchDetails1(widget.rentalId).then((_) {
      // Load unit data after property details are set
      fetchunits1();
    });
  }

  List<unit_properties> data = [];
  final Properies_summery_Repo unit1Repository = Properies_summery_Repo();
  Future<void> fetchunits1() async {
    try {
      print('Fetching units...');
      final fetchedunit1 =
          await unit1Repository.fetchunit(widget.properties.rentalId ?? "");
      print('Fetched units: $fetchedunit1');

      setState(() {
        data = fetchedunit1;
        isLoading = false;

        // Clear existing property groups
        propertyGroups.clear();
        propertyGroupControllers.clear();
        propertyGroupImages.clear();
        propertyGroupImagenames.clear();
        originalValues.clear();

        print('Creating property groups for ${data.length} units');
        print('Property Type: ${selectedpropertytypedata?.propertyType}');
        print('Is Multi Unit: ${selectedpropertytypedata?.isMultiunit}');

        // Create property groups for each unit
        for (var unit in data) {
          print('Processing unit:');
          print('- Unit name: ${unit.rentalunit}');
          print('- Unit address: ${unit.rentalunitadress}');
          print('- Unit sqft: ${unit.rentalsqft}');

          List<TextEditingController> controllers = [];
          List<Widget> fields = [];

          if (selectedpropertytypedata?.propertyType == 'Commercial') {
            if (selectedpropertytypedata?.isMultiunit == true) {
              // Commercial multi-unit
              print('Setting up Commercial multi-unit controllers');
              controllers = [
                TextEditingController(text: unit.rentalunit ?? ''),
                TextEditingController(text: unit.rentalunitadress ?? ''),
                TextEditingController(text: unit.rentalsqft ?? ''),
              ];
              fields = [
                customTextField('Unit', controllers[0]),
                customTextField('Unit Address', controllers[1]),
                customTextField('SQft', controllers[2]),
                const SizedBox(height: 10),
                photo(propertyGroups.length),
              ];
            } else {
              // Commercial single unit
              print('Setting up Commercial single unit controllers');
              print('Unit data:');
              print('- sqft: "${unit.rentalsqft}"');
              print('- unit: "${unit.rentalunit}"');
              print('- address: "${unit.rentalunitadress}"');

              // For Commercial single unit, if sqft is empty but unit has a value, use that
              String sqftValue = unit.rentalsqft?.isNotEmpty == true
                  ? unit.rentalsqft!
                  : unit.rentalunit ?? '';

              print('Using sqft value: "$sqftValue"');

              controllers = [
                TextEditingController(
                    text: sqftValue), // sqft in first position
                TextEditingController(), // dummy controllers for consistency
                TextEditingController(),
              ];

              print('Initialized controllers:');
              for (int j = 0; j < controllers.length; j++) {
                print('Controller $j: "${controllers[j].text}"');
              }

              fields = [
                customTextField('SQft', controllers[0]),
                const SizedBox(height: 10),
                photo(propertyGroups.length),
              ];
            }
          } else {
            // Residential properties
            if (selectedpropertytypedata?.isMultiunit == true) {
              print('Setting up Residential multi-unit controllers');
              // Use original values directly for display
              controllers = [
                TextEditingController(text: unit.rentalunit ?? ''),
                TextEditingController(text: unit.rentalunitadress ?? ''),
                TextEditingController(text: unit.rentalsqft ?? ''),
                TextEditingController(text: unit.rentalbath ?? ''),
                TextEditingController(text: unit.rentalbed ?? ''),
              ];
              // Store original values for API
              originalValues.add({
                'bath': unit.rentalbath ?? '',
                'bed': unit.rentalbed ?? '',
              });
              fields = [
                customTextField('Unit', controllers[0]),
                customTextField('Unit Address', controllers[1]),
                customTextField('SQft', controllers[2]),
                customDropdownField('Bath', bathArray, controllers[3]),
                customDropdownField('Bed', roomsArray, controllers[4]),
                const SizedBox(height: 10),
                photo(propertyGroups.length),
              ];
            } else {
              print('Setting up Residential single unit controllers');
              // Extract correct values from potentially corrupted data
              Map<String, String> correctValues = extractCorrectValues(unit);

              print('Extracted correct values:');
              print('- SQFT: "${correctValues['sqft']}"');
              print('- Bath: "${correctValues['bath']}"');
              print('- Bed: "${correctValues['bed']}"');

              controllers = [
                TextEditingController(text: correctValues['sqft'] ?? ''),
                TextEditingController(text: correctValues['bath'] ?? ''),
                TextEditingController(text: correctValues['bed'] ?? ''),
              ];
              // Store original values for API
              originalValues.add({
                'bath': correctValues['bath'] ?? '',
                'bed': correctValues['bed'] ?? '',
              });
              fields = [
                customTextField('SQft', controllers[0]),
                customDropdownField('Bath', bathArray, controllers[1]),
                customDropdownField('Bed', roomsArray, controllers[2]),
                const SizedBox(height: 10),
                photo(propertyGroups.length),
              ];
            }
          }

          print('Adding controllers:');
          for (int i = 0; i < controllers.length; i++) {
            print('Controller $i: "${controllers[i].text}"');
          }

          propertyGroups.add(fields);
          propertyGroupControllers.add(controllers);

          // Handle images - construct full URL for display
          if (unit.rentalImages != null && unit.rentalImages!.isNotEmpty) {
            String imageFilename = unit.rentalImages![0];
            print('Processing image for unit: $imageFilename');

            // Check if it's already a full URL
            if (imageFilename.startsWith('http')) {
              propertyGroupImagenames.add(imageFilename);
              print('Using full URL: $imageFilename');
            } else {
              // Construct full URL using the image_url constant
              String fullUrl = '$image_url$imageFilename';
              propertyGroupImagenames.add(fullUrl);
              print('Constructed URL: $fullUrl');
            }
            propertyGroupImages.add(null);
          } else {
            propertyGroupImagenames.add(null);
            propertyGroupImages.add(null);
            print('No images for this unit');
          }
        }

        selectedIsMultiUnit = data.length > 1;
        print('Updated selectedIsMultiUnit: $selectedIsMultiUnit');
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load units: $e');
    }
  }

  Future<void> fetchDetails1(String rentalId) async {
    try {
      Rentals fetchedDetails =
          await Properies_summery_Repo().fetchrentalDetails(rentalId);

      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        originalValues.clear();
        // print(fetchedDetails.rentalAddress);
        // selectedpropertytype = fetchedDetails.propertyTypeData?.propertyType;
        selectedpropertytypedata = propertytype(
            propertyType: fetchedDetails.propertyTypeData?.propertyType ?? "",
            propertysubType:
                fetchedDetails.propertyTypeData?.propertySubType ?? "",
            isMultiunit: fetchedDetails.propertyTypeData?.isMultiunit ?? false,
            propertyId: fetchedDetails.propertyTypeData?.propertyId ?? "");
        selectedpropertytype = fetchedDetails.propertyTypeData?.propertyType;
        selectedProperty = fetchedDetails.propertyTypeData?.propertySubType;
        address.text = fetchedDetails.rentalAddress!;
        city.text = fetchedDetails.rentalCity!;
        state.text = fetchedDetails.rentalState!;
        postalcode.text = fetchedDetails.rentalPostcode!;
        // country.text = fetchedDetails.rentalCountry!;
        country.text = fetchedDetails.rentalCountry ?? 'N/A';
        selectedProperty = fetchedDetails.propertyTypeData!.propertySubType;
        Ownersdetails = RentalOwner(
            rentalOwnerId: fetchedDetails.rentalOwnerId,
            rentalOwnerPhoneNumber:
                fetchedDetails.rentalOwnerData!.rentalOwnerPhoneNumber,
            rentalOwnerName: fetchedDetails.rentalOwnerData!.rentalOwnerName,
            rentalOwnerHomeNumber:
                fetchedDetails.rentalOwnerData?.rentalOwnerHomeNumber,
            rentalOwnerBusinessNumber:
                fetchedDetails.rentalOwnerData?.rentalOwnerBuisinessNumber,
            rentalOwnerAlternateEmail:
                fetchedDetails.rentalOwnerData?.rentalOwnerAlternativeEmail,
            rentalOwnerPrimaryEmail:
                fetchedDetails.rentalOwnerData?.rentalOwnerPrimaryEmail,
            rentalOwnerCompanyName:
                fetchedDetails.rentalOwnerData?.rentalOwnerCompanyName,
            city: fetchedDetails.rentalOwnerData?.city,
            state: fetchedDetails.rentalOwnerData?.state,
            streetAddress: fetchedDetails.rentalOwnerData?.Address,
            postalCode: fetchedDetails.rentalOwnerData?.postalCode,
            country: fetchedDetails.rentalOwnerData?.country,
            processorList:
                fetchedDetails.rentalOwnerData?.processorList?.map((item) {
              return ProcessorList.fromJson(item as Map<String, dynamic>);
            }).toList());
        firstname.text = fetchedDetails.rentalOwnerData!.rentalOwnerName!;
        comname.text = fetchedDetails.rentalOwnerData!.rentalOwnerCompanyName!;
        primaryemail.text =
            fetchedDetails.rentalOwnerData!.rentalOwnerPrimaryEmail!;
        alternativeemail.text =
            fetchedDetails.rentalOwnerData!.rentalOwnerAlternativeEmail!;
        // print(alternativeemail);
        phonenum.text = fetchedDetails.rentalOwnerData!.rentalOwnerPhoneNumber!;
        // print(phonenum);
        homenum.text = fetchedDetails.rentalOwnerData!.rentalOwnerHomeNumber!;
        // print(homenum);
        businessnum.text =
            fetchedDetails.rentalOwnerData!.rentalOwnerBuisinessNumber!;
        // print(widget.properties.rentalOwnerData!.rentalOwnerBuisinessNumber);
        street2.text = fetchedDetails.rentalOwnerData!.Address!;
        city2.text = fetchedDetails.rentalOwnerData!.city!;
        state2.text = fetchedDetails.rentalOwnerData!.state!;
        county2.text = fetchedDetails.rentalOwnerData!.country!;
        code2.text = fetchedDetails.rentalOwnerData!.postalCode!;
        selectedStaff = fetchedDetails.staffMemberId!.isEmpty
            ? null
            : fetchedDetails.staffMemberId ?? null;
        // print(selectedStaffmember);
        Provider.of<OwnerDetailsProvider>(context, listen: false)
            .setOwnerDetails(Ownersdetails!);

        initialAddress = fetchedDetails.rentalAddress!;
        initialselectedselectedStaff = (fetchedDetails.staffMemberId!.isEmpty
            ? null
            : fetchedDetails.staffMemberId ?? null)!;
        initialCity = fetchedDetails.rentalCity!;
        initialState = fetchedDetails.rentalState!;
        initialPostalCode = fetchedDetails.rentalPostcode!;
        initialCountry = fetchedDetails.rentalCountry ?? 'N/A';
        initialFirstName = fetchedDetails.rentalOwnerData!.rentalOwnerName!;
        initialCompanyName =
            fetchedDetails.rentalOwnerData!.rentalOwnerCompanyName!;
        initialPrimaryEmail =
            fetchedDetails.rentalOwnerData!.rentalOwnerPrimaryEmail!;
        initialAlternativeEmail =
            fetchedDetails.rentalOwnerData!.rentalOwnerAlternativeEmail!;
        initialHomeNumber =
            fetchedDetails.rentalOwnerData!.rentalOwnerHomeNumber!;
        initialBuisinessNumber =
            fetchedDetails.rentalOwnerData!.rentalOwnerBuisinessNumber!;
        initialrentalOwnerAddress = fetchedDetails.rentalOwnerData!.Address!;
        initialrentalOwnercity = fetchedDetails.rentalOwnerData!.city!;
        initialrentalOwnerstate = fetchedDetails.rentalOwnerData!.state!;
        initialrentalOwnercountry = fetchedDetails.rentalOwnerData!.country!;
        initialrentalOwnerpostalCode =
            fetchedDetails.rentalOwnerData!.postalCode!;
        initialPhoneNumber =
            fetchedDetails.rentalOwnerData!.rentalOwnerPhoneNumber!;

        // _selectedProperty = fetchedDetails.rentalId; // Uncomment and update based on your use case
      });
    } catch (e) {
      // print('Failed to fetch property details: $e');
    }
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
  // Track original values for API (separate from display values)
  List<Map<String, String>> originalValues = [];

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
      try {
        String? filename = await uploadImage(File(pickedFile.path));
        print('Uploaded filename: $filename');
        setState(() {
          // Store the full URL for the uploaded image
          if (filename != null && filename.isNotEmpty) {
            propertyGroupImagenames[index] = '$image_url$filename';
            print('Stored full URL: ${propertyGroupImagenames[index]}');
          }
          // Store the local file for immediate display
          propertyGroupImages[index] = File(pickedFile.path);
        });
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    final String uploadUrl = '${image_upload_url}/api/images/upload';

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
    return FormField<String>(
      validator: (value) {
        if (Controller.text.isEmpty) {
          return 'required';
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
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
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF8A95A8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF8A95A8), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget customDropdownField(
    String hint,
    List<String> items,
    TextEditingController controller,
  ) {
    // Check if the current value exists in the items list
    String? currentValue = controller.text.isNotEmpty ? controller.text : null;
    bool valueExists = currentValue != null && items.contains(currentValue);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: DropdownButtonFormField<String>(
        value: valueExists ? currentValue : null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        hint: Text(valueExists ? hint : (currentValue ?? hint)),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          controller.text = newValue ?? '';
        },
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  static const List<String> roomsArray = [
    "1 Bed",
    "2 Bed",
    "3 Bed",
    "4 Bed",
    "5 Bed",
    "6 Bed",
    "7 Bed",
    "8 Bed",
    "9 Bed",
    "9+ Bed",
  ];

  static const List<String> bathArray = [
    "1 Bath",
    "1.5 Bath",
    "2 Bath",
    "2.5 Bath",
    "3 Bath",
    "3.5 Bath",
    "4 Bath",
    "4.5 Bath",
    "5 Bath",
    "5+ Bath",
  ];

  // Helper method to get actual property type
  String getActualPropertyType(String? propertyType) {
    if (propertyType == null) return '';
    if (propertyType == 'Single-Family') return 'Commercial';
    return propertyType;
  }

  // Helper method to find best matching dropdown option for display
  String findBestDropdownMatch(String? dbValue, List<String> options) {
    if (dbValue == null || dbValue.isEmpty) {
      return '';
    }

    // Check if the value exists in the dropdown options (exact match)
    if (options.contains(dbValue)) {
      return dbValue;
    }

    // Try to find an exact match (case insensitive)
    String searchValue = dbValue.toLowerCase();
    for (String option in options) {
      if (option.toLowerCase() == searchValue) {
        return option;
      }
    }

    // For numeric values like "2", "4", etc., return empty string to show as hint
    // This way the dropdown will show the original value as hint instead of converting it
    return '';
  }

  // Helper method to check if value exists in dropdown options
  bool isValueInDropdown(String? dbValue, List<String> options) {
    if (dbValue == null || dbValue.isEmpty) {
      return false;
    }

    // Check if the value exists in the dropdown options (exact match)
    if (options.contains(dbValue)) {
      return true;
    }

    // Try to find an exact match (case insensitive)
    String searchValue = dbValue.toLowerCase();
    for (String option in options) {
      if (option.toLowerCase() == searchValue) {
        return true;
      }
    }

    // Only return true if the value is already in dropdown format (contains "Bath" or "Bed")
    if (searchValue.contains('bath') || searchValue.contains('bed')) {
      return true;
    }

    // For numeric values like "2", "3", etc., return false to use text field
    return false;
  }

  // Helper method to safely set dropdown value - only set if it exists in options
  String safeDropdownValue(String? dbValue, List<String> options) {
    if (dbValue == null || dbValue.isEmpty) {
      return '';
    }

    // Check if the value exists in the dropdown options (exact match)
    if (options.contains(dbValue)) {
      return dbValue; // Use as is if it exists in dropdown
    }

    // Try to find an exact match (case insensitive)
    String searchValue = dbValue.toLowerCase();
    for (String option in options) {
      if (option.toLowerCase() == searchValue) {
        return option;
      }
    }

    // Only try to match if the value is already in dropdown format (contains "Bath" or "Bed")
    if (searchValue.contains('bath') || searchValue.contains('bed')) {
      for (String option in options) {
        if (option.toLowerCase().contains(searchValue)) {
          return option;
        }
      }
    }

    // If no match found, return empty string to avoid dropdown error
    return '';
  }

  // Helper method to extract correct values from corrupted data
  Map<String, String> extractCorrectValues(unit_properties unit) {
    Map<String, String> result = {
      'sqft': '',
      'bath': '',
      'bed': '',
    };

    // Try to find numeric sqft value
    if (unit.rentalsqft != null &&
        RegExp(r'^\d+$').hasMatch(unit.rentalsqft!)) {
      result['sqft'] = unit.rentalsqft!;
    } else if (unit.rentalunit != null &&
        RegExp(r'^\d+$').hasMatch(unit.rentalunit!)) {
      result['sqft'] = unit.rentalunit!;
    } else if (unit.rentalunitadress != null &&
        RegExp(r'^\d+$').hasMatch(unit.rentalunitadress!)) {
      result['sqft'] = unit.rentalunitadress!;
    }

    // Try to find bath value
    if (unit.rentalbath != null &&
        unit.rentalbath!.toLowerCase().contains('bath')) {
      result['bath'] = unit.rentalbath!;
    } else if (unit.rentalunit != null &&
        unit.rentalunit!.toLowerCase().contains('bath')) {
      result['bath'] = unit.rentalunit!;
    } else if (unit.rentalunitadress != null &&
        unit.rentalunitadress!.toLowerCase().contains('bath')) {
      result['bath'] = unit.rentalunitadress!;
    } else if (unit.rentalsqft != null &&
        unit.rentalsqft!.toLowerCase().contains('bath')) {
      result['bath'] = unit.rentalsqft!;
    }

    // Try to find bed value
    if (unit.rentalbed != null &&
        unit.rentalbed!.toLowerCase().contains('bed')) {
      result['bed'] = unit.rentalbed!;
    } else if (unit.rentalunit != null &&
        unit.rentalunit!.toLowerCase().contains('bed')) {
      result['bed'] = unit.rentalunit!;
    } else if (unit.rentalunitadress != null &&
        unit.rentalunitadress!.toLowerCase().contains('bed')) {
      result['bed'] = unit.rentalunitadress!;
    } else if (unit.rentalsqft != null &&
        unit.rentalsqft!.toLowerCase().contains('bed')) {
      result['bed'] = unit.rentalsqft!;
    }

    return result;
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
                  style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Show image - prioritize local image over network image
            if (propertyGroupImages[index] != null)
              // Show local image if selected (new image from gallery)
              Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            propertyGroupImages[index] =
                                null; // Clear the local image
                            propertyGroupImagenames[index] =
                                null; // Also clear the network image
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
              )
            else if (propertyGroupImagenames[index] != null &&
                propertyGroupImagenames[index]!.isNotEmpty)
              // Show network image if no local image (existing image from API)
              Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            propertyGroupImagenames[index] =
                                null; // Clear the existing image
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
                        child: Image.network(
                          propertyGroupImagenames[index]!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            print(
                                'Image URL: ${propertyGroupImagenames[index]}');
                            return Container(
                              height: 50,
                              width: 50,
                              color: Colors.grey[300],
                              child:
                                  const Icon(Icons.error, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            // Show add image button if no image is displayed
            if (propertyGroupImages[index] == null &&
                (propertyGroupImagenames[index] == null ||
                    propertyGroupImagenames[index]!.isEmpty))
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      getImage(index).then((_) {
                        setState(
                            () {}); // Rebuild the widget after selecting the image
                      });
                    },
                    child: Image.asset(
                      'assets/images/addimage.png',
                      height: 40,
                      width: 40,
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  void addPropertyGroup() {
    // print("hello");
    List<Widget> fields = [];
    List<TextEditingController> controllers = [];

    // print(selectedpropertytype);

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
        customDropdownField('Bath', bathArray, bathController),
        customDropdownField('Bed', roomsArray, bedController),
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
        customDropdownField('Bath', bathArray, bathController),
        customDropdownField('Bed', roomsArray, bedController),
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

    // print(propertyGroupControllers.length);

    for (int i = 0; i < propertyGroupControllers.length; i++) {
      List<TextEditingController> controllers = propertyGroupControllers[i];
      for (int j = 0; j < controllers.length; j++) {
        // print(controllers[j].text);
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
  String? processor_id;
  List<OwnersDetails> OwnersdetailsGroups = [];
  bool hasError = false;

  final FocusNode _nodeText1 = FocusNode();
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),
      ],
    );
  }

  bool isEditable = false;

  @override
  Widget build(BuildContext context) {
    // print(selectedIsMultiUnit);
    // print(selectedProperty);
    final ownerDetails =
        Provider.of<OwnerDetailsProvider>(context).OwnerDetails;

    final firstnameController =
        TextEditingController(text: ownerDetails?.rentalOwnerName);
    final comnameController =
        TextEditingController(text: ownerDetails?.rentalOwnerCompanyName);
    final primaryemailController =
        TextEditingController(text: ownerDetails?.rentalOwnerPrimaryEmail);
    final phonenumController =
        TextEditingController(text: ownerDetails?.rentalOwnerPhoneNumber);
    final cityController = TextEditingController(text: ownerDetails?.city);
    final stateController = TextEditingController(text: ownerDetails?.state);
    final countyController = TextEditingController(text: ownerDetails?.country);
    final codeController =
        TextEditingController(text: ownerDetails?.postalCode);
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Properties",
        dropdown: true,
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
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: blueColor,
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: const Text(
                      "Edit Property",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                //dropdown
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: blueColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      child: Column(
                        children: [
                          // Row(
                          //   children: [
                          //     SizedBox(
                          //       width: 15,
                          //     ),
                          //     Text(
                          //       "New Property ",
                          //       style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //           color: blueColor,
                          //           fontSize:
                          //               MediaQuery.of(context).size.width < 500
                          //                   ? 17
                          //                   : 18),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Property Information",
                                style: TextStyle(
                                    color: const Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 16
                                            : 18),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                "What is the property type?",
                                style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 15
                                            : 18),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              FutureBuilder<List<propertytype>>(
                                future: futureProperties,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: SpinKitFadingCircle(
                                      color: Colors.black,
                                      size: 40.0,
                                    ));
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Text('No properties found');
                                  } else {
                                    Map<String, List<propertytype>>
                                        groupedProperties =
                                        groupPropertiesByType(snapshot.data!);

                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                            // height: MediaQuery.of(context)
                                            //         .size
                                            //         .height *
                                            //     .05,
                                            height: 50,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .6,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xFF8A95A8),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                value: groupedProperties
                                                        .isNotEmpty
                                                    ? (groupedProperties.entries
                                                            .expand((entry) =>
                                                                entry.value.map(
                                                                    (item) => item
                                                                        .propertysubType))
                                                            .contains(
                                                                selectedProperty)
                                                        ? selectedProperty
                                                        : null)
                                                    : null,
                                                hint: Text(
                                                  'Add Property Type',
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 15
                                                            : 18,
                                                    color:
                                                        const Color(0xFF8A95A8),
                                                  ),
                                                ),
                                                onChanged: isEditable
                                                    ? (String? newValue) {
                                                        if (newValue ==
                                                            'Edit_properties') {
                                                          // Prevent the dropdown from changing the selected item
                                                          setState(() {
                                                            selectedProperty =
                                                                null;
                                                          });
                                                          // Show the dialog
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              bool isChecked =
                                                                  false; // Moved isChecked inside the StatefulBuilder
                                                              return StatefulBuilder(
                                                                builder: (BuildContext
                                                                        context,
                                                                    StateSetter
                                                                        setState) {
                                                                  return Dialog(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    surfaceTintColor:
                                                                        Colors
                                                                            .white,
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Container(
                                                                            // height: MediaQuery.of(context).size.height * .43,
                                                                            // width: MediaQuery.of(context)
                                                                            //     .size
                                                                            //     .width *
                                                                            //     .99,
                                                                            // decoration: BoxDecoration(
                                                                            //     color: Colors.white,
                                                                            //     borderRadius: BorderRadius.circular(10),
                                                                            //     border: Border.all(
                                                                            //       color: Color.fromRGBO(
                                                                            //           21,
                                                                            //           43,
                                                                            //           81,
                                                                            //           1),
                                                                            //     )),
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                const SizedBox(
                                                                                  height: 20,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      width: 15,
                                                                                    ),
                                                                                    Text(
                                                                                      "New Property Type",
                                                                                      style: TextStyle(fontWeight: FontWeight.bold, color: blueColor, fontSize: MediaQuery.of(context).size.width < 500 ? 17 : 22),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Material(
                                                                                        child: Container(
                                                                                            // height: 30,
                                                                                            // width: 30,
                                                                                            // decoration: BoxDecoration(
                                                                                            //   border: Border.all(color: blueColor),
                                                                                            //   borderRadius: BorderRadius.circular(20)
                                                                                            // ),
                                                                                            child: const Center(child: Icon(Icons.close))),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 8,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      width: 15,
                                                                                    ),
                                                                                    Text(
                                                                                      "Property Type*",
                                                                                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 18),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      width: 15,
                                                                                    ),
                                                                                    DropdownButtonHideUnderline(
                                                                                      child: DropdownButton2<String>(
                                                                                        isExpanded: true,
                                                                                        hint: const Row(
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
                                                                                        value: selectedValue,
                                                                                        onChanged: (value) {
                                                                                          setState(() {
                                                                                            selectedValue = value;
                                                                                          });
                                                                                        },
                                                                                        buttonStyleData: ButtonStyleData(
                                                                                          height: 50,
                                                                                          width: 160,
                                                                                          padding: const EdgeInsets.only(left: 14, right: 14),
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                            border: Border.all(
                                                                                              color: Colors.black26,
                                                                                            ),
                                                                                            color: Colors.white,
                                                                                          ),
                                                                                          elevation: 3,
                                                                                        ),
                                                                                        dropdownStyleData: DropdownStyleData(
                                                                                          maxHeight: 200,
                                                                                          width: 200,
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(14),
                                                                                            //color: Colors.redAccent,
                                                                                          ),
                                                                                          offset: const Offset(-20, 0),
                                                                                          scrollbarTheme: ScrollbarThemeData(
                                                                                            radius: const Radius.circular(40),
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
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 20,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      width: 15,
                                                                                    ),
                                                                                    Text(
                                                                                      "Property SubType*",
                                                                                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 18),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      width: 15,
                                                                                    ),
                                                                                    Material(
                                                                                      elevation: 2,
                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                      child: Container(
                                                                                        width: MediaQuery.of(context).size.width < 500 ? 160 : 160,
                                                                                        padding: const EdgeInsets.only(left: 10),
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white,
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        ),
                                                                                        child: TextFormField(
                                                                                          controller: subtype,
                                                                                          decoration: const InputDecoration(border: InputBorder.none, hintText: "Townhome"),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 20,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    if (MediaQuery.of(context).size.width < 500) SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                                                                    if (MediaQuery.of(context).size.width > 500) SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                                                                    Container(
                                                                                      height: MediaQuery.of(context).size.height * 0.02,
                                                                                      width: MediaQuery.of(context).size.height * 0.02,
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.white,
                                                                                        borderRadius: BorderRadius.circular(5),
                                                                                      ),
                                                                                      child: Checkbox(
                                                                                        activeColor: isChecked ? blueColor : Colors.white,
                                                                                        checkColor: Colors.white,
                                                                                        value: isChecked, // assuming _isChecked is a boolean variable indicating whether the checkbox is checked or not
                                                                                        onChanged: (value) {
                                                                                          setState(() {
                                                                                            isChecked = value ?? false; // ensure value is not null
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                                                                    Text(
                                                                                      "Multi unit",
                                                                                      style: TextStyle(
                                                                                        fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 18,
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 20,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    if (MediaQuery.of(context).size.width < 500) SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                                                                                    if (MediaQuery.of(context).size.width > 500) SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                                                                    GestureDetector(
                                                                                      onTap: () async {
                                                                                        if (selectedValue == null || subtype.text.isEmpty) {
                                                                                          setState(() {
                                                                                            iserror = true;
                                                                                          });
                                                                                        } else {
                                                                                          setState(() {
                                                                                            isLoading = true;
                                                                                            iserror = false;
                                                                                          });
                                                                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                                          String? id = prefs.getString("adminId");
                                                                                          PropertyTypeRepository()
                                                                                              .addPropertyType(
                                                                                            adminId: id!,
                                                                                            propertyType: selectedValue,
                                                                                            propertySubType: subtype.text,
                                                                                            isMultiUnit: isChecked,
                                                                                          )
                                                                                              .then((value) {
                                                                                            setState(() {
                                                                                              isLoading = false;
                                                                                            });
                                                                                            Navigator.pop(context, true);
                                                                                          }).catchError((e) {
                                                                                            setState(() {
                                                                                              isLoading = false;
                                                                                            });
                                                                                          });
                                                                                        }
                                                                                        // print(selectedValue);
                                                                                      },
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                                        child: Container(
                                                                                          height: MediaQuery.of(context).size.width < 500 ? 40 : 45,
                                                                                          width: MediaQuery.of(context).size.width < 500 ? 125 : 165,
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                            color: blueColor,
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
                                                                                                : Text(
                                                                                                    "Add Property Type",
                                                                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width < 500 ? 13 : 15.5),
                                                                                                  ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Material(
                                                                                        elevation: 2,
                                                                                        child: Container(width: MediaQuery.of(context).size.width < 500 ? 90 : 90, height: MediaQuery.of(context).size.width < 500 ? 40 : 40, color: Colors.white, child: const Center(child: Text("Cancel"))),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 2,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                if (iserror)
                                                                                  const Text(
                                                                                    "Please fill in all fields correctly.",
                                                                                    style: TextStyle(color: Colors.redAccent),
                                                                                  ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
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
                                                            print(snapshot.data!
                                                                .where((element) =>
                                                                    element
                                                                        .propertysubType ==
                                                                    newValue)
                                                                .first
                                                                .isMultiunit);
                                                            // selectedIsMultiUnit = snapshot.data!.where((element) => element.isMultiunit == newValue ).first;
                                                            selectedpropertytypedata = snapshot
                                                                .data!
                                                                .where((element) =>
                                                                    element
                                                                        .propertysubType ==
                                                                    newValue)
                                                                .first;
                                                            // print(selectedProperty);
                                                            selectedProperty =
                                                                newValue;
                                                            propertyGroups = [];
                                                            // Call the method here
                                                            selectedpropertytype =
                                                                selectedpropertytypedata!
                                                                    .propertyType;
                                                            selectedIsMultiUnit =
                                                                selectedpropertytypedata!
                                                                    .isMultiunit!;
                                                          });
                                                          showError =
                                                              selectedProperty ==
                                                                  null;
                                                          propertyGroups
                                                              .clear();
                                                          addPropertyGroup();
                                                          propertyTypeError =
                                                              false;
                                                        }
                                                      }
                                                    : null,
                                                items: [
                                                  ...groupedProperties.entries
                                                      .expand((entry) {
                                                    return [
                                                      DropdownMenuItem<String>(
                                                        enabled: false,
                                                        child: Text(
                                                          entry.key,
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1)),
                                                        ),
                                                      ),
                                                      ...entry.value
                                                          .map((item) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: item
                                                              .propertysubType,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 16.0),
                                                            child: Text(
                                                              item.propertysubType ??
                                                                  '',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ];
                                                  }).toList(),
                                                  const DropdownMenuItem<
                                                      String>(
                                                    value: 'Edit_properties',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.add,
                                                            size:
                                                                15), // Adjusted icon size
                                                        SizedBox(width: 6),
                                                        Text(
                                                            'Add New properties',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    16 //MediaQuery.of(context).size.width * .03
                                                                )), // Adjusted text size
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                isExpanded: true,
                                                buttonStyleData:
                                                    ButtonStyleData(
                                                  height: 50,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                  maxHeight: 300,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.white,
                                                  ),
                                                  scrollbarTheme:
                                                      ScrollbarThemeData(
                                                    radius:
                                                        const Radius.circular(
                                                            40),
                                                    thickness:
                                                        MaterialStateProperty
                                                            .all(6),
                                                    thumbVisibility:
                                                        MaterialStateProperty
                                                            .all(true),
                                                  ),
                                                ),
                                                menuItemStyleData:
                                                    const MenuItemStyleData(
                                                  height: 40,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        if (showError)
                                          const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Please select a property type.',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),
                                      ],
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
                                    const SizedBox(
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
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                "What is the street  address?",
                                style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 15
                                            : 18),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Address",
                                style: TextStyle(
                                    color: const Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 14
                                            : 18),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),

                              // Expanded(
                              //   child: Container(
                              //     height: 40,
                              //     decoration: BoxDecoration(
                              //       color: Colors.white,
                              //       borderRadius: BorderRadius.circular(5),
                              //       border:
                              //       Border.all(color: Color(0xFF8A95A8)),
                              //     ),
                              //     child: Stack(
                              //       children: [
                              //         Positioned.fill(
                              //           child: TextField(
                              //             style: TextStyle(
                              //               color: Colors.black,
                              //               fontSize:
                              //               MediaQuery.of(context).size.width < 500 ? 13 : 15,
                              //             ),
                              //             onChanged: (value) {
                              //               setState(() {
                              //                 addresserror = false;
                              //               });
                              //             },
                              //             controller: address,
                              //             cursorColor:
                              //             blueColor,
                              //             decoration: InputDecoration(
                              //               enabledBorder: addresserror
                              //                   ? OutlineInputBorder(
                              //                 borderRadius:
                              //                 BorderRadius.circular(
                              //                     5),
                              //                 borderSide: BorderSide(
                              //                     color: Colors
                              //                         .red), // Set border color here
                              //               )
                              //                   : InputBorder.none,
                              //               border: InputBorder.none,
                              //               contentPadding: EdgeInsets.all(14),
                              //               // prefixIcon: Container(
                              //               //   height: 20,
                              //               //   width: 20,
                              //               //   padding: EdgeInsets.all(13),
                              //               //   child: FaIcon(
                              //               //     FontAwesomeIcons.envelope,
                              //               //     size: 20,
                              //               //     color: Colors.grey[600],
                              //               //   ),
                              //               // ),
                              //               hintText: "Enter address",
                              //               hintStyle: TextStyle(
                              //                   color: Color(0xFF8A95A8),
                              //                   fontSize:  MediaQuery.of(context).size.width < 500 ? 14 : 18),
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      border: Border.all(color: greyColor)
                                      // color: Color.fromRGBO(196, 196, 196, .3),
                                      ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: TextField(
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 14
                                                : 15,
                                          ),
                                          keyboardType: TextInputType
                                              .text, // Adjust as needed
                                          onChanged: (value) {
                                            setState(() {
                                              addresserror = false;
                                            });
                                          },
                                          controller: address,
                                          cursorColor: blueColor,
                                          decoration: InputDecoration(
                                            enabledBorder: addresserror
                                                ? OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: const BorderSide(
                                                        color: Colors
                                                            .red), // Set border color here
                                                  )
                                                : InputBorder.none,
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.all(14),
                                            // prefixIcon: Container(
                                            //   height: 20,
                                            //   width: 20,
                                            //   padding: EdgeInsets.all(13),
                                            //   child: FaIcon(
                                            //     FontAwesomeIcons.locationArrow, // Replace with your icon
                                            //     size: 20,
                                            //     color: Colors.grey[600],
                                            //   ),
                                            // ),
                                            hintText: "Enter address",
                                            hintStyle: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 14
                                                  : 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                          addresserror
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
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
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // First Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "City",
                                        style: TextStyle(
                                          color: const Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 14.5
                                              : 18,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFF8A95A8)),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: TextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                controller: city,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14
                                                          : 15,
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    cityerror = false;
                                                  });
                                                },
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  enabledBorder: cityerror
                                                      ? OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .red), // Error border color
                                                        )
                                                      : InputBorder.none,
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets.all(14),
                                                  hintText: "Enter city",
                                                  hintStyle: TextStyle(
                                                    color:
                                                        const Color(0xFF8A95A8),
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      cityerror
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: Text(
                                                    citymessage,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .04,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Second Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "State",
                                        style: TextStyle(
                                          color: const Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 14.5
                                              : 18,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFF8A95A8)),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: TextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                controller: state,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14
                                                          : 15,
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    stateerror = false;
                                                  });
                                                },
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  enabledBorder: stateerror
                                                      ? OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .red), // Error border color
                                                        )
                                                      : InputBorder.none,
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets.all(14),
                                                  hintText: "Enter state",
                                                  hintStyle: TextStyle(
                                                    color:
                                                        const Color(0xFF8A95A8),
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      stateerror
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: Text(
                                                    statemessage,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .04,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // First Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Country",
                                        style: TextStyle(
                                          color: const Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 14.5
                                              : 18,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFF8A95A8)),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: TextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                controller: country,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14
                                                          : 15,
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    countryerror = false;
                                                  });
                                                },
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  enabledBorder: countryerror
                                                      ? OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .red), // Error border color
                                                        )
                                                      : InputBorder.none,
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets.all(14),
                                                  hintText: "Enter country",
                                                  hintStyle: TextStyle(
                                                    color:
                                                        const Color(0xFF8A95A8),
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      countryerror
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: Text(
                                                    countrymessage,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .04,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Second Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Zip Code",
                                        style: TextStyle(
                                          color: const Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 14.5
                                              : 18,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFF8A95A8)),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: TextField(
                                                focusNode: _nodeText1,
                                                controller: postalcode,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14
                                                          : 15,
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    postalcodeerror = false;
                                                  });
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                // keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  enabledBorder: postalcodeerror
                                                      ? OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .red), // Error border color
                                                        )
                                                      : InputBorder.none,
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets.all(14),
                                                  hintText: "Enter zip code",
                                                  hintStyle: TextStyle(
                                                    color:
                                                        const Color(0xFF8A95A8),
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      postalcodeerror
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: Text(
                                                    postalcodemessage,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .04,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                //rental
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: blueColor),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Owner Information",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 16.5
                                              : 20),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "Who is the property owner ? (Required)",
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        //  fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 14.5
                                                : 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "This information will be used to help prepare owner drawns and 1099s",
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        //  fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 14.5
                                                : 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddRentalowners(
                                              OwnersDetails: Ownersdetails,
                                              isEdit: true,
                                            )));
                              },
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Icon(Icons.add,
                                      size: 25, color: Colors.green[400]),
                                  const SizedBox(width: 9),
                                  Text(
                                    "Add Rental Owner",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[500],
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 18,
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
                                padding: EdgeInsets.only(top: 8.0, bottom: 3),
                                child: Text(
                                  'required',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            Consumer<OwnerDetailsProvider>(
                              builder: (context, provider, child) {
                                Ownersdetails = provider.OwnerDetails;
                                return Ownersdetails != null
                                    ? Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const SizedBox(width: 15),
                                              Text(
                                                "Owners Information",
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: blueColor),
                                                  ),
                                                  child: DataTable(
                                                    border: TableBorder(
                                                      horizontalInside:
                                                          BorderSide(
                                                        color: blueColor,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    columnSpacing: 10,
                                                    headingRowHeight:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 40
                                                            : 40,
                                                    dataRowHeight:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 40
                                                            : 40,
                                                    columns: [
                                                      DataColumn(
                                                        label: Expanded(
                                                          child: Text(
                                                            'Name',
                                                            style: TextStyle(
                                                                fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width <
                                                                        500
                                                                    ? 14
                                                                    : 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Expanded(
                                                          child: Text(
                                                            'PhoneNumber',
                                                            style: TextStyle(
                                                                fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width <
                                                                        500
                                                                    ? 14
                                                                    : 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Expanded(
                                                          child: Text(
                                                            'Action',
                                                            style: TextStyle(
                                                                fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width <
                                                                        500
                                                                    ? 14
                                                                    : 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
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
                                                                      .rentalOwnerName ??
                                                                  'N/A',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      MediaQuery.of(context).size.width <
                                                                              500
                                                                          ? 14
                                                                          : 18),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                              Ownersdetails!
                                                                      .rentalOwnerPhoneNumber ??
                                                                  'N/A',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      MediaQuery.of(context).size.width <
                                                                              500
                                                                          ? 14
                                                                          : 18),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Row(
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    //  final ownerDetails = Provider.of<OwnerDetailsProvider>(context).OwnerDetails;
                                                                    //for edit pur
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => EditRentalowners(
                                                                                  rentalId: widget.rentalId,
                                                                                  pro_id: processor_id!,
                                                                                )));
                                                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>AddRentalowners(OwnersDetails: Ownersdetails,isEdit: true,)));
                                                                    //   }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    child:
                                                                        FaIcon(
                                                                      FontAwesomeIcons
                                                                          .edit,
                                                                      size: MediaQuery.of(context).size.width <
                                                                              500
                                                                          ? 17
                                                                          : 20,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 4),
                                                                InkWell(
                                                                  onTap: () {
                                                                    provider
                                                                        .clearOwners();

                                                                    setState(
                                                                        () {
                                                                      RentalOwner?
                                                                          owner;
                                                                      Ownersdetails =
                                                                          owner;
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    child:
                                                                        FaIcon(
                                                                      FontAwesomeIcons
                                                                          .trashCan,
                                                                      size: MediaQuery.of(context).size.width <
                                                                              500
                                                                          ? 17
                                                                          : 20,
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
                                              ),
                                              const SizedBox(width: 15),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
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
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: blueColor),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "Who will be primary manager of this Property ?",
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        //  fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 14.5
                                                : 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "If staff member has not yet been added as user in your account ,they can be added to the account"
                                    ",than as the manager later through the property's summary details.",
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        //  fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 14
                                                : 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Manage (Optional)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                FutureBuilder<List<Staffmembers>>(
                                  future: futureStaffMembers,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: SpinKitFadingCircle(
                                        color: Colors.black,
                                        size: 40.0,
                                      ));
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Text(
                                          'No staff members found');
                                    } else {
                                      List<Staffmembers> staffMembers =
                                          snapshot.data!;

                                      // Sort staff members alphabetically by name (A-Z)
                                      staffMembers.sort((a, b) =>
                                          (a.staffmemberName ?? '')
                                              .toLowerCase()
                                              .compareTo(
                                                  (b.staffmemberName ?? '')
                                                      .toLowerCase()));

                                      List<DropdownMenuItem<String>>
                                          dropdownItems = staffMembers
                                              .map<DropdownMenuItem<String>>(
                                                  (Staffmembers staffMember) {
                                        return DropdownMenuItem<String>(
                                          value: staffMember.staffmemberId,
                                          onTap: () {
                                            setState(() {
                                              sid = staffMember.staffmemberId;
                                            });
                                          },
                                          child: Text(
                                            staffMember.staffmemberName ?? '',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        );
                                      }).toList();
                                      // Add the special "Add new property" item
                                      dropdownItems.add(
                                        DropdownMenuItem<String>(
                                          value: 'Edit_properties',
                                          child: GestureDetector(
                                            onTap: () {
                                              name.clear();
                                              designation.clear();
                                              phonenumber.clear();
                                              email.clear();
                                              password.clear();
                                              nameerror = false;
                                              designationerror = false;
                                              phonenumbererror = false;
                                              emailerror = false;
                                              passworderror = false;
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  bool isChecked =
                                                      false; // Moved isChecked inside the StatefulBuilder
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return Dialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        surfaceTintColor:
                                                            Colors.white,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10,
                                                                  right: 5,
                                                                  bottom: 20,
                                                                  top: 10),
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Spacer(),
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
                                                                            const FaIcon(
                                                                          FontAwesomeIcons
                                                                              .xmark,
                                                                          size:
                                                                              20,
                                                                          color:
                                                                              Color(0xFF8A95A8),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Text(
                                                                      "New Staff Member",
                                                                      style: TextStyle(
                                                                          color:
                                                                              blueColor,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              18),
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
                                                                      "Staff member name..*",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                        width:
                                                                            15),
                                                                    Material(
                                                                      elevation:
                                                                          4,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            50,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .63,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(2),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                const Color(0xFF8A95A8),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Positioned.fill(
                                                                              child: TextField(
                                                                                onChanged: (value) {
                                                                                  setState(() {
                                                                                    nameerror = false;
                                                                                  });
                                                                                },
                                                                                controller: name,
                                                                                cursorColor: blueColor,
                                                                                decoration: InputDecoration(
                                                                                  hintText: "Enter a staff member name here..*",
                                                                                  hintStyle: const TextStyle(
                                                                                    fontSize: 13,
                                                                                    color: Color(0xFF8A95A8),
                                                                                  ),
                                                                                  enabledBorder: nameerror
                                                                                      ? OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(2),
                                                                                          borderSide: const BorderSide(
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        )
                                                                                      : InputBorder.none,
                                                                                  border: InputBorder.none,
                                                                                  contentPadding: const EdgeInsets.all(12),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            20),
                                                                  ],
                                                                ),
                                                                nameerror
                                                                    ? Row(
                                                                        children: [
                                                                          const SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              namemessage,
                                                                              style: const TextStyle(color: Colors.red, fontSize: 14),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                20,
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Container(),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Text(
                                                                      "Designation...*",
                                                                      style: TextStyle(
                                                                          // color: Colors.grey,
                                                                          color: Color(0xFF8A95A8),
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 13),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                        width:
                                                                            15),
                                                                    Material(
                                                                      elevation:
                                                                          4,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            50,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .63,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(2),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                const Color(0xFF8A95A8),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Positioned.fill(
                                                                              child: TextField(
                                                                                onChanged: (value) {
                                                                                  setState(() {
                                                                                    designationerror = false;
                                                                                  });
                                                                                },
                                                                                controller: designation,
                                                                                cursorColor: blueColor,
                                                                                decoration: InputDecoration(
                                                                                  hintText: "Enter Designation here..*",
                                                                                  hintStyle: const TextStyle(
                                                                                    fontSize: 13,
                                                                                    color: Color(0xFF8A95A8),
                                                                                  ),
                                                                                  enabledBorder: designationerror
                                                                                      ? OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(2),
                                                                                          borderSide: const BorderSide(
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        )
                                                                                      : InputBorder.none,
                                                                                  border: InputBorder.none,
                                                                                  contentPadding: const EdgeInsets.all(12),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            20),
                                                                  ],
                                                                ),
                                                                designationerror
                                                                    ? Row(
                                                                        children: [
                                                                          const SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              designationmessage,
                                                                              style: const TextStyle(color: Colors.red, fontSize: 14),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                20,
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Container(),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Text(
                                                                      "Phone Number...",
                                                                      style: TextStyle(
                                                                          // color: Colors.grey,
                                                                          color: Color(0xFF8A95A8),
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 13),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                        width:
                                                                            15),
                                                                    Material(
                                                                      elevation:
                                                                          4,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            50,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .63,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(2),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                const Color(0xFF8A95A8),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Positioned.fill(
                                                                              child: TextField(
                                                                                onChanged: (value) {
                                                                                  setState(() {
                                                                                    phonenumbererror = false;
                                                                                  });
                                                                                },
                                                                                controller: phonenumber,
                                                                                inputFormatters: [
                                                                                  FilteringTextInputFormatter.digitsOnly,
                                                                                  LengthLimitingTextInputFormatter(10),
                                                                                  PhoneNumberFormatter(),
                                                                                ],
                                                                                keyboardType: TextInputType.number,
                                                                                cursorColor: blueColor,
                                                                                decoration: InputDecoration(
                                                                                  hintText: "Enter Phone Number here..*",
                                                                                  hintStyle: const TextStyle(
                                                                                    fontSize: 13,
                                                                                    color: Color(0xFF8A95A8),
                                                                                  ),
                                                                                  enabledBorder: phonenumbererror
                                                                                      ? OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(2),
                                                                                          borderSide: const BorderSide(
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        )
                                                                                      : InputBorder.none,
                                                                                  border: InputBorder.none,
                                                                                  contentPadding: const EdgeInsets.all(12),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            20),
                                                                  ],
                                                                ),
                                                                phonenumbererror
                                                                    ? Row(
                                                                        children: [
                                                                          const SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              phonenumbermessage,
                                                                              style: const TextStyle(color: Colors.red, fontSize: 14),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                20,
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Container(),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Text(
                                                                      "Email...*",
                                                                      style: TextStyle(
                                                                          // color: Colors.grey,
                                                                          color: Color(0xFF8A95A8),
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 13),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                        width:
                                                                            15),
                                                                    Material(
                                                                      elevation:
                                                                          4,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            50,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .63,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(2),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                const Color(0xFF8A95A8),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Positioned.fill(
                                                                              child: TextField(
                                                                                onChanged: (value) {
                                                                                  setState(() {
                                                                                    emailerror = false;
                                                                                  });
                                                                                },
                                                                                controller: email,
                                                                                cursorColor: blueColor,
                                                                                decoration: InputDecoration(
                                                                                  hintText: "Enter Email here..*",
                                                                                  hintStyle: const TextStyle(
                                                                                    fontSize: 13,
                                                                                    color: Color(0xFF8A95A8),
                                                                                  ),
                                                                                  enabledBorder: emailerror
                                                                                      ? OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(2),
                                                                                          borderSide: const BorderSide(
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        )
                                                                                      : InputBorder.none,
                                                                                  border: InputBorder.none,
                                                                                  contentPadding: const EdgeInsets.all(12),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            20),
                                                                  ],
                                                                ),
                                                                emailerror
                                                                    ? Row(
                                                                        children: [
                                                                          const SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              emailmessage,
                                                                              style: const TextStyle(color: Colors.red, fontSize: 14),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                20,
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Container(),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Text(
                                                                      "Password...*",
                                                                      style: TextStyle(
                                                                          // color: Colors.grey,
                                                                          color: Color(0xFF8A95A8),
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 13),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                        width:
                                                                            15),
                                                                    Material(
                                                                      elevation:
                                                                          4,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            50,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .63,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(2),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                const Color(0xFF8A95A8),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Positioned.fill(
                                                                              child: TextField(
                                                                                onChanged: (value) {
                                                                                  setState(() {
                                                                                    passworderror = false;
                                                                                  });
                                                                                },
                                                                                controller: password,
                                                                                cursorColor: blueColor,
                                                                                decoration: InputDecoration(
                                                                                  hintText: "Enter Password here..*",
                                                                                  hintStyle: const TextStyle(
                                                                                    fontSize: 13,
                                                                                    color: Color(0xFF8A95A8),
                                                                                  ),
                                                                                  enabledBorder: passworderror
                                                                                      ? OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(2),
                                                                                          borderSide: const BorderSide(
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        )
                                                                                      : InputBorder.none,
                                                                                  border: InputBorder.none,
                                                                                  contentPadding: const EdgeInsets.all(12),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            20),
                                                                  ],
                                                                ),
                                                                passworderror
                                                                    ? Row(
                                                                        children: [
                                                                          const SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              passwordmessage,
                                                                              style: const TextStyle(color: Colors.red, fontSize: 14),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                20,
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Container(),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    if (MediaQuery.of(context)
                                                                            .size
                                                                            .width >
                                                                        500)
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.013,
                                                                      ),
                                                                    if (MediaQuery.of(context)
                                                                            .size
                                                                            .width <
                                                                        500)
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.035,
                                                                      ),
                                                                    //                                                                   GestureDetector(
                                                                    //                                                                     onTap:
                                                                    //                                                                         () async {
                                                                    //                                                                       if (name
                                                                    //                                                                           .text
                                                                    //                                                                           .isEmpty) {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           nameerror =
                                                                    //                                                                               true;
                                                                    //                                                                           namemessage =
                                                                    //                                                                               "required";
                                                                    //                                                                         });
                                                                    //                                                                       } else {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           nameerror =
                                                                    //                                                                               false;
                                                                    //                                                                         });
                                                                    //                                                                       }
                                                                    //                                                                       if (designation
                                                                    //                                                                           .text
                                                                    //                                                                           .isEmpty) {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           designationerror =
                                                                    //                                                                               true;
                                                                    //                                                                           designationmessage =
                                                                    //                                                                               "required";
                                                                    //                                                                         });
                                                                    //                                                                       } else {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           designationerror =
                                                                    //                                                                               false;
                                                                    //                                                                         });
                                                                    //                                                                       }
                                                                    //                                                                       if (phonenumber
                                                                    //                                                                           .text
                                                                    //                                                                           .isEmpty) {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           phonenumbererror =
                                                                    //                                                                               true;
                                                                    //                                                                           phonenumbermessage =
                                                                    //                                                                               "required";
                                                                    //                                                                         });
                                                                    //                                                                       } else {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           phonenumbererror =
                                                                    //                                                                               false;
                                                                    //                                                                         });
                                                                    //                                                                       }
                                                                    //                                                                       if (email
                                                                    //                                                                           .text
                                                                    //                                                                           .isEmpty) {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           emailerror =
                                                                    //                                                                               true;
                                                                    //                                                                           emailmessage =
                                                                    //                                                                               "required";
                                                                    //                                                                         });
                                                                    //                                                                       } else {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           emailerror =
                                                                    //                                                                               false;
                                                                    //                                                                         });
                                                                    //                                                                       }
                                                                    //                                                                       if (password
                                                                    //                                                                           .text
                                                                    //                                                                           .isEmpty) {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           passworderror =
                                                                    //                                                                               true;
                                                                    //                                                                           passwordmessage =
                                                                    //                                                                               "required";
                                                                    //                                                                         });
                                                                    //                                                                       } else {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           passworderror =
                                                                    //                                                                               false;
                                                                    //                                                                         });
                                                                    //                                                                       }
                                                                    //                                                                       if (!nameerror &&
                                                                    //                                                                           !designationerror &&
                                                                    //                                                                           !phonenumbererror &&
                                                                    //                                                                           !emailerror &&
                                                                    //                                                                           !phonenumbererror) {
                                                                    //                                                                         setState(
                                                                    //                                                                             () {
                                                                    //                                                                           loading =
                                                                    //                                                                               true;
                                                                    //                                                                         });
                                                                    //                                                                       }
                                                                    //                                                                       SharedPreferences
                                                                    //                                                                           prefs =
                                                                    //                                                                           await SharedPreferences
                                                                    //                                                                               .getInstance();
                                                                    //                                                                       String?
                                                                    //                                                                           adminId =
                                                                    //                                                                           prefs.getString(
                                                                    //                                                                               "adminId");
                                                                    //                                                                       if (adminId !=
                                                                    //                                                                           null) {
                                                                    //                                                                         try {
                                                                    //                                                                           await StaffMemberRepository()
                                                                    //                                                                               .addStaffMember(
                                                                    //                                                                             adminId:
                                                                    //                                                                                 adminId,
                                                                    //                                                                             staffmemberName:
                                                                    //                                                                                 name.text,
                                                                    //                                                                             staffmemberDesignation:
                                                                    //                                                                                 designation.text,
                                                                    //                                                                             staffmemberPhoneNumber:
                                                                    //                                                                                 phonenumber.text,
                                                                    //                                                                             staffmemberEmail:
                                                                    //                                                                                 email.text,
                                                                    //                                                                             staffmemberPassword:
                                                                    //                                                                                 password.text,
                                                                    //                                                                           );
                                                                    //                                                                           setState(
                                                                    //                                                                               () {
                                                                    //                                                                             loading =
                                                                    //                                                                                 false;
                                                                    //                                                                           });
                                                                    //                                                                           Navigator.of(context)
                                                                    //                                                                               .pop(true);
                                                                    //                                                                         } catch (e) {
                                                                    //                                                                           setState(
                                                                    //                                                                               () {
                                                                    //                                                                             loading =
                                                                    //                                                                                 false;
                                                                    //                                                                           });
                                                                    //                                                                           // Handle error
                                                                    //                                                                         }
                                                                    //                                                                       }
                                                                    //                                                                     },
                                                                    //                                                                     child:
                                                                    //                                                                         ClipRRect(
                                                                    //                                                                       borderRadius:
                                                                    //                                                                           BorderRadius.circular(
                                                                    //                                                                               5.0),
                                                                    //                                                                       child:
                                                                    //                                                                           Container(
                                                                    //                                                                         height:
                                                                    //                                                                             30.0,
                                                                    //                                                                         width: MediaQuery.of(context).size.width *
                                                                    //                                                                             .36,
                                                                    //                                                                         decoration:
                                                                    //                                                                             BoxDecoration(
                                                                    //                                                                           borderRadius:
                                                                    //                                                                               BorderRadius.circular(5.0),
                                                                    //                                                                           color: blueColor
                                                                    //
                                                                    //
                                                                    // ,
                                                                    //                                                                           boxShadow: [
                                                                    //                                                                             BoxShadow(
                                                                    //                                                                               color: Colors.grey,
                                                                    //                                                                               offset: Offset(0.0, 1.0), //(x,y)
                                                                    //                                                                               blurRadius: 6.0,
                                                                    //                                                                             ),
                                                                    //                                                                           ],
                                                                    //                                                                         ),
                                                                    //                                                                         child:
                                                                    //                                                                             Center(
                                                                    //                                                                           child:
                                                                    //                                                                               Text(
                                                                    //                                                                             "Add staff Member",
                                                                    //                                                                             style: TextStyle(
                                                                    //                                                                                 color: Colors.white,
                                                                    //                                                                                 fontWeight: FontWeight.bold,
                                                                    //                                                                                 fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 18),
                                                                    //                                                                           ),
                                                                    //                                                                         ),
                                                                    //                                                                       ),
                                                                    //                                                                     ),
                                                                    //                                                                   ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        // Reset error states
                                                                        setState(
                                                                            () {
                                                                          nameerror =
                                                                              false;
                                                                          designationerror =
                                                                              false;
                                                                          phonenumbererror =
                                                                              false;
                                                                          emailerror =
                                                                              false;
                                                                          passworderror =
                                                                              false;
                                                                        });

                                                                        // Validate fields
                                                                        bool
                                                                            isValid =
                                                                            true;

                                                                        if (name
                                                                            .text
                                                                            .isEmpty) {
                                                                          setState(
                                                                              () {
                                                                            nameerror =
                                                                                true;
                                                                            namemessage =
                                                                                "required";
                                                                          });
                                                                          isValid =
                                                                              false;
                                                                        }

                                                                        if (designation
                                                                            .text
                                                                            .isEmpty) {
                                                                          setState(
                                                                              () {
                                                                            designationerror =
                                                                                true;
                                                                            designationmessage =
                                                                                "required";
                                                                          });
                                                                          isValid =
                                                                              false;
                                                                        }

                                                                        // Validate phone number
                                                                        String formattedPhoneNumber = phonenumber.text.replaceAll(
                                                                            RegExp(r'\D'),
                                                                            '');
                                                                        if (formattedPhoneNumber
                                                                            .isEmpty) {
                                                                          setState(
                                                                              () {
                                                                            phonenumbererror =
                                                                                true;
                                                                            phonenumbermessage =
                                                                                "required";
                                                                          });
                                                                          isValid =
                                                                              false;
                                                                        } else if (formattedPhoneNumber.length !=
                                                                            10) {
                                                                          setState(
                                                                              () {
                                                                            phonenumbererror =
                                                                                true;
                                                                            phonenumbermessage =
                                                                                "must be 10 digits";
                                                                          });
                                                                          isValid =
                                                                              false;
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            phonenumbererror =
                                                                                false;
                                                                          });
                                                                        }

                                                                        // Validate email
                                                                        if (email
                                                                            .text
                                                                            .isEmpty) {
                                                                          setState(
                                                                              () {
                                                                            emailerror =
                                                                                true;
                                                                            emailmessage =
                                                                                "required";
                                                                          });
                                                                          isValid =
                                                                              false;
                                                                        } else if (!EmailValidator.validate(
                                                                            email.text)) {
                                                                          setState(
                                                                              () {
                                                                            emailerror =
                                                                                true;
                                                                            emailmessage =
                                                                                "Email is not valid";
                                                                          });
                                                                          isValid =
                                                                              false;
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            emailerror =
                                                                                false;
                                                                          });
                                                                        }

                                                                        // Validate password
                                                                        if (password
                                                                            .text
                                                                            .isEmpty) {
                                                                          setState(
                                                                              () {
                                                                            passworderror =
                                                                                true;
                                                                            passwordmessage =
                                                                                "required";
                                                                          });
                                                                          isValid =
                                                                              false;
                                                                        } else if (password.text.length <
                                                                            8) {
                                                                          setState(
                                                                              () {
                                                                            passworderror =
                                                                                true;
                                                                            passwordmessage =
                                                                                "at least 8 characters";
                                                                          });
                                                                          isValid =
                                                                              false;
                                                                        } else {
                                                                          String?
                                                                              validationMessage =
                                                                              ValidatePassword(password.text);
                                                                          if (validationMessage !=
                                                                              null) {
                                                                            setState(() {
                                                                              passworderror = true;
                                                                              passwordmessage = validationMessage; // Use the dynamic message
                                                                            });
                                                                            isValid =
                                                                                false;
                                                                          } else {
                                                                            setState(() {
                                                                              passworderror = false; // No error
                                                                            });
                                                                          }
                                                                        }

                                                                        // If all fields are valid, proceed to add the staff member
                                                                        if (isValid) {
                                                                          setState(
                                                                              () {
                                                                            loading =
                                                                                true;
                                                                          });

                                                                          SharedPreferences
                                                                              prefs =
                                                                              await SharedPreferences.getInstance();
                                                                          String?
                                                                              adminId =
                                                                              prefs.getString("adminId");

                                                                          if (adminId !=
                                                                              null) {
                                                                            try {
                                                                              await StaffMemberRepository().addStaffMember(
                                                                                adminId: adminId,
                                                                                staffmemberName: name.text,
                                                                                staffmemberDesignation: designation.text,
                                                                                staffmemberPhoneNumber: phonenumber.text,
                                                                                staffmemberEmail: email.text,
                                                                                staffmemberPassword: password.text,
                                                                              );
                                                                              setState(() {
                                                                                loading = false;
                                                                              });
                                                                              Navigator.of(context).pop(true);
                                                                            } catch (e) {
                                                                              setState(() {
                                                                                loading = false;
                                                                              });
                                                                              // Handle error
                                                                            }
                                                                          }
                                                                        }
                                                                      },
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              37.0,
                                                                          width:
                                                                              MediaQuery.of(context).size.width * .36,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5.0),
                                                                            color:
                                                                                blueColor,
                                                                            boxShadow: [
                                                                              const BoxShadow(
                                                                                color: Colors.grey,
                                                                                offset: Offset(0.0, 1.0), //(x,y)
                                                                                blurRadius: 6.0,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child: loading
                                                                                ? const SpinKitFadingCircle(
                                                                                    color: Colors.white,
                                                                                    size: 25.0,
                                                                                  )
                                                                                : Text(
                                                                                    "Add Staff Member",
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 18,
                                                                                    ),
                                                                                  ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: const Text(
                                                                          "Cancel"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
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
                                                const Icon(
                                                  Icons.add,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  'Add New Staffmember',
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 12
                                                              : 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                          // height: MediaQuery.of(context)
                                          //     .size
                                          //     .height *
                                          //     .05,
                                          height: 50,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFF8A95A8),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              value: selectedStaff,
                                              hint: Text(
                                                'Select',
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 18,
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                ),
                                              ),
                                              onChanged: (String? newValue) {
                                                if (newValue ==
                                                    'Edit_properties') {
                                                  // Prevent the dropdown from changing the selected item
                                                  setState(() {
                                                    selectedStaff = null;
                                                  });
                                                  // Show the dialog
                                                  // showDialog(
                                                  //   context: context,
                                                  //   builder:
                                                  //       (BuildContext context) {
                                                  //     //  bool isChecked = false; // Moved isChecked inside the StatefulBuilder
                                                  //     return StatefulBuilder(
                                                  //       builder: (BuildContext
                                                  //       context,
                                                  //           StateSetter
                                                  //           setState) {
                                                  //         return AlertDialog(
                                                  //           backgroundColor:
                                                  //           Colors.white,
                                                  //           surfaceTintColor:
                                                  //           Colors.white,
                                                  //           title: Text(
                                                  //             "Add Rental Owner",
                                                  //             style: TextStyle(
                                                  //                 fontWeight:
                                                  //                 FontWeight
                                                  //                     .bold,
                                                  //                 color: Color
                                                  //                     .fromRGBO(
                                                  //                     21,
                                                  //                     43,
                                                  //                     81,
                                                  //                     1),
                                                  //                 fontSize: 15),
                                                  //           ),
                                                  //           content:
                                                  //           SingleChildScrollView(
                                                  //               child:
                                                  //               Column(
                                                  //                 children: [],
                                                  //               )),
                                                  //         );
                                                  //       },
                                                  //     );
                                                  //   },
                                                  // );
                                                } else {
                                                  setState(() {
                                                    selectedStaff = newValue;
                                                    print(selectedStaff);
                                                  });
                                                }
                                              },
                                              items: dropdownItems,
                                              isExpanded: true,
                                              buttonStyleData: ButtonStyleData(
                                                height: 50,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                              dropdownStyleData:
                                                  DropdownStyleData(
                                                maxHeight: 300,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .5,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.white,
                                                ),
                                                offset: const Offset(0, -5),
                                                scrollbarTheme:
                                                    ScrollbarThemeData(
                                                  radius:
                                                      const Radius.circular(40),
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
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                ),
                const SizedBox(
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
                        border: Border.all(color: blueColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'RECIDENTIAL UNIT',
                                  style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Enter Recidential Units',
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
                                          padding: const EdgeInsets.only(
                                              left: 16, right: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Align(
                                              //   alignment:
                                              //       Alignment.centerRight,
                                              //   child: InkWell(
                                              //     onTap: () =>
                                              //         removePropertyGroup(
                                              //             index),
                                              //     child: Icon(Icons.close,
                                              //         color: Colors.black),
                                              //   ),
                                              // ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Visibility(
                                                  visible:
                                                      !(selectedpropertytype ==
                                                              'Residential' &&
                                                          selectedIsMultiUnit ==
                                                              false &&
                                                          index == 0),
                                                  child: InkWell(
                                                    onTap: () =>
                                                        removePropertyGroup(
                                                            index),
                                                    child: const Icon(
                                                        Icons.close,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              ...group,
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(
                              height: 15,
                            ),
                            if (selectedpropertytypedata?.isMultiunit == true)
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                    Container(
                                      height: 40,
                                      width: MediaQuery.of(context).size.width *
                                          .38,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        // borderRadius: BorderRadius.circular(3),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(color: blueColor),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: Colors.grey,
                                        //     offset: Offset(0.0, 1.0), //(x,y)
                                        //     blurRadius: 6.0,
                                        //   ),
                                        // ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Add another unit",
                                          style: TextStyle(
                                              color: blueColor,
                                              // fontWeight: FontWeight.bold,
                                              fontSize: 14),
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
                        border: Border.all(color: blueColor),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'COMMERCIAL UNIT',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Enter Commercial Units',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
                                            padding: const EdgeInsets.only(
                                                left: 16, right: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Align(
                                                //   alignment:
                                                //       Alignment.centerRight,
                                                //   child: InkWell(
                                                //     onTap: () =>
                                                //         removePropertyGroup(
                                                //             index),
                                                //     child: Icon(Icons.close,
                                                //         color: Colors.black),
                                                //   ),
                                                // ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Visibility(
                                                    visible:
                                                        !(selectedpropertytype ==
                                                                'Commercial' &&
                                                            selectedIsMultiUnit ==
                                                                false &&
                                                            index == 0),
                                                    child: InkWell(
                                                      onTap: () =>
                                                          removePropertyGroup(
                                                              index),
                                                      child: const Icon(
                                                          Icons.close,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                ...group,
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 15),
                              if (selectedpropertytypedata?.isMultiunit == true)
                                GestureDetector(
                                  onTap: () {
                                    addPropertyGroup();
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02),
                                      Container(
                                        height: 40,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .38,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          // borderRadius: BorderRadius.circular(3),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(color: blueColor),
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Colors.grey,
                                          //     offset: Offset(0.0, 1.0), //(x,y)
                                          //     blurRadius: 6.0,
                                          //   ),
                                          // ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Add another unit",
                                            style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
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
                  const Text(
                    "required",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    //SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                    GestureDetector(
//                       onTap: () async {
//                         if (address.text.isEmpty) {
//                           setState(() {
//                             addresserror = true;
//                             addressmessage = "required";
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
//                           // print(selectedpropertytypedata!.propertyId);
//                           print('hiii${widget.properties.propertyId}');
//                           print('staff${widget.properties.staffMemberId}');
//                           SharedPreferences prefs =
//                           await SharedPreferences.getInstance();
//                           String? id = prefs.getString("adminId");
//                           Rental rentals = Rental(
//                             rentalId: widget.rentalId,
//                             adminId: id,
//                             propertyId: widget.properties.propertyId,
//                             // propertyId: selectedpropertytypedata!.propertyId,
//                             address: address.text,
//                             city: city.text,
//                             state: state.text,
//                             country: country.text,
//                             postcode: postalcode.text,
//                             // staffMemberId: sid,
//                             staffMemberId: widget.properties.staffMemberId,
//                           );
//                           List<Unit> units = [];
//                           if (propertyGroupControllers.isNotEmpty) {
//                             List<TextEditingController> firstControllers =
//                             propertyGroupControllers[0];
//                             bool isFirstBlank = firstControllers
//                                 .every((controller) => controller.text.isEmpty);
//                             //1714547540497
//                             //1709188861753
//                             if (isFirstBlank) {
//                               propertyGroupControllers.removeAt(0);
//                             }
//                           }
//                           if (selectedpropertytype == 'Commercial' &&
//                               selectedIsMultiUnit == true) {
//                             for (int i = 0;
//                             i < propertyGroupControllers.length;
//                             i++) {
//                               if (units.length <= i) {
//                                 units.add(Unit());
//                               }
//                               List<TextEditingController> controllers =
//                               propertyGroupControllers[i];
//                               units[i].unit = controllers[0].text;
//                               units[i].address = controllers[1].text;
//                               units[i].sqft = controllers[2].text;
//                               units[i].Image = propertyGroupImagenames[i];
//                               //      units[i].bath = controllers[3].text;
//                               //     units[i].bed = controllers[4].text;
//
// //                                  units[i].unit = controllers[0].text;
//                             }
//                           } else if (selectedpropertytype == 'Residential' &&
//                               selectedIsMultiUnit == true) {
//                             for (int i = 0;
//                             i < propertyGroupControllers.length;
//                             i++) {
//                               if (units.length <= i) {
//                                 units.add(Unit());
//                               }
//                               List<TextEditingController> controllers =
//                               propertyGroupControllers[i];
//                               units[i].unit = controllers[0].text;
//                               units[i].address = controllers[1].text;
//                               units[i].sqft = controllers[2].text;
//                               units[i].bath = controllers[3].text;
//                               units[i].bed = controllers[4].text;
//                               units[i].Image = propertyGroupImagenames[i];
// //                                  units[i].unit = controllers[0].text;
//                             }
//                           } else if (selectedpropertytype == 'Residential') {
//                             for (int i = 0;
//                             i < propertyGroupControllers.length;
//                             i++) {
//                               if (units.length <= i) {
//                                 units.add(Unit());
//                               }
//                               List<TextEditingController> controllers =
//                               propertyGroupControllers[i];
//                               print(controllers.length);
//                               units[i].sqft = controllers[0].text;
//                               units[i].bath = controllers[1].text;
//                               units[i].bed = controllers[2].text;
//                               units[i].Image = propertyGroupImagenames[i];
// //                                  units[i].unit = controllers[0].text;
//                             }
//                           } else if (selectedpropertytype == 'Commercial') {
//                             for (int i = 0;
//                             i < propertyGroupControllers.length;
//                             i++) {
//                               if (units.length <= i) {
//                                 units.add(Unit());
//                               }
//                               List<TextEditingController> controllers =
//                               propertyGroupControllers[i];
//                               units[i].sqft = controllers[0].text;
//                               units[i].Image = propertyGroupImagenames[i];
//                               //units[i].address = controllers[1].text;
//                               //units[i].sqft = controllers[2].text;
// //                                  units[i].unit = controllers[0].text;
//                             }
//                           }
//                           RentalOwners owners = RentalOwners(
//                             adminId: id,
//                             firstName: firstname.text,
//                             companyName: comname.text,
//                             primaryEmail: primaryemail.text,
//                             phoneNumber: phonenum.text,
//                             city: city2.text,
//                             state: state2.text,
//                             country: county2.text,
//                             postalCode: code2.text,
//                           );
//                           RentalRequest rentalrequest = RentalRequest(
//                               rentalOwner: owners,
//                               rental: rentals,
//                               units: units);
//                           final updatedOwner = RentalOwner(
//                             rentalOwnerName: firstnameController.text,
//                             rentalOwnerCompanyName: comnameController.text,
//                             rentalOwnerPrimaryEmail: primaryemailController.text,
//                             rentalOwnerPhoneNumber: phonenumController.text,
//                             city: cityController.text,
//                             state: stateController.text,
//                             country: countyController.text,
//                             postalCode: codeController.text,
//                           );
//                           RentalOwner? ownerDetails = context.read<OwnerDetailsProvider>().ownerDetails;
//
//                           String processorId = context.read<OwnerDetailsProvider>().selectedprocessorlist ?? "";
//
//                           List<Map<String, String>> processorIds = ownerDetails!.processorList!.map((processor) {
//                             return {
//                               'processor_id': processor.processorId ?? "",
//                             };
//                           }).toList();
//
//                           //Provider.of<OwnerDetailsProvider>(context, listen: false).setOwnerDetails(updatedOwner);
//
//                           Rentals properties = Rentals(
//                               adminId: id,
//                               rentalOwnerData: RentalOwnerData(
//                                   adminId: widget.properties.adminId,
//                                   rentalOwnerId: widget.properties.rentalOwnerId,
//                                   rentalOwnerName: updatedOwner.rentalOwnerName,
//                                   rentalOwnerCompanyName: updatedOwner.rentalOwnerCompanyName,
//                                   rentalOwnerPrimaryEmail: updatedOwner.rentalOwnerPrimaryEmail,
//                                   rentalOwnerPhoneNumber: updatedOwner.rentalOwnerPhoneNumber,
//                                   city: updatedOwner.city,
//                                   state: updatedOwner.state,
//                                   country: updatedOwner.country,
//                                   postalCode: updatedOwner.postalCode,
//                                   processorList: processorIds
//                               ),
//                               rentalId: widget.rentalId,
//                               propertyId: widget.properties.propertyId,
//                               rentalAddress: address.text,
//                               rentalCity: city.text,
//                               rentalState: state.text,
//                               rentalCountry: country.text,
//                               rentalPostcode: postalcode.text,
//                               staffMemberId: sid,
//                               processor_id:processorId
//                           );
//                           PropertiesRepository()
//                               .updateRental1(properties)
//                               .then((value) {
//                             setState(() {
//                               widget.properties.rentalOwnerData = RentalOwnerData(
//                                 adminId: widget.properties.adminId,
//                                 rentalOwnerId: widget.properties.rentalOwnerId,
//                                 rentalOwnerName: updatedOwner.rentalOwnerName,
//                                 rentalOwnerCompanyName: updatedOwner.rentalOwnerCompanyName,
//                                 rentalOwnerPrimaryEmail: updatedOwner.rentalOwnerPrimaryEmail,
//                                 rentalOwnerPhoneNumber: updatedOwner.rentalOwnerPhoneNumber,
//                                 rentalOwnerAlternativeEmail: updatedOwner.rentalOwnerAlternateEmail,
//                                 rentalOwnerBuisinessNumber: updatedOwner.rentalOwnerBusinessNumber,
//                                 rentalOwnerHomeNumber: updatedOwner.rentalOwnerHomeNumber,
//                                 city: updatedOwner.city,
//                                 state: updatedOwner.state,
//                                 country: updatedOwner.country,
//                                 postalCode: updatedOwner.postalCode,
//                               );
//                               widget.properties.rentalAddress = address.text;
//                               widget.properties.propertyTypeData?.propertyType =
//                                   selectedpropertytype;
//                               widget.properties.propertyTypeData
//                                   ?.propertySubType = selectedpropertytype;
//                               isLoading = false;
//                             });
//                             Navigator.of(context).pop(true);
//                           }).catchError((e) {
//                             setState(() {
//                               isLoading = false;
//                             });
//                           });
//                         }
//                         print(selectedValue);
//                       },
                      onTap: () async {
                        print("calling");

                        // Validate selected property
                        if (selectedProperty == null) {
                          setState(() {
                            showError = true;
                          });
                          return; // Exit if no property is selected
                        } else {
                          setState(() {
                            showError = false;
                          });
                        }

                        // Validate form fields
                        if (address.text.trim().isEmpty) {
                          setState(() {
                            addresserror = true;
                            addressmessage = "required";
                          });
                          return; // Exit if address is empty
                        } else {
                          setState(() {
                            addresserror = false;
                          });
                        }

                        if (city.text.trim().isEmpty) {
                          setState(() {
                            cityerror = true;
                            citymessage = "required";
                          });
                          return; // Exit if city is empty
                        } else {
                          setState(() {
                            cityerror = false;
                          });
                        }

                        if (state.text.trim().isEmpty) {
                          setState(() {
                            stateerror = true;
                            statemessage = "required";
                          });
                          return; // Exit if state is empty
                        } else {
                          setState(() {
                            stateerror = false;
                          });
                        }

                        if (country.text.trim().isEmpty) {
                          setState(() {
                            countryerror = true;
                            countrymessage = "required";
                          });
                          return; // Exit if country is empty
                        } else {
                          setState(() {
                            countryerror = false;
                          });
                        }

                        if (postalcode.text.trim().isEmpty) {
                          setState(() {
                            postalcodeerror = true;
                            postalcodemessage = "required";
                          });
                          return; // Exit if postal code is empty
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
                          return; // Exit if owner details are not provided
                        } else {
                          setState(() {
                            hasError = false;
                          });
                        }

                        // Check for unit changes
                        print('=== STARTING CHANGE DETECTION ===');
                        print('Property Type: $selectedpropertytype');
                        print('Is Multi Unit: $selectedIsMultiUnit');
                        print('Checking for unit changes...');
                        print('Data length: ${data.length}');
                        print(
                            'Controllers length: ${propertyGroupControllers.length}');

                        bool hasUnitChanges = false;
                        print('Checking unit changes...');

                        // Debug: Print controller structure
                        print('=== CONTROLLER STRUCTURE DEBUG ===');
                        for (int i = 0;
                            i < propertyGroupControllers.length;
                            i++) {
                          print('Unit $i controllers:');
                          for (int j = 0;
                              j < propertyGroupControllers[i].length;
                              j++) {
                            print(
                                '  Controller $j: "${propertyGroupControllers[i][j].text}"');
                          }
                        }
                        print('=== END CONTROLLER STRUCTURE DEBUG ===');

                        if (data.length == propertyGroupControllers.length) {
                          for (int i = 0; i < data.length; i++) {
                            var oldUnit = data[i];
                            var controllers = propertyGroupControllers[i];

                            // Add detailed debug prints
                            print('Unit ${i + 1} Details:');
                            print('Old sqft: "${oldUnit.rentalsqft}"');
                            print(
                                'New sqft: "${controllers[0].text}"'); // Fixed: sqft is in controller[0]
                            print('Old unit: "${oldUnit.rentalunit}"');
                            print(
                                'New unit: "${controllers[0].text}"'); // For single unit, unit name is same as sqft
                            print('Old address: "${oldUnit.rentalunitadress}"');
                            print('New address: "${controllers[1].text}"');

                            // Compare values based on property type
                            bool sqftChanged = false;
                            bool unitChanged = false;
                            bool addressChanged = false;
                            bool bathChanged = false;
                            bool bedChanged = false;
                            bool imageChanged = false;

                            print(
                                'Comparing values for ${selectedpropertytype} ${selectedIsMultiUnit == true ? "multi-unit" : "single unit"}:');

                            // Fix property type detection - Single-Family should be Commercial
                            String actualPropertyType =
                                getActualPropertyType(selectedpropertytype);

                            if (actualPropertyType == 'Commercial') {
                              if (selectedIsMultiUnit == true) {
                                // Commercial multi-unit
                                String oldSqft =
                                    oldUnit.rentalsqft?.trim() ?? '';
                                String newSqft = controllers[2].text.trim();
                                String oldUnitName =
                                    oldUnit.rentalunit?.trim() ?? '';
                                String newUnitName = controllers[0].text.trim();
                                String oldAddress =
                                    oldUnit.rentalunitadress?.trim() ?? '';
                                String newAddress = controllers[1].text.trim();

                                sqftChanged = oldSqft != newSqft;
                                unitChanged = oldUnitName != newUnitName;
                                addressChanged = oldAddress != newAddress;

                                print('Commercial multi-unit comparison:');
                                print(
                                    '- Sqft: "$oldSqft" -> "$newSqft" = $sqftChanged');
                                print(
                                    '- Unit: "$oldUnitName" -> "$newUnitName" = $unitChanged');
                                print(
                                    '- Address: "$oldAddress" -> "$newAddress" = $addressChanged');
                              } else {
                                // Commercial single unit
                                String oldSqft =
                                    oldUnit.rentalsqft?.trim() ?? '';
                                String newSqft = controllers[0].text.trim();

                                sqftChanged = oldSqft != newSqft;

                                print('Commercial single unit comparison:');
                                print(
                                    '- Sqft: "$oldSqft" -> "$newSqft" = $sqftChanged');
                              }
                            } else if (actualPropertyType == 'Residential') {
                              if (selectedIsMultiUnit == true) {
                                // Residential multi-unit
                                print('=== RESIDENTIAL MULTI-UNIT DEBUG ===');
                                print(
                                    'Controllers available: ${controllers.length}');
                                for (int c = 0; c < controllers.length; c++) {
                                  print(
                                      'Controller $c: "${controllers[c].text}"');
                                }

                                String oldSqft =
                                    oldUnit.rentalsqft?.trim() ?? '';
                                String newSqft = controllers[2].text.trim();
                                String oldUnitName =
                                    oldUnit.rentalunit?.trim() ?? '';
                                String newUnitName = controllers[0].text.trim();
                                String oldAddress =
                                    oldUnit.rentalunitadress?.trim() ?? '';
                                String newAddress = controllers[1].text.trim();
                                String oldBath =
                                    oldUnit.rentalbath?.trim() ?? '';
                                String newBath = controllers[3].text.trim();
                                String oldBed = oldUnit.rentalbed?.trim() ?? '';
                                String newBed = controllers[4].text.trim();

                                sqftChanged = oldSqft != newSqft;
                                unitChanged = oldUnitName != newUnitName;
                                addressChanged = oldAddress != newAddress;
                                bathChanged = oldBath != newBath;
                                bedChanged = oldBed != newBed;

                                print('Residential multi-unit comparison:');
                                print(
                                    '- Sqft: "$oldSqft" -> "$newSqft" = $sqftChanged');
                                print(
                                    '- Unit: "$oldUnitName" -> "$newUnitName" = $unitChanged');
                                print(
                                    '- Address: "$oldAddress" -> "$newAddress" = $addressChanged');
                                print(
                                    '- Bath: "$oldBath" -> "$newBath" = $bathChanged');
                                print(
                                    '- Bed: "$oldBed" -> "$newBed" = $bedChanged');
                              } else {
                                // Residential single unit
                                // Extract correct values from potentially corrupted data for comparison
                                Map<String, String> correctValues =
                                    extractCorrectValues(oldUnit);

                                String oldSqft = correctValues['sqft'] ?? '';
                                String newSqft = controllers[0].text.trim();
                                String oldBath = correctValues['bath'] ?? '';
                                String newBath = controllers[1].text.trim();
                                String oldBed = correctValues['bed'] ?? '';
                                String newBed = controllers[2].text.trim();

                                // Check if the data is corrupted (sqft contains "Bed" or "Bath")
                                bool isDataCorrupted = oldUnit.rentalsqft
                                            ?.toLowerCase()
                                            .contains('bed') ==
                                        true ||
                                    oldUnit.rentalsqft
                                            ?.toLowerCase()
                                            .contains('bath') ==
                                        true;

                                if (isDataCorrupted) {
                                  print(
                                      'Detected corrupted data - using extracted correct values for comparison');
                                  print(
                                      'Original corrupted sqft: "${oldUnit.rentalsqft}"');
                                  print('Extracted correct sqft: "$oldSqft"');
                                  print('Extracted correct bath: "$oldBath"');
                                  print('Extracted correct bed: "$oldBed"');
                                }

                                // Compare using extracted correct values
                                sqftChanged = oldSqft != newSqft;
                                bathChanged = oldBath != newBath;
                                bedChanged = oldBed != newBed;

                                print('Residential single unit comparison:');
                                print(
                                    '- Sqft: "$oldSqft" -> "$newSqft" = $sqftChanged');
                                print(
                                    '- Bath: "$oldBath" -> "$newBath" = $bathChanged');
                                print(
                                    '- Bed: "$oldBed" -> "$newBed" = $bedChanged');
                                print('- Data corrupted: $isDataCorrupted');
                              }
                            }

                            // Check for image changes
                            print('Checking image changes for unit ${i + 1}:');
                            print('Old images: ${oldUnit.rentalImages}');
                            print(
                                'New local image: ${propertyGroupImages[i]?.path}');
                            print(
                                'New network image: ${propertyGroupImagenames[i]}');

                            // Check if there's a new local image (user added a new image)
                            if (propertyGroupImages[i] != null) {
                              imageChanged = true;
                              print('Image changed: New local image added');
                            }
                            // Check if network image was removed (user removed existing image)
                            else if (oldUnit.rentalImages != null &&
                                oldUnit.rentalImages!.isNotEmpty &&
                                (propertyGroupImagenames[i] == null ||
                                    propertyGroupImagenames[i]!.isEmpty)) {
                              imageChanged = true;
                              print('Image changed: Existing image removed');
                            }
                            // Check if network image changed (different from original)
                            else if (oldUnit.rentalImages != null &&
                                oldUnit.rentalImages!.isNotEmpty &&
                                propertyGroupImagenames[i] != null &&
                                propertyGroupImagenames[i]!.isNotEmpty) {
                              String oldImage = oldUnit.rentalImages![0];
                              String newImage = propertyGroupImagenames[i]!;
                              // Extract filename from URL if it's a full URL
                              if (newImage.startsWith('http')) {
                                newImage = newImage.split('/').last;
                              }
                              if (oldImage != newImage) {
                                imageChanged = true;
                                print(
                                    'Image changed: Different image (old: $oldImage, new: $newImage)');
                              }
                            }

                            // Check if any changes were detected
                            if (sqftChanged ||
                                unitChanged ||
                                addressChanged ||
                                bathChanged ||
                                bedChanged ||
                                imageChanged) {
                              print('Changes detected in unit ${i + 1}:');
                              print('- Sqft changed: $sqftChanged');
                              print('- Unit changed: $unitChanged');
                              print('- Address changed: $addressChanged');
                              print('- Bath changed: $bathChanged');
                              print('- Bed changed: $bedChanged');
                              print('- Image changed: $imageChanged');
                              hasUnitChanges = true;
                              break; // Exit the loop once we find a change
                            } else {
                              print('No changes detected in unit ${i + 1}');
                            }
                          }
                        }

                        // Check for changes
                        print('Unit changes detected: $hasUnitChanges');

                        bool hasChanges = hasUnitChanges ||
                            address.text != initialAddress ||
                            city.text != initialCity ||
                            state.text != initialState ||
                            country.text != initialCountry ||
                            postalcode.text != initialPostalCode ||
                            firstname.text != Ownersdetails?.rentalOwnerName ||
                            comname.text !=
                                Ownersdetails?.rentalOwnerCompanyName ||
                            primaryemail.text !=
                                Ownersdetails?.rentalOwnerPrimaryEmail ||
                            alternativeemail.text !=
                                Ownersdetails?.rentalOwnerAlternateEmail ||
                            phonenum.text !=
                                Ownersdetails?.rentalOwnerPhoneNumber ||
                            homenum.text !=
                                Ownersdetails?.rentalOwnerHomeNumber ||
                            businessnum.text !=
                                Ownersdetails?.rentalOwnerBusinessNumber ||
                            street2.text != Ownersdetails?.streetAddress ||
                            city2.text != Ownersdetails?.city ||
                            state2.text != Ownersdetails?.state ||
                            county2.text != Ownersdetails?.country ||
                            code2.text != Ownersdetails?.postalCode ||
                            selectedStaff != widget.properties.staffMemberId;

                        print('=== CHANGE DETECTION DEBUG ===');
                        print('Final hasChanges value: $hasChanges');
                        print('Unit changes: $hasUnitChanges');

                        print('--- Property Details ---');
                        print('Current address: "${address.text}"');
                        print('Initial address: "$initialAddress"');
                        print(
                            'Address changed: ${address.text != initialAddress}');

                        print('Current city: "${city.text}"');
                        print('Initial city: "$initialCity"');
                        print('City changed: ${city.text != initialCity}');

                        print('Current state: "${state.text}"');
                        print('Initial state: "$initialState"');
                        print('State changed: ${state.text != initialState}');

                        print('Current country: "${country.text}"');
                        print('Initial country: "$initialCountry"');
                        print(
                            'Country changed: ${country.text != initialCountry}');

                        print('Current postal code: "${postalcode.text}"');
                        print('Initial postal code: "$initialPostalCode"');
                        print(
                            'Postal code changed: ${postalcode.text != initialPostalCode}');

                        print('--- Owner Details ---');
                        print('Current first name: "${firstname.text}"');
                        print(
                            'Initial first name: "${Ownersdetails?.rentalOwnerName}"');
                        print(
                            'First name changed: ${firstname.text != Ownersdetails?.rentalOwnerName}');

                        print('Current company name: "${comname.text}"');
                        print(
                            'Initial company name: "${Ownersdetails?.rentalOwnerCompanyName}"');
                        print(
                            'Company name changed: ${comname.text != Ownersdetails?.rentalOwnerCompanyName}');

                        print('Current primary email: "${primaryemail.text}"');
                        print(
                            'Initial primary email: "${Ownersdetails?.rentalOwnerPrimaryEmail}"');
                        print(
                            'Primary email changed: ${primaryemail.text != Ownersdetails?.rentalOwnerPrimaryEmail}');

                        print(
                            'Current alternative email: "${alternativeemail.text}"');
                        print(
                            'Initial alternative email: "${Ownersdetails?.rentalOwnerAlternateEmail}"');
                        print(
                            'Alternative email changed: ${alternativeemail.text != Ownersdetails?.rentalOwnerAlternateEmail}');

                        print('Current phone number: "${phonenum.text}"');
                        print(
                            'Initial phone number: "${Ownersdetails?.rentalOwnerPhoneNumber}"');
                        print(
                            'Phone number changed: ${phonenum.text != Ownersdetails?.rentalOwnerPhoneNumber}');

                        print('Current home number: "${homenum.text}"');
                        print(
                            'Initial home number: "${Ownersdetails?.rentalOwnerHomeNumber}"');
                        print(
                            'Home number changed: ${homenum.text != Ownersdetails?.rentalOwnerHomeNumber}');

                        print('Current business number: "${businessnum.text}"');
                        print(
                            'Initial business number: "${Ownersdetails?.rentalOwnerBusinessNumber}"');
                        print(
                            'Business number changed: ${businessnum.text != Ownersdetails?.rentalOwnerBusinessNumber}');

                        print('Current street2: "${street2.text}"');
                        print(
                            'Initial street2: "${Ownersdetails?.streetAddress}"');
                        print(
                            'Street2 changed: ${street2.text != Ownersdetails?.streetAddress}');

                        print('Current city2: "${city2.text}"');
                        print('Initial city2: "${Ownersdetails?.city}"');
                        print(
                            'City2 changed: ${city2.text != Ownersdetails?.city}');

                        print('Current state2: "${state2.text}"');
                        print('Initial state2: "${Ownersdetails?.state}"');
                        print(
                            'State2 changed: ${state2.text != Ownersdetails?.state}');

                        print('Current county2: "${county2.text}"');
                        print('Initial county2: "${Ownersdetails?.country}"');
                        print(
                            'County2 changed: ${county2.text != Ownersdetails?.country}');

                        print('Current code2: "${code2.text}"');
                        print('Initial code2: "${Ownersdetails?.postalCode}"');
                        print(
                            'Code2 changed: ${code2.text != Ownersdetails?.postalCode}');

                        print('Current staff: "$selectedStaff"');
                        print(
                            'Initial staff: "${widget.properties.staffMemberId}"');
                        print(
                            'Staff changed: ${selectedStaff != widget.properties.staffMemberId}');
                        print('=== END CHANGE DETECTION DEBUG ===');

                        print("=== TESTING CHANGE DETECTION ===");
                        print("hasChanges value: $hasChanges");

                        if (!hasChanges) {
                          // Show message if no changes detected
                          print("=== NO CHANGES DETECTED - EXITING EARLY ===");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No changes detected'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          Navigator.pop(context, false);
                          return; // Exit if no changes
                        }

                        print(
                            "=== CHANGES DETECTED - PROCEEDING WITH API CALL ===");

                        // Proceed with form submission
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? id = prefs.getString("adminId");

                        Rental rentals = Rental(
                          rentalId: widget.rentalId,
                          adminId: id,
                          propertyId: widget.properties.propertyId,
                          address: address.text.trim(),
                          city: city.text.trim(),
                          state: state.text.trim(),
                          country: country.text.trim(),
                          postcode: postalcode.text.trim(),
                          staffMemberId: widget.properties.staffMemberId,
                        );

                        List<Map<String, dynamic>> convertedUnits = [];

                        // First, validate and clean up controllers
                        if (propertyGroupControllers.isNotEmpty) {
                          List<TextEditingController> firstControllers =
                              propertyGroupControllers[0];
                          bool isFirstBlank = firstControllers.every(
                              (controller) => controller.text.trim().isEmpty);
                          if (isFirstBlank) {
                            propertyGroupControllers.removeAt(0);
                          }
                        }

                        // Prepare units based on property type
                        for (int i = 0;
                            i < propertyGroupControllers.length;
                            i++) {
                          List<TextEditingController> controllers =
                              propertyGroupControllers[i];
                          Map<String, dynamic> unitData = {
                            "admin_id": id,
                            "unit_id": DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString() +
                                "_$i",
                            "rental_images": []
                          };

                          // Handle images - prioritize new images over existing ones
                          print('Handling images for unit $i:');
                          print(
                              '- Local image: ${propertyGroupImages[i]?.path}');
                          print(
                              '- Existing image: ${propertyGroupImagenames[i]}');

                          if (propertyGroupImages[i] != null) {
                            // If new image is selected, use the uploaded filename
                            if (propertyGroupImagenames[i] != null &&
                                propertyGroupImagenames[i]!.isNotEmpty) {
                              // Extract filename from URL if it's a full URL
                              String imageValue = propertyGroupImagenames[i]!;
                              if (imageValue.startsWith('http')) {
                                // Extract filename from URL
                                imageValue = imageValue.split('/').last;
                              }
                              unitData["rental_images"] = [imageValue];
                              print('- Using uploaded filename: $imageValue');
                            } else {
                              // If no filename yet, use the file path temporarily
                              unitData["rental_images"] = [
                                propertyGroupImages[i]!.path
                              ];
                              print(
                                  '- Using file path: ${propertyGroupImages[i]!.path}');
                            }
                          } else if (propertyGroupImagenames[i] != null &&
                              propertyGroupImagenames[i]!.isNotEmpty) {
                            // If no new image but existing image exists, keep the existing one
                            // Extract filename from URL if it's a full URL
                            String imageValue = propertyGroupImagenames[i]!;
                            if (imageValue.startsWith('http')) {
                              // Extract filename from URL
                              imageValue = imageValue.split('/').last;
                            }
                            unitData["rental_images"] = [imageValue];
                            print('- Using existing image: $imageValue');
                          } else {
                            print('- No images for this unit');
                          }

                          String actualPropertyType =
                              getActualPropertyType(selectedpropertytype);

                          if (actualPropertyType == 'Commercial' &&
                              selectedIsMultiUnit == true) {
                            if (controllers[0].text.trim().isNotEmpty &&
                                controllers[1].text.trim().isNotEmpty &&
                                controllers[2].text.trim().isNotEmpty) {
                              unitData.addAll({
                                "rental_unit": controllers[0].text.trim(),
                                "rental_unit_adress":
                                    controllers[1].text.trim(),
                                "rental_sqft": controllers[2].text.trim(),
                              });
                              convertedUnits.add(unitData);
                            }
                          } else if (actualPropertyType == 'Residential' &&
                              selectedIsMultiUnit == true) {
                            print(
                                '=== PREPARING RESIDENTIAL MULTI-UNIT DATA ===');
                            print(
                                'Controller 0 (Unit): "${controllers[0].text.trim()}"');
                            print(
                                'Controller 1 (Address): "${controllers[1].text.trim()}"');
                            print(
                                'Controller 2 (SQft): "${controllers[2].text.trim()}"');
                            print(
                                'Controller 3 (Bath): "${controllers[3].text.trim()}"');
                            print(
                                'Controller 4 (Bed): "${controllers[4].text.trim()}"');

                            if (controllers[0].text.trim().isNotEmpty &&
                                controllers[1].text.trim().isNotEmpty &&
                                controllers[2].text.trim().isNotEmpty &&
                                controllers[3].text.trim().isNotEmpty &&
                                controllers[4].text.trim().isNotEmpty) {
                              unitData.addAll({
                                "rental_unit": controllers[0].text.trim(),
                                "rental_unit_adress":
                                    controllers[1].text.trim(),
                                "rental_sqft": controllers[2].text.trim(),
                                "rental_bath": i < originalValues.length
                                    ? originalValues[i]['bath'] ??
                                        controllers[3].text.trim()
                                    : controllers[3].text.trim(),
                                "rental_bed": i < originalValues.length
                                    ? originalValues[i]['bed'] ??
                                        controllers[4].text.trim()
                                    : controllers[4].text.trim(),
                              });
                              convertedUnits.add(unitData);
                              print('Added unit data: $unitData');
                            } else {
                              print('Skipping unit - some fields are empty');
                            }
                          } else if (actualPropertyType == 'Residential') {
                            if (controllers[0].text.trim().isNotEmpty &&
                                controllers[1].text.trim().isNotEmpty &&
                                controllers[2].text.trim().isNotEmpty) {
                              unitData.addAll({
                                "rental_sqft": controllers[0].text.trim(),
                                "rental_bath": i < originalValues.length
                                    ? originalValues[i]['bath'] ??
                                        controllers[1].text.trim()
                                    : controllers[1].text.trim(),
                                "rental_bed": i < originalValues.length
                                    ? originalValues[i]['bed'] ??
                                        controllers[2].text.trim()
                                    : controllers[2].text.trim(),
                              });
                              convertedUnits.add(unitData);
                            }
                          } else if (actualPropertyType == 'Commercial') {
                            // For Commercial single unit, we only need sqft
                            unitData.addAll({
                              "rental_sqft": controllers[0].text,
                              "rental_unit": "Unit 1", // Default unit name
                              "rental_unit_adress":
                                  address.text, // Use main property address
                            });
                            convertedUnits.add(unitData);
                          }
                        }

                        print("Converted Units: $convertedUnits");

                        RentalOwners owners = RentalOwners(
                          adminId: id,
                          firstName: firstname.text.trim(),
                          companyName: comname.text.trim(),
                          primaryEmail: primaryemail.text.trim(),
                          phoneNumber: phonenum.text.trim(),
                          city: city2.text.trim(),
                          state: state2.text.trim(),
                          country: county2.text.trim(),
                          postalCode: code2.text.trim(),
                        );

                        // RentalRequest rentalrequest = RentalRequest(
                        //   rentalOwner: owners,
                        //   rental: rentals,
                        //   units: units,
                        // );

                        final updatedOwner = RentalOwner(
                          rentalOwnerName: firstnameController.text.trim(),
                          rentalOwnerCompanyName: comnameController.text.trim(),
                          rentalOwnerPrimaryEmail:
                              primaryemailController.text.trim(),
                          rentalOwnerPhoneNumber:
                              phonenumController.text.trim(),
                          city: cityController.text.trim(),
                          state: stateController.text.trim(),
                          country: countyController.text.trim(),
                          postalCode: codeController.text.trim(),
                        );

                        RentalOwner? ownerDetails =
                            context.read<OwnerDetailsProvider>().ownerDetails;

                        String processorId = context
                                .read<OwnerDetailsProvider>()
                                .selectedprocessorlist ??
                            "";

                        List<Map<String, String>> processorIds =
                            ownerDetails!.processorList!.map((processor) {
                          return {
                            'processor_id': processor.processorId ?? "",
                          };
                        }).toList();

                        // Convert List<Unit> to List<Map<String, dynamic>>
                        // convertedUnits is already prepared above

                        print(
                            "Number of units being sent: ${convertedUnits.length}");

                        // Prepare units data
                        List<Map<String, dynamic>> unitData = [];
                        print('Preparing unit data...');
                        print('Property Type: $selectedpropertytype');
                        print('Is Multi Unit: $selectedIsMultiUnit');
                        print(
                            'Controllers length: ${propertyGroupControllers.length}');
                        print('Current controllers values:');
                        for (var controllers in propertyGroupControllers) {
                          for (int i = 0; i < controllers.length; i++) {
                            print('Controller $i: "${controllers[i].text}"');
                          }
                        }
                        print('Data values:');
                        for (var unit in data) {
                          print('Unit sqft: "${unit.rentalsqft}"');
                          print('Unit name: "${unit.rentalunit}"');
                          print('Unit address: "${unit.rentalunitadress}"');
                        }
                        print('Has unit changes: $hasUnitChanges');
                        for (int i = 0;
                            i < propertyGroupControllers.length;
                            i++) {
                          var controllers = propertyGroupControllers[i];
                          print('Preparing unit data for API:');
                          print('Property type: $selectedpropertytype');
                          print('Is multi unit: $selectedIsMultiUnit');
                          print('Current controller values:');
                          for (int j = 0; j < controllers.length; j++) {
                            print('Controller $j: "${controllers[j].text}"');
                          }
                          print('Old unit data:');
                          print('- sqft: "${data[i].rentalsqft}"');
                          print('- unit: "${data[i].rentalunit}"');
                          print('- address: "${data[i].rentalunitadress}"');

                          // For Commercial single unit, ensure sqft goes to rental_sqft
                          Map<String, dynamic> unit;
                          String actualPropertyType =
                              getActualPropertyType(selectedpropertytype);

                          if (actualPropertyType == 'Commercial' &&
                              !selectedIsMultiUnit) {
                            print('Preparing Commercial single unit data');
                            unit = {
                              'admin_id': id,
                              'unit_id': data[i].unitId ??
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                              'rental_unit': controllers[0]
                                  .text, // Use the actual unit name
                              'rental_unit_adress': address.text,
                              'rental_sqft': controllers[0]
                                  .text, // sqft from first controller
                              'rental_images':
                                  propertyGroupImagenames[i] != null
                                      ? [propertyGroupImagenames[i]]
                                      : [],
                              'rental_bath':
                                  "", // Add empty bath for consistency
                              'rental_bed': "", // Add empty bed for consistency
                            };
                          } else {
                            print('Preparing multi-unit data');
                            unit = {
                              'admin_id': id,
                              'unit_id': data[i].unitId ??
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                              'rental_unit': controllers[0].text,
                              'rental_unit_adress': controllers[1].text,
                              'rental_sqft': controllers[2].text,
                              'rental_images':
                                  propertyGroupImagenames[i] != null
                                      ? [propertyGroupImagenames[i]]
                                      : [],
                              'rental_bath': "",
                              'rental_bed': "",
                            };
                          }

                          print('Prepared unit data:');
                          print('- Unit ID: ${unit["unit_id"]}');
                          print('- Unit Name: ${unit["rental_unit"]}');
                          print(
                              '- Unit Address: ${unit["rental_unit_adress"]}');
                          print('- Unit Sqft: ${unit["rental_sqft"]}');
                          print('Prepared unit data:');
                          print('- Unit ID: ${unit["unit_id"]}');
                          print('- Unit Name: ${unit["rental_unit"]}');
                          print(
                              '- Unit Address: ${unit["rental_unit_adress"]}');
                          print('- Unit Sqft: ${unit["rental_sqft"]}');
                          print('Preparing unit ${i + 1}:');
                          print('Unit: ${controllers[0].text.trim()}');
                          print('Address: ${controllers[1].text.trim()}');
                          print('Sqft: ${controllers[2].text.trim()}');
                          if (selectedpropertytype == 'Residential') {
                            unit['rental_bath'] = i < originalValues.length
                                ? originalValues[i]['bath'] ??
                                    controllers[3].text.trim()
                                : controllers[3].text.trim();
                            unit['rental_bed'] = i < originalValues.length
                                ? originalValues[i]['bed'] ??
                                    controllers[4].text.trim()
                                : controllers[4].text.trim();
                          }
                          unitData.add(unit);
                        }
                        print('Prepared unit data: $unitData');

                        print('Has unit changes: $hasUnitChanges');
                        print('Final unit data: $unitData');

                        print('Making API call with updated unit data...');
                        Rentals properties = Rentals(
                          units: unitData,
                          // Always pass the units, even if empty
                          adminId: id,
                          rentalOwnerData: RentalOwnerData(
                            adminId: widget.properties.adminId,
                            rentalOwnerId: ownerDetails.rentalOwnerId,
                            rentalOwnerName: updatedOwner.rentalOwnerName,
                            rentalOwnerCompanyName:
                                updatedOwner.rentalOwnerCompanyName,
                            rentalOwnerPrimaryEmail:
                                updatedOwner.rentalOwnerPrimaryEmail,
                            rentalOwnerPhoneNumber:
                                updatedOwner.rentalOwnerPhoneNumber,
                            rentalOwnerHomeNumber:
                                updatedOwner.rentalOwnerHomeNumber,
                            rentalOwnerBuisinessNumber:
                                updatedOwner.rentalOwnerBusinessNumber,
                            city: updatedOwner.city,
                            state: updatedOwner.state,
                            country: updatedOwner.country,
                            postalCode: updatedOwner.postalCode,
                            processorList: processorIds,
                          ),
                          rentalId: widget.rentalId,
                          propertyId: widget.properties.propertyId,
                          rentalAddress: address.text.trim(),
                          rentalOwnerId: ownerDetails.rentalOwnerId,
                          rentalCity: city.text.trim(),
                          rentalState: state.text.trim(),
                          rentalCountry: country.text.trim(),
                          rentalPostcode: postalcode.text.trim(),
                          staffMemberId: selectedStaff,
                          processor_id: processorId,
                        );

                        print('About to make API call');
                        print('Has changes: $hasChanges');
                        print('Has unit changes: $hasUnitChanges');
                        print('Properties object:');
                        print('- Units: ${properties.units}');
                        print('- Rental ID: ${properties.rentalId}');
                        print('- Property ID: ${properties.propertyId}');

                        try {
                          print('Making API call to update rental...');
                          await PropertiesRepository()
                              .updateRental1(properties);
                          print('API call successful');

                          print('Update completed successfully');
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text('Property updated successfully'),
                          //     backgroundColor: Colors.green,
                          //   ),
                          // );

                          Navigator.of(context).pop(true);
                        } catch (e) {
                          print('Error updating property: $e');
                          setState(() {
                            isLoading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to update property: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width * .33,
                          decoration: BoxDecoration(
                            color: blueColor,
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: loading
                                ? const SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 25.0,
                                  )
                                : const Text(
                                    "Edit Property",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    InkWell(
                        onTap: () {
                          // displayPropertyData();
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: blueColor),
                        )),
                  ],
                ),
                const Column(
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
              activeColor: blueColor,
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
                        cursorColor: blueColor,
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
              child: FaIcon(
                FontAwesomeIcons.trashCan,
                size: 20,
                color: blueColor,
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
                                activeColor: blueColor,
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
                                          cursorColor: blueColor,
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
                                child: FaIcon(
                                  FontAwesomeIcons.trashCan,
                                  size: 20,
                                  color: blueColor,
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
}

class Owner {
  final String id;
  final String rentalOwnerId;
  final String adminId;
  final String rentalOwnername;
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
    required this.rentalOwnername,
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
      rentalOwnername: json['rentalOwner_name'] ?? "",
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
      DataCell(Text(rental.rentalOwnerName!)),
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
