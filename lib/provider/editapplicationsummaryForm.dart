
import 'package:flutter/material.dart';

class EditFormState with ChangeNotifier {
  bool _showEditForm = false;

  bool get showEditForm => _showEditForm;

  void toggleEditForm() {
    _showEditForm = !_showEditForm;
    notifyListeners();
  }

  void setEditForm(bool value) {
    _showEditForm = value;
    notifyListeners();
  }
}
