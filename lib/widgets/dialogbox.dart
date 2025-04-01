import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:hex/hex.dart';

class EmvParser {
  /// Parses raw EMV TLV data
  static Map<String, String> parseEmvData(String hexData) {
    Map<String, String> emvData = {};
    List<int> bytes = HEX.decode(hexData);
    int index = 0;
    print("bytes: $bytes");
    while (index < bytes.length) {
      if (index + 1 >= bytes.length) break;

      // Read Tag
      String tag = bytes[index].toRadixString(16).padLeft(2, '0').toUpperCase();
      print("tag $tag");
      index++;
      print("index :- $index");
      // Read Length
      int length = bytes[index];
      index++;
      print("length :- $length");
      print("index :- :- $index");

      // Read Value
      String value = HEX.encode(bytes.sublist(index, index + length)).toUpperCase();
      index += length;

      // Store parsed EMV data
      emvData[tag] = value;
    }

    return emvData;
  }

  /// Extracts Card Number & Expiry Date from EMV Data
  static Map<String, String> extractCardDetails(List<String> responses) {
    for (String response in responses) {
      Map<String, String> parsedData = parseEmvData(response);
      print(parsedData);
      if (parsedData.containsKey("5A")) {
        return {
          "Card Number": parsedData["5A"] ?? "Unknown",
          "Expiry Date": parsedData["5F24"] ?? "Unknown",
        };
      } else if (parsedData.containsKey("77")) {
        String track2Data = parsedData["77"] ?? "";
        print(track2Data);
        List<String> trackDataParts = track2Data.split('D');

        if (trackDataParts.length > 1) {
          String cardNumber = trackDataParts[0].substring(trackDataParts[0].length - 16);

          return {
            "Card Number":cardNumber,
            "Expiry Date": "20" + trackDataParts[1].substring(0, 2) + "-" + trackDataParts[1].substring(2, 4),
          };
        }
      }
      else if (parsedData.containsKey("57")) {
        String track2Data = parsedData["57"] ?? "";
        print(track2Data);
        List<String> trackDataParts = track2Data.split('D');

        if (trackDataParts.length > 1) {
          String cardNumber = trackDataParts[0].substring(trackDataParts[0].length - 16);

          return {
            "Card Number":cardNumber,
            "Expiry Date": "20" + trackDataParts[1].substring(0, 2) + "-" + trackDataParts[1].substring(2, 4),
          };
        }
      }
    }
    return {"Card Number": "Unknown", "Expiry Date": "Unknown"};
  }
}

void main(){
  runApp(MaterialApp(
    home:NFCReaderScreen() ,
  ));
}
class NFCReaderScreen extends StatefulWidget {
  @override
  _NFCReaderScreenState createState() => _NFCReaderScreenState();
}

class _NFCReaderScreenState extends State<NFCReaderScreen> {
  String _cardInfo = "Tap NFC Card to Read Data";

  Future<void> _readMasterCard() async {
    try {
      setState(() {
        _cardInfo = "Reading card...";
      });

      // Request NFC Access
      NFCTag tag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));

      // Select Payment System Environment (PPSE)
      String response = await FlutterNfcKit.transceive("00A404000E325041592E5359532E444446303100");
      if (!response.endsWith("9000")) {
        throw Exception("PPSE selection failed.");
      }

      // Known AIDs for MasterCard and Visa
      List<String> knownAIDs = [
        "A0000000041010", // MasterCard
        "A0000000031010"  // Visa
      ];

      String selectedAid = "";
      for (String aid in knownAIDs) {
        response = await FlutterNfcKit.transceive("00A4040007${aid}00");
        print(response);
        if (response.endsWith("9000")) {
          selectedAid = aid;
          print("AID Selected: $aid");
          break;
        }
      }

      if (selectedAid.isEmpty) {
        throw Exception("No supported AID found.");
      }

      // 🔹 Extract PDOL for Visa (if needed)
      List<String> responses = [];
      response = await FlutterNfcKit.transceive("80A8000002830000");

      if (!response.endsWith("9000")) {
        print("Failed GET PROCESSING OPTIONS using default command. Trying PDOL extraction...");

        // Read Application File Locator (AFL)
        response = await FlutterNfcKit.transceive("80A800002383212800000000000000000000000000000002500000000000097820052600E8DA935200");
        if (!response.endsWith("9000")) {
          throw Exception("Failed to get processing options (Visa fallback also failed).");
        }
      }

      // Extract Data
      responses.add(response.substring(0, response.length - 4)); // Remove SW1SW2

      // APDU Commands to Read Card Data
      List<String> commands = [
        "00B2011400",
        "00B2010C00",
        "00B2012400",
        "00B2022400",
        "00B2011C00",  // 🔹 New: Read record 1 from SFI 7 (Cardholder Name - Possible)
        "00B2010A00"
      ];

      for (String cmd in commands) {
        try {
          String cmdResponse = await FlutterNfcKit.transceive(cmd);
          if (cmdResponse.endsWith("9000")) {
            responses.add(cmdResponse.substring(0, cmdResponse.length - 4)); // Remove SW1SW2
          }
        } catch (e) {
          print("Command failed: $cmd, Error: $e");
        }
      }

      // Extract Card Number & Expiry Date
      Map<String, String> cardDetails = EmvParser.extractCardDetails(responses);

      setState(() {
        _cardInfo = "Card: ${cardDetails["Card Number"]}\nExpiry: ${cardDetails["Expiry Date"]}";
      });
    } catch (e) {
      setState(() {
        _cardInfo = "Error: $e";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Visa NFC Reader")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_cardInfo, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _readMasterCard,
              child: Text("Tap to Read NFC Card"),
            ),
          ],
        ),
      ),
    );
  }
}
