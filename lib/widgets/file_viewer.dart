import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FileViewerDialog extends StatefulWidget {
  final String fileName;
  final String? fileUrl;

  const FileViewerDialog({
    Key? key,
    required this.fileName,
    this.fileUrl,
  }) : super(key: key);

  @override
  State<FileViewerDialog> createState() => _FileViewerDialogState();
}

class _FileViewerDialogState extends State<FileViewerDialog> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkFileAvailability();
  }

  void _checkFileAvailability() {
    setState(() {
      _isLoading = false;
    });
  }

  String _getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  bool _isImageFile(String fileName) {
    final imageExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'tiff',
      'webp'
    ];
    return imageExtensions.contains(_getFileExtension(fileName));
  }

  bool _isPdfFile(String fileName) {
    return _getFileExtension(fileName) == 'pdf';
  }

  String _getFileUrl() {
    if (widget.fileUrl != null && widget.fileUrl!.isNotEmpty) {
      return widget.fileUrl!;
    }

    // Construct URL from API base and filename
    return '${Api_url}/uploads/${widget.fileName}';
  }

  Future<void> _openFileExternally() async {
    try {
      final url = _getFileUrl();
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Cannot open file externally');
      }
    } catch (e) {
      _showError('Error opening file: ${e.toString()}');
    }
  }

  void _showError(String message) {
    setState(() {
      _error = message;
    });
  }

  Widget _buildImageWidget() {
    final imageUrl = _getFileUrl();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => _buildErrorWidget(
          'Failed to load image',
          FontAwesomeIcons.image,
        ),
      ),
    );
  }

  Widget _buildPdfWidget() {
    final pdfUrl = _getFileUrl();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.9,
      child: PDF(
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        onRender: (pages) {
          setState(() {
            _isLoading = false;
          });
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
            _error = 'Failed to load PDF: ${error.toString()}';
          });
        },
        onPageError: (page, error) {
          setState(() {
            _error = 'Failed to load page $page: ${error.toString()}';
          });
        },
        onViewCreated: (PDFViewController pdfViewController) {
          // PDF loaded successfully
        },
      ).cachedFromUrl(
        pdfUrl,
        placeholder: (progress) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading PDF... ${(progress * 100).toInt()}%'),
            ],
          ),
        ),
        errorWidget: (error) => _buildErrorWidget(
          'Failed to load PDF',
          FontAwesomeIcons.filePdf,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, IconData icon) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openFileExternally,
              icon: const FaIcon(FontAwesomeIcons.externalLinkAlt, size: 14),
              label: const Text('Open Externally'),
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedFileWidget() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.file,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'File type not supported for preview',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'File: ${widget.fileName}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openFileExternally,
              icon: const FaIcon(FontAwesomeIcons.externalLinkAlt, size: 14),
              label: const Text('Open Externally'),
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    _isPdfFile(widget.fileName)
                        ? FontAwesomeIcons.filePdf
                        : _isImageFile(widget.fileName)
                            ? FontAwesomeIcons.image
                            : FontAwesomeIcons.file,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.fileName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.xmark,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _error != null
                        ? _buildErrorWidget(
                            _error!, FontAwesomeIcons.exclamationTriangle)
                        : _isImageFile(widget.fileName)
                            ? _buildImageWidget()
                            : _isPdfFile(widget.fileName)
                                ? _buildPdfWidget()
                                : _buildUnsupportedFileWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Static method to show the dialog
class FileViewer {
  static void showReceiptDialog(BuildContext context, String fileName,
      {String? fileUrl}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return FileViewerDialog(
          fileName: fileName,
          fileUrl: fileUrl,
        );
      },
    );
  }
}
