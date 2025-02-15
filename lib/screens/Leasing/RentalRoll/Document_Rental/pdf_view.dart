import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../../../widgets/appbar.dart';
import '../../../../widgets/custom_drawer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;

  PDFViewerScreen({required this.pdfUrl});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localFilePath;
  bool isLoading = false;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  void initState() {
    super.initState();
   // _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/temp.pdf");
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        localFilePath = file.path;
        isLoading = false;
      });
    } catch (e) {
      print("Error downloading PDF: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Rent Roll",
        dropdown: true,
      ),
      body:SfPdfViewer.network(
        widget.pdfUrl,
        canShowPageLoadingIndicator: false,
        key: _pdfViewerKey,

      )

    );
  }
}
