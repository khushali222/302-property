import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart' as staff_appbar;
import 'package:three_zero_two_property/StaffModule/widgets/custom_drawer.dart' as staff_drawer;
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../../../constant/constant.dart';
import '../../../../../Model/gallery_photo_model.dart';
import '../../../../../services/gallery_service.dart';
import '../../../../../widgets/appbar.dart';
import '../../../../../widgets/custom_drawer.dart';

/// Full-screen Edit Photo: update description and/or replace image.
class EditPhotoScreen extends StatefulWidget {
  final String rentalId;
  final GalleryPhoto photo;
  final VoidCallback? onSaved;
  /// When true, use Staff AppBar and drawer; when false, use Admin AppBar and drawer.
  final bool isStaffModule;

  const EditPhotoScreen({
    Key? key,
    required this.rentalId,
    required this.photo,
    this.onSaved,
    this.isStaffModule = true,
  }) : super(key: key);

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  late TextEditingController _descController;
  bool _loading = false;
  String? _currentImageFilename;
  File? _pickedFile;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.photo.description);
    _currentImageFilename = widget.photo.image;
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final file = File(x.path);
    setState(() => _loading = true);
    try {
      final filenames = await GalleryService.uploadImages([file]);
      if (filenames.isNotEmpty && mounted) {
        setState(() {
          _pickedFile = file;
          _currentImageFilename = filenames.first;
        });
      }
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: 'Upload failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final desc = _descController.text.trim();
    final descriptionChanged = desc != widget.photo.description;
    final imageChanged = _currentImageFilename != null &&
        _currentImageFilename != widget.photo.image;
    if (!descriptionChanged && !imageChanged) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() => _loading = true);
    try {
      await GalleryService.updatePhoto(
        widget.rentalId,
        widget.photo.id,
        description: desc,
        image: imageChanged ? _currentImageFilename : null,
      );
      if (!mounted) return;
      Fluttertoast.showToast(msg: 'Photo updated successfully');
      widget.onSaved?.call();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: 'Failed to update: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showImage = _pickedFile != null
        ? _pickedFile
        : null;
    final imageUrl = _currentImageFilename != null &&
            _currentImageFilename!.isNotEmpty &&
            showImage == null
        ? (_currentImageFilename!.startsWith('http')
            ? _currentImageFilename!
            : '$image_url$_currentImageFilename')
        : null;
    return Scaffold(
      appBar: widget.isStaffModule
          ? staff_appbar.widget_302_Staff.App_Bar(context: context)
          : widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: widget.isStaffModule
          ? staff_drawer.CustomDrawerStaff(
              currentpage: "Properties",
              dropdown: true,
            )
          : CustomDrawer(
              currentpage: "Properties",
              dropdown: true,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           
            titleBar(
              width: MediaQuery.of(context).size.width * .90,
              title: 'Edit Photo',
            ),
            const SizedBox(height: 14),
            const Text(
              'Update photo details.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text('Photo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _loading ? null : _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDEE2E6),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    FaIcon(FontAwesomeIcons.images, size: 40, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    Text(
                      'Click to change image',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Maximum file size: 10MB per image',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final blockHeight = (constraints.maxWidth * 0.28).clamp(90.0, 140.0).toDouble();
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: blockHeight,
                        height: blockHeight,
                        child: showImage != null
                            ? Image.file(showImage, fit: BoxFit.cover)
                            : (imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image, size: 48),
                                  )
                                : const Icon(Icons.image, size: 48)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          const Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: blockHeight,
                            width: double.infinity,
                            child: TextField(
                          controller: _descController,
                          maxLines: 3,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: 'Enter photo description (optional)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: blueColor,
                      side: BorderSide(color: blueColor),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: _loading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ?  SizedBox(
                            height: 22,
                            width: 22,
                            child: SpinKitFadingCircle(
                              color: Colors.white,
                              size: 28,
                            )
                        )
                        : const Text('Update', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
