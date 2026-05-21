import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../../constant/constant.dart';

/// Full-screen image preview when user taps a gallery photo.
/// Image is shown at ~50% of screen height (pinch to zoom). No description overlay.
class PhotoPreviewScreen extends StatelessWidget {
  final String imageUrl;

  const PhotoPreviewScreen({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fullUrl = imageUrl.startsWith('http') ? imageUrl : '$image_url$imageUrl';
    final size = MediaQuery.sizeOf(context);
    final previewHeight = size.height * 0.5;
    final previewWidth = size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: fullUrl,
                  fit: BoxFit.contain,
                  width: previewWidth,
                  height: previewHeight,
                  placeholder: (_, __) => const Center(
                    child: SpinKitFadingCircle(color: Colors.white, size: 28),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white54,
                    child: Icon(Icons.close, color: Colors.black87),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
