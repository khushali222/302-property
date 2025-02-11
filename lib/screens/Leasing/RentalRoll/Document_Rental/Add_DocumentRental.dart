import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/lease.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/applicants.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

class AddDocument extends StatefulWidget {
  const AddDocument({super.key});

  @override
  State<AddDocument> createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController firstName = TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String renderId = '';
  String unitId = '';
  final List<String> items = [
    "Insurance policy Docs",
    "Lease agreements",
    "Lease renewal offers",
    "Lease renewal letters"
  ];
  String? selectedValue;

  File? _image;
  List<File> _images = [];
  String? _uploadedFileName;
  List<String> _uploadedFileNames = [];
  Future<String?> uploadImage(File imageFile) async {
    print(imageFile.path);
    final String uploadUrl = '${image_upload_url}/api/images/upload';

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          uploadUrl,
        ));
    request.files
        .add(await http.MultipartFile.fromPath('files', imageFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);
    print(responseData.body);

    var responseBody = json.decode(responseData.body);
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
        _images.add(File(image.path));
      });
      _uploadImage(File(image.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String? fileName = await uploadImage(imageFile);
      setState(() {
        _uploadedFileNames.add(fileName!);
        _uploadedFileName = fileName;
      });
    } catch (e) {
      print('Image upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Column(
          children: [
            titleBar(
              width: MediaQuery.of(context).size.width * .91,
              title: 'Add Document',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: blueColor,
                    ),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      const Text('Name *',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      const SizedBox(
                        height: 4,
                      ),
                      CustomTextField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        hintText: 'Enter first name',
                        controller: firstName,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text('Document Type *',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      const SizedBox(
                        height: 4,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FormField<String>(
                            validator: (value) {
                              if (selectedValue == null) {
                                return 'Please select an option';
                              }
                              return null;
                            },
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
                                      items: items
                                          .map((String item) =>
                                              DropdownMenuItem<String>(
                                                value: item,
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                        padding: const EdgeInsets.only(
                                            left: 14, right: 14),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          //color: Colors.redAccent,
                                        ),
                                        offset: const Offset(-20, 0),
                                        scrollbarTheme: ScrollbarThemeData(
                                          radius: const Radius.circular(40),
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
                                    ),
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 14, top: 8),
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
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text('Upload file *',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      const SizedBox(
                        height: 4,
                      ),
                      Container(
                        height: 45,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () async {
                            _pickImage().then((_) {
                              setState(
                                  () {}); // Rebuild the widget after selecting the image
                            });
                          },
                          child: Text(
                            'Upload here',
                            style: TextStyle(color: Color(0xFFf7f8f9)),
                          ),
                        ),
                      ),
                      _images.isNotEmpty
                          ? Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    //color: Colors.blue,
                                    child: Wrap(
                                      spacing:
                                          8.0, // Horizontal spacing between items
                                      runSpacing:
                                          8.0, // Vertical spacing between rows
                                      children: List.generate(
                                        _images.length,
                                        (index) {
                                          return Container(
                                            // color: Colors.green,
                                            width: 85,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 60,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _images
                                                              .removeAt(index);
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      // color:Colors.blue,
                                                      child: Image.file(
                                                        _images[index],
                                                        height: 80,
                                                        width: 80,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Text("No images selected."),
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
                      width: 170,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0))),
                          onPressed: () async {
                            if (_formkey.currentState?.validate() ?? false) {
                              print('valid');

                              //_submitApplicantAndLease();
                              //charges
                            } else {
                              print('invalid');
                            }
                          },
                          child: const Text(
                            'Create Applicant',
                            style: TextStyle(color: Color(0xFFf7f8f9)),
                          ))),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                      height: 50,
                      width: 120,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFffffff),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0))),
                          onPressed: () {
                            Navigator.pop(context);
                            firstName.clear();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF748097)),
                          )))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _submitApplicantAndLease() async {
  //   setState(() {
  //     _Loading = true;
  //   });
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String adminId = prefs.getString('adminId').toString();
  //
  //     print(firstName.text);
  //     print(lastName.text);
  //     print(email.text);
  //     print(mobileNumber.text);
  //     print(homeNumber.text);
  //     print(telePhoneNumber.text);
  //     print(bussinessNumber.text);
  //     print(_selectedProperty.toString());
  //     print(_selectedUnit.toString());
  //
  //     // Create the ApplicantDetails object
  //     ApplicantDetails applicantData = ApplicantDetails(
  //       adminId: adminId,
  //       applicantFirstName: firstName.text.trim(),
  //       applicantLastName: lastName.text.trim(),
  //       applicantEmail: email.text.trim(),
  //       applicantPhoneNumber: mobileNumber.text.trim(),
  //       applicantHomeNumber: homeNumber.text.trim(),
  //       applicantTelephoneNumber: telePhoneNumber.text.trim(),
  //       applicantBusinessNumber: bussinessNumber.text.trim(),
  //     );
  //
  //     // Create the LeaseApplicant object
  //     LeaseApplicant leaseData = LeaseApplicant(
  //       adminId: adminId,
  //       rentalAddress: _selectedPropertyId.toString(),
  //       rentalUnit: _selectedUnitId.toString(),
  //     );
  //
  //     print(_selectedProperty);
  //     print(_selectedUnit);
  //     // Create the ApplicantData object
  //     Datum applicantDataObj = Datum(
  //       applicant: applicantData,
  //       lease: leaseData,
  //     );
  //
  //     // Make the POST request
  //     final Map<String, dynamic> response =
  //     await ApplicantRepository.postApplicant(
  //       applicantData: applicantDataObj,
  //     );
  //
  //     // Handle successful response
  //     Navigator.pop(context, true);
  //     // print('Response: $response');
  //   } catch (e) {
  //     // Handle error
  //     print('Error posting applicant and lease: $e');
  //   } finally {
  //     setState(() {
  //       _Loading = false;
  //     });
  //   }
  // }
}
