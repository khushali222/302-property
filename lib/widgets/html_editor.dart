import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: NfcReaderScreen(),
    );
  }
}

class NfcReaderScreen extends StatefulWidget {
  @override
  _NfcReaderScreenState createState() => _NfcReaderScreenState();
}

class _NfcReaderScreenState extends State<NfcReaderScreen> {
  String _nfcData = "Tap your card to scan";
  bool _isScanning = false;

  Future<void> _startNfcSession() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        setState(() => _nfcData = 'NFC is not available');
        return;
      }

      setState(() => _isScanning = true);

      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        Uint8List? uid;
        if (tag.data.containsKey('isodep')) {
          uid = Uint8List.fromList(tag.data['isodep']['identifier']);
        } else if (tag.data.containsKey('nfca')) {
          uid = Uint8List.fromList(tag.data['nfca']['identifier']);
        }
        String hexUid = "";
        if (uid != null) {
           hexUid = uid.map((b) => b.toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
          setState(() => _nfcData = "Card UID: $hexUid");
        } else {
          setState(() => _nfcData = "Could not read UID");
        }

        await NfcManager.instance.stopSession();
        Navigator.of(context).pop({'success': true, 'cardId': hexUid});
        setState(() => _isScanning = false);
      });
    } catch (e) {
      setState(() {
        _nfcData = 'NFC Error: $e';
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NFC Scanner"),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/images/nfc_card_scan.json' ,

            ),
            SizedBox(height: 20),
            Text(
              _nfcData,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isScanning ? null : _startNfcSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isScanning ? "Scanning..." : "Tap to Scan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
