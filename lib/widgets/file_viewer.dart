import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:typed_data' show Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';

class FileViewer extends StatefulWidget {
  final String fileName;
  final String? fileUrl;
  final String? filePath;
  final bool showInDialog;
  final String?
      mimeType; // For file type detection when filename lacks extension

  const FileViewer({
    Key? key,
    required this.fileName,
    this.fileUrl,
    this.filePath,
    this.showInDialog = false,
    this.mimeType,
  }) : super(key: key);

  // Static method to show receipt in dialog
  static void showReceiptDialog(BuildContext context, String fileName,
      {String? fileUrl, String? mimeType}) {
    print('=== DIALOG DEBUG ===');
    print('showReceiptDialog called with fileName: $fileName');
    print('fileUrl: $fileUrl');
    print('mimeType: $mimeType');
    print('Api_url: $Api_url');
    if (fileUrl == null) {
      print('Full URL would be: ${image_url}$fileName');
    }

    try {
      print('=== SHOWING DIALOG ===');
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (BuildContext dialogContext) {
          print('=== DIALOG BUILDER CALLED ===');
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              width: MediaQuery.of(dialogContext).size.width * 0.9,
              height: MediaQuery.of(dialogContext).size.height * 0.8,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            fileName,
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
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Content - wrapped in error boundary
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        try {
                          return FileViewer(
                            fileName: fileName,
                            fileUrl: fileUrl,
                            mimeType: mimeType,
                            showInDialog: true,
                          );
                        } catch (e) {
                          print('Error in FileViewer widget: $e');
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.triangleExclamation,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading document',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'File: $fileName',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((_) {
        print('=== DIALOG CLOSED ===');
      }).catchError((error) {
        print('=== DIALOG ERROR ===');
        print('Error: $error');
      });
    } catch (e) {
      print('Error showing dialog: $e');
      // Fallback: Show a simple error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to open document: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  bool _isLoading = true;
  String? _error;
  String? _downloadedFilePath; // For PDFs that need authentication
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    print('=== FILE VIEWER INIT STATE ===');
    print('fileName: ${widget.fileName}');
    print('showInDialog: ${widget.showInDialog}');
    print('fileUrl: ${widget.fileUrl}');
    _checkFileAvailability();
    _cleanupOldTempFiles(); // Clean up old temp files on init
  }

  // Clean up old temp files (older than 1 hour) to prevent memory issues
  Future<void> _cleanupOldTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final files = tempDir.listSync();
      
      int cleanedCount = 0;
      for (var file in files) {
        if (file is File && file.path.contains('_lease') || file.path.contains('_check')) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);
          // Delete files older than 1 hour
          if (age.inHours > 1) {
            try {
              await file.delete();
              cleanedCount++;
            } catch (e) {
              print('Error deleting old temp file: $e');
            }
          }
        }
      }
      if (cleanedCount > 0) {
        print('=== CLEANED UP $cleanedCount OLD TEMP FILES ===');
      }
    } catch (e) {
      print('Error cleaning up temp files: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Clean up downloaded file after a delay to allow viewing
    if (_downloadedFilePath != null) {
      // Schedule cleanup after 10 seconds to allow user to view/share
      Future.delayed(Duration(seconds: 10), () {
        try {
          final file = File(_downloadedFilePath!);
          if (file.existsSync()) {
            file.deleteSync();
            print('=== CLEANED UP TEMP FILE ===');
            print('Deleted: $_downloadedFilePath');
          }
        } catch (e) {
          print('Error cleaning up temp file: $e');
        }
      });
    }
    super.dispose();
  }

  void _checkFileAvailability() {
    print('=== CHECKING FILE AVAILABILITY ===');

    // For lease documents, download the file first (both images and PDFs)
    // since cachedFromUrl doesn't support custom headers for authentication
    if (widget.fileUrl != null &&
        widget.fileUrl!.contains('/api/lease-document/preview-document/')) {
      _downloadAuthenticatedFile();
    } else {
      if (!_isDisposed && mounted) {
        if (!_isDisposed && mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
      print('_isLoading set to false');
    }
  }

  Future<void> _downloadAuthenticatedFile() async {
    try {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      print('=== DOWNLOADING AUTHENTICATED FILE ===');
      print('URL: ${widget.fileUrl}');
      print('MIME Type: ${widget.mimeType}');
      print('MIME Type: ${widget.mimeType}');

      // Get authentication tokens
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminId = prefs.getString('adminId');
      String? staffId = prefs.getString('staff_id');
      String? id = (staffId != null && staffId.isNotEmpty) ? staffId : adminId;

      if (token == null || id == null) {
        throw Exception('Authentication tokens not found');
      }

      // Download the file with authentication headers
      final response = await http.get(
        Uri.parse(widget.fileUrl!),
        headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $id',
        },
      );

      print('Download response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body length: ${response.bodyBytes.length}');

      // Check if response is actually an error JSON
      if (response.statusCode != 200) {
        try {
          final errorBody = json.decode(response.body);
          print('Error response body: $errorBody');
        } catch (e) {
          print('Could not parse error response as JSON');
        }
      }

      if (response.statusCode == 200) {
        // Check if response is actually a valid file (not an error JSON)
        // PDFs should be at least 100 bytes, images at least 50 bytes
        final contentLength = response.bodyBytes.length;
        final contentType = response.headers['content-type'] ?? '';

        print('Content-Type from header: $contentType');
        print('File size: $contentLength bytes');

        // Determine file type first
        final isPdf = contentType.contains('application/pdf') ||
            (widget.mimeType != null && widget.mimeType!.contains('pdf')) ||
            widget.fileName.toLowerCase().endsWith('.pdf');
        final isImage = contentType.startsWith('image/') ||
            (widget.mimeType != null && widget.mimeType!.startsWith('image/'));

        // Check if response might be JSON error (starts with { or [)
        if (contentLength < 50) {
          try {
            final possibleJson = utf8.decode(response.bodyBytes);
            if (possibleJson.trim().startsWith('{') ||
                possibleJson.trim().startsWith('[')) {
              final jsonData = json.decode(possibleJson);
              final errorMsg = jsonData['message'] ??
                  jsonData['error'] ??
                  jsonData.toString();
              // Check if it's a "file not found" type error
              if (errorMsg.toString().toLowerCase().contains('not found') ||
                  errorMsg.toString().toLowerCase().contains('no file')) {
                throw Exception('File not found');
              }
              throw Exception('Server returned error: $errorMsg');
            }
            // If it's a very small file and not JSON, it's likely empty/corrupted
            // Check if it's a PDF based on content type or filename
            final mightBePdf = contentType.contains('application/pdf') ||
                (widget.mimeType != null && widget.mimeType!.contains('pdf')) ||
                widget.fileName.toLowerCase().endsWith('.pdf');
            if (mightBePdf && contentLength < 100) {
              throw Exception('File not found or empty');
            }
          } catch (e) {
            // If it's already an Exception, rethrow it
            if (e is Exception) {
              rethrow;
            }
            // Not JSON, continue validation below
          }
        }

        // Validate minimum file size based on type

        if (isPdf && contentLength < 100) {
          throw Exception(
              'File not found or file is too small (${contentLength} bytes) to be a valid PDF. File may be corrupted or empty.');
        }
        if (isImage && contentLength < 50) {
          throw Exception(
              'File not found or file is too small (${contentLength} bytes) to be a valid image. File may be corrupted or empty.');
        }

        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        // Determine file extension from content-type header first, then mime type, then filename
        String extension = '';

        // Try content-type header first (most reliable)
        if (contentType.isNotEmpty) {
          if (contentType.startsWith('image/')) {
            extension = contentType.split('/')[1].split(';')[0].trim();
          } else if (contentType.contains('application/pdf') ||
              contentType.contains('pdf')) {
            extension = 'pdf';
          }
        }

        // Fallback to mimeType parameter
        if (extension.isEmpty && widget.mimeType != null) {
          if (widget.mimeType!.startsWith('image/')) {
            extension = widget.mimeType!.split('/')[1].split(';')[0].trim();
          } else if (widget.mimeType == 'application/pdf' ||
              widget.mimeType!.contains('pdf')) {
            extension = 'pdf';
          }
        }

        // If no extension from mime type, try filename
        if (extension.isEmpty && widget.fileName.contains('.')) {
          extension = widget.fileName.split('.').last.toLowerCase();
        }

        // Fallback based on content type detection
        if (extension.isEmpty) {
          if (isPdf) {
            extension = 'pdf';
          } else if (isImage) {
            extension = 'png'; // Default image extension
          } else {
            extension = 'pdf'; // Final fallback
          }
        }

        final fileName =
            widget.fileName.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_');
        final file = File(
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName.$extension');
        await file.writeAsBytes(response.bodyBytes);

        print('File downloaded to: ${file.path}');
        print('File size: ${file.lengthSync()} bytes');
        print('File extension: $extension');
        print('Content-Type: $contentType');

        if (!_isDisposed && mounted) {
          setState(() {
            _downloadedFilePath = file.path;
            _isLoading = false;
          });
        }
      } else {
        if (!_isDisposed && mounted) {
          setState(() {
            _error = 'Failed to download file (Status: ${response.statusCode})';
            _isLoading = false;
          });
        }
        // Try to parse error response
        String errorMessage =
            'Failed to download file: Status ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody['message'] != null) {
            errorMessage = errorBody['message'];
          }
        } catch (e) {
          // Not JSON, use default message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('=== FILE DOWNLOAD ERROR ===');
      print('Error: $e');
      String errorMessage = e.toString();

      // Check if it's a "file not found" error
      if (errorMessage.toLowerCase().contains('not found') ||
          errorMessage.toLowerCase().contains('404') ||
          errorMessage.toLowerCase().contains('no file')) {
        errorMessage = 'File not found';
      } else if (errorMessage.toLowerCase().contains('too small') ||
          errorMessage.toLowerCase().contains('corrupted') ||
          errorMessage.toLowerCase().contains('empty')) {
        errorMessage = 'File not found or file is corrupted/empty';
      }

      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _error = errorMessage;
        });
      }
    }
  }

  String _getFileExtension(String fileName) {
    // Check if filename has an extension
    if (fileName.contains('.')) {
      final extension = fileName.split('.').last.toLowerCase();
      print('=== FILE EXTENSION DEBUG ===');
      print('fileName: $fileName');
      print('extension: $extension');
      return extension;
    }
    // No extension found
    print('=== FILE EXTENSION DEBUG ===');
    print('fileName: $fileName');
    print('No extension found in filename');
    return '';
  }

  String? _getMimeTypeExtension() {
    if (widget.mimeType == null) return null;

    // Extract extension from mime type
    final mimeType = widget.mimeType!.toLowerCase();
    if (mimeType.contains('/')) {
      final parts = mimeType.split('/');
      if (parts.length == 2) {
        final type = parts[1].split(';')[0].trim(); // Remove any parameters
        print('=== MIME TYPE DEBUG ===');
        print('mimeType: ${widget.mimeType}');
        print('extracted type: $type');
        return type;
      }
    }
    return null;
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

    // First try to get extension from filename
    String? extension = _getFileExtension(fileName);

    // If no extension in filename, try mime type
    if (extension.isEmpty) {
      final mimeExt = _getMimeTypeExtension();
      if (mimeExt != null) {
        extension = mimeExt;
      }
    }

    // Check image mime types
    if (widget.mimeType != null) {
      final mimeType = widget.mimeType!.toLowerCase();
      if (mimeType.startsWith('image/')) {
        print('=== IS IMAGE CHECK ===');
        print('fileName: $fileName');
        print('mimeType: ${widget.mimeType}');
        print('isImage: true (from mime type)');
        return true;
      }
    }

    final isImage = extension.isNotEmpty && imageExtensions.contains(extension);
    print('=== IS IMAGE CHECK ===');
    print('fileName: $fileName');
    print('extension: $extension');
    print('mimeType: ${widget.mimeType}');
    print('isImage: $isImage');
    return isImage;
  }

  bool _isPdfFile(String fileName) {
    // First try to get extension from filename
    String? extension = _getFileExtension(fileName);

    // If no extension in filename, try mime type
    if (extension.isEmpty) {
      final mimeExt = _getMimeTypeExtension();
      if (mimeExt != null) {
        extension = mimeExt;
      }
    }

    // Check PDF mime type
    if (widget.mimeType != null) {
      final mimeType = widget.mimeType!.toLowerCase();
      if (mimeType == 'application/pdf') {
        print('=== IS PDF CHECK ===');
        print('fileName: $fileName');
        print('mimeType: ${widget.mimeType}');
        print('isPdf: true (from mime type)');
        return true;
      }
    }

    final isPdf = extension == 'pdf';
    print('=== IS PDF CHECK ===');
    print('fileName: $fileName');
    print('extension: $extension');
    print('mimeType: ${widget.mimeType}');
    print('isPdf: $isPdf');
    return isPdf;
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
    if (!_isDisposed && mounted) {
      setState(() {
        _error = message;
      });
    }
  }

  Widget _buildImageWidget() {
    // If we have a downloaded file path (authenticated image), use it
    if (_downloadedFilePath != null &&
        File(_downloadedFilePath!).existsSync()) {
      print('=== IMAGE WIDGET DEBUG ===');
      print('Loading image from file: $_downloadedFilePath');

      return Image.file(
        File(_downloadedFilePath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('=== IMAGE FILE ERROR ===');
          print('File: $_downloadedFilePath');
          print('Error: $error');
          return _buildErrorWidget(
            'Failed to load image\nError: $error',
            FontAwesomeIcons.image,
          );
        },
      );
    }

    // Otherwise, use the URL (for non-authenticated images)
    final imageUrl = _getFileUrl();
    print('=== IMAGE WIDGET DEBUG ===');
    print('Loading image from URL: $imageUrl');

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) {
        print('Image loading placeholder for: $url');
        return Center(
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
    // If we have a downloaded file path (authenticated PDF), use Printing.previewPdf
    // to display it directly in the dialog
    if (_downloadedFilePath != null &&
        File(_downloadedFilePath!).existsSync() &&
        widget.fileUrl != null &&
        widget.fileUrl!.contains('/api/lease-document/preview-document/')) {
      print('=== PDF WIDGET DEBUG ===');
      print('Loading PDF from downloaded file: $_downloadedFilePath');

      // Use Printing.previewPdf to display PDF in dialog
      return FutureBuilder<Uint8List>(
        future: File(_downloadedFilePath!).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCircle(
                    color: Colors.black,
                    size: 45,
                  ),
                  const SizedBox(height: 16),
                  const Text('Loading PDF...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            print('=== PDF READ ERROR ===');
            print('Error: ${snapshot.error}');
            return _buildErrorWidget(
              'Failed to read PDF file\nError: ${snapshot.error}',
              FontAwesomeIcons.filePdf,
            );
          }

          if (snapshot.hasData) {
            final pdfBytes = snapshot.data!;
            print('=== PDF BYTES LOADED ===');
            print('PDF size: ${pdfBytes.length} bytes');

            // Validate PDF file size and header
            if (pdfBytes.length < 100) {
              return _buildErrorWidget(
                'File not found or file is too small (${pdfBytes.length} bytes) to be a valid PDF.\n\nFile may be corrupted or empty.',
                FontAwesomeIcons.filePdf,
              );
            }

            // Check PDF header (should start with %PDF)
            final pdfHeader = String.fromCharCodes(pdfBytes.take(4));
            if (pdfHeader != '%PDF') {
              print('=== INVALID PDF HEADER ===');
              print('Expected: %PDF');
              print('Got: $pdfHeader');
              return _buildErrorWidget(
                'File not found or invalid PDF file format.\n\nFile may be corrupted or not a valid PDF.',
                FontAwesomeIcons.filePdf,
              );
            }

            // Use Printing.previewPdf to display PDF
            return PdfPreview(
              build: (format) async => pdfBytes,
              allowPrinting: false,
              allowSharing: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
            );
          }

          return _buildErrorWidget(
            'Failed to load PDF',
            FontAwesomeIcons.filePdf,
          );
        },
      );
    }

    // Otherwise, use the URL (for non-authenticated PDFs like property tax receipts)
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
        if (!_isDisposed && mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        print('=== PDF ERROR ===');
        print('PDF URL: $pdfUrl');
        print('Error: $error');
        if (!_isDisposed && mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Failed to load PDF: ${error.toString()}';
          });
        }
      },
      onPageError: (page, error) {
        print('=== PDF PAGE ERROR ===');
        print('Page: $page');
        print('Error: $error');
        if (!_isDisposed && mounted) {
          setState(() {
            _error = 'Failed to load page $page: ${error.toString()}';
          });
        }
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
    // Check if it's a "file not found" error
    final isFileNotFound = message.toLowerCase().contains('not found') ||
        message.toLowerCase().contains('no file');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            isFileNotFound ? FontAwesomeIcons.fileCircleQuestion : icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              isFileNotFound ? 'File not found' : message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!widget.showInDialog) ...[
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnsupportedFileWidget() {
    print('=== BUILDING UNSUPPORTED FILE WIDGET ===');
    print('fileName: ${widget.fileName}');
    print('showInDialog: ${widget.showInDialog}');
    print('Will show external button: ${!widget.showInDialog}');

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'File type not supported for preview',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'File: ${widget.fileName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'URL: ${_getFileUrl()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!widget.showInDialog) ...[
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('=== FILE VIEWER BUILD ===');
    print('showInDialog: ${widget.showInDialog}');
    print('fileName: ${widget.fileName}');
    print('_isLoading: $_isLoading');
    print('_error: $_error');

    // If showing in dialog, don't wrap with Scaffold
    if (widget.showInDialog) {
      print('=== BUILDING DIALOG CONTENT ===');

      if (_isLoading) {
        print('Returning loading widget');
        return const Center(
          child: SpinKitFadingCircle(
            color: Colors.black,
            size: 45,
          ),
        );
      }

      if (_error != null) {
        print('Returning error widget: $_error');
        return _buildErrorWidget(_error!, FontAwesomeIcons.exclamationTriangle);
      }

      final isImage = _isImageFile(widget.fileName);
      final isPdf = _isPdfFile(widget.fileName);

      print('=== FILE TYPE DETERMINATION ===');
      print('isImage: $isImage');
      print('isPdf: $isPdf');

      if (isImage) {
        print('Building image widget');
        return _buildImageWidget();
      } else if (isPdf) {
        print('Building PDF widget');
        return _buildPdfWidget();
      } else {
        print('Building unsupported file widget');
        return _buildUnsupportedFileWidget();
      }
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
