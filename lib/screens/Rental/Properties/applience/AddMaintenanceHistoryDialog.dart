import 'package:three_zero_two_property/services/app_log.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constant/constant.dart';
import '../../../../repository/maintenance_history_service.dart';

class AddMaintenanceHistoryDialog extends StatefulWidget {
  final String applianceId;

  AddMaintenanceHistoryDialog({required this.applianceId});

  @override
  _AddMaintenanceHistoryDialogState createState() =>
      _AddMaintenanceHistoryDialogState();
}

class _AddMaintenanceHistoryDialogState
    extends State<AddMaintenanceHistoryDialog> {
  String? _selectedEventType;
  final _vendorController = TextEditingController();
  List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;

  final List<String> _eventTypes = [
    'Install',
    'Repair',
    'Maintenance',
    'Decommission'
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth * (isSmallScreen ? 0.95 : 0.9),
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Maintenance History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Color(0xFF1E3A8A), width: 2),
                        ),
                        child: Icon(
                          Icons.close,
                          color: blueColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),

                // Event Type Field
                Text(
                  'Event Type *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedEventType,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                      hintText: 'Select Event Type',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                    ),
                    items: _eventTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedEventType = newValue;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),

                // Vendor Field
                Text(
                  'Vendor',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _vendorController,
                  decoration: InputDecoration(
                    hintText: 'Enter Vendor Name',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF1E3A8A)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 16),

                // File Upload Area
                GestureDetector(
                  onTap: _pickFiles,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          color: Color(0xFF1E3A8A),
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Click to upload or drag and drop',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Maximum File Size is 20MB',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Supported File Types are .png, .jpeg, .pdf, .csv',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,

                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_selectedFiles.isNotEmpty) ...[
                          SizedBox(height: 16),
                          ...(_selectedFiles
                              .map((file) => Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.file_present,
                                            color: Color(0xFF1E3A8A)),
                                        SizedBox(width: 8),
                                        Expanded(child: Text(file.name)),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedFiles.remove(file);
                                            });
                                          },
                                          child: Icon(Icons.close,
                                              color: Colors.red, size: 16),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList()),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Action Butto,ns
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 8 : 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: blueColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveMaintenanceHistory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpeg', 'jpg', 'pdf', 'csv'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      logError('Error picking files: $e');
    }
  }

  Future<void> _saveMaintenanceHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString('adminId');
    String? token = prefs.getString('token');

    if (_selectedEventType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an event type')),
      );
      return;
    }

    if (adminId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert PlatformFile to File objects
      List<File> files = [];
      for (var platformFile in _selectedFiles) {
        if (platformFile.path != null) {
          files.add(File(platformFile.path!));
        }
      }

      await MaintenanceHistoryService().addMaintenanceHistory(
        applianceId: widget.applianceId,
        adminId: adminId,
        token: token,
        vendor: _vendorController.text.trim(),
        event: _selectedEventType!,
        files: files.isNotEmpty ? files : null,
      );

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maintenance history added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding maintenance history: ${friendlyErrorMessage(e)}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _vendorController.dispose();
    super.dispose();
  }
}
