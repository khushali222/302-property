// import 'dart:io';

// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:file_picker/file_picker.dart';

// import 'package:flutter/material.dart';

// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
// import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

// class AddLease extends StatefulWidget {
//   @override
//   _AddLeaseState createState() => _AddLeaseState();
// }

// class _AddLeaseState extends State<AddLease>
//     with SingleTickerProviderStateMixin {
//   bool isEnjoyNowSelected = true;
//   String? _selectedProperty;
//   String? _selectedLeaseType;
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   final TextEditingController Amount = TextEditingController();
//   final TextEditingController rentAmount = TextEditingController();
//   final TextEditingController rentNextDueDate = TextEditingController();
//   final TextEditingController rentMemo = TextEditingController();
//   final TextEditingController securityDepositeAmount = TextEditingController();
//   final TextEditingController recurringContentAmount = TextEditingController();
//   final TextEditingController recurringContentMemo = TextEditingController();
//   final TextEditingController oneTimeContentMemo = TextEditingController();
//   final TextEditingController oneTimeContentAmount = TextEditingController();
//   final TextEditingController signatureController = TextEditingController();
//   GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

//   String? _selectedRent;
//   final TextEditingController _startDate = TextEditingController();
//   final TextEditingController _endDate = TextEditingController();

//   bool _selectedResidentsEmail = false; // Initialize the boolean variable

//   final List<String> items = [
//     'Item1',
//     'Item2',
//     'Item3',
//   ];
//   String? selectedValue;
//   List<File> _pdfFiles = [];

//   Future<void> _pickPdfFiles() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//       allowMultiple: true,
//     );

//     if (result != null) {
//       List<File> files = result.paths
//           .where((path) => path != null)
//           .map((path) => File(path!))
//           .toList();

//       if (files.length > 10) {
//         files = files.sublist(0, 10);
//       }

//       setState(() {
//         _pdfFiles = files;
//       });
//     }
//   }

