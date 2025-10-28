import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';
import '../../constant/constant.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/appbar.dart';
import '../../widgets/custom_drawer.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Form state
  String? _selectedCategory;
  String? _selectedPriority;
  List<File> _attachments = [];
  bool _isSubmitting = false;

  // Dropdown options
  final List<String> _categories = [
    'Bug',
    'Question',
    'Feature Request',
    'Billing',
    'Other'
  ];

  final List<String> _priorities = ['Low', 'Normal', 'High', 'Urgent'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Validation methods
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!EmailValidator.validate(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateSubject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a subject';
    }
    if (value.trim().length < 5) {
      return 'Subject must be at least 5 characters';
    }
    if (value.trim().length > 100) {
      return 'Subject must be less than 100 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a description';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (value.trim().length > 1000) {
      return 'Description must be less than 1000 characters';
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  String? _validatePriority(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a priority';
    }
    return null;
  }

  // File handling methods
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'pdf',
          'doc',
          'docx',
          'txt'
        ],
      );

      if (result != null) {
        List<File> newFiles = result.paths.map((path) => File(path!)).toList();

        // Check file count limit
        if (_attachments.length + newFiles.length > 5) {
          Fluttertoast.showToast(
            msg: 'Maximum 5 files allowed',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          return;
        }

        // Check file size limit (10MB per file)
        for (File file in newFiles) {
          int fileSizeInBytes = await file.length();
          double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

          if (fileSizeInMB > 10) {
            Fluttertoast.showToast(
              msg:
                  'File ${file.path.split('/').last} is too large. Maximum size is 10MB.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
            );
            return;
          }
        }

        setState(() {
          _attachments.addAll(newFiles);
        });

        Fluttertoast.showToast(
          msg: '${newFiles.length} file(s) added successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error picking files: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  // Form submission
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      Fluttertoast.showToast(
        msg: 'Please select a category',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (_selectedPriority == null) {
      Fluttertoast.showToast(
        msg: 'Please select a priority',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Here you would typically send the data to your backend
      Map<String, dynamic> formData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'subject': _subjectController.text.trim(),
        'category': _selectedCategory,
        'priority': _selectedPriority,
        'description': _descriptionController.text.trim(),
        'attachments': _attachments.map((file) => file.path).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('Form submitted with data: $formData');

      // Show success message
      Fluttertoast.showToast(
        msg: 'Ticket submitted successfully! We\'ll get back to you shortly.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Clear form
      _clearForm();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error submitting ticket. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedPriority = null;
      _attachments.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Contact Support",
        dropdown: false,
      ),
      appBar: widget_302.App_Bar(context: context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tell us what\'s going on. We\'ll get back to you shortly.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),

              // Name Field
              Text(
                'Name *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                hintText: 'Your name',
                validator: _validateName,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
              ),
              SizedBox(height: 20),

              // Email Field
              Text(
                'Email *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: _emailController,
                hintText: 'you@company.com',
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),

              // Subject Field
              Text(
                'Subject *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: _subjectController,
                hintText: 'Brief summary',
                validator: _validateSubject,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),

              // Category Dropdown
              Text(
                'Category *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF8A95A8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: DropdownButtonFormField2<String>(
                  isExpanded: false,
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  hint: Text(
                    'Select category',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 5), // ✅ FIX
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: _validateCategory,
                ),
              ),
              SizedBox(height: 20),

              // Priority Dropdown
              Text(
                'Priority *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF8A95A8)!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: DropdownButtonFormField2<String>(
                  value: _selectedPriority,
                  isExpanded: false,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  hint: Text(
                    'Select priority',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 5), // ✅ FIX
                  ),
                  iconStyleData: IconStyleData(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  items: _priorities.map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(
                        priority,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPriority = newValue;
                    });
                  },
                  validator: _validatePriority,
                ),
              ),
              SizedBox(height: 20),

              // Description Field
              Text(
                'Description *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Describe the issue in detail',
                validator: _validateDescription,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
              ),
              SizedBox(height: 20),

              // Attachments Section
              Text(
                'Attachments (Maximum of 5)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),

              // File Upload Button
              GestureDetector(
                onTap: _pickFiles,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFF8A95A8)!,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    color: Colors.grey[50],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 40,
                        color: blueColor,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Click to upload files',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: blueColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Each file must be 10 MB or less. Supported: images, PDF, documents',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Attached Files List
              if (_attachments.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Attached Files:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                ..._attachments.asMap().entries.map((entry) {
                  int index = entry.key;
                  File file = entry.value;
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF8A95A8)!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          color: blueColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            file.path.split('/').last,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeAttachment(index),
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],

              SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Submitting...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Submit Ticket',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
