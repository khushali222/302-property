import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/unit.dart';
import '../../../model/properties.dart';
import '../../../model/properties_summery.dart';
import '../../../model/unitsummery_propeties.dart';
import '../../../provider/property_summery.dart';
import '../../../repository/properties_summery.dart';
import '../../../repository/unit_data.dart';

// void main() {
//   runApp(const MaterialApp(home: unitScreen()));
// }

class unitScreen extends StatefulWidget {
  Rentals? properties;
  unit_properties? unit;
  unitScreen({
    super.key,
    this.properties,
    this.unit,
  });

  @override
  State<unitScreen> createState() => _unitScreenState();
}

class _unitScreenState extends State<unitScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                //height: screenHeight * 0.82,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromRGBO(21, 43, 83, 1),
                    width: 1,
                  ),
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 36,
                            width: 76,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(21, 43, 83, 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0))),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 36,
                            width: 126,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(21, 43, 83, 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0))),
                              onPressed: () {},
                              child: const Text(
                                'Delete unit',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: screenHeight * 0.30,
                      width: screenWidth * 0.8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: const Image(
                          image: NetworkImage(
                              'https://images.unsplash.com/photo-1718002125137-5582481c462f?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                'ADDRESS',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[800]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                '${widget.properties?.rentalAddress}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[800]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                '${widget.properties?.rentalCity} ${widget.properties?.rentalState}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[800]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                '${widget.properties?.rentalCountry} ${widget.properties?.rentalPostcode}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        // height: screenHeight * 0.26,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.white,
                          border: Border.all(
                            color: const Color.fromRGBO(21, 43, 83, 1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Add Lease',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(21, 43, 83, 1),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 36,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Add Lease',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(21, 43, 83, 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Rental Applicant',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(21, 43, 83, 1),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 36,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Create Applicant',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(21, 43, 83, 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
             LeasesTable(unit:widget.unit),
            AppliancesPart(unit:widget.unit),
          ],
        ),
      ),
    );
  }
}

class LeasesTable extends StatefulWidget {
  unit_properties? unit;
  LeasesTable({
    super.key,
    this.unit,
  });
  //LeasesTable({Key? key}) : super(key: key);

  @override
  State<LeasesTable> createState() => _LeasesTableState();
}

class _LeasesTableState extends State<LeasesTable> {
  final UnitData leaseRepository = UnitData();

  List<unit_lease> leases = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeases();
  }

  Future<void> fetchLeases() async {
    //  try {
    final fetchedLeases =
        await leaseRepository.fetchUnitLeases(widget.unit!.unitId!);
    print(widget.unit!.unitId!);
    print('hello');
    setState(() {
      print(widget.unit!.unitId!);
      print('hello');
      leases = fetchedLeases;
      isLoading = false;
    });
    //} catch (e) {
    setState(() {
      isLoading = false;
    });
    //print('Failed to load leases: $e');
    //}
  }

  String getStatus(String startDate, String endDate) {
    final now = DateTime.now();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return (now.isAfter(start) && now.isBefore(end)) ? 'Active' : 'Inactive';
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Leases',
                style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(21, 43, 83, 1),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: DataTable(
          //     border: TableBorder.all(
          //       width: 1.0,
          //       color: const Color.fromRGBO(21, 43, 83, 1),
          //     ),
          //     columns: [
          //       const DataColumn(
          //         label: Text('Status'),
          //       ),
          //       const DataColumn(
          //         label: Text('Start - End'),
          //       ),
          //       const DataColumn(
          //         label: Text('Tenant'),
          //       ),
          //       const DataColumn(
          //         label: Text('Type'),
          //       ),
          //       const DataColumn(
          //         label: Text('Rent'),
          //       ),
          //     ],
          //     rows: leases.map((lease) {
          //       return DataRow(cells: [
          //         DataCell(Text(lease.status)),
          //         DataCell(InkWell(
          //           onTap: () {},
          //           child: Text(
          //             lease.startEndDate,
          //             style: TextStyle(color: Colors.blue),
          //           ),
          //         )),
          //         DataCell(Text(lease.tenant)),
          //         DataCell(Text(lease.type)),
          //         DataCell(Text(lease.rent)),
          //       ]);
          //     }).toList(),
          //   ),
          // ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : leases.isEmpty
                  ? Center(
                      child: Text(
                          'You don\'t have any lease for this unit right now ..'))
                  :
          SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: Color.fromRGBO(21, 43, 83, 1),
                          )),
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Color.fromRGBO(21, 43, 83, 1)),
                            headingTextStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            columns: [
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Start-End')),
                              DataColumn(label: Text('Tenant')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Rent')),
                            ],
                            rows: leases.map((lease) {
                              return DataRow(cells: [
                                DataCell(Text(getStatus(
                                    lease.startDate!, lease.endDate!))),
                                DataCell(Text(
                                  '${lease.startDate} - ${lease.endDate}',
                                  style: TextStyle(color: Colors.blue),
                                )),
                                DataCell(Text(
                                    '${lease.tenantFirstName} ${lease.tenantLastName}')),
                                DataCell(Text('${lease.leaseType}')),
                                DataCell(Text('${lease.amount}')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}

class Lease {
  final String status;
  final String startEndDate;
  final String tenant;
  final String type;
  final String rent;

  Lease({
    required this.status,
    required this.startEndDate,
    required this.tenant,
    required this.type,
    required this.rent,
  });
}

List<Lease> leases = [
  Lease(
    status: 'Active',
    startEndDate: '05-15-2024-06-15-2024',
    tenant: 'Alex Wilkins',
    type: 'Fixed',
    rent: '30',
  ),
  Lease(
    status: 'Active',
    startEndDate: '05-15-2024-06-15-2024',
    tenant: 'Alex Wilkins',
    type: 'Fixed',
    rent: '30',
  ),
  // Add more leases as needed
];

class AppliancesPart extends StatefulWidget {
  Rentals? properties;
  unit_properties? unit;
  AppliancesPart({
    this.unit,this.properties
});
  @override
  _AppliancesPartState createState() => _AppliancesPartState();
}

class _AppliancesPartState extends State<AppliancesPart> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _installedDate = TextEditingController();
  final UnitData leaseRepository = UnitData();
  List<unit_appliance> leases = [];

  bool isLoading = true;  Future<void> fetchLeases() async {
    //  try {
    final fetchedLeases =
    await leaseRepository.fetchApplianceData(widget.unit!.unitId!);
    print(widget.unit!.unitId!);
    print('hello');
    setState(() {
      print(widget.unit!.unitId!);
      print('hello');
      leases = fetchedLeases;
      isLoading = false;
    });
    //} catch (e) {
    setState(() {
      isLoading = false;
    });
    //print('Failed to load leases: $e');
    //}
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLeases();
  }
  reload_screen(){
    setState(() {

    });
  }
  DateTime? _selectedDate;
  //bool isLoading = false;
  bool iserror = false;
  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Appliances',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(21, 43, 83, 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return
                                    AlertDialog(
                                      title: const Text('Add Appliances'),
                                      content: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomTextFormField(
                                              labelText: 'Name',
                                              hintText: 'Enter Name',
                                              keyboardType: TextInputType.text,
                                              controller: _name,
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty) {
                                              //     return 'Please enter name';
                                              //   }
                                              //   return null;
                                              // },
                                            ),
                                            CustomTextFormField(
                                              labelText: 'Description',
                                              hintText: 'Enter description',
                                              keyboardType: TextInputType.text,
                                              controller: _description,
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty) {
                                              //     return 'Please enter description';
                                              //   }
                                              //   return null;
                                              // },
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2100),
                                                ).then((date) {
                                                  if (date != null) {
                                                    setState(() {
                                                      _selectedDate = date;
                                                      _installedDate.text =
                                                          date.toString();
                                                    });
                                                  }
                                                });
                                              },
                                              child: AbsorbPointer(
                                                child: CustomTextFormField(
                                                  labelText: 'Date',
                                                  hintText: 'Select Date',
                                                  keyboardType: TextInputType.datetime,
                                                  controller: _installedDate,
                                                  // validator: (value) {
                                                  //   if (value == null ||
                                                  //       value.isEmpty) {
                                                  //     return 'Please select date';
                                                  //   }
                                                  //   return null;
                                                  // },
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    height: 42,
                                                    width: 80,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                          const Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  8.0))),
                                                      // onPressed: () async {
                                                      //   if (_formKey.currentState?.validate() ?? false) {
                                                      //     setState(() {
                                                      //       isLoading = true;
                                                      //       iserror = false;
                                                      //     });
                                                      //     SharedPreferences prefs = await SharedPreferences.getInstance();
                                                      //     String? id = prefs.getString("adminId");
                                                      //
                                                      //     Properies_summery_Repo()
                                                      //         .addappliances(
                                                      //       appliancename: _name.text,
                                                      //       appliancedescription: _description.text,
                                                      //       installeddate: _installedDate.text,
                                                      //     )
                                                      //         .then((value) {
                                                      //       setState(() {
                                                      //         isLoading = false;
                                                      //       });
                                                      //       Navigator.pop(context, true);
                                                      //     })
                                                      //         .catchError((e) {
                                                      //       setState(() {
                                                      //         isLoading = false;
                                                      //       });
                                                      //     });
                                                      //   } else {
                                                      //     setState(() {
                                                      //       iserror = true;
                                                      //     });
                                                      //   }
                                                      // },
                                                      onPressed: () async {
                                                        if (_name.text.isEmpty || _description.text.isEmpty || _installedDate.text.isEmpty ) {
                                                          setState(() {
                                                            iserror = true;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            isLoading = true;
                                                            iserror = false;
                                                          });
                                                          SharedPreferences prefs =
                                                          await SharedPreferences.getInstance();
                                                          String? id = prefs.getString("adminId");
                                                          print("calling");
                                                          Properies_summery_Repo()
                                                              .addappliances(
                                                            adminId: id,
                                                            unitId: widget.unit?.unitId,
                                                            appliancename: _name.text,
                                                            appliancedescription: _description.text,
                                                            installeddate: _installedDate.text,
                                                          ).then((value) {
                                                            print(widget.properties?.adminId);
                                                            print(widget.unit?.unitId);
                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                            reload_screen();
                                                            Navigator.pop(context,true);
                                                          }).catchError((e) {
                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                          });
                                                        }

                                                      },
                                                      child: const Text(
                                                        'Save',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                      BorderRadius.circular(8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.25),
                                                          spreadRadius: 0,
                                                          blurRadius: 15,
                                                          offset: const Offset(0.5,
                                                              0.5), // Shadow moved to the right and bottom
                                                        )
                                                      ],
                                                    ),
                                                    height: 40,
                                                    width: 70,
                                                    child: Center(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: const Text('Cancel'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if(iserror)
                                              Text(
                                                "Please fill in all fields correctly.",
                                                style: TextStyle(color: Colors.redAccent),
                                              )
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color.fromRGBO(21, 43, 83, 1),
                            width: 1,
                          ),
                        ),
                        height: 40,
                        width: 70,
                        child: const Center(
                          child: Text('Add'),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
                SizedBox(
                  height: 15,
                ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(21, 43, 83, 1),
                        )),
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Color.fromRGBO(21, 43, 83, 1)),
                      headingTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                      columns: [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Installed Date')),
                        DataColumn(label: Text('Action')),

                      ],
                      rows: leases.map((lease) {
                        return DataRow(cells: [
                          DataCell(Text(
                              '${lease.applianceName} ')),
                          DataCell(Text(
                            '${lease.applianceDescription}',
                            style: TextStyle(color: Colors.blue),
                          )),
                          DataCell(Text(
                              '${lease.installedDate} ')),
                          DataCell( IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.edit,
                                size: 15,
                                color: Color(0xFF8A95A8),
                              ),
                              onPressed: () {}
                          ),),

                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController controller;
  //final FormFieldValidator<String> validator;

  CustomTextFormField({
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    required this.controller,
    // required this.validator,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: widget.controller,
        //validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        style: const TextStyle(fontSize: 16.0),
        keyboardType: widget.keyboardType,
        autofocus: _isFocused,
      ),
    );
  }
}
