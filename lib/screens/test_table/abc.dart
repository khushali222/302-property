import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
// void Main(){
//   runApp()
// }

class AddTenant extends StatefulWidget {
  @override
  State<AddTenant> createState() => _AddTenantState();
}

class _AddTenantState extends State<AddTenant> {
  final TextEditingController firstName = TextEditingController();

  final TextEditingController lastName = TextEditingController();

  final TextEditingController phoneNumber = TextEditingController();

  final TextEditingController workNumber = TextEditingController();

  final TextEditingController email = TextEditingController();

  final TextEditingController alterEmail = TextEditingController();

  final TextEditingController passWord = TextEditingController();

  final TextEditingController dob = TextEditingController();

  final TextEditingController taxPayerId = TextEditingController();

  final TextEditingController comments = TextEditingController();

  final TextEditingController contactName = TextEditingController();

  final TextEditingController relationToTenant = TextEditingController();

  final TextEditingController emergencyEmail = TextEditingController();

  final TextEditingController emergencyPhoneNumber = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formkey,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      height: 812,
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
                            Text('First Name *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter first name',
                              controller: firstName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the first name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Last Name *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter last name',
                              controller: lastName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the last name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Phone Number *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              hintText: 'Enter phone number',
                              controller: phoneNumber,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the phone number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Work Number',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              hintText: 'Enter work number',
                              controller: workNumber,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Email *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter Email',
                              controller: email,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Alternative Email',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter alternative email',
                              controller: alterEmail,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Password *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    keyboardType: TextInputType.text,
                                    obscureText: true,
                                    hintText: 'Enter password',
                                    controller: passWord,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'please enter password';
                                      }
                                      return null;
                                    },
                                    suffixIcon: Icon(Icons.abc),
                                  ),
                                ),
                                SizedBox(
                                    width:
                                    10), // Add some space between the widgets
                                Container(
                                  width: 38,
                                  height: 40,
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.eyeSlash,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(1.2, 1.2),
                                        blurRadius: 10.0,
                                        spreadRadius: 2.0,
                                      ),
                                    ],
                                    border: Border.all(
                                        width: 0, color: Colors.white),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                ),
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
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      height: 398,
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
                            Text('Personal Information',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(21, 43, 103, 1))),
                            SizedBox(
                              height: 15,
                            ),
                            Text('Date of Birth',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 46,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(1.2,
                                          1.2), // Shadow offset to the bottom right
                                      blurRadius:
                                      10.0, // How much to blur the shadow
                                      spreadRadius:
                                      2.0, // How much the shadow should spread
                                    ),
                                  ],
                                  border:
                                  Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: TextFormField(
                                style: TextStyle(
                                  color: Color(0xFF8898aa), // Text color
                                  fontSize: 16.0, // Text size
                                  fontWeight: FontWeight.w400, // Text weight
                                ),
                                controller: _dateController,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: Color(0xFFb0b6c3)),
                                  border: InputBorder.none,
                                  // labelText: 'Select Date',
                                  hintText: 'Select Date',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () {
                                      _selectDate(context);
                                    },
                                  ),
                                ),
                                readOnly: true,
                                onTap: () {
                                  _selectDate(context);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('TaxPayer ID',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(height: 10),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter contact name',
                              controller: taxPayerId,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Comments',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 90,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(1.2,
                                          1.2), // Shadow offset to the bottom right
                                      blurRadius:
                                      10.0, // How much to blur the shadow
                                      spreadRadius:
                                      2.0, // How much the shadow should spread
                                    ),
                                  ],
                                  border:
                                  Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: comments,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        fontSize: 13, color: Color(0xFFb0b6c3)),
                                    hintText: 'Enter the comment',
                                  )),
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
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      height: 508,
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
                            Text('Emergency Contact',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(21, 43, 103, 1))),
                            SizedBox(
                              height: 15,
                            ),
                            Text('Contact Name',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter contact name',
                              controller: contactName,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Relationship to Tenant',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter relationship to tenant',
                              controller: relationToTenant,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('E-Mail',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter email',
                              controller: emergencyEmail,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Phone Number',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              hintText: 'Enter phone number',
                              controller: emergencyPhoneNumber,
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
                                borderRadius: BorderRadius.circular(8.0)),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF67758e),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8.0))),
                                onPressed: () {
                                  if (_formkey.currentState!.validate()) {
                                    print('Form is valid');
                                  } else {
                                    print('Form is invalid');
                                  }
                                },
                                child: Text(
                                  'Add Tenant',
                                  style: TextStyle(color: Color(0xFFf7f8f9)),
                                ))),
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
                                onPressed: () {},
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
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;

  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onSuffixIconPressed;

  CustomTextField({
    Key? key,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.emailAddress,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSuffixIconPressed,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  TextEditingController _textController =
  TextEditingController(); // Add this line

  @override
  void dispose() {
    _textController.dispose(); // Dispose the controller when not needed anymore
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        FormField<String>(
          validator: (value) {
            if (_textController.text.isEmpty) {
              setState(() {
                _errorMessage = 'Please ${widget.hintText}';
              });
              return '';
            }
            setState(() {
              _errorMessage = null;
            });
            return null;
          },
          builder: (FormFieldState<String> state) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(4, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    keyboardType: widget.keyboardType,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        state.validate();
                      }
                      return null;
                    },
                    controller: _textController,
                    decoration: InputDecoration(
                      hintStyle:
                      TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
                      border: InputBorder.none,
                      hintText: widget.hintText,
                    ),
                  ),
                ),
                if (state.hasError)
                  SizedBox(height: 24), // Reserve space for error message
              ],
            );
          },
        ),
        if (_errorMessage != null)
          Positioned(
            top: 60,
            left: 8,
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}
