import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/applicant_summery_model.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/editapplicationsummaryForm.dart';
import 'package:three_zero_two_property/repository/applicant_summery_repo.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/Summary/SummaryEditApplicant.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/editApplicant.dart';
import 'package:three_zero_two_property/widgets/CustomDateField.dart';
import 'package:three_zero_two_property/widgets/CustomEmailField.dart';
import 'package:three_zero_two_property/widgets/CustomTextField.dart';

class ApplicantContent extends StatefulWidget {
  final String applicant_id;
  applicant_summery_details applicantDetail;
  ApplicantContent({required this.applicant_id, required this.applicantDetail});

  @override
  State<ApplicantContent> createState() => _ApplicantContentState();
}

class _ApplicantContentState extends State<ApplicantContent> {
  bool checked = false;
  bool showEditForm = false;
  final _formKey = GlobalKey<FormState>();
  final _formEditKey = GlobalKey<FormState>();

  // Controllers for each input field

  final TextEditingController _applicantStreetAddressController =
      TextEditingController();
  final TextEditingController _applicantCityController =
      TextEditingController();
  final TextEditingController _applicantStateController =
      TextEditingController();
  final TextEditingController _applicantCountryController =
      TextEditingController();
  final TextEditingController _applicantPostalCodeController =
      TextEditingController();
  final TextEditingController _applicantFirstNameController =
      TextEditingController();
  final TextEditingController _applicantLastNameController =
      TextEditingController();
  final TextEditingController _applicantEmailController =
      TextEditingController();
  final TextEditingController _applicantPhoneNumberController =
      TextEditingController();
  final TextEditingController _applicantBirthdateController =
      TextEditingController();

  final TextEditingController _agreeByController = TextEditingController();
  final TextEditingController _emergencyFirstNameController =
      TextEditingController();
  final TextEditingController _emergencyLastNameController =
      TextEditingController();
  final TextEditingController _emergencyRelationshipController =
      TextEditingController();
  final TextEditingController _emergencyEmailController =
      TextEditingController();
  final TextEditingController _emergencyPhoneNumberController =
      TextEditingController();

  final TextEditingController _rentalAddressController =
      TextEditingController();
  final TextEditingController _rentalCityController = TextEditingController();
  final TextEditingController _rentalStateController = TextEditingController();
  final TextEditingController _rentalCountryController =
      TextEditingController();
  final TextEditingController _rentalPostcodeController =
      TextEditingController();
  final TextEditingController _rentalOwnerFirstNameController =
      TextEditingController();
  final TextEditingController _rentalOwnerLastNameController =
      TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _leavingReasonController =
      TextEditingController();
  final TextEditingController _rentalOwnerEmailController =
      TextEditingController();
  final TextEditingController _rentalOwnerPhoneNumberController =
      TextEditingController();

  final TextEditingController _employmentNameController =
      TextEditingController();
  final TextEditingController _employmentStreetAddressController =
      TextEditingController();
  final TextEditingController _employmentCityController =
      TextEditingController();
  final TextEditingController _employmentStateController =
      TextEditingController();
  final TextEditingController _employmentCountryController =
      TextEditingController();
  final TextEditingController _employmentPostalCodeController =
      TextEditingController();
  final TextEditingController _employmentPrimaryEmailController =
      TextEditingController();
  final TextEditingController _employmentPhoneNumberController =
      TextEditingController();
  final TextEditingController _employmentPositionController =
      TextEditingController();
  final TextEditingController _supervisorFirstNameController =
      TextEditingController();
  final TextEditingController _supervisorLastNameController =
      TextEditingController();
  final TextEditingController _supervisorTitleController =
      TextEditingController();

  @override
  void dispose() {
    // Dispose controllers
    _emergencyFirstNameController.dispose();
    _emergencyLastNameController.dispose();
    _emergencyRelationshipController.dispose();
    _emergencyEmailController.dispose();
    _emergencyPhoneNumberController.dispose();

    _rentalAddressController.dispose();
    _rentalCityController.dispose();
    _rentalStateController.dispose();
    _rentalCountryController.dispose();
    _rentalPostcodeController.dispose();
    _rentalOwnerFirstNameController.dispose();
    _rentalOwnerLastNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _rentController.dispose();
    _leavingReasonController.dispose();
    _rentalOwnerEmailController.dispose();
    _rentalOwnerPhoneNumberController.dispose();

    _employmentNameController.dispose();
    _employmentStreetAddressController.dispose();
    _employmentCityController.dispose();
    _employmentStateController.dispose();
    _employmentCountryController.dispose();
    _employmentPostalCodeController.dispose();
    _employmentPrimaryEmailController.dispose();
    _employmentPhoneNumberController.dispose();
    _employmentPositionController.dispose();
    _supervisorFirstNameController.dispose();
    _supervisorLastNameController.dispose();
    _supervisorTitleController.dispose();

    _applicantStreetAddressController.dispose();
    _applicantCityController.dispose();
    _applicantStateController.dispose();
    _applicantCountryController.dispose();
    _applicantPostalCodeController.dispose();
    _applicantFirstNameController.dispose();
    _applicantLastNameController.dispose();
    _applicantEmailController.dispose();
    _applicantPhoneNumberController.dispose();
    _agreeByController.dispose();

    super.dispose();
  }

  late Future<ApplicantContentDetails> futureApplicantDetails;
  bool showAddForm = false;

  @override
  void initState() {
    super.initState();
    futureApplicantDetails =
        ApplicantSummeryRepository().fetchApplicantDetails(widget.applicant_id);
    fetchApplicantInForm();
  }

  void fetchApplicantInForm() {
    // Delayed execution to set the values after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _applicantFirstNameController.text =
            widget.applicantDetail.applicantFirstName ?? '';
        _applicantLastNameController.text =
            widget.applicantDetail.applicantLastName ?? '';
        _applicantEmailController.text =
            widget.applicantDetail.applicantEmail ?? '';
        _applicantPhoneNumberController.text =
            widget.applicantDetail.applicantPhoneNumber ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final editFormState = Provider.of<EditFormState>(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<ApplicantContentDetails>(
        future: futureApplicantDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: SpinKitFadingCircle(
              color: Colors.black,
              size: 40.0,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var data = snapshot.data!.data;

            print(data!.isApplicantDataEmpty.toString());

            return SingleChildScrollView(
              child: data!.isApplicantDataEmpty == true
                  ? showAddForm == true
                      ? Container(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Text('Enter Applicant Details',
                                          softWrap: true,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              color: blueColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showAddForm = false;
                                        });
                                      },
                                      child: Container(
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          elevation: 4,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: blueColor,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 81, 1)),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Applicant information',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: blueColor),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            const Color.fromRGBO(21, 43, 83, 1),
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'First name',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'First Name',
                                          controller:
                                              _applicantFirstNameController,
                                          keyboardType: TextInputType.text,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter first name';
                                            }

                                            return null;
                                          },
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Last Name',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Last Name',
                                          controller:
                                              _applicantLastNameController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter last name';
                                            }

                                            return null;
                                          },
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Birth Date',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomDateField(
                                          hintText: 'Pick date of birth',
                                          controller:
                                              _applicantBirthdateController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Email',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomEmailField(
                                          hintText: 'Enter your email',
                                          controller: _applicantEmailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Phone Number',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Phone Number',
                                          controller:
                                              _applicantPhoneNumberController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter phone number';
                                            }

                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),
