import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../Model/RentalOwnersData.dart';
import '../../../model/rentalOwner.dart';
import '../../../model/rentalowners_summery.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../repository/Staffmember.dart';
import '../../../widgets/drawer_tiles.dart';

class Edit_rentalowners extends StatefulWidget {
  RentalOwnerData rentalOwner;
  Edit_rentalowners({super.key, required this.rentalOwner});

  @override
  State<Edit_rentalowners> createState() => _Edit_rentalownersState();
}

class _Edit_rentalownersState extends State<Edit_rentalowners> {
  TextEditingController name = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController comname = TextEditingController();
  TextEditingController primaryemail = TextEditingController();
  TextEditingController alternativeemail = TextEditingController();
  TextEditingController phonenum = TextEditingController();
  TextEditingController homenum = TextEditingController();
  TextEditingController officenum = TextEditingController();
  TextEditingController street2 = TextEditingController();
  TextEditingController city2 = TextEditingController();
  TextEditingController state2 = TextEditingController();
  TextEditingController county2 = TextEditingController();
  TextEditingController code2 = TextEditingController();
  TextEditingController proid = TextEditingController();
  TextEditingController taxtype = TextEditingController();
  TextEditingController taxid = TextEditingController();

  bool nameerror = false;
  bool lastnameerror = false;
  bool comnameerror = false;
  bool primaryemailerror = false;
  bool alternativeerror = false;
  bool phonenumerror = false;
  bool homenumerror = false;
  bool officenumerror = false;
  bool street2error = false;
  bool city2error = false;
  bool state2error = false;
  bool county2error = false;
  bool code2error = false;
  bool proiderror = false;
  bool taxtypeerror = false;
  bool taxiderror = false;

  String namemessage = "";
  String lastnamemessage = "";
  String comnamemessage = "";
  String primaryemailmessage = "";
  String alternativemessage = "";
  String phonenummessage = "";
  String homenummessage = "";
  String officenummessage = "";
  String street2message = "";
  String city2message = "";
  String state2message = "";
  String county2message = "";
  String code2message = "";
  String proidmessage = "";
  String taxtypemessage = "";
  String taxidmessage = "";

  bool isLoading = false;
  Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize with one text field
    _controllers[0] = TextEditingController();