//   late TabController _tabController;
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Property Management'),
//       ),
//       body: Container(
//         color: Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Form(
//             key: formKey,
//             child: ListView(
//               children: [
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color.fromRGBO(21, 43, 83, 1),
//                       ),
//                       borderRadius: BorderRadius.circular(10.0)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('Property *',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         CustomDropdown(
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please select an item';
//                             }
//                             return null;
//                           },
//                           labelText: 'Select Rent',
//                           items: items,
//                           selectedValue: _selectedLeaseType,
//                           onChanged: (String? value) {
//                             setState(() {
//                               _selectedLeaseType = value;
//                             });
//                           },
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         const Text('Lease Type *',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         CustomDropdown(
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please select an item';
//                             }
//                             return null;
//                           },
//                           labelText: 'Select Lease',
//                           items: items,
//                           selectedValue: _selectedLeaseType,
//                           onChanged: (String? value) {
//                             setState(() {
//                               _selectedLeaseType = value;
//                             });
//                           },
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         const Text('Start Date *',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         Container(
//                           height: 45,
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8.0),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 offset: const Offset(4, 4),
//                                 blurRadius: 8,
//                               ),
//                             ],
//                           ),
//                           child: TextFormField(
//                             controller: _startDate,
//                             readOnly: true,
//                             decoration: InputDecoration(
//                                 suffixIcon: IconButton(
//                                     onPressed: () {},
//                                     icon: const Icon(Icons.date_range_rounded)),
//                                 border: InputBorder.none,
//                                 hintText: 'dd mm yyyy',
//                                 hintStyle: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w400,
//                                   color: Color(0xFFb0b6c3),
//                                 )),
//                             onTap: () async {
//                               DateTime? pickedDate = await showDatePicker(
//                                 context: context,
//                                 initialDate: DateTime.now(),
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime(2101),
//                                 locale: const Locale('en', 'US'),
//                               );

//                               if (pickedDate != null) {
//                                 String formattedDate =
//                                     "${pickedDate!.day.toString().padLeft(2, '0')}-${pickedDate!.month.toString().padLeft(2, '0')}-${pickedDate!.year}";
//                                 setState(() {
//                                   _startDate.text = formattedDate.toString();
//                                 });
//                               }
//                             },
//                             validator: (value) => _startDate == null
//                                 ? 'Please select a start date'
//                                 : null,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         const Text('End Date *',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         Container(
//                           height: 45,
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8.0),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 offset: const Offset(4, 4),
//                                 blurRadius: 8,
//                               ),
//                             ],
//                           ),
//                           child: TextFormField(
//                             controller: _endDate,
//                             readOnly: true,
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                               suffixIcon: IconButton(
//                                   onPressed: () {},
//                                   icon: const Icon(Icons.date_range_rounded)),
//                               hintStyle: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w400,
//                                 color: Color(0xFFb0b6c3),
//                               ),
//                               hintText: 'dd mm yyyy',
//                             ),
//                             onTap: () async {
//                               DateTime? pickedDate = await showDatePicker(
//                                 context: context,
//                                 initialDate: DateTime.now(),
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime(2101),
//                               );
//                               if (pickedDate != null) {
//                                 String formattedDate =
//                                     "${pickedDate!.day.toString().padLeft(2, '0')}-${pickedDate!.month.toString().padLeft(2, '0')}-${pickedDate!.year}";
//                                 setState(() {
//                                   _endDate.text = formattedDate.toString();
//                                 });
//                               }
//                             },
//                             validator: (value) => _startDate == null
//                                 ? 'Please select a end date'
//                                 : null,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color.fromRGBO(21, 43, 83, 1),
//                       ),
//                       borderRadius: BorderRadius.circular(10.0)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text('Rent',
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Color(0xFF152b51))),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text('Rent Cycle *',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         CustomDropdown(
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please select an item';
//                             }
//                             return null;
//                           },
//                           labelText: 'Select Rent',
//                           items: items,
//                           selectedValue: _selectedRent,
//                           onChanged: (String? value) {
//                             setState(() {
//                               _selectedRent = value;
//                             });
//                           },
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         const Text('Amount *',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         CustomTextField(
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'please enter amount';
//                             }
//                           },
//                           keyboardType: TextInputType.text,
//                           hintText: 'Enter Amount',
//                           controller: rentAmount,
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         const Text('Next Due Date',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         Container(
//                           height: 45,
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8.0),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 offset: const Offset(4, 4),
//                                 blurRadius: 8,
//                               ),
//                             ],
//                           ),
//                           child: TextFormField(
//                               controller: rentNextDueDate,
//                               readOnly: true,
//                               decoration: InputDecoration(
//                                 border: InputBorder.none,
//                                 suffixIcon: IconButton(
//                                     onPressed: () {},
//                                     icon: const Icon(Icons.date_range_rounded)),
//                                 hintStyle: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w400,
//                                   color: Color(0xFFb0b6c3),
//                                 ),
//                                 hintText: 'dd mm yyyy',
//                               ),
//                               onTap: () async {
//                                 DateTime? pickedDate = await showDatePicker(
//                                   context: context,
//                                   initialDate: DateTime.now(),
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime(2101),
//                                 );
//                                 if (pickedDate != null) {
//                                   String formattedDate =
//                                       "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate!.month.toString().padLeft(2, '0')}-${pickedDate!.year}";
//                                   setState(() {
//                                     rentNextDueDate.text =
//                                         formattedDate.toString();
//                                   });
//                                 }
//                               },
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'please select a date';
//                                 }
//                                 return null;
//                               }),
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         const Text('Memo',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         CustomTextField(
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'please enter signature';
//                             }
//                             return null;
//                           },
//                           keyboardType: TextInputType.text,
//                           hintText: 'Enter Memo',
//                           controller: rentMemo,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color.fromRGBO(21, 43, 83, 1),
//                       ),
//                       borderRadius: BorderRadius.circular(10.0)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text('Security Deposit (Optional)',
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Color(0xFF152b51))),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text('Amount',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         CustomTextField(
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'please enter amount';
//                             }
//                             return null;
//                           },
//                           keyboardType: TextInputType.text,
//                           hintText: 'Enter Amount',
//                           controller: securityDepositeAmount,
//                         ),
//                         const Padding(
//                           padding: EdgeInsets.all(10.0),
//                           child: Text(
//                               'Don\'t forget to record the payment once you have connected the deposite',
//                               style: TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.grey)),
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color.fromRGBO(21, 43, 83, 1),
//                       ),
//                       borderRadius: BorderRadius.circular(10.0)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text('Charges (Optional)',
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Color(0xFF152b51))),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text('Add Charges',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey)),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Expanded(
//                               child: InkWell(
//                                 onTap: () {
//                                   showDialog(
//                                       context: context,
//                                       builder: (context) {
//                                         return AlertDialog(
//                                           backgroundColor: Colors.white,
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(10.0)),
//                                           title: const Text(
//                                               'Add Recurring content',
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Color(0xFF152b51))),
//                                           content: Container(
//                                             height: 300,
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 CustomDropdown(
//                                                   validator: (value) {
//                                                     if (value == null ||
//                                                         value.isEmpty) {
//                                                       return 'Please select an item';
//                                                     }
//                                                     return null;
//                                                   },
//                                                   labelText: 'Account *',
//                                                   items: items,
//                                                   selectedValue:
//                                                       _selectedProperty,
//                                                   onChanged: (String? value) {
//                                                     setState(() {
//                                                       _selectedProperty = value;
//                                                     });
//                                                   },
//                                                 ),
//                                                 const SizedBox(
//                                                   height: 8,
//                                                 ),
//                                                 const Text('Amount *',
//                                                     style: TextStyle(
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey)),
//                                                 const SizedBox(
//                                                   height: 8,
//                                                 ),
//                                                 CustomTextField(
//                                                   validator: (value) {
//                                                     if (value == null ||
//                                                         value.isEmpty) {
//                                                       return 'please enter amount';
//                                                     }
//                                                     return null;
//                                                   },
//                                                   keyboardType:
//                                                       TextInputType.text,
//                                                   hintText: 'Enter Amount',
//                                                   controller:
//                                                       recurringContentMemo,
//                                                 ),
//                                                 const SizedBox(
//                                                   height: 8,
//                                                 ),
//                                                 const Text('Memo',
//                                                     style: TextStyle(
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey)),
//                                                 const SizedBox(
//                                                   height: 8,
//                                                 ),
//                                                 CustomTextField(
//                                                   validator: (value) {
//                                                     if (value == null ||
//                                                         value.isEmpty) {
//                                                       return 'please enter memo';
//                                                     }
//                                                     return null;
//                                                   },
//                                                   keyboardType:
//                                                       TextInputType.text,
//                                                   hintText: 'Enter Memo',
//                                                   controller:
//                                                       recurringContentMemo,
//                                                 ),
//                                                 Padding(
//                                                   padding: const EdgeInsets.all(
//                                                       16.0),
//                                                   child: Row(
//                                                     children: [
//                                                       Container(
//                                                           height: 50,
//                                                           width: 90,
//                                                           decoration: BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           8.0)),
//                                                           child: ElevatedButton(
//                                                               style: ElevatedButton.styleFrom(
//                                                                   backgroundColor:
//                                                                       const Color(
//                                                                           0xFF152b51),
//                                                                   shape: RoundedRectangleBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               8.0))),
//                                                               onPressed: () {},
//                                                               child: const Text(
//                                                                 'Add',
//                                                                 style: TextStyle(
//                                                                     color: Color(
//                                                                         0xFFf7f8f9)),
//                                                               ))),
//                                                       const SizedBox(
//                                                         width: 8,
//                                                       ),
//                                                       Container(
//                                                           height: 50,
//                                                           width: 94,
//                                                           decoration: BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           8.0)),
//                                                           child: ElevatedButton(
//                                                               style: ElevatedButton.styleFrom(
//                                                                   backgroundColor:
//                                                                       const Color(
//                                                                           0xFFffffff),
//                                                                   shape: RoundedRectangleBorder(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               8.0))),
//                                                               onPressed: () {
//                                                                 Navigator.pop(
//                                                                     context);
//                                                               },
//                                                               child: const Text(
//                                                                 'Cancel',
//                                                                 style: TextStyle(
//                                                                     color: Color(
//                                                                         0xFF748097)),
//                                                               )))
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       });
//                                 },
//                                 child: const Text('+Add One Time Charge',
//                                     style: TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF2ec433))),
//                               ),
//                             ),
//                             InkWell(
//                               onTap: () {
//                                 showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return AlertDialog(
//                                         backgroundColor: Colors.white,
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(10.0)),
//                                         title: const Text(
//                                             'Add One Time Charge Content',
//                                             style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: Color(0xFF152b51))),
//                                         content: Container(
//                                           height: 300,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               CustomDropdown(
//                                                 validator: (value) {
//                                                   if (value == null ||
//                                                       value.isEmpty) {
//                                                     return 'Please select an item';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 labelText: 'Account *',
//                                                 items: items,
//                                                 selectedValue:
//                                                     _selectedProperty,
//                                                 onChanged: (String? value) {
//                                                   setState(() {
//                                                     _selectedProperty = value;
//                                                   });
//                                                 },
//                                               ),
//                                               const SizedBox(
//                                                 height: 8,
//                                               ),
//                                               const Text('Account *',
//                                                   style: TextStyle(
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.grey)),
//                                               const SizedBox(
//                                                 height: 8,
//                                               ),
//                                               CustomTextField(
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 hintText: 'Enter Account',
//                                                 controller:
//                                                     oneTimeContentAmount,
//                                               ),
//                                               const SizedBox(
//                                                 height: 8,
//                                               ),
//                                               const Text('Memo',
//                                                   style: TextStyle(
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.grey)),
//                                               const SizedBox(
//                                                 height: 8,
//                                               ),
//                                               CustomTextField(
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 hintText: 'Enter Memo',
//                                                 controller: oneTimeContentMemo,
//                                               ),
//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.all(16.0),
//                                                 child: Row(
//                                                   children: [
//                                                     Container(
//                                                         height: 50,
//                                                         width: 90,
//                                                         decoration: BoxDecoration(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         8.0)),
//                                                         child: ElevatedButton(
//                                                             style: ElevatedButton.styleFrom(
//                                                                 backgroundColor:
//                                                                     const Color(
//                                                                         0xFF152b51),
//                                                                 shape: RoundedRectangleBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             8.0))),
//                                                             onPressed: () {},
//                                                             child: const Text(
//                                                               'Add',
//                                                               style: TextStyle(
//                                                                   color: Color(
//                                                                       0xFFf7f8f9)),
//                                                             ))),
//                                                     const SizedBox(
//                                                       width: 8,
//                                                     ),
//                                                     Container(
//                                                         height: 50,
//                                                         width: 94,
//                                                         decoration: BoxDecoration(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         8.0)),
//                                                         child: ElevatedButton(
//                                                             style: ElevatedButton.styleFrom(
//                                                                 backgroundColor:
//                                                                     const Color(
//                                                                         0xFFffffff),
//                                                                 shape: RoundedRectangleBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             8.0))),
//                                                             onPressed: () {
//                                                               Navigator.pop(
//                                                                   context);
//                                                             },
//                                                             child: const Text(
//                                                               'Cancel',
//                                                               style: TextStyle(
//                                                                   color: Color(
//                                                                       0xFF748097)),
//                                                             )))
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     });
//                               },
//                               child: const Text('+Add Recurring Charge',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF2ec433))),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color.fromRGBO(21, 43, 83, 1),
//                       ),
//                       borderRadius: BorderRadius.circular(10.0)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text('Charges (Optional)',
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Color(0xFF152b51))),
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         Container(
//                           height: 50,
//                           width: 95,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF152b51),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                             onPressed: () async {
//                               await _pickPdfFiles();
//                             },
//                             child: const Text(
//                               'Upload',
//                               style: TextStyle(color: Color(0xFFf7f8f9)),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Flexible(
//                           fit: FlexFit.loose,
//                           child: ListView.builder(
//                             shrinkWrap: true,
//                             itemCount: _pdfFiles.length,
//                             itemBuilder: (context, index) {
//                               return ListTile(
//                                 title: Text(
//                                     _pdfFiles[index].path.split('/').last,
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                         color: Color(0xFF748097))),
//                                 trailing: IconButton(
//                                     onPressed: () {
//                                       setState(() {
//                                         _pdfFiles.removeAt(index);
//                                       });
//                                     },
//                                     icon: const FaIcon(
//                                       FontAwesomeIcons.remove,
//                                       color: Color(0xFF748097),
//                                     )),
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                   height: 400,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: const Color.fromRGBO(21, 43, 83, 1),
//                     ),
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                           'E-Signature',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: Color(0xFF152b51),
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         SizedBox(
//                           height: 330, // Set a fixed height for TabBarView
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () async {
//                                         setState(() {
//                                           isEnjoyNowSelected = true;
//                                         });
//                                         // await homeController
//                                         //     .refreshSubHomeforenjoynow();
//                                       },
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           border: isEnjoyNowSelected != false
//                                               ? null
//                                               : Border.all(
//                                                   color: const Color.fromRGBO(
//                                                       21, 43, 83, 1),
//                                                   width: 1),
//                                           gradient: isEnjoyNowSelected
//                                               ? const LinearGradient(
//                                                   colors: [
//                                                     Color.fromRGBO(
//                                                         21, 43, 83, 1),
//                                                     Color.fromRGBO(
//                                                         21, 43, 83, 1),
//                                                   ],
//                                                 )
//                                               : null,
//                                           //   color: isEnjoyNowSelected ? Colors.white : Colors.transparent,
//                                           borderRadius: const BorderRadius.only(
//                                             topLeft: Radius.circular(4),
//                                             bottomLeft: Radius.circular(4),
//                                           ),
//                                         ),
//                                         alignment: Alignment.center,
//                                         padding: isEnjoyNowSelected
//                                             ? const EdgeInsets.symmetric(
//                                                 vertical: 13)
//                                             : const EdgeInsets.symmetric(
//                                                 vertical: 12),
//                                         child: isEnjoyNowSelected
//                                             ? Text(
//                                                 "Draw Signature",
//                                                 style: TextStyle(
//                                                   color: !isEnjoyNowSelected
//                                                       ? Colors.transparent
//                                                       : Colors.white,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               )
//                                             : ShaderMask(
//                                                 shaderCallback: (bounds) {
//                                                   return const LinearGradient(
//                                                     colors: [
//                                                       Color.fromRGBO(
//                                                           21, 43, 83, 1),
//                                                       Color.fromRGBO(
//                                                           21, 43, 83, 1),
//                                                     ],
//                                                   ).createShader(bounds);
//                                                 },
//                                                 child: Text(
//                                                   "Draw Signature",
//                                                   style: TextStyle(
//                                                     color: isEnjoyNowSelected
//                                                         ? Colors.transparent
//                                                         : Colors.white,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () async {
//                                         setState(() {
//                                           isEnjoyNowSelected = false;
//                                         });
//                                       },
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           border: isEnjoyNowSelected == false
//                                               ? null
//                                               : Border.all(
//                                                   color: const Color.fromRGBO(
//                                                       21, 43, 83, 1),
//                                                   width: 1),
//                                           gradient: isEnjoyNowSelected == false
//                                               ? const LinearGradient(
//                                                   colors: [
//                                                     Color.fromRGBO(
//                                                         21, 43, 83, 1),
//                                                     Color.fromRGBO(
//                                                         21, 43, 83, 1),
//                                                   ],
//                                                 )
//                                               : null,
//                                           borderRadius: const BorderRadius.only(
//                                             topRight: Radius.circular(4),
//                                             bottomRight: Radius.circular(4),
//                                           ),
//                                         ),
//                                         alignment: Alignment.center,
//                                         padding: isEnjoyNowSelected
//                                             ? const EdgeInsets.symmetric(
//                                                 vertical: 12)
//                                             : const EdgeInsets.symmetric(
//                                                 vertical: 13),
//                                         child: !isEnjoyNowSelected
//                                             ? Text(
//                                                 "Type Signature",
//                                                 style: TextStyle(
//                                                   color: isEnjoyNowSelected
//                                                       ? Colors.transparent
//                                                       : Colors.white,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               )
//                                             : ShaderMask(
//                                                 shaderCallback: (bounds) {
//                                                   return const LinearGradient(
//                                                     colors: [
//                                                       Color.fromRGBO(
//                                                           21, 43, 83, 1),
//                                                       Color.fromRGBO(
//                                                           21, 43, 83, 1),
//                                                     ],
//                                                   ).createShader(bounds);
//                                                 },
//                                                 child: Text(
//                                                   "Type Signature",
//                                                   style: TextStyle(
//                                                     color: !isEnjoyNowSelected
//                                                         ? Colors.transparent
//                                                         : Colors.white,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               isEnjoyNowSelected
//                                   ? Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         const SizedBox(
//                                           height: 5,
//                                         ),
//                                         Container(
//                                           height: 36,
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(10.0),
//                                               border: Border.all(width: 1)),
//                                           child: ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                                 shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10)),
//                                                 backgroundColor: Colors.white),
//                                             onPressed: () {
//                                               _signaturePadKey.currentState!
//                                                   .clear();
//                                             },
//                                             child: const Text('Clear'),
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 5,
//                                         ),
//                                         Container(
//                                           child: SfSignaturePad(
//                                             key: _signaturePadKey,
//                                             strokeColor: Colors.black,
//                                             backgroundColor: Colors.grey[200],
//                                           ),
//                                           height: 200,
//                                           width: 300,
//                                         ),
//                                       ],
//                                     )
//                                   : Padding(
//                                       padding: const EdgeInsets.only(top: 16.0),
//                                       child: Container(
//                                         height: 250,
//                                         decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(10.0),
//                                             border: Border.all(width: 1)),
//                                         child: Column(
//                                           children: [
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 10.0),
//                                               child: TextFormField(
//                                                 validator: (value) {
//                                                   if (value == null ||
//                                                       value.isEmpty) {
//                                                     return 'please enter signature';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 maxLength: 30,
//                                                 decoration: InputDecoration(
//                                                     hintText: 'Type Signature',
//                                                     hintStyle: TextStyle(
//                                                       color: Colors.grey[400],
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                     )),
//                                                 controller: signatureController,
//                                                 onChanged: (newValue) {
//                                                   setState(() {
//                                                     signatureController.text =
//                                                         newValue;
//                                                   });
//                                                 },
//                                               ),
//                                             ),
//                                             const SizedBox(
//                                               height: 20,
//                                             ),
//                                             Container(
//                                               child: Text(
//                                                 '${signatureController.text}',
//                                                 style:
//                                                     GoogleFonts.dancingScript(
//                                                   fontSize: 38,
//                                                   color: Colors.blue,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color.fromRGBO(21, 43, 83, 1),
//                       ),
//                       borderRadius: BorderRadius.circular(10.0)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           children: [
//                             const Text('Residents center Welcome Email',
//                                 style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                     color: Color(0xFF152b51))),
//                             const SizedBox(
//                               width: 5,
//                             ),
//                             Switch(
//                               activeColor: const Color(0xFF152b51),
//                               value: _selectedResidentsEmail,
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedResidentsEmail = newValue;
//                                 });
//                               },
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const Text(
//                             'We send a welcome email to anyone without resident center access',
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Color(0xFF748097))),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     children: [
//                       Container(
//                           height: 50,
//                           width: 150,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8.0)),
//                           child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF67758e),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius:
//                                           BorderRadius.circular(8.0))),
//                               onPressed: () {
//                                 if (formKey.currentState!.validate()) {
//                                   print('Form is valid');
//                                 } else {
//                                   print('Form is invalid');
//                                 }
//                               },
//                               child: const Text(
//                                 'Add Lease',
//                                 style: TextStyle(color: Color(0xFFf7f8f9)),
//                               ))),
//                       const SizedBox(
//                         width: 8,
//                       ),
//                       Container(
//                           height: 50,
//                           width: 120,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8.0)),
//                           child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFffffff),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius:
//                                           BorderRadius.circular(8.0))),
//                               onPressed: () {},
//                               child: const Text(
//                                 'Cancel',
//                                 style: TextStyle(color: Color(0xFF748097)),
//                               )))
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CustomDropdown extends StatefulWidget {
//   final List<String> items;
//   final String? labelText;
//   final String? selectedValue;
//   final ValueChanged<String?> onChanged;
//   final FormFieldValidator<String>? validator;

//   CustomDropdown({
//     Key? key,
//     required this.labelText,
//     required this.items,
//     required this.selectedValue,
//     required this.onChanged,
//     required this.validator,
//   }) : super(key: key);

//   @override
//   _CustomDropdownState createState() => _CustomDropdownState();
// }

// class _CustomDropdownState extends State<CustomDropdown> {
//   @override
//   Widget build(BuildContext context) {
//     return FormField<String>(
//       validator: widget.validator,
//       builder: (FormFieldState<String> state) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             DropdownButtonHideUnderline(
//               child: DropdownButton2<String>(
//                 isExpanded: true,
//                 hint: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         widget.labelText ?? '',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                           color: Color(0xFFb0b6c3),
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 items: widget.items
//                     .map((String item) => DropdownMenuItem<String>(
//                           value: item,
//                           child: Text(
//                             item,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w400,
//                               color: Colors.black87,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ))
//                     .toList(),
//                 value: widget.selectedValue,
//                 onChanged: (value) {
//                   widget.onChanged(value);
//                   state.didChange(value);
//                 },
//                 buttonStyleData: ButtonStyleData(
//                   height: 45,
//                   width: 160,
//                   padding: const EdgeInsets.only(left: 14, right: 14),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(6),
//                     color: Colors.white,
//                   ),
//                   elevation: 2,
//                 ),
//                 iconStyleData: const IconStyleData(
//                   icon: Icon(
//                     Icons.arrow_drop_down,
//                   ),
//                   iconSize: 24,
//                   iconEnabledColor: Color(0xFFb0b6c3),
//                   iconDisabledColor: Colors.grey,
//                 ),
//                 dropdownStyleData: DropdownStyleData(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(6),
//                     color: Colors.white,
//                   ),
//                   scrollbarTheme: ScrollbarThemeData(
//                     radius: const Radius.circular(6),
//                     thickness: MaterialStateProperty.all(6),
//                     thumbVisibility: MaterialStateProperty.all(true),
//                   ),
//                 ),
//                 menuItemStyleData: const MenuItemStyleData(
//                   height: 40,
//                   padding: EdgeInsets.only(left: 14, right: 14),
//                 ),
//               ),
//             ),
//             if (state.hasError)
//               Padding(
//                 padding: const EdgeInsets.only(left: 14, top: 8),
//                 child: Text(
//                   state.errorText!,
//                   style: const TextStyle(R
//                     color: Colors.red,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