//Applicant Street Address
                                const SizedBox(
                                  height: 16.0,
                                ),
                                Text(
                                  'Applicant Street Address',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: blueColor),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 43, 83, 1),
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Street Address',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Street Address',
                                          controller:
                                              _applicantStreetAddressController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'City',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'City',
                                          controller: _applicantCityController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'State',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'State',
                                          controller: _applicantStateController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Country',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Country',
                                          controller:
                                              _applicantCountryController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Postal Code',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500]),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Postal Code',
                                          controller:
                                              _applicantPostalCodeController,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Emergency contact',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: blueColor,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 43, 83, 1),
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'First Name',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'First Name',
                                          controller:
                                              _emergencyFirstNameController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Last Name',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Last Name',
                                          controller:
                                              _emergencyLastNameController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Relationship',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Relationship',
                                          controller:
                                              _emergencyRelationshipController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Email',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Email',
                                          controller: _emergencyEmailController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Phone Number',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Phone Number',
                                          controller:
                                              _emergencyPhoneNumberController,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Rental history',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: blueColor,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 43, 83, 1),
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Rental Address',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Rental Address',
                                          controller: _rentalAddressController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'City',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'City',
                                          controller: _rentalCityController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'State',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'State',
                                          controller: _rentalStateController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Country',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Country',
                                          controller: _rentalCountryController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Postcode',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Postcode',
                                          controller: _rentalPostcodeController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Start Date',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Start Date',
                                          controller: _startDateController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'End Date',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'End Date',
                                          controller: _endDateController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Rent Amount',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Rent Amount',
                                          controller: _rentController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Reason for Leaving',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Reason for Leaving',
                                          controller: _leavingReasonController,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Rental owner information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: blueColor,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 43, 83, 1),
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'First Name',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'First Name',
                                          controller:
                                              _rentalOwnerFirstNameController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Last Name',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Last Name',
                                          controller:
                                              _rentalOwnerLastNameController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Email',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Email',
                                          controller:
                                              _rentalOwnerEmailController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Phone Number',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Phone Number',
                                          controller:
                                              _rentalOwnerPhoneNumberController,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Employment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: blueColor,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 43, 83, 1),
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Company Name',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Company Name',
                                          controller: _employmentNameController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Street Address',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Street Address',
                                          controller:
                                              _employmentStreetAddressController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'City',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'City',
                                          controller: _employmentCityController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'State',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'State',
                                          controller:
                                              _employmentStateController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Country',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Country',
                                          controller:
                                              _employmentCountryController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Postal Code',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Postal Code',
                                          controller:
                                              _employmentPostalCodeController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Primary Email',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Primary Email',
                                          controller:
                                              _employmentPrimaryEmailController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Phone Number',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Phone Number',
                                          controller:
                                              _employmentPhoneNumberController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Position',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Position',
                                          controller:
                                              _employmentPositionController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Supervisor First Name',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Supervisor First Name',
                                          controller:
                                              _supervisorFirstNameController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Supervisor Last Name',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Supervisor Last Name',
                                          controller:
                                              _supervisorLastNameController,
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          'Supervisor Title',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        NewCustomTextField(
                                          hintText: 'Supervisor Title',
                                          controller:
                                              _supervisorTitleController,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 16.0,
                                    top: 16.0,
                                  ),
                                  child: Text('Terms and conditions',
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                          color: blueColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 16.0,
                                    top: 16.0,
                                  ),
                                  child: Text(
                                      '''I understand that this is a routine application to establish credit, character, employment, and rental history. I also understand that this is NOT an agreement to rent and that all applications must be approved. I authorize verification of references given. I declare that the statements above are true and correct, and I agree that the Rental owner may terminate my agreement entered into in reliance on any misstatement made above.''',
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                        value: checked, onChanged: (value) {}),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4.0,
                                      ),
                                      child: Text('Agreed to*',
                                          softWrap: true,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400)),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4.0,
                                  ),
                                  child: Text('Agreed by',
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                NewCustomTextField(
                                  hintText: 'Agreed by...',
                                  controller: _agreeByController,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 16.0,
                                    top: 16.0,
                                  ),
                                  child: RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text:
                                            'By submitting this application, I (1) am giving permission to run a background check on me, which may include obtaining my credit report from a consumer reporting agency; and (2) agreeing to the ',
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    TextSpan(
                                        text: ' and ',
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    TextSpan(
                                        text: 'Terms of Service.',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                  ])),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: blueColor),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String? adminId =
                                          prefs.getString('adminId');
                                      // printAllFields();
                                      Data data = Data(
                                        emergencyContact: EmergencyContact(
                                          firstName:
                                              _emergencyFirstNameController
                                                  .text,
                                          lastName:
                                              _emergencyLastNameController.text,
                                          relationship:
                                              _emergencyRelationshipController
                                                  .text,
                                          email: _emergencyEmailController.text,
                                          phoneNumber: int.tryParse(
                                              _emergencyPhoneNumberController
                                                  .text),
                                        ),
                                        rentalHistory: RentalHistory(
                                          rentalAdress:
                                              _rentalAddressController.text,
                                          rentalCity:
                                              _rentalCityController.text,
                                          rentalState:
                                              _rentalStateController.text,
                                          rentalCountry:
                                              _rentalCountryController.text,
                                          rentalPostcode:
                                              _rentalPostcodeController.text,
                                          rentalOwnerFirstName:
                                              _rentalOwnerFirstNameController
                                                  .text,
                                          rentalOwnerLastName:
                                              _rentalOwnerLastNameController
                                                  .text,
                                          startDate: _startDateController.text,
                                          endDate: _endDateController.text,
                                          rent: _rentController.text,
                                          leavingReason:
                                              _leavingReasonController.text,
                                          rentalOwnerPrimaryEmail:
                                              _rentalOwnerEmailController.text,
                                          rentalOwnerPhoneNumber: int.tryParse(
                                              _rentalOwnerPhoneNumberController
                                                  .text),
                                        ),
                                        employment: Employment(
                                          name: _employmentNameController.text,
                                          streetAddress:
                                              _employmentStreetAddressController
                                                  .text,
                                          city: _employmentCityController.text,
                                          state:
                                              _employmentStateController.text,
                                          country:
                                              _employmentCountryController.text,
                                          postalCode:
                                              _employmentPostalCodeController
                                                  .text,
                                          employmentPrimaryEmail:
                                              _employmentPrimaryEmailController
                                                  .text,
                                          employmentPhoneNumber: int.tryParse(
                                              _employmentPhoneNumberController
                                                  .text),
                                          employmentPosition:
                                              _employmentPositionController
                                                  .text,
                                          supervisorFirstName:
                                              _supervisorFirstNameController
                                                  .text,
                                          supervisorLastName:
                                              _supervisorLastNameController
                                                  .text,
                                          supervisorTitle:
                                              _supervisorTitleController.text,
                                        ),

                                        applicantId: widget.applicantDetail
                                            .applicantId, // Assuming this value is not set from a controller
                                        adminId:
                                            adminId, // Assuming this value is not set from a controller
                                        applicantStreetAddress:
                                            _applicantStreetAddressController
                                                .text,
                                        applicantCity:
                                            _applicantCityController.text,
                                        applicantState:
                                            _applicantStateController.text,
                                        applicantCountry:
                                            _applicantCountryController.text,
                                        applicantPostalCode:
                                            _applicantPostalCodeController.text,
                                        agreeBy: _agreeByController.text,

                                        applicantFirstName:
                                            _applicantFirstNameController.text,
                                        applicantLastName:
                                            _applicantLastNameController.text,
                                        applicantEmail:
                                            _applicantEmailController.text,
                                        applicantPhoneNumber:
                                            _applicantPhoneNumberController
                                                .text,
                                        isApplicantDataEmpty:
                                            false, // Default value
                                      );
                                      print('entry');
                                      ApplicantSummeryRepository
                                          applicantSummeryRepository =
                                          ApplicantSummeryRepository();
                                      print('entry');
                                      bool success =
                                          await ApplicantSummeryRepository()
                                              .addApplicantSummaryForm(
                                                  data, widget.applicant_id);
                                      if (success == true) {
                                        print('complete');
                                        Fluttertoast.showToast(
                                            msg:
                                                'Applicant Added Successfully');
                                      } else {
                                        print('not complete');
                                        Fluttertoast.showToast(
                                            msg: 'Failed to add applicant');
                                      }
                                    } else {
                                      setState(
                                          () {}); // Rebuild to show the error message
                                      print('Form is invalid');
                                    }
                                  },
                                  child: const Text('Save Applicant'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          child: screenWidth > 500
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                        top: 16.0,
                                      ),
                                      child: Text(
                                          'A rental application is not associated with the applicant. A link to the online rental application can be either emailed directly to the applicant for completion or the application details can be entered manually.',
                                          softWrap: true,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Material(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            elevation: 4,
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: const Color.fromRGBO(
                                                        21, 43, 81, 1)),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Email link to online rental application',
                                                  style: TextStyle(
                                                      color: blueColor,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              print('entry $showAddForm');
                                              setState(() {
                                                showAddForm = true;
                                              });
                                              print('$showAddForm');
                                            },
                                            child: Material(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              elevation: 4,
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                      color:
                                                          const Color.fromRGBO(
                                                              21, 43, 81, 1)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Manually enter application details',
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 18,
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                        top: 16.0,
                                      ),
                                      child: Text(
                                          'A rental application is not associated with the applicant. A link to the online rental application can be either emailed directly to the applicant for completion or the application details can be entered manually.',
                                          softWrap: true,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        ApplicantSummeryRepository
                                            applicantsummeryRepository =
                                            ApplicantSummeryRepository();
                                        int reponse =
                                            await applicantsummeryRepository
                                                .sendMail(widget.applicant_id);
                                        if (reponse == 200) {
                                          Fluttertoast.showToast(
                                              msg: 'Mail Send Successfully');
                                        } else {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'Failed to send mail try again later');
                                        }
                                      },
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        elevation: 4,
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                                color: const Color.fromRGBO(
                                                    21, 43, 81, 1)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Email link to online rental application',
                                              style: TextStyle(
                                                  color: blueColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        print('entry $showAddForm');
                                        setState(() {
                                          showAddForm = true;
                                        });
                                        print('$showAddForm');
                                      },
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        elevation: 4,
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                                color: const Color.fromRGBO(
                                                    21, 43, 81, 1)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Manually enter application details',
                                              style: TextStyle(
                                                  color: blueColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        )
                  : editFormState.showEditForm
                      ? EditApplicantSummary(
                          applicantId: widget.applicant_id,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            data!.rentalHistory != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 81, 1)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  top: 16,
                                                  bottom: 16),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        flex: 3,
                                                        child: Container(
                                                          child: Text(
                                                            "Applicant Information",
                                                            style: TextStyle(
                                                                color: const Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    81,
                                                                    1),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .045),
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            editFormState
                                                                .setEditForm(
                                                                    true);
                                                            // setState(() {
                                                            //   showEditForm =
                                                            //       true;
                                                            // });
                                                          },
                                                          child: Text(
                                                            "Edit", // Updated text to differentiate from the first one
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .045),
                                                          ),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  // Button color
                                                                  backgroundColor:
                                                                      blueColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  // Unit ID
                                                  const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Applicant Name",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${(data.applicantFirstName ?? '').isEmpty ? 'N/A' : data.applicantFirstName} ${(data.applicantLastName ?? '').isEmpty ? 'N/A' : data.applicantLastName}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 18,
                                                  ),
