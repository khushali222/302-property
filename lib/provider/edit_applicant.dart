import 'package:flutter/cupertino.dart';
import 'package:three_zero_two_property/Model/applicant_summery_model.dart';

class ApplicantDetailsProvider extends ChangeNotifier {
  Data? _applicantDetails;

  Data? get applicantDetails => _applicantDetails;

  void setApplicantDetails(Data details) {
    _applicantDetails = details;
    notifyListeners();
  }
}