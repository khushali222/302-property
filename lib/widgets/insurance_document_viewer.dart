import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:three_zero_two_property/constant/constant.dart';

/// Shared view/download logic for renter's insurance policy documents.
///
/// Used by both the Renters Insurance details screen (ViewRentersDetails) and
/// the Renters Insurance table rows so there's a single source of truth.
///
/// The document is served at the public `image_url + filename` endpoint
/// (`/api/images/get-file/<file>`), so no auth/id is required.

const Set<String> _imageExts = {
  'png',
  'jpg',
  'jpeg',
  'jfif',
  'gif',
  'webp',
  'bmp'
};

/// VIEW: images open in an in-app zoomable preview; other types (PDF/doc) are
/// handed off to the OS via the download/share sheet.
void viewInsuranceDocument(BuildContext context, String? filename) {
  final name = (filename ?? '').trim();
  if (name.isEmpty) {
    Fluttertoast.showToast(msg: "No document attached");
    return;
  }
  final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
  if (_imageExts.contains(ext)) {
    _previewImage(context, name);
  } else {
    downloadInsuranceDocument(context, name, viewing: true);
  }
}

/// In-app zoomable image preview dialog (white background).
void _previewImage(BuildContext context, String filename) {
  final url = '$image_url$filename';
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) {
      final screenH = MediaQuery.of(ctx).size.height;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              // Hug the image: the card sizes to the picture (no empty white),
              // bounded so it's never huge and never a thin bar.
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(ctx).size.width - 56,
                maxHeight: screenH * 0.6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  // No cross-fade: prevents the loading spinner from briefly
                  // layering on top of the image as it fades in.
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  placeholder: (context, _) => const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(
                      child: SpinKitFadingCircle(
                          color: Color(0xFF152B51), size: 44),
                    ),
                  ),
                  errorWidget: (context, _, error) => const SizedBox(
                    width: 220,
                    height: 170,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image,
                              color: Colors.grey, size: 48),
                          SizedBox(height: 8),
                          Text('Could not load image',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -14,
              right: -14,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// DOWNLOAD: fetch to a temp file, then open the native save/share sheet
/// (Save to Files, Photos, open-with, ...). Works on iOS and Android.
Future<void> downloadInsuranceDocument(BuildContext context, String? filename,
    {bool viewing = false}) async {
  final name = (filename ?? '').trim();
  if (name.isEmpty) {
    Fluttertoast.showToast(msg: "No document attached");
    return;
  }
  final url = '$image_url$name';
  final messenger = ScaffoldMessenger.of(context);

  messenger.showSnackBar(
    SnackBar(
      content: Row(children: [
        const SizedBox(
          width: 18,
          height: 18,
          child:
              CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text('${viewing ? "Opening" : "Downloading"} $name...')),
      ]),
      duration: const Duration(seconds: 30),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  try {
    final tempDir = await getTemporaryDirectory();
    final savePath = path.join(tempDir.path, name);

    await Dio().download(url, savePath);

    messenger.hideCurrentSnackBar();
    await Share.shareXFiles([XFile(savePath)], subject: name);
  } catch (e) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
            '${viewing ? "Open" : "Download"} failed. Please try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