    name.text = widget.rentalOwner.rentalOwnername!;
    comname.text = widget.rentalOwner.rentalOwnerCompanyName!;
    // comname.text = widget.rentalOwner.rentalOwnerCompanyName!;
    primaryemail.text = widget.rentalOwner.rentalOwnerPrimaryEmail!;
    alternativeemail.text = widget.rentalOwner.rentalOwnerAlternateEmail!;
    phonenum.text = widget.rentalOwner.rentalOwnerPhoneNumber!;
    homenum.text = widget.rentalOwner.rentalOwnerHomeNumber!;
    officenum.text = widget.rentalOwner.rentalOwnerBusinessNumber!;
    street2.text = widget.rentalOwner.streetAddress!;
    city2.text = widget.rentalOwner.city!;
    state2.text = widget.rentalOwner.state!;
    county2.text = widget.rentalOwner.country!;
    code2.text = widget.rentalOwner.postalCode!;
    //proid.text = widget.rentalOwner.processorLists.toString();
    taxtype.text = widget.rentalOwner.textIdentityType!;
    taxid.text = widget.rentalOwner.texpayerId!;
    //birthdateController.text = widget.rentalOwner.b;
    startdateController.text = widget.rentalOwner.startDate!;
    enddateController.text = widget.rentalOwner.endDate!;
  }

  // Add a text field
  void _addTextField() {
    int nextIndex = _controllers.length;
    setState(() {
      _controllers[nextIndex] = TextEditingController();
    });
  }

  // Remove a text field
  void _removeTextField(int index) {
    setState(() {
      _controllers.remove(index);
    });
  }

  //TextEditingController birthdateController = TextEditingController();
  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();

  // bool birthdateerror = false;
  bool startdatederror = false;
  bool enddatederror = false;

  //String birthdatemessage = "";
  String startdatemessage = "";
  String enddatemessage = "";

  //DateTime? birthdate;
  DateTime? startdate;
  DateTime? enddate;

  // Future<void> _birthDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: birthdate ?? DateTime.now(),
  //     firstDate: DateTime(2015, 8),
  //     lastDate: DateTime(2101),
  //     builder: (BuildContext context, Widget? child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           primaryColor:
  //               Color.fromRGBO(21, 43, 83, 1), // Header background color
  //           // accentColor: Colors.white, // Button text color
  //           colorScheme: ColorScheme.light(
  //             primary: Color.fromRGBO(21, 43, 83, 1), // Selection color
  //             onPrimary: Colors.white, // Text color
  //             surface: Colors.white, // Calendar background color
  //             onSurface: Colors.black, // Calendar text color
  //           ),
  //           dialogBackgroundColor: Colors.white, // Background color
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null && picked != birthdate) {
  //     setState(() {
  //       birthdate = picked;
  //       birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
  //       //startdateController.text = DateFormat('yyyy-MM-dd').format(picked);
  //       //enddateController.text = DateFormat('yyyy-MM-dd').format(picked);
  //     });
  //   }
  // }

  Future<void> _startDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startdate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor:
            const Color.fromRGBO(21, 43, 83, 1), // Header background color
            // accentColor: Colors.white, // Button text color
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(21, 43, 83, 1), // Selection color
              onPrimary: Colors.white, // Text color
              surface: Colors.white, // Calendar background color
              onSurface: Colors.black, // Calendar text color
            ),
            dialogBackgroundColor: Colors.white, // Background color
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != startdate) {
      setState(() {
        startdate = picked;
        // birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
        startdateController.text = DateFormat('yyyy-MM-dd').format(picked);
        // enddateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _endDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: enddate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor:
            const Color.fromRGBO(21, 43, 83, 1), // Header background color
            // accentColor: Colors.white, // Button text color
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(21, 43, 83, 1), // Selection color
              onPrimary: Colors.white, // Text color
              surface: Colors.white, // Calendar background color
              onSurface: Colors.black, // Calendar text color
            ),
            dialogBackgroundColor: Colors.white, // Background color
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != enddate) {
      setState(() {
        enddate = picked;
        //birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
        //startdateController.text = DateFormat('yyyy-MM-dd').format(picked);
        enddateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget302.,
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
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                height: 50.0,
                padding: const EdgeInsets.only(top: 8, left: 10),
                width: MediaQuery.of(context).size.width * .91,
                margin: const EdgeInsets.only(bottom: 6.0),
                //Same as `blurRadius` i guess
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
                child: const Text(
                  "Add Rental Owners",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
              ),
            ),
          ),
          //Personal information
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Personal information",
                            style: TextStyle(
                                color: const Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                MediaQuery.of(context).size.width * .045),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //first name
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Name",
                            style: TextStyle(
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            nameerror = false;
                                          });
                                        },
                                        controller: name,
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: nameerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(11),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      nameerror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            namemessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //company name
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Company Name",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
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
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter company name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: comnameerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      comnameerror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            comnamemessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //birth date
                      // Row(
                      //   children: [
                      //     SizedBox(
                      //       width: 2,
                      //     ),
                      //     Text(
                      //       "Date Of Birth",
                      //       style: TextStyle(
                      //           // color: Colors.grey,
                      //           color: Color(0xFF8A95A8),
                      //           fontWeight: FontWeight.bold,
                      //           fontSize:
                      //               MediaQuery.of(context).size.width * .036),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // Row(
                      //   children: [
                      //     SizedBox(width: 2),
                      //     Expanded(
                      //       child: Material(
                      //         elevation: 4,
                      //         child: Container(
                      //           height: 50,
                      //           width: MediaQuery.of(context).size.width * .6,
                      //           decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(2),
                      //             border: Border.all(
                      //               color: Color(0xFF8A95A8),
                      //             ),
                      //           ),
                      //           child: Stack(
                      //             children: [
                      //               Positioned.fill(
                      //                 child: TextField(
                      //                   onChanged: (value) {
                      //                     setState(() {
                      //                       birthdateerror = false;
                      //                       // _selectDate(context);
                      //                     });
                      //                   },
                      //                   controller: birthdateController,
                      //                   cursorColor:
                      //                       Color.fromRGBO(21, 43, 81, 1),
                      //                   decoration: InputDecoration(
                      //                     hintText: "yyyy/mm/dd",
                      //                     hintStyle: TextStyle(
                      //                       fontSize: MediaQuery.of(context)
                      //                               .size
                      //                               .width *
                      //                           .037,
                      //                       color: Color(0xFF8A95A8),
                      //                     ),
                      //                     enabledBorder: birthdateerror
                      //                         ? OutlineInputBorder(
                      //                             borderRadius:
                      //                                 BorderRadius.circular(3),
                      //                             borderSide: BorderSide(
                      //                               color: Colors.red,
                      //                             ),
                      //                           )
                      //                         : InputBorder.none,
                      //                     border: InputBorder.none,
                      //                     contentPadding: EdgeInsets.all(12),
                      //                     suffixIcon: IconButton(
                      //                       icon: Icon(Icons.calendar_today),
                      //                       onPressed: () =>
                      //                           _startDate(context),
                      //                     ),
                      //                   ),
                      //                   readOnly: true,
                      //                   onTap: () {
                      //                     _birthDate(context);
                      //                     setState(() {
                      //                       birthdateerror = false;
                      //                     });
                      //                   },
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(width: 2),
                      //   ],
                      // ),
                      // birthdateerror
                      //     ? Row(
                      //         children: [
                      //           Spacer(),
                      //           Text(
                      //             birthdatemessage,
                      //             style: TextStyle(
                      //                 color: Colors.red,
                      //                 fontSize:
                      //                     MediaQuery.of(context).size.width *
                      //                         .035),
                      //           ),
                      //           SizedBox(
                      //             width: 2,
                      //           ),
                      //         ],
                      //       )
                      //     : Container(),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          //merchent id
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Merchant Id",
                            style: TextStyle(
                                color: const Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                MediaQuery.of(context).size.width * .045),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Processor Id",
                            style: TextStyle(
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 1, right: 1),
                        child: Column(
                          children: [
                            Column(
                              children: _controllers.entries.map((entry) {
                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Material(
                                          elevation: 3,
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(5),
                                              color: Colors.white,
                                              border: Border.all(
                                                  color:
                                                  const Color(0xFF8A95A8)),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: TextField(
                                                    controller: entry.value,
                                                    cursorColor:
                                                    const Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    decoration:
                                                    const InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                      EdgeInsets.only(
                                                          top: 12.5,
                                                          bottom: 12.5,
                                                          left: 15),
                                                      hintText:
                                                      "Enter processor",
                                                      hintStyle: TextStyle(
                                                        color:
                                                        Color(0xFF8A95A8),
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
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              .02),
                                      InkWell(
                                        onTap: () {
                                          _removeTextField(entry.key);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.zero,
                                          child: const FaIcon(
                                            FontAwesomeIcons.trashCan,
                                            size: 20,
                                            color:
                                            Color.fromRGBO(21, 43, 81, 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _addTextField();
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Container(
                                      height: 30.0,
                                      width: MediaQuery.of(context).size.width *
                                          .3,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(5.0),
                                        color:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        boxShadow: [
                                          const BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Add another",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          //management agreement
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Management Agreement ",
                            style: TextStyle(
                                color: const Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                MediaQuery.of(context).size.width * .045),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //start date
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Start Date",
                            style: TextStyle(
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            startdatederror = false;
                                            // _selectDate(context);
                                          });
                                        },
                                        controller: startdateController,
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "mm/dd/yyyy",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: startdatederror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(3),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                          suffixIcon: IconButton(
                                            icon: const Icon(
                                                Icons.calendar_today),
                                            onPressed: () {
                                              _startDate(context);
                                              setState(() {
                                                startdatederror = false;
                                              });
                                            },
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () {
                                          _startDate(context);
                                          setState(() {
                                            startdatederror = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      startdatederror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            startdatemessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //enddate
                      Row(
                        children: [
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            "End Date",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            enddatederror = false;
                                            // _selectDate(context);
                                          });
                                        },
                                        controller: enddateController,
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "mm/dd/yyyy",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: enddatederror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(3),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                          suffixIcon: IconButton(
                                            icon: const Icon(
                                                Icons.calendar_today),
                                            onPressed: () => _endDate(context),
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () {
                                          _endDate(context);
                                          setState(() {
                                            enddatederror = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      enddatederror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            enddatemessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          //contact information
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Contact information",
                            style: TextStyle(
                                color: const Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                MediaQuery.of(context).size.width * .045),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //primary email
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Primary E-mail",
                            style: TextStyle(
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
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
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter primary e-mail",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: primaryemailerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      primaryemailerror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            primaryemailmessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //alternative email
                      Row(
                        children: [
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            "Alternative E-mail",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
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
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter alternative e-mail ",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: alternativeerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      alternativeerror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            alternativemessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //phonenumber
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Phone Number",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
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
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter phone number",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: phonenumerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      phonenumerror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            phonenummessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //homenumber
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Home Number",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
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
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter home number",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: homenumerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      homenumerror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            homenummessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //office number
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Office Number",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            officenumerror = false;
                                          });
                                        },
                                        controller: officenum,
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter office number",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: officenumerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      officenumerror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            officenummessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //street address
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Street Address",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
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
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter street address",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: street2error
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      street2error
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            street2message,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //enter city
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "City",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
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
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter city",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: city2error
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      city2error
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            city2message,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //emter state
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "State",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
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
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter state",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: state2error
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      state2error
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            state2message,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //enter country
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Country",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
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
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter country",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: county2error
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      county2error
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            county2message,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      //postal code
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Postal Code",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
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
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter postal code",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: code2error
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      code2error
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            code2message,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          //tax payer information
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Tax Payer Information ",
                            style: TextStyle(
                                color: const Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                MediaQuery.of(context).size.width * .045),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Tax Identify Type",
                            style: TextStyle(
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            taxtypeerror = false;
                                          });
                                        },
                                        controller: taxtype,
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter tax identify type",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: taxtypeerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      taxtypeerror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            taxtypemessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
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
                            width: 3,
                          ),
                          Text(
                            "Tax PayerId",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: const Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            taxiderror = false;
                                          });
                                        },
                                        controller: taxid,
                                        cursorColor:
                                        const Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter SSN or EIN",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: const Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: taxiderror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      taxiderror
                          ? Row(
                        children: [
                          const Spacer(),
                          Text(
                            taxidmessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    .035),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.065),
              GestureDetector(
                onTap: () async {
                  if (name.text.isEmpty) {
                    setState(() {
                      nameerror = true;
                      namemessage = "required";
                    });
                  } else {
                    setState(() {
                      nameerror = false;
                    });
                  }
                  if (comname.text.isEmpty) {
                    setState(() {
                      comnameerror = true;
                      comnamemessage = "required";
                    });
                  } else {
                    setState(() {
                      comnameerror = false;
                    });
                  }
                  // if (birthdateController.text.isEmpty) {
                  //   setState(() {
                  //     birthdateerror = true;
                  //     birthdatemessage = "required";
                  //   });
                  // } else {
                  //   setState(() {
                  //     birthdateerror = false;
                  //   });
                  // }
                  if (startdateController.text.isEmpty) {
                    setState(() {
                      startdatederror = true;
                      startdatemessage = "required";
                    });
                  } else {
                    setState(() {
                      startdatederror = false;
                    });
                  }
                  if (enddateController.text.isEmpty) {
                    setState(() {
                      enddatederror = true;
                      enddatemessage = "required";
                    });
                  } else {
                    setState(() {
                      enddatederror = false;
                    });
                  }
                  if (primaryemail.text.isEmpty) {
                    setState(() {
                      primaryemailerror = true;
                      primaryemailmessage = "required";
                    });
                  } else {
                    setState(() {
                      primaryemailerror = false;
                    });
                  }
                  if (alternativeemail.text.isEmpty) {
                    setState(() {
                      alternativeerror = true;
                      alternativemessage = "required";
                    });
                  } else {
                    setState(() {
                      alternativeerror = false;
                    });
                  }
                  if (phonenum.text.isEmpty) {
                    setState(() {
                      phonenumerror = true;
                      phonenummessage = "required";
                    });
                  } else {
                    setState(() {
                      phonenumerror = false;
                    });
                  }
                  if (homenum.text.isEmpty) {
                    setState(() {
                      homenumerror = true;
                      homenummessage = "required";
                    });
                  } else {
                    setState(() {
                      homenumerror = false;
                    });
                  }
                  if (officenum.text.isEmpty) {
                    setState(() {
                      officenumerror = true;
                      officenummessage = "required";
                    });
                  } else {
                    setState(() {
                      officenumerror = false;
                    });
                  }
                  if (street2.text.isEmpty) {
                    setState(() {
                      street2error = true;
                      street2message = "required";
                    });
                  } else {
                    setState(() {
                      street2error = false;
                    });
                  }
                  if (city2.text.isEmpty) {
                    setState(() {
                      city2error = true;
                      city2message = "required";
                    });
                  } else {
                    setState(() {
                      city2error = false;
                    });
                  }
                  if (state2.text.isEmpty) {
                    setState(() {
                      state2error = true;
                      state2message = "required";
                    });
                  } else {
                    setState(() {
                      state2error = false;
                    });
                  }
                  if (city2.text.isEmpty) {
                    setState(() {
                      city2error = true;
                      city2message = "required";
                    });
                  } else {
                    setState(() {
                      city2error = false;
                    });
                  }
                  if (county2.text.isEmpty) {
                    setState(() {
                      county2error = true;
                      county2message = "required";
                    });
                  } else {
                    setState(() {
                      county2error = false;
                    });
                  }
                  if (code2.text.isEmpty) {
                    setState(() {
                      code2error = true;
                      code2message = "required";
                    });
                  } else {
                    setState(() {
                      code2error = false;
                    });
                  }
                  if (taxtype.text.isEmpty) {
                    setState(() {
                      taxtypeerror = true;
                      taxtypemessage = "required";
                    });
                  } else {
                    setState(() {
                      taxtypeerror = false;
                    });
                  }
                  if (taxid.text.isEmpty) {
                    setState(() {
                      taxiderror = true;
                      taxidmessage = "required";
                    });
                  } else {
                    setState(() {
                      taxiderror = false;
                    });
                  }
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  String? adminId = prefs.getString("adminId");
                  if (adminId != null &&
                      name.text.isNotEmpty &&
                      comname.text.isNotEmpty &&
                      startdateController.text.isNotEmpty &&
                      enddateController.text.isNotEmpty &&
                      primaryemail.text.isNotEmpty &&
                      alternativeemail.text.isNotEmpty &&
                      phonenum.text.isNotEmpty &&
                      homenum.text.isNotEmpty &&
                      officenum.text.isNotEmpty &&
                      street2.text.isNotEmpty &&
                      city2.text.isNotEmpty &&
                      state2.text.isNotEmpty &&
                      county2.text.isNotEmpty &&
                      code2.text.isNotEmpty &&
                      taxtype.text.isNotEmpty &&
                      taxid.text.isNotEmpty) {
                    try {
                      await RentalOwnerService().Edit_Rentalowners(
                        adminId: adminId,
                        rentalownerId: widget.rentalOwner.rentalownerId,
                        rentalOwnerName: name.text,
                        rentalOwnerPrimaryEmail: primaryemail.text,
                        rentalOwnerAlternateEmail: alternativeemail.text,
                        rentalOwnerPhoneNumber: phonenum.text,
                        rentalOwnerHomeNumber: homenum.text,
                        rentalOwnerBusinessNumber: officenum.text,
                        startDate: startdateController.text,
                        endDate: enddateController.text,
                        texpayerId: taxid.text,
                        textIdentityType: taxtype.text,
                        city: city2.text,
                        state: state2.text,
                        streetAddress: street2.text,
                        country: county2.text,
                        postalCode: code2.text,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.of(context).pop(true);
                      reload_Screen();
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      // Handle error
                    }
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * .045,
                    width: MediaQuery.of(context).size.width * .36,
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
                      child: Text(
                        "Edit Rental Owner",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * .034),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  reload_Screen() {
    setState(() {});
  }
}