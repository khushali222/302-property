import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FileViewer extends StatefulWidget {
  final String fileName;
  final String? fileUrl;
  final String? filePath;
  final bool showInDialog;

  const FileViewer({
    Key? key,
    required this.fileName,
    this.fileUrl,
    this.filePath,
    this.showInDialog = false,
  }) : super(key: key);

  // Static method to show receipt in dialog
  static void showReceiptDialog(BuildContext context, String fileName) {
    print('=== DIALOG DEBUG ===');
    print('showReceiptDialog called with fileName: $fileName');
    print('Api_url: $Api_url');
    print('Full URL would be: ${image_url}$fileName');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Expanded(
                      //   child: Text(
                      //     fileName,
                      //     style: const TextStyle(
                      //       color: Colors.white,
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 16,
                      //     ),
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // ),
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.expand,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => _openFullScreen(context, fileName),
                        tooltip: 'View More',
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
                Expanded(
                  child: FileViewer(
                    fileName: fileName,
                    showInDialog: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _openFullScreen(BuildContext context, String fileName) {
    // Close the dialog first
    Navigator.of(context).pop();

    // Then open full screen viewer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewer(
          fileName: fileName,
          showInDialog: false, // This will show full screen
        ),
      ),
    );
  }

  static Future<void> _openFileExternally(
      BuildContext context, String fileName) async {
    try {
      final url = '${image_url}$fileName';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot open file externally'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
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
      print('=== FILE VIEWER DEBUG ===');
      print('Using provided fileUrl: ${widget.fileUrl}');
      return widget.fileUrl!;
    }

    // Construct URL from API base and filename
    final constructedUrl = '${image_url}${widget.fileName}';
    print('=== FILE VIEWER DEBUG ===');
    print('image_url: $image_url');
    print('fileName: ${widget.fileName}');
    print('Constructed URL: $constructedUrl');
    return constructedUrl;
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
    print('=== IMAGE WIDGET DEBUG ===');
    print('Loading image from URL: $imageUrl');

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) {
        print('Image loading placeholder for: $url');
        return  Center(
          child: SpinKitFadingCircle(
            color: Colors.black,
            size: 45,
          ),
        );
      },
      errorWidget: (context, url, error) {
        print('=== IMAGE ERROR ===');
        print('URL: $url');
        print('Error: $error');
        return _buildErrorWidget(
          'Failed to load image\nURL: $url\nError: $error',
          FontAwesomeIcons.image,
        );
      },
    );
  }

  Widget _buildPdfWidget() {
    final pdfUrl = _getFileUrl();
    print('=== PDF WIDGET DEBUG ===');
    print('Loading PDF from URL: $pdfUrl');

    return PDF(
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
        print('=== PDF ERROR ===');
        print('PDF URL: $pdfUrl');
        print('Error: $error');
        setState(() {
          _isLoading = false;
          _error = 'Failed to load PDF: ${error.toString()}';
        });
      },
      onPageError: (page, error) {
        print('=== PDF PAGE ERROR ===');
        print('Page: $page');
        print('Error: $error');
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
            SpinKitFadingCircle(
              color: Colors.black,
              size: 45,
            ),
            const SizedBox(height: 16),
            Text('Loading PDF... ${(progress * 100).toInt()}%'),
          ],
        ),
      ),
      errorWidget: (error) {
        print('=== PDF CACHE ERROR ===');
        print('PDF URL: $pdfUrl');
        print('Cache Error: $error');
        return _buildErrorWidget(
          'Failed to load PDF\nURL: $pdfUrl\nError: $error',
          FontAwesomeIcons.filePdf,
        );
      },
    );
  }

  Widget _buildErrorWidget(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _openFileExternally,
                icon: const FaIcon(FontAwesomeIcons.externalLinkAlt),
                label: const Text('Open Externally'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  foregroundColor: Colors.white,
                ),
              ),
              if (!widget.showInDialog) ...[
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FileViewer(
                          fileName: widget.fileName,
                          showInDialog: false,
                        ),
                      ),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.expand),
                  label: const Text('View More'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedFileWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.file,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'File type not supported for preview',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'File: ${widget.fileName}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openFileExternally,
            icon: const FaIcon(FontAwesomeIcons.externalLinkAlt),
            label: const Text('Open Externally'),
            style: ElevatedButton.styleFrom(
              backgroundColor: blueColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If showing in dialog, don't wrap with Scaffold
    if (widget.showInDialog) {
      return _isLoading
          ? const Center(
        child: SpinKitFadingCircle(
          color: Colors.black,
          size: 45,
        ),
      )
          : _error != null
              ? _buildErrorWidget(_error!, FontAwesomeIcons.exclamationTriangle)
              : _isImageFile(widget.fileName)
                  ? _buildImageWidget()
                  : _isPdfFile(widget.fileName)
                      ? _buildPdfWidget()
                      : _buildUnsupportedFileWidget();
    }

    // Original full-screen implementation
    return Scaffold(
      appBar: AppBar(
        // title: Text(
        //   widget.fileName,
        //   style: const TextStyle(
        //     color: Colors.white,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        backgroundColor: blueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        // actions: [
        //   IconButton(
        //     icon: const FaIcon(
        //       FontAwesomeIcons.externalLinkAlt,
        //       color: Colors.white,
        //     ),
        //     onPressed: _openFileExternally,
        //     tooltip: 'Open Externally',
        //   ),
        // ],
      ),
      body: _isLoading
          ? const Center(
        child: SpinKitFadingCircle(
          color: Colors.black,
          size: 45,
        ),
      )
          : _error != null
              ? _buildErrorWidget(_error!, FontAwesomeIcons.exclamationTriangle)
              : _isImageFile(widget.fileName)
                  ? _buildImageWidget()
                  : _isPdfFile(widget.fileName)
                      ? _buildPdfWidget()
                      : _buildUnsupportedFileWidget(),
    );
  }
}
