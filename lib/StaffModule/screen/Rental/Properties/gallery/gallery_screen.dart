import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../constant/constant.dart';
import '../../../../../Model/gallery_photo_model.dart';
import '../../../../../services/gallery_service.dart';
import 'add_photo_screen.dart';
import 'edit_photo_screen.dart';
import 'photo_preview_screen.dart';

/// Full-screen Gallery: grid of photos with Add Photo, Edit, Delete, Set Cover, and tap-to-preview.
class GalleryScreen extends StatefulWidget {
  final String rentalId;
  final String? propertyAddress;

  const GalleryScreen({
    Key? key,
    required this.rentalId,
    this.propertyAddress,
  }) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<GalleryPhoto> _photos = [];
  bool _loading = true;
  String? _error;
  String? _settingCoverPhotoId;

  Future<void> _loadGallery() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await GalleryService.getGallery(widget.rentalId);
      if (mounted) {
        setState(() {
          _photos = res.photos;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _deletePhoto(GalleryPhoto photo) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFF3E0),
                            border: Border.all(color: const Color(0xFFFF9800), width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              '!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9800),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Are you sure?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: blueColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Do you want to delete this photo from the gallery?',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '×',
                          style: TextStyle(fontSize: 22, color: blueColor, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: blueColor,
                        side: BorderSide(color: blueColor),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm != true) return;
    try {
      await GalleryService.deletePhoto(widget.rentalId, photo.id);
      if (mounted) {
        Fluttertoast.showToast(msg: 'Photo deleted');
        _loadGallery();
      }
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: 'Failed to delete: $e');
    }
  }

  Future<void> _setCover(GalleryPhoto photo) async {
    if (photo.isCover) return;
    setState(() => _settingCoverPhotoId = photo.id);
    // Optimistic update: show this photo as cover immediately
    setState(() {
      _photos = _photos
          .map((p) => p.copyWith(isCover: p.id == photo.id))
          .toList();
    });
    try {
      await GalleryService.setCover(widget.rentalId, photo.id);
      if (mounted) {
        Fluttertoast.showToast(msg: 'Cover photo set');
        _loadGallery();
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Failed to set cover: $e');
        _loadGallery();
      }
    } finally {
      if (mounted) setState(() => _settingCoverPhotoId = null);
    }
  }

  void _openAddPhoto() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddPhotoScreen(
          rentalId: widget.rentalId,
          onAdded: _loadGallery,
        ),
      ),
    );
    if (added == true) _loadGallery();
  }

  void _openEdit(GalleryPhoto photo) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditPhotoScreen(
          rentalId: widget.rentalId,
          photo: photo,
          onSaved: _loadGallery,
        ),
      ),
    );
    if (updated == true) _loadGallery();
  }

  void _openPreview(GalleryPhoto photo) {
    final url = photo.image.startsWith('http')
        ? photo.image
        : '$image_url${photo.image}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PhotoPreviewScreen(imageUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _openAddPhoto,
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: const Text('Add Photo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _loading
          ?  Center(child: SpinKitFadingCircle(color: blueColor, size: 28))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGallery,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _photos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No photos yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _openAddPhoto,
                            icon: const FaIcon(FontAwesomeIcons.plus, size: 18),
                            label: const Text('Add Photo'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadGallery,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          final photo = _photos[index];
                          final imageUrl = photo.image.startsWith('http')
                              ? photo.image
                              : '$image_url${photo.image}';
                          return _GalleryCard(
                            imageUrl: imageUrl,
                            description: photo.description,
                            isCover: photo.isCover,
                            isSettingCover: _settingCoverPhotoId == photo.id,
                            onTap: () => _openPreview(photo),
                            onEdit: () => _openEdit(photo),
                            onDelete: () => _deletePhoto(photo),
                            onSetCover: () => _setCover(photo),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final String imageUrl;
  final String description;
  final bool isCover;
  final bool isSettingCover;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetCover;

  const _GalleryCard({
    required this.imageUrl,
    required this.description,
    required this.isCover,
    this.isSettingCover = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onSetCover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCover ? blueColor : const Color(0xFFDEE2E6),
          width: isCover ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: onTap,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey[200],
                  child: Center(child: SpinKitFadingCircle(color: blueColor, size: 32)),
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
              ),
            ),
            if (isCover)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'COVER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 6,
              right: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: FontAwesomeIcons.pen,
                    iconColor: Colors.green,
                    backgroundColor: const Color(0xFFE8F5E9),
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 6),
                  _ActionButton(
                    icon: FontAwesomeIcons.trashCan,
                    iconColor: Colors.red,
                    backgroundColor: const Color(0xFFFFEBEE),
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
            if (description.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            if (!isCover)
              Positioned(
                bottom: 6,
                right: 6,
                child: isSettingCover
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: SpinKitFadingCircle(
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      )
                    : _StarButton(onTap: onSetCover),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    this.backgroundColor = const Color(0xFFF5F5F5),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: FaIcon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

class _StarButton extends StatelessWidget {
  final VoidCallback onTap;

  const _StarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.withOpacity(0.6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: FaIcon(FontAwesomeIcons.solidStar, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
