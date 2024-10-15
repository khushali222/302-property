import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
class InternetConnectivity with ChangeNotifier {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  InternetConnectivity() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result;

      notifyListeners();
    });
  }

  bool get isConnected => _connectionStatus != ConnectivityResult.none;
}
class InternetWrapper extends StatefulWidget {
  final Widget child;

  const InternetWrapper({ required this.child}) ;

  @override
  _InternetWrapperState createState() => _InternetWrapperState();
}


class _InternetWrapperState extends State<InternetWrapper> {
  /*ConnectivityResult _connectionStatus = ConnectivityResult.none;
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result;
      });
    });
  }*/

  Widget build(BuildContext context) {
    final internetConnectivity = Provider.of<InternetConnectivity>(context);
    return internetConnectivity.isConnected
        ? Scaffold(body: widget.child)
        : Scaffold(
      body: Center(
        child: AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => SystemNavigator.pop(),
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}