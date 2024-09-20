import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constant/constant.dart';
import '../../../model/LeaseSummary.dart';
import '../../../model/get_lease.dart';
import '../../../repository/lease.dart';
import '../../../widgets/CustomTableShimmer.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

class Renewlease extends StatefulWidget {
  LeaseSummary lease;
  String leaseId;
   Renewlease({super.key, required this.leaseId,required this.lease});

  @override
  State<Renewlease> createState() => _RenewleaseState();
}

class _RenewleaseState extends State<Renewlease> {

  List formDataRecurringList = [];
  late Future<LeaseSummary> futureLeaseSummary;


  TabController? _tabController;
  @override
  void initState() {
    // TODO: implement initState
    futureLeaseSummary = LeaseRepository.fetchLeaseSummary(widget.leaseId);
   // _tabController = TabController(length: 3, vsync: this);
    _selectedLeaseType = widget.lease.data?.leaseType;
     startDateController.text = widget.lease.data!.startDate ?? "";
     endDateController.text = widget.lease.data!.endDate ?? "";
     rent.text = widget.lease.data!.amount.toString();
     super.initState();
  }
  TextEditingController rent = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  DateTime? _startDate;
  final TextEditingController endDateController = TextEditingController();
  String moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool isLoading = false;
  bool isMovedOut = false;
  String? _selectedLeaseType;
  final List<String> leaseTypeitems = [
    'Fixed',
    'Fixed w/rollover',
    'At-will(month to month)',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer:CustomDrawer(currentpage: "Rent Roll",dropdown: true,),
      body:
      ListView(
        children: [
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                height: 50.0,
                padding: const EdgeInsets.only(top: 10, left: 10),
                width: MediaQuery.of(context).size.width * .91,
                margin: const EdgeInsets.only(bottom: 6.0),
                //Same as `blurRadius` i guess
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
                child: const Text(
                  "Renew Lease",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            child: FutureBuilder<LeaseSummary>(
              future: futureLeaseSummary,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No data found'));
                } else {
                  final leasesummery = snapshot.data!;
                  //final data = leaseLedger.data!.toList();
                  return Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 20),
                    child: SingleChildScrollView(
                      child:
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${leasesummery.data?.rentalAddress}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: blueColor),),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Material(
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
                                    left: 8, right: 8, top: 10, bottom: 30),
                                child: Column(
                                  children: [

                                    Container(
                                      height: 40,

                                      decoration: BoxDecoration(
                                          color: grey,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8))
                                      ),
                                      child: Column(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 10,),
                                              Text("Current terms",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Table(
                                      children: [
                                        TableRow(children: [
                                          TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Lease Type',
                                                  style: TextStyle(
                                                      color: const Color(0xFF8A95A8),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                              )),
                                          TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 12),
                                                child: Text(
                                                  '${leasesummery.data?.leaseType}',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                        ]),
                                        TableRow(children: [
                                          TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Start - End ',
                                                  style: TextStyle(
                                                      color: const Color(0xFF8A95A8),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                              )),
                                          TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 12),
                                                child: Text(
                                                  '${leasesummery.data?.startDate} to ${leasesummery.data?.endDate}',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                        ]),
                                        TableRow(children: [
                                          TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Rent',
                                                  style: TextStyle(
                                                      color: const Color(0xFF8A95A8),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                              )),
                                          TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 12),
                                                child: Text(
                                                  '${leasesummery.data?.amount}',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              )),
                                        ]),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Material(
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
                                    left: 8, right: 8, top: 10, bottom: 30),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: grey,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8))
                                      ),
                                      child: Column(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 10,),
                                              Text("Offer",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Lease Type',
                                          style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 5,),
                                        Expanded(
                                          child: FormField<String>(
                                            initialValue: _selectedLeaseType,
                                            builder: (FormFieldState<String> state) {
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
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
                                                      items: leaseTypeitems
                                                          .map(
                                                            (String item) => DropdownMenuItem<String>(
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
                                                        ),
                                                      )
                                                          .toList(),
                                                      value: _selectedLeaseType,
                                                      onChanged: (value) {
                                                        // Update the FormField state
                                                        setState(() {
                                                          _selectedLeaseType = value;
                                                          state.didChange(value);
                                                        });
                                                        state.reset();
                                                      },
                                                      buttonStyleData: ButtonStyleData(
                                                        height: 50,

                                                        padding: const EdgeInsets.only(left: 14, right: 14),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(6),
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
                                                  if (state.hasError)
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 14, top: 8),
                                                      child: Text(
                                                        state.errorText!,
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                            validator: (value) {
                                              if (_selectedLeaseType == null) {
                                                return 'Please select a lease type';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('Start Date *',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor)),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomTextField(
                                        onTap: () async {
                                          DateTime? pickedDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                            locale: const Locale('en', 'US'),
                                            builder: (BuildContext context, Widget? child) {
                                              return Theme(
                                                data: ThemeData.light().copyWith(
                                                  colorScheme: const ColorScheme.light(
                                                    primary: Color.fromRGBO(21, 43, 83,
                                                        1), // header background color
                                                    onPrimary:
                                                    Colors.white, // header text color
                                                    onSurface: Color.fromRGBO(
                                                        21, 43, 83, 1), // body text color
                                                  ),
                                                  textButtonTheme: TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.white,
                                                      backgroundColor: const Color.fromRGBO(
                                                          21,
                                                          43,
                                                          83,
                                                          1), // button text color
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (pickedDate != null) {
                                            // String formattedStartDate =
                                            //     "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                            String formattedStartDate = "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                            DateTime endDate = DateTime(pickedDate.year,
                                                pickedDate.month + 1, pickedDate.day);


                                            // String formattedEndDate =
                                            //     "${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}";
                                            setState(() {
                                              startDateController.text = formattedStartDate;
                                              _startDate = pickedDate;

                                            });
                                          }
                                        },
                                        readOnnly: true,
                                        suffixIcon: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(Icons.date_range_rounded)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select start date';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.text,
                                        hintText: 'dd-mm-yyyy',
                                        controller: startDateController,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('End Date *',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor)),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomTextField(
                                        onTap: () async {
                                          DateTime? pickedDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                            locale: const Locale('en', 'US'),
                                            builder: (BuildContext context, Widget? child) {
                                              return Theme(
                                                data: ThemeData.light().copyWith(
                                                  colorScheme: const ColorScheme.light(
                                                    primary: Color.fromRGBO(21, 43, 83,
                                                        1), // header background color
                                                    onPrimary:
                                                    Colors.white, // header text color
                                                    onSurface: Color.fromRGBO(
                                                        21, 43, 83, 1), // body text color
                                                  ),
                                                  textButtonTheme: TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.white,
                                                      backgroundColor: const Color.fromRGBO(
                                                          21,
                                                          43,
                                                          83,
                                                          1), // button text color
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (pickedDate != null) {
                                            // String formattedDate =
                                            //     "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                            String formattedDate = "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                            setState(() {
                                              endDateController.text = formattedDate;
                                            });
                                          }
                                        },
                                        readOnnly: true,
                                        suffixIcon: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(Icons.date_range_rounded)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select end date';
                                          }
                                          return null;
                                        },
                                        optional: true,
                                        keyboardType: TextInputType.text,
                                        hintText: 'dd-mm-yyyy',
                                        controller: endDateController,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Rent',
                                          style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    CustomTextField(
                                      keyboardType: TextInputType.emailAddress,
                                      hintText: 'Enter rent',
                                      controller: rent,
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: (){

                                },
                                child: Container(
                                    height:  MediaQuery.of(context).size.width < 500 ? 40 :45,
                                    width: MediaQuery.of(context).size.width < 500 ? 90 : 150,

                                    decoration: BoxDecoration(
                                        color: blueColor,
                                        borderRadius: BorderRadius.circular(5.0)),
                                    child: Center(
                                      child: Text(
                                        'Ok',
                                        style: TextStyle(
                                            fontSize:
                                            MediaQuery.of(context).size.width <
                                                500
                                                ? 16
                                                : 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    )),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height:  MediaQuery.of(context).size.width < 500 ? 35 :45,
                                    width: MediaQuery.of(context).size.width < 500 ? 120 : 165,

                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5.0)),
                                    child: Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                            fontSize:
                                            MediaQuery.of(context).size.width <
                                                500
                                                ? 16
                                                : 18,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
