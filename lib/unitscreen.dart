import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MaterialApp(home: unitScreen()));
}

class unitScreen extends StatefulWidget {
  const unitScreen({Key? key}) : super(key: key);

  @override
  State<unitScreen> createState() => _unitScreenState();
}

class _unitScreenState extends State<unitScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: screenHeight * 0.82,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 36,
                              width: 76,
                              child: ElevatedButton(
                                onPressed: () {},
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
                                  'landmark location',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[800]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  'Area Location',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[800]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  'State, Country',
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
                          height: screenHeight * 0.26,
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
                                    child:  const Text(
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
              const LeasesTable(),
              AppliancesPart(),
            ],
          ),
        ),
      ),
    );
  }
}
class LeasesTable extends StatelessWidget {
  const LeasesTable({Key? key}) : super(key: key);

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
                    fontSize: 14,
                    color: Color.fromRGBO(21, 43, 83, 1),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              border: TableBorder.all(
                width: 1.0,
                color: const Color.fromRGBO(21, 43, 83, 1),
              ),
              columns: [
                const DataColumn(
                  label: Text('Status'),
                ),
                const DataColumn(
                  label: Text('Start - End'),
                ),
                const DataColumn(
                  label: Text('Tenant'),
                ),
                const DataColumn(
                  label: Text('Type'),
                ),
                const DataColumn(
                  label: Text('Rent'),
                ),
              ],
              rows: leases.map((lease) {
                return DataRow(cells: [
                  DataCell(Text(lease.status)),
                  DataCell(InkWell(
                    onTap: () {},
                    child: Text(
                      lease.startEndDate,
                      style: TextStyle(color: Colors.blue),
                    ),
                  )),
                  DataCell(Text(lease.tenant)),
                  DataCell(Text(lease.type)),
                  DataCell(Text(lease.rent)),
                ]);
              }).toList(),
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
  @override
  _AppliancesPartState createState() => _AppliancesPartState();
}

class _AppliancesPartState extends State<AppliancesPart> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _installedDate = TextEditingController();

  DateTime? _selectedDate;

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
                            return AlertDialog(
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter name';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomTextFormField(
                                      labelText: 'Description',
                                      hintText: 'Enter description',
                                      keyboardType: TextInputType.text,
                                      controller: _description,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter description';
                                        }
                                        return null;
                                      },
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
                                              _installedDate.text = date.toString();
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
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please select date';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 42,
                                            width: 80,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  const Color.fromRGBO(21, 43, 83, 1),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(8.0))),
                                              onPressed: () {
                                                if (_formKey.currentState?.validate() ?? false) {
                                                  // Save the data
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: const Text(
                                                'Save',
                                                style: TextStyle(
                                                    fontSize: 14, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.25),
                                                  spreadRadius: 0,
                                                  blurRadius: 15,
                                                  offset: const Offset(0.5, 0.5), // Shadow moved to the right and bottom
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
                                  ],
                                ),
                              ),
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
  final FormFieldValidator<String> validator;

  CustomTextFormField({
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    required this.controller,
    required this.validator,
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
        validator: widget.validator,
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
