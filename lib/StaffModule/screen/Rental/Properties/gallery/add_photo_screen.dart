import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../constant/constant.dart';
import '../../../../../services/gallery_service.dart';
import '../../../../../widgets/appbar.dart';
import '../../../../../widgets/custom_drawer.dart';
import '../../../../../widgets/titleBar.dart';
import '../../../../widgets/appbar.dart' as staff_appbar;
import '../../../../widgets/custom_drawer.dart' as staff_drawer;

/// Full-screen Add Photos: pick images, add descriptions, upload then POST to gallery + history.
class AddPhotoScreen extends StatefulWidget {
  final String rentalId;
  final VoidCallback? onAdded;
  /// When true, use Staff AppBar and drawer; when false, use Admin AppBar and drawer.
  final bool isStaffModule;

  const AddPhotoScreen({
    Key? key,
    required this.rentalId,
    this.onAdded,
    this.isStaffModule = true,
  }) : super(key: key);

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final List<File> _files = [];
  final List<TextEditingController> _descControllers = [];
  bool _loading = false;
  static const int _maxSizeMb = 10;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final list = await picker.pickMultiImage();
    if (list.isEmpty) return;
    setState(() {
      for (final x in list) {
        _files.add(File(x.path));
        _descControllers.add(TextEditingController());
      }
    });
  }

  void _removeAt(int index) {
    setState(() {
      _descControllers[index].dispose();
      _files.removeAt(index);
      _descControllers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_files.isEmpty) {
      Fluttertoast.showToast(msg: 'Select at least one photo');
      return;
    }
    setState(() => _loading = true);
    try {
      final filenames = await GalleryService.uploadImages(_files);
      for (var i = 0; i < filenames.length; i++) {
        final desc = _descControllers[i].text.trim();
        await GalleryService.addPhotoToGallery(
          widget.rentalId,
          image: filenames[i],
          description: desc,
        );
        await GalleryService.postGalleryHistory(
          widget.rentalId,
          description: desc.isEmpty ? 'Photo' : desc,
        );
      }
      if (!mounted) return;
      Fluttertoast.showToast(msg: 'Photos added successfully');
      widget.onAdded?.call();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: 'Failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in _descControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhotos = _files.isNotEmpty;
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
      body: SingleChildScrollView(child: Column(
        children: [
          const SizedBox(height: 20),
          titleBar(
            width: MediaQuery.of(context).size.width * .90,
            title: 'Add Photos',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
          
                Text(
                  'Add multiple photos to the gallery.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 20),
                if (!hasPhotos) ...[
                  const Text(
                    'Photos *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _loading ? null : _pickImages,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDEE2E6), width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.images,
                            size: 48,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Click to upload images (multiple selection allowed)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Maximum file size: ${_maxSizeMb}MB per image',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (hasPhotos) ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _files.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDEE2E6)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _files[index],
                                    width: 88,
                                    height: 88,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeAt(index),
                                    child:  Padding(padding: const EdgeInsets.all(2.0), child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.white,
                                      child: FaIcon(FontAwesomeIcons.xmark, color: Colors.black, size: 10),
                                    ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _descControllers[index],
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter photo description (optional)',
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: blueColor,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: blueColor),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: _loading ? null : _pickImages,
                      icon: const FaIcon(FontAwesomeIcons.plus, size: 15),
                      label: const Text('Add More Photos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                    ),
                  ),
                ],
              ],
            ),
          ),
         SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
            child: Row(
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
                    onPressed: _loading || _files.isEmpty ? null : _submit,
                    child: _loading
                          ? SpinKitFadingCircle(color: Colors.white, size: 28)
                        : const Text('Add Photo', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
