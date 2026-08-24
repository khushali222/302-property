import 'package:three_zero_two_property/services/app_log.dart';
import 'package:flutter/material.dart';
import '../../../../constant/constant.dart';
import '../../../../repository/appliance_note_service.dart';

class AddNoteDialog extends StatefulWidget {
  final String applianceId;
  final VoidCallback? onNoteAdded;
  final String? noteId;
  final String? initialText;

  AddNoteDialog({
    required this.applianceId,
    this.onNoteAdded,
    this.noteId,
    this.initialText,
      });

  @override
  _AddNoteDialogState createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _noteController.text = widget.initialText!;
    }
  }

  Future<void> _updateNote() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter note text')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      ApplianceNoteService noteService = ApplianceNoteService();
      await noteService.updateNote(
        applianceId: widget.applianceId,    
        noteId: widget.noteId!,
        noteText: _noteController.text.trim(),
      );
      Navigator.pop(context, true);
      if (widget.onNoteAdded != null) {
        widget.onNoteAdded!();  
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note updated successfully'),
          backgroundColor: Colors.green,
        ),    
      );
    } catch (e) {
      logError('Error updating note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating note: ${friendlyErrorMessage(e)}'),    
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.noteId != null ? 'Edit Note' : 'Add Note',
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
                      border: Border.all(color: blueColor, width: 2),
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
            SizedBox(height: 24),

            // Note Text Field
            Text(
              'Note Text',
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
              child: TextFormField(
                controller: _noteController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter Note Text',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: EdgeInsets.symmetric(vertical: 12),
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
                    onPressed: _isLoading ? null : widget.noteId != null ? _updateNote : _saveNote,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter note text')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      ApplianceNoteService noteService = ApplianceNoteService();
      
      await noteService.addNote(
        applianceId: widget.applianceId,
        noteText: _noteController.text.trim(),
      );

      Navigator.pop(context, true);
      
      // Call the callback to refresh data
      if (widget.onNoteAdded != null) {
        widget.onNoteAdded!();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      logError('Error adding note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding note: ${friendlyErrorMessage(e)}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
} 