import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart';
import 'package:three_zero_two_property/StaffModule/widgets/custom_drawer.dart';
import '../../../../../constant/constant.dart';
import '../../../../../Model/gallery_photo_model.dart';
import '../../../../../services/gallery_service.dart';

/// Full-screen Edit Photo: update description and/or replace image.
class EditPhotoScreen extends StatefulWidget {
  final String rentalId;
  final GalleryPhoto photo;
  final VoidCallback? onSaved;

  const EditPhotoScreen({
    Key? key,
    required this.rentalId,
    required this.photo,
    this.onSaved,
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
    setState(() => _loading = true);
    try {
      await GalleryService.updatePhoto(
        widget.rentalId,
        widget.photo.id,
        description: desc,
        image: _currentImageFilename != widget.photo.image ? _currentImageFilename : null,
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Photo'),
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Properties",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Update photo details.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: showImage != null
                        ? Image.file(showImage!, fit: BoxFit.cover)
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Enter photo description (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                    child: const Text('Cancel'),
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
                        : const Text('Update'),
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