// Applicant Birth Date
                                                  const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Applicant Birth Date",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${(data.applicantFirstName ?? '').isEmpty ? 'N/A' : data.applicantFirstName}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 18,
                                                  ),
// Applicant Current Address
                                                  const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Applicant Current Address",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${(data.applicantCity ?? '').isEmpty ? 'N/A' : data.applicantCity}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 18,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : showEditForm
                                    ? Form(
                                        key: _formEditKey,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                      'Edit Applicant Details',
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                          color: blueColor,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      showEditForm = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    child: Material(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                      elevation: 4,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: blueColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          border: Border.all(
                                                              color: const Color
                                                                  .fromRGBO(21,
                                                                  43, 81, 1)),
                                                        ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            Text(
                                              'Applicant information',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: blueColor),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: const Color.fromRGBO(
                                                        21, 43, 83, 1),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'First name',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'First Name',
                                                      controller:
                                                          _applicantFirstNameController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Last Name',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Last Name',
                                                      controller:
                                                          _applicantLastNameController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Phone Number',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    CustomDateField(
                                                      hintText:
                                                          'Pick date of birth',
                                                      controller:
                                                          _applicantBirthdateController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Email',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Email',
                                                      controller:
                                                          _applicantEmailController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Phone Number',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Phone Number',
                                                      controller:
                                                          _applicantPhoneNumberController,
                                                    ),
                                                    const SizedBox(height: 16),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            //Applicant Street Address
                                            const SizedBox(
                                              height: 16.0,
                                            ),
                                            Text(
                                              'Applicant Street Address',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: blueColor),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 83, 1),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Street Address',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText:
                                                          'Street Address',
                                                      controller:
                                                          _applicantStreetAddressController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'City',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'City',
                                                      controller:
                                                          _applicantCityController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'State',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'State',
                                                      controller:
                                                          _applicantStateController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Country',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Country',
                                                      controller:
                                                          _applicantCountryController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Postal Code',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Postal Code',
                                                      controller:
                                                          _applicantPostalCodeController,
                                                    ),
                                                    const SizedBox(height: 16),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            Text(
                                              'Emergency contact',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: blueColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 83, 1),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'First Name',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'First Name',
                                                      controller:
                                                          _emergencyFirstNameController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Last Name',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Last Name',
                                                      controller:
                                                          _emergencyLastNameController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Relationship',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Relationship',
                                                      controller:
                                                          _emergencyRelationshipController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Email',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Email',
                                                      controller:
                                                          _emergencyEmailController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Phone Number',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Phone Number',
                                                      controller:
                                                          _emergencyPhoneNumberController,
                                                    ),
                                                    const SizedBox(height: 16),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            const SizedBox(
                                              height: 16,
                                            ),
                                            Text(
                                              'Rental history',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: blueColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 83, 1),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Rental Address',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText:
                                                          'Rental Address',
                                                      controller:
                                                          _rentalAddressController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'City',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'City',
                                                      controller:
                                                          _rentalCityController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'State',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'State',
                                                      controller:
                                                          _rentalStateController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Country',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Country',
                                                      controller:
                                                          _rentalCountryController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Postcode',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Postcode',
                                                      controller:
                                                          _rentalPostcodeController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Start Date',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Start Date',
                                                      controller:
                                                          _startDateController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'End Date',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'End Date',
                                                      controller:
                                                          _endDateController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Rent Amount',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Rent Amount',
                                                      controller:
                                                          _rentController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Reason for Leaving',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText:
                                                          'Reason for Leaving',
                                                      controller:
                                                          _leavingReasonController,
                                                    ),
                                                    const SizedBox(height: 16),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            Text(
                                              'Rental owner information',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: blueColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 83, 1),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'First Name',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'First Name',
                                                      controller:
                                                          _rentalOwnerFirstNameController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Last Name',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Last Name',
                                                      controller:
                                                          _rentalOwnerLastNameController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Email',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Email',
                                                      controller:
                                                          _rentalOwnerEmailController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Phone Number',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Phone Number',
                                                      controller:
                                                          _rentalOwnerPhoneNumberController,
                                                    ),
                                                    const SizedBox(height: 16),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            Text(
                                              'Employment',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: blueColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 83, 1),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Company Name',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Company Name',
                                                      controller:
                                                          _employmentNameController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Street Address',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText:
                                                          'Street Address',
                                                      controller:
                                                          _employmentStreetAddressController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'City',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'City',
                                                      controller:
                                                          _employmentCityController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'State',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'State',
                                                      controller:
                                                          _employmentStateController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Country',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Country',
                                                      controller:
                                                          _employmentCountryController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Postal Code',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Postal Code',
                                                      controller:
                                                          _employmentPostalCodeController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Primary Email',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Primary Email',
                                                      controller:
                                                          _employmentPrimaryEmailController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Phone Number',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Phone Number',
                                                      controller:
                                                          _employmentPhoneNumberController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Position',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText: 'Position',
                                                      controller:
                                                          _employmentPositionController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Supervisor First Name',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText:
                                                          'Supervisor First Name',
                                                      controller:
                                                          _supervisorFirstNameController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Supervisor Last Name',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText:
                                                          'Supervisor Last Name',
                                                      controller:
                                                          _supervisorLastNameController,
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    Text(
                                                      'Supervisor Title',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    NewCustomTextField(
                                                      hintText:
                                                          'Supervisor Title',
                                                      controller:
                                                          _supervisorTitleController,
                                                    ),
                                                    const SizedBox(height: 16),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 16.0,
                                                top: 16.0,
                                              ),
                                              child: Text(
                                                  'Terms and conditions',
                                                  softWrap: true,
                                                  overflow: TextOverflow.fade,
                                                  style: TextStyle(
                                                      color: blueColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 16.0,
                                                top: 16.0,
                                              ),
                                              child: Text(
                                                  '''I understand that this is a routine application to establish credit, character, employment, and rental history. I also understand that this is NOT an agreement to rent and that all applications must be approved. I authorize verification of references given. I declare that the statements above are true and correct, and I agree that the Rental owner may terminate my agreement entered into in reliance on any misstatement made above.''',
                                                  softWrap: true,
                                                  overflow: TextOverflow.fade,
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Checkbox(
                                                    value: checked,
                                                    onChanged: (value) {}),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 4.0,
                                                  ),
                                                  child: Text('Agreed to*',
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[500],
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 4.0,
                                              ),
                                              child: Text('Agreed by',
                                                  softWrap: true,
                                                  overflow: TextOverflow.fade,
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            NewCustomTextField(
                                              hintText: 'Agreed by...',
                                              controller: _agreeByController,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 16.0,
                                                top: 16.0,
                                              ),
                                              child: RichText(
                                                  text: TextSpan(children: [
                                                TextSpan(
                                                    text:
                                                        'By submitting this application, I (1) am giving permission to run a background check on me, which may include obtaining my credit report from a consumer reporting agency; and (2) agreeing to the ',
                                                    style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                TextSpan(
                                                    text: 'Privacy Policy',
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                TextSpan(
                                                    text: ' and ',
                                                    style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                TextSpan(
                                                    text: 'Terms of Service.',
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ])),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: blueColor),
                                              onPressed: () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  String? adminId = prefs
                                                      .getString('adminId');
                                                  // printAllFields();
                                                  Data data = Data(
                                                    emergencyContact:
                                                        EmergencyContact(
                                                      firstName:
                                                          _emergencyFirstNameController
                                                              .text,
                                                      lastName:
                                                          _emergencyLastNameController
                                                              .text,
                                                      relationship:
                                                          _emergencyRelationshipController
                                                              .text,
                                                      email:
                                                          _emergencyEmailController
                                                              .text,
                                                      phoneNumber: int.tryParse(
                                                          _emergencyPhoneNumberController
                                                              .text),
                                                    ),
                                                    rentalHistory:
                                                        RentalHistory(
                                                      rentalAdress:
                                                          _rentalAddressController
                                                              .text,
                                                      rentalCity:
                                                          _rentalCityController
                                                              .text,
                                                      rentalState:
                                                          _rentalStateController
                                                              .text,
                                                      rentalCountry:
                                                          _rentalCountryController
                                                              .text,
                                                      rentalPostcode:
                                                          _rentalPostcodeController
                                                              .text,
                                                      rentalOwnerFirstName:
                                                          _rentalOwnerFirstNameController
                                                              .text,
                                                      rentalOwnerLastName:
                                                          _rentalOwnerLastNameController
                                                              .text,
                                                      startDate:
                                                          _startDateController
                                                              .text,
                                                      endDate:
                                                          _endDateController
                                                              .text,
                                                      rent:
                                                          _rentController.text,
                                                      leavingReason:
                                                          _leavingReasonController
                                                              .text,
                                                      rentalOwnerPrimaryEmail:
                                                          _rentalOwnerEmailController
                                                              .text,
                                                      rentalOwnerPhoneNumber:
                                                          int.tryParse(
                                                              _rentalOwnerPhoneNumberController
                                                                  .text),
                                                    ),
                                                    employment: Employment(
                                                      name:
                                                          _employmentNameController
                                                              .text,
                                                      streetAddress:
                                                          _employmentStreetAddressController
                                                              .text,
                                                      city:
                                                          _employmentCityController
                                                              .text,
                                                      state:
                                                          _employmentStateController
                                                              .text,
                                                      country:
                                                          _employmentCountryController
                                                              .text,
                                                      postalCode:
                                                          _employmentPostalCodeController
                                                              .text,
                                                      employmentPrimaryEmail:
                                                          _employmentPrimaryEmailController
                                                              .text,
                                                      employmentPhoneNumber:
                                                          int.tryParse(
                                                              _employmentPhoneNumberController
                                                                  .text),
                                                      employmentPosition:
                                                          _employmentPositionController
                                                              .text,
                                                      supervisorFirstName:
                                                          _supervisorFirstNameController
                                                              .text,
                                                      supervisorLastName:
                                                          _supervisorLastNameController
                                                              .text,
                                                      supervisorTitle:
                                                          _supervisorTitleController
                                                              .text,
                                                    ),

                                                    applicantId: widget
                                                        .applicantDetail
                                                        .applicantId, // Assuming this value is not set from a controller
                                                    adminId:
                                                        adminId, // Assuming this value is not set from a controller
                                                    applicantStreetAddress:
                                                        _applicantStreetAddressController
                                                            .text,
                                                    applicantCity:
                                                        _applicantCityController
                                                            .text,
                                                    applicantState:
                                                        _applicantStateController
                                                            .text,
                                                    applicantCountry:
                                                        _applicantCountryController
                                                            .text,
                                                    applicantPostalCode:
                                                        _applicantPostalCodeController
                                                            .text,
                                                    agreeBy:
                                                        _agreeByController.text,

                                                    applicantFirstName:
                                                        _applicantFirstNameController
                                                            .text,
                                                    applicantLastName:
                                                        _applicantLastNameController
                                                            .text,
                                                    applicantEmail:
                                                        _applicantEmailController
                                                            .text,
                                                    applicantPhoneNumber:
                                                        _applicantPhoneNumberController
                                                            .text,
                                                    isApplicantDataEmpty:
                                                        false, // Default value
                                                  );
                                                  print('entry');
                                                  ApplicantSummeryRepository
                                                      applicantSummeryRepository =
                                                      ApplicantSummeryRepository();
                                                  print('entry');
                                                  bool success =
                                                      await ApplicantSummeryRepository()
                                                          .addApplicantSummaryForm(
                                                              data,
                                                              widget
                                                                  .applicant_id);
                                                  if (success == true) {
                                                    print('complete');
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'Applicant Added Successfully');
                                                  } else {
                                                    print('not complete');
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'Failed to add applicant');
                                                  }
                                                } else {
                                                  setState(
                                                      () {}); // Rebuild to show the error message
                                                  print('Form is invalid');
                                                }
                                              },
                                              child:
                                                  const Text('Save Applicant'),
                                            ),
                                          ],
                                        ),
                                      )
                                    : showEditForm
                                        ? EditApplicantSummary(
                                            applicantId: widget.applicant_id,
                                          )
                                        : LayoutBuilder(
                                          builder: (context,contraints) {
                                            if(contraints.maxWidth > 500){
                                              return Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(0.0),
                                                    child: Material(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                          border: Border.all(
                                                              color: const Color
                                                                  .fromRGBO(
                                                                  21, 43, 81, 1)),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 16,
                                                              right: 16,
                                                              top: 16,
                                                              bottom: 16),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    flex: 3,
                                                                    child:
                                                                    Container(
                                                                      child: Text(
                                                                        "Applicant Information",
                                                                        style: TextStyle(
                                                                            color: const Color
                                                                                .fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            MediaQuery.of(context).size.width *
                                                                                .03),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    child:
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        print(
                                                                            'full edit');
                                                                        setState(
                                                                                () {
                                                                              showEditForm =
                                                                              true;
                                                                            });
                                                                      },
                                                                      child: Text(
                                                                        "Edit", // Updated text to differentiate from the first one
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            MediaQuery.of(context).size.width *
                                                                                .03),
                                                                      ),
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        // Button color
                                                                          backgroundColor:
                                                                          blueColor),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              // Unit ID


                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Column(
                                                                      children: [
                                                                        const Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 2,
                                                                            ),
                                                                            Text(
                                                                              "Applicant Name",
                                                                              style: TextStyle(
                                                                                  color: Color(
                                                                                      0xFF8A95A8),
                                                                                  fontWeight:
                                                                                  FontWeight
                                                                                      .bold,
                                                                                  fontSize:
                                                                                  18),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            const SizedBox(
                                                                                width: 2),
                                                                            Text(
                                                                              '${data.applicantFirstName} ${data.applicantLastName}',
                                                                              style:
                                                                              const TextStyle(
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                                fontSize: 16,
                                                                                color: Color
                                                                                    .fromRGBO(
                                                                                    21,
                                                                                    43,
                                                                                    83,
                                                                                    1),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                                width: 2),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 18,
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(
                                                                      children: [
                                                                        const Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 2,
                                                                            ),
                                                                            Text(
                                                                              "Applicant Birth Date",
                                                                              style: TextStyle(
                                                                                  color: Color(
                                                                                      0xFF8A95A8),
                                                                                  fontWeight:
                                                                                  FontWeight
                                                                                      .bold,
                                                                                  fontSize:
                                                                                  18),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            const SizedBox(
                                                                                width: 2),
                                                                            Text(
                                                                              '${data.applicantCity ?? 'N/A'}',
                                                                              style:
                                                                              const TextStyle(
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                                fontSize:16,
                                                                                color: Color
                                                                                    .fromRGBO(
                                                                                    21,
                                                                                    43,
                                                                                    83,
                                                                                    1),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                                width: 2),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              // Rental Owner


                                                              const SizedBox(
                                                                height: 18,
                                                              ),
                                                              // Tenant
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Column(
                                                                      children: [
                                                                        const Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 2,
                                                                            ),
                                                                            Text(
                                                                              "Applicant Current Address",
                                                                              style: TextStyle(
                                                                                  color: Color(
                                                                                      0xFF8A95A8),
                                                                                  fontWeight:
                                                                                  FontWeight
                                                                                      .bold,
                                                                                  fontSize:
                                                                                  18),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            const SizedBox(
                                                                                width: 2),
                                                                            Text(
                                                                              '${data.applicantStreetAddress ?? 'N/A'}',
                                                                              style:
                                                                              const TextStyle(
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                                fontSize: 16,
                                                                                color: Color
                                                                                    .fromRGBO(
                                                                                    21,
                                                                                    43,
                                                                                    83,
                                                                                    1),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                                width: 2),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 18,
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(
                                                                      children: [
                                                                        const Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 2,
                                                                            ),
                                                                            Text(
                                                                              "Applicant Email",
                                                                              style: TextStyle(
                                                                                  color: Color(
                                                                                      0xFF8A95A8),
                                                                                  fontWeight:
                                                                                  FontWeight
                                                                                      .bold,
                                                                                  fontSize:
                                                                                  18),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            const SizedBox(
                                                                                width: 2),
                                                                            Text(
                                                                              '${data.applicantEmail ?? 'N/A'}',
                                                                              style:
                                                                              const TextStyle(
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                                fontSize: 16,
                                                                                color: Color
                                                                                    .fromRGBO(
                                                                                    21,
                                                                                    43,
                                                                                    83,
                                                                                    1),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                                width: 2),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                             

                                                            
                                                              // Tenant
                                                            
                                                              
                                                              const SizedBox(
                                                                height: 18,
                                                              ),
                                                              // Tenant
                                                              const Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    "Applicant Phone",
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        fontSize:
                                                                        18),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const SizedBox(
                                                                      width: 2),
                                                                  Text(
                                                                    '${data.applicantPhoneNumber ?? 'N/A'}',
                                                                    style:
                                                                    const TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      fontSize:16,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 2),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // Add more fields as needed
                                                ],
                                              );
                                            }
                                            return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(0.0),
                                                    child: Material(
                                                      borderRadius:
                                                          BorderRadius.circular(10),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10),
                                                          border: Border.all(
                                                              color: const Color
                                                                  .fromRGBO(
                                                                  21, 43, 81, 1)),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  left: 16,
                                                                  right: 16,
                                                                  top: 16,
                                                                  bottom: 16),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    flex: 3,
                                                                    child:
                                                                        Container(
                                                                      child: Text(
                                                                        "Applicant Information",
                                                                        style: TextStyle(
                                                                            color: const Color
                                                                                .fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                            fontSize:
                                                                                MediaQuery.of(context).size.width *
                                                                                    .045),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        print(
                                                                            'full edit');
                                                                        setState(
                                                                            () {
                                                                          showEditForm =
                                                                              true;
                                                                        });
                                                                      },
                                                                      child: Text(
                                                                        "Edit", // Updated text to differentiate from the first one
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                            fontSize:
                                                                                MediaQuery.of(context).size.width *
                                                                                    .045),
                                                                      ),
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                              // Button color
                                                                              backgroundColor:
                                                                                  blueColor),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              // Unit ID
                                                              const Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    "Applicant Name",
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const SizedBox(
                                                                      width: 2),
                                                                  Text(
                                                                    '${data.applicantFirstName} ${data.applicantLastName}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 2),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 18,
                                                              ),
                                                              // Rental Owner
                                                              const Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    "Applicant Birth Date",
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const SizedBox(
                                                                      width: 2),
                                                                  Text(
                                                                    '${data.applicantCity ?? 'N/A'}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 2),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 18,
                                                              ),
                                                              // Tenant
                                                              const Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    "Applicant Current Address",
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const SizedBox(
                                                                      width: 2),
                                                                  Text(
                                                                    '${data.applicantStreetAddress ?? 'N/A'}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 2),
                                                                ],
                                                              ),

                                                              const SizedBox(
                                                                height: 18,
                                                              ),
                                                              // Tenant
                                                              const Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    "Applicant Email",
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const SizedBox(
                                                                      width: 2),
                                                                  Text(
                                                                    '${data.applicantEmail ?? 'N/A'}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 2),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 18,
                                                              ),
                                                              // Tenant
                                                              const Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    "Applicant Phone",
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const SizedBox(
                                                                      width: 2),
                                                                  Text(
                                                                    '${data.applicantPhoneNumber ?? 'N/A'}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 2),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // Add more fields as needed
                                                ],
                                              );
                                          }
                                        ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            data!.rentalHistory != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 81, 1)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  top: 16,
                                                  bottom: 16),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Rental History",
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromRGBO(
                                                                21, 43, 81, 1),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .045),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  // Unit ID
                                                  const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Rental Address",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      Flexible(
                                                        child: Text(
                                                          '${(data.rentalHistory?.rentalAdress ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.rentalAdress}, '
                                                          '${(data.rentalHistory?.rentalCity ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.rentalCity}, '
                                                          '${(data.rentalHistory?.rentalState ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.rentalState}, '
                                                          '${(data.rentalHistory?.rentalCountry ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.rentalCountry}, '
                                                          '${(data.rentalHistory?.rentalPostcode ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.rentalPostcode}',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 24,
                                                  ),
// Rental Owner
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Rental Dates",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${(data.rentalHistory?.startDate ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.startDate} to ${(data.rentalHistory?.endDate ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.endDate}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Monthly Rent",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${(data.rentalHistory?.rent ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.rent}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 24,
                                                  ),
// Tenant
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Reason of Leaving",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${(data.rentalHistory?.leavingReason ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.leavingReason}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Rental Owner Name",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${(data.rentalHistory?.rentalOwnerFirstName ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.rentalOwnerFirstName} ${(data.rentalHistory?.rentalOwnerLastName ?? 'N/A').isEmpty ? 'N/A' : data.rentalHistory!.rentalOwnerLastName}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(
                                                    height: 24,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Rental Owner Phone",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${data.rentalHistory!.rentalOwnerPhoneNumber ?? 'N/A'}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Rental Owner Email",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${data.rentalHistory!.rentalOwnerPrimaryEmail ?? 'N/A'}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 18,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : showEditForm
                                    ? Container()
                                    : LayoutBuilder(
                                      builder: (context,constraint) {
                                        if(constraint.maxWidth > 600){
                                          return Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(0.0),
                                                child: Material(
                                                  borderRadius:
                                                  BorderRadius.circular(10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      border: Border.all(
                                                          color:
                                                          const Color.fromRGBO(
                                                              21, 43, 81, 1)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 16,
                                                          right: 16,
                                                          top: 16,
                                                          bottom: 16),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              Text(
                                                                "Rental History",
                                                                style: TextStyle(
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize: MediaQuery.of(
                                                                        context)
                                                                        .size
                                                                        .width *
                                                                        .03),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          // Unit ID
                                                          const Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 2,
                                                              ),
                                                              Text(
                                                                "Rental Address",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize: 18),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          const Row(
                                                            children: [
                                                              SizedBox(width: 2),
                                                              Text(
                                                                'N/A',
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize:16,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      83,
                                                                      1),
                                                                ),
                                                              ),
                                                              SizedBox(width: 2),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 18,
                                                          ),
                                                          // Rental Owner
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  child:
                                                                  const Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      Text(
                                                                        "Rental Dates",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            18),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        'N/A',
                                                                        style:
                                                                        TextStyle(
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:16,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  child:
                                                                  const Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      Text(
                                                                        "Monthly Rent",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            18),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        'N/A',
                                                                        style:
                                                                        TextStyle(
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:16,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 18,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  child:
                                                                  const Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      Text(
                                                                        "Reason of Leaving",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            18),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        'N/A',
                                                                        style:
                                                                        TextStyle(
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:16,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  child:
                                                                  const Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      Text(
                                                                        "Rental Owner Name",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            18),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        'N/A',
                                                                        style:
                                                                        TextStyle(
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:16,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          const SizedBox(
                                                            height: 24,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      const Text(
                                                                        "Rental Owner Phone",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            18),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        '${(data.rentalHistory?.rentalOwnerPhoneNumber ?? 'N/A').toString().isEmpty ? 'N/A' :'N/A'}',
                                                                        style:
                                                                        const TextStyle(
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:16,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      const Text(
                                                                        "Rental Owner Email",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            18),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        '${(data.rentalHistory?.rentalOwnerPrimaryEmail ?? 'N/A').isEmpty ? 'N/A' : 'N/A'}',
                                                                        style:
                                                                        const TextStyle(
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:16,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              83,
                                                                              1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(0.0),
                                                child: Material(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(10),
                                                      border: Border.all(
                                                          color:
                                                              const Color.fromRGBO(
                                                                  21, 43, 81, 1)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 16,
                                                              right: 16,
                                                              top: 16,
                                                              bottom: 16),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              Text(
                                                                "Rental History",
                                                                style: TextStyle(
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: MediaQuery.of(
                                                                                context)
                                                                            .size
                                                                            .width *
                                                                        .045),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          // Unit ID
                                                          const Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 2,
                                                              ),
                                                              Text(
                                                                "Rental Address",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: 12),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          const Row(
                                                            children: [
                                                              SizedBox(width: 2),
                                                              Text(
                                                                'N/A',
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                              SizedBox(width: 2),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 18,
                                                          ),
                                                          // Rental Owner
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  child:
                                                                      const Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      Text(
                                                                        "Rental Dates",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        'N/A',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                                  21,
                                                                                  43,
                                                                                  83,
                                                                                  1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  child:
                                                                      const Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      Text(
                                                                        "Monthly Rent",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        'N/A',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                                  21,
                                                                                  43,
                                                                                  83,
                                                                                  1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 18,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  child:
                                                                      const Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      Text(
                                                                        "Reason of Leaving",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        'N/A',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                                  21,
                                                                                  43,
                                                                                  83,
                                                                                  1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  child:
                                                                      const Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      Text(
                                                                        "Rental Owner Name",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        'N/A',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                                  21,
                                                                                  43,
                                                                                  83,
                                                                                  1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          const SizedBox(
                                                            height: 24,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      const Text(
                                                                        "Rental Owner Phone",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        '${(data.rentalHistory?.rentalOwnerPhoneNumber ?? 'N/A').toString().isEmpty ? 'N/A' :'N/A'}',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                                  21,
                                                                                  43,
                                                                                  83,
                                                                                  1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                        width: 2,
                                                                      ),
                                                                      const Text(
                                                                        "Rental Owner Email",
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF8A95A8),
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        '${(data.rentalHistory?.rentalOwnerPrimaryEmail ?? 'N/A').isEmpty ? 'N/A' : 'N/A'}',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                          color: Color
                                                                              .fromRGBO(
                                                                                  21,
                                                                                  43,
                                                                                  83,
                                                                                  1),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                      }
                                    ),
                            const SizedBox(
                              height: 16,
                            ),
                            data!.emergencyContact != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 81, 1)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  top: 16,
                                                  bottom: 16),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Emergency Contact Information",
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromRGBO(
                                                                21, 43, 81, 1),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .045),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  // Unit ID
                                                  const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Emergency Contact Name",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${(data.emergencyContact?.firstName ?? 'N/A').isEmpty ? '' : data.emergencyContact!.firstName} ${(data.emergencyContact?.lastName ?? 'N/A').isEmpty ? 'N/A' : data.emergencyContact!.lastName}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 18,
                                                  ),
// Emergency Contact Relationship
                                                  const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Emergency Contact Relationship",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${(data.emergencyContact?.relationship ?? 'N/A').isEmpty ? 'N/A' : data.emergencyContact!.relationship}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 18,
                                                  ),
// Emergency Contact Email
                                                  const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Emergency Contact Email",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${(data.emergencyContact?.email ?? 'N/A').isEmpty ? 'N/A' : data.emergencyContact!.email}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 18,
                                                  ),
// Emergency Contact Phone
                                                  const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Emergency Contact Phone",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${(data.emergencyContact?.phoneNumber ?? 'N/A').toString().isEmpty ? 'N/A' : data.emergencyContact!.phoneNumber}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 18,
                                                  ),

                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : showEditForm
                                    ? Container()
                                    : LayoutBuilder(
                                      builder: (context,contraints) {
                                        if(contraints.maxWidth > 600)
                                          {
                                            return Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(0.0),
                                                  child: Material(
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                        BorderRadius.circular(10),
                                                        border: Border.all(
                                                            color:
                                                            const Color.fromRGBO(
                                                                21, 43, 81, 1)),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            left: 16,
                                                            right: 16,
                                                            top: 16,
                                                            bottom: 16),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 2,
                                                                ),
                                                                Text(
                                                                  "Emergency Contact Information",
                                                                  style: TextStyle(
                                                                      color: const Color
                                                                          .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      fontSize: MediaQuery.of(
                                                                          context)
                                                                          .size
                                                                          .width *
                                                                          .03),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // Unit ID
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    children: [
                                                                      const Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width: 2,
                                                                          ),
                                                                          Text(
                                                                            "Emergency Contact Name",
                                                                            style: TextStyle(
                                                                                color: Color(
                                                                                    0xFF8A95A8),
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                                fontSize: 18),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      const Row(
                                                                        children: [
                                                                          SizedBox(width: 2),
                                                                          Text(
                                                                            'N/A',
                                                                            style: TextStyle(
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontSize:16,
                                                                              color: Color
                                                                                  .fromRGBO(
                                                                                  21,
                                                                                  43,
                                                                                  83,
                                                                                  1),
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 2),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 18,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    children: [
                                                                      const Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width: 2,
                                                                          ),
                                                                          Text(
                                                                            "Emergency Contact Relationship",
                                                                            style: TextStyle(
                                                                                color: Color(
                                                                                    0xFF8A95A8),
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                                fontSize: 18),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      const Row(
                                                                        children: [
                                                                          SizedBox(width: 2),
                                                                          Text(
                                                                            'N/A',
                                                                            style: TextStyle(
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontSize:16,
                                                                              color: Color
                                                                                  .fromRGBO(
                                                                                  21,
                                                                                  43,
                                                                                  83,
                                                                                  1),
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 2),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            
                                                            // Rental Owner
                                                           

                                                            const SizedBox(
                                                              height: 18,
                                                            ),
                                                            // Tenant
                                                            const Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width: 2,
                                                                          ),
                                                                          Text(
                                                                            "Emergency Contact Email",
                                                                            style: TextStyle(
                                                                                color: Color(
                                                                                    0xFF8A95A8),
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                                fontSize: 18),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          SizedBox(width: 2),
                                                                          Text(
                                                                            'N/A',
                                                                            style: TextStyle(
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontSize:16,
                                                                              color: Color
                                                                                  .fromRGBO(
                                                                                  21,
                                                                                  43,
                                                                                  83,
                                                                                  1),
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 2),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 18,
                                                                ),
                                                                // Tenant
                                                                Expanded(
                                                                  child: Column(
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width: 2,
                                                                          ),
                                                                          Text(
                                                                            "Emergency Contact Phone",
                                                                            style: TextStyle(
                                                                                color: Color(
                                                                                    0xFF8A95A8),
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                                fontSize: 18),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          SizedBox(width: 2),
                                                                          Text(
                                                                            'N/A',
                                                                            style: TextStyle(
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontSize:16,
                                                                              color: Color
                                                                                  .fromRGBO(
                                                                                  21,
                                                                                  43,
                                                                                  83,
                                                                                  1),
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 2),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                           
                                                           
                                                           
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        return Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(0.0),
                                              child: Material(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    border: Border.all(
                                                        color:
                                                        const Color.fromRGBO(
                                                            21, 43, 81, 1)),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 16,
                                                        right: 16,
                                                        top: 16,
                                                        bottom: 16),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              "Emergency Contact Information",
                                                              style: TextStyle(
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      81,
                                                                      1),
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: MediaQuery.of(
                                                                      context)
                                                                      .size
                                                                      .width *
                                                                      .045),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        // Unit ID
                                                        const Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              "Emergency Contact Name",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF8A95A8),
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        const Row(
                                                          children: [
                                                            SizedBox(width: 2),
                                                            Text(
                                                              'N/A',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                              ),
                                                            ),
                                                            SizedBox(width: 2),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 18,
                                                        ),
                                                        // Rental Owner
                                                        const Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              "Emergency Contact Relationship",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF8A95A8),
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        const Row(
                                                          children: [
                                                            SizedBox(width: 2),
                                                            Text(
                                                              'N/A',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                              ),
                                                            ),
                                                            SizedBox(width: 2),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 18,
                                                        ),
                                                        // Tenant
                                                        const Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              "Emergency Contact Email",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF8A95A8),
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        const Row(
                                                          children: [
                                                            SizedBox(width: 2),
                                                            Text(
                                                              'N/A',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                              ),
                                                            ),
                                                            SizedBox(width: 2),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 18,
                                                        ),
                                                        // Tenant
                                                        const Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              "Emergency Contact Phone",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF8A95A8),
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        const Row(
                                                          children: [
                                                            SizedBox(width: 2),
                                                            Text(
                                                              'N/A',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                              ),
                                                            ),
                                                            SizedBox(width: 2),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );

                                      }
                                    ),
                            const SizedBox(
                              height: 16,
                            ),
                            data!.employment != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      21, 43, 81, 1)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  top: 16,
                                                  bottom: 16),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Employment",
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromRGBO(
                                                                21, 43, 81, 1),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .045),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  // Unit ID
                                                  const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        "Employer Address",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      Flexible(
                                                        child: Text(
                                                          '${(data.employment?.streetAddress?.isEmpty ?? true) ? 'N/A' : data.employment!.streetAddress}, '
                                                          '${(data.employment?.city?.isEmpty ?? true) ? 'N/A' : data.employment!.city}, '
                                                          '${(data.employment?.state?.isEmpty ?? true) ? 'N/A' : data.employment!.state}, '
                                                          '${(data.employment?.country?.isEmpty ?? true) ? 'N/A' : data.employment!.country}, '
                                                          '${(data.employment?.postalCode?.isEmpty ?? true) ? 'N/A' : data.employment!.postalCode}',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 24,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Employer Name",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${(data.employment?.name?.isEmpty ?? true) ? 'N/A' : data.employment!.name}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Employer Phone Number",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${(data.employment?.employmentPhoneNumber?.toString().isEmpty ?? true) ? 'N/A' : data.employment!.employmentPhoneNumber}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 24,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Employer Email",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${(data.employment?.employmentPrimaryEmail?.isEmpty ?? true) ? 'N/A' : data.employment!.employmentPrimaryEmail}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Employer Position",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${(data.employment?.employmentPosition?.isEmpty ?? true) ? 'N/A' : data.employment!.employmentPosition}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 24,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Supervisor Name",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${(data.employment?.supervisorFirstName?.isEmpty ?? true) ? 'N/A' : data.employment!.supervisorFirstName} '
                                                                '${(data.employment?.supervisorLastName?.isEmpty ?? true) ? 'N/A' : data.employment!.supervisorLastName}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Text(
                                                                "Supervisor Title",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                '${(data.employment?.supervisorTitle?.isEmpty ?? true) ? 'N/A' : data.employment!.supervisorTitle}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          83,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  // Tenant
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : showEditForm
                                    ? Container()
                                    : LayoutBuilder(
                                      builder: (context,contraints) {
                                        if(contraints.maxWidth  > 500)
                                          {
                                            return Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(0.0),
                                                  child: Material(
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                        BorderRadius.circular(10),
                                                        border: Border.all(
                                                            color:
                                                            const Color.fromRGBO(
                                                                21, 43, 81, 1)),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            left: 16,
                                                            right: 16,
                                                            top: 16,
                                                            bottom: 16),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 2,
                                                                ),
                                                                Text(
                                                                  "Employment",
                                                                  style: TextStyle(
                                                                      color: const Color
                                                                          .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      fontSize: MediaQuery.of(
                                                                          context)
                                                                          .size
                                                                          .width *
                                                                          .03),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // Unit ID
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // Unit ID
                                                            const Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 2,
                                                                ),
                                                                Text(
                                                                  "Employer Address",
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xFF8A95A8),
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      fontSize: 18),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            const Row(
                                                              children: [
                                                                SizedBox(width: 2),
                                                                Text(
                                                                  'N/A',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:16,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        83,
                                                                        1),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 2),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            const SizedBox(
                                                              height: 18,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Container(
                                                                    child:
                                                                    const Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        SizedBox(
                                                                          width: 2,
                                                                        ),
                                                                        Text(
                                                                          "Employer Name",
                                                                          style: TextStyle(
                                                                              color: Color(
                                                                                  0xFF8A95A8),
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontSize:
                                                                              18),
                                                                        ),
                                                                        SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text(
                                                                          'N/A',
                                                                          style:
                                                                          TextStyle(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:16,
                                                                            color: Color
                                                                                .fromRGBO(
                                                                                21,
                                                                                43,
                                                                                83,
                                                                                1),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    child:
                                                                    const Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        SizedBox(
                                                                          width: 2,
                                                                        ),
                                                                        Text(
                                                                          "Employer Phone Number",
                                                                          style: TextStyle(
                                                                              color: Color(
                                                                                  0xFF8A95A8),
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontSize:
                                                                              18),
                                                                        ),
                                                                        SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text(
                                                                          'N/A',
                                                                          style:
                                                                          TextStyle(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:16,
                                                                            color: Color
                                                                                .fromRGBO(
                                                                                21,
                                                                                43,
                                                                                83,
                                                                                1),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            // Unit ID

                                                            const SizedBox(
                                                              height: 18,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Container(
                                                                    child:
                                                                    const Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        SizedBox(
                                                                          width: 2,
                                                                        ),
                                                                        Text(
                                                                          "Employer Email",
                                                                          style: TextStyle(
                                                                              color: Color(
                                                                                  0xFF8A95A8),
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontSize:
                                                                              18),
                                                                        ),
                                                                        SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text(
                                                                          'N/A',
                                                                          style:
                                                                          TextStyle(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:16,
                                                                            color: Color
                                                                                .fromRGBO(
                                                                                21,
                                                                                43,
                                                                                83,
                                                                                1),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    child:
                                                                    const Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        SizedBox(
                                                                          width: 2,
                                                                        ),
                                                                        Text(
                                                                          "Position Held",
                                                                          style: TextStyle(
                                                                              color: Color(
                                                                                  0xFF8A95A8),
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,

                                                                              fontSize:
                                                                              18),
                                                                        ),
                                                                        SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text(
                                                                          'N/A',
                                                                          style:
                                                                          TextStyle(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:16,
                                                                            color: Color
                                                                                .fromRGBO(
                                                                                21,
                                                                                43,
                                                                                83,
                                                                                1),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            const SizedBox(
                                                              height: 18,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Container(
                                                                    child:
                                                                    const Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        SizedBox(
                                                                          width: 2,
                                                                        ),
                                                                        Text(
                                                                          "Supervisor Title",
                                                                          style: TextStyle(
                                                                              color: Color(
                                                                                  0xFF8A95A8),
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontSize:
                                                                              12),
                                                                        ),
                                                                        SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text(
                                                                          'N/A',
                                                                          style:
                                                                          TextStyle(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:16,
                                                                            color: Color
                                                                                .fromRGBO(
                                                                                21,
                                                                                43,
                                                                                83,
                                                                                1),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    child:
                                                                    const Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        SizedBox(
                                                                          width: 2,
                                                                        ),
                                                                        Text(
                                                                          "Supervisor Name",
                                                                          style: TextStyle(
                                                                              color: Color(
                                                                                  0xFF8A95A8),
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontSize:
                                                                              18),
                                                                        ),
                                                                        SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text(
                                                                          'N/A',
                                                                          style:
                                                                          TextStyle(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold, fontSize:16,
                                                                            color: Color
                                                                                .fromRGBO(
                                                                                21,
                                                                                43,
                                                                                83,
                                                                                1),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        return Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(0.0),
                                              child: Material(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    border: Border.all(
                                                        color:
                                                        const Color.fromRGBO(
                                                            21, 43, 81, 1)),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 16,
                                                        right: 16,
                                                        top: 16,
                                                        bottom: 16),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              "Employment",
                                                              style: TextStyle(
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      81,
                                                                      1),
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: MediaQuery.of(
                                                                      context)
                                                                      .size
                                                                      .width *
                                                                      .045),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        // Unit ID
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        // Unit ID
                                                        const Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              "Employer Address",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF8A95A8),
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        const Row(
                                                          children: [
                                                            SizedBox(width: 2),
                                                            Text(
                                                              'N/A',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
                                                              ),
                                                            ),
                                                            SizedBox(width: 2),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const SizedBox(
                                                          height: 18,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                child:
                                                                const Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    Text(
                                                                      "Employer Name",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                          12),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'N/A',
                                                                      style:
                                                                      TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Color
                                                                            .fromRGBO(
                                                                            21,
                                                                            43,
                                                                            83,
                                                                            1),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                child:
                                                                const Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    Text(
                                                                      "Employer Phone Number",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                          12),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'N/A',
                                                                      style:
                                                                      TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Color
                                                                            .fromRGBO(
                                                                            21,
                                                                            43,
                                                                            83,
                                                                            1),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        // Unit ID

                                                        const SizedBox(
                                                          height: 18,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                child:
                                                                const Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    Text(
                                                                      "Employer Email",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                          12),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'N/A',
                                                                      style:
                                                                      TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Color
                                                                            .fromRGBO(
                                                                            21,
                                                                            43,
                                                                            83,
                                                                            1),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                child:
                                                                const Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    Text(
                                                                      "Position Held",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                          12),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'N/A',
                                                                      style:
                                                                      TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Color
                                                                            .fromRGBO(
                                                                            21,
                                                                            43,
                                                                            83,
                                                                            1),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(
                                                          height: 18,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                child:
                                                                const Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    Text(
                                                                      "Supervisor Title",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                          12),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'N/A',
                                                                      style:
                                                                      TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Color
                                                                            .fromRGBO(
                                                                            21,
                                                                            43,
                                                                            83,
                                                                            1),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                child:
                                                                const Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    Text(
                                                                      "Supervisor Name",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF8A95A8),
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                          12),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'N/A',
                                                                      style:
                                                                      TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Color
                                                                            .fromRGBO(
                                                                            21,
                                                                            43,
                                                                            83,
                                                                            1),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    ),
                          ],
                        ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  void printAllFields() {
    print('Applicant : ${widget.applicant_id}');
    print(
        'Applicant Street Address: ${_applicantStreetAddressController.text}');
    print('Applicant City: ${_applicantCityController.text}');
    print('Applicant State: ${_applicantStateController.text}');
    print('Applicant Country: ${_applicantCountryController.text}');
    print('Applicant Postal Code: ${_applicantPostalCodeController.text}');
    print('Applicant First Name: ${_applicantFirstNameController.text}');
    print('Applicant Last Name: ${_applicantLastNameController.text}');
    print('Applicant Email: ${_applicantEmailController.text}');
    print('Applicant Phone Number: ${_applicantPhoneNumberController.text}');
    print('Applicant Birthdate: ${_applicantBirthdateController.text}');
    print('Agree By: ${_agreeByController.text}');
    print('Emergency First Name: ${_emergencyFirstNameController.text}');
    print('Emergency Last Name: ${_emergencyLastNameController.text}');
    print('Emergency Relationship: ${_emergencyRelationshipController.text}');
    print('Emergency Email: ${_emergencyEmailController.text}');
    print('Emergency Phone Number: ${_emergencyPhoneNumberController.text}');
    print('Rental Address: ${_rentalAddressController.text}');
    print('Rental City: ${_rentalCityController.text}');
    print('Rental State: ${_rentalStateController.text}');
    print('Rental Country: ${_rentalCountryController.text}');
    print('Rental Postcode: ${_rentalPostcodeController.text}');
    print('Rental Owner First Name: ${_rentalOwnerFirstNameController.text}');
    print('Rental Owner Last Name: ${_rentalOwnerLastNameController.text}');
    print('Start Date: ${_startDateController.text}');
    print('End Date: ${_endDateController.text}');
    print('Rent: ${_rentController.text}');
    print('Leaving Reason: ${_leavingReasonController.text}');
    print('Rental Owner Email: ${_rentalOwnerEmailController.text}');
    print(
        'Rental Owner Phone Number: ${_rentalOwnerPhoneNumberController.text}');
    print('Employment Name: ${_employmentNameController.text}');
    print(
        'Employment Street Address: ${_employmentStreetAddressController.text}');
    print('Employment City: ${_employmentCityController.text}');
    print('Employment State: ${_employmentStateController.text}');
    print('Employment Country: ${_employmentCountryController.text}');
    print('Employment Postal Code: ${_employmentPostalCodeController.text}');
    print(
        'Employment Primary Email: ${_employmentPrimaryEmailController.text}');
    print('Employment Phone Number: ${_employmentPhoneNumberController.text}');
    print('Employment Position: ${_employmentPositionController.text}');
    print('Supervisor First Name: ${_supervisorFirstNameController.text}');
    print('Supervisor Last Name: ${_supervisorLastNameController.text}');
    print('Supervisor Title: ${_supervisorTitleController.text}');
  }
}
