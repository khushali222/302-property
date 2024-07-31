import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/GetCardDetailModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/Preminum%20Plans/GetCardDetailSerivce.dart';
import 'package:three_zero_two_property/screens/Login/login_screen.dart';
import 'package:three_zero_two_property/screens/Plans/PreminumPlanForm.dart';
import 'package:three_zero_two_property/screens/Plans/planform.dart';
import '../../widgets/appbar.dart';
import '../../widgets/drawer_tiles.dart';

class PlanPurchaseCard extends StatefulWidget {
  bool isappbarShow = true;
  PlanPurchaseCard({this.isappbarShow = true});

  @override
  State<PlanPurchaseCard> createState() => _PlanPurchaseCardState();
}

class _PlanPurchaseCardState extends State<PlanPurchaseCard> {
  late Future<List<CardData>> _futureCard;
  List<CardData> Cards = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    // TODO: implement initState
    _futureCard = fetchData();
    super.initState();
  }

  Future<List<CardData>> fetchData() async {
    GetCardDetailService service = GetCardDetailService();
    try {
      List<CardData>? data = await service.fetchCardDetail();
      setState(() {
        Cards = data!;
        isLoading = false;
        errorMessage = null; // Reset error message on successful data fetch
      });
      return data!;
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load renters insurance data. Please try again later.';
      });
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: !widget.isappbarShow
          ? null
          : AppBar(
              // leading: Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: CircleAvatar(
              //     maxRadius: 20,
              //     backgroundColor: Colors.grey[300],
              //     child: IconButton(
              //       icon: Icon(
              //         Icons.arrow_back,
              //         color: blueColor,
              //       ),
              //       onPressed: () {
              //         Navigator.pop(context);
              //       },
              //     ),
              //   ),
              // ),
              elevation: 0,
              backgroundColor: Colors.white,
              centerTitle: true,
              title: Text(
                'Plan Purchase',
                style: TextStyle(color: blueColor, fontWeight: FontWeight.bold),
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.clear();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login_Screen()),
                          (route) => false);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: 20,
                          color: blueColor,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Logout',
                          style: TextStyle(color: blueColor),
                        ),
                      ],
                    )),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CardData>>(
          future: _futureCard,
          builder: (context, snapshot) {
            if (isLoading) {
              return const Center(
                child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 40.0,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(errorMessage ?? 'Unknown error'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data available'));
            }
            var data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Column(
                      children: data
                          .map((plan) => buildPlanCard(context, plan))
                          .toList(),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}

Widget buildPlanCard(BuildContext context, CardData plan) {
  void _showEnhancedAlert(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Warning",
      desc: "Your NMI account is not linked, contact support.",
      style: AlertStyle(
        backgroundColor: Colors.white,
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        descStyle: TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
        animationType: AnimationType.grow,
        isOverlayTapDismiss: false,
        overlayColor: Colors.black.withOpacity(0.5),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: blueColor, width: 2),
        ),
        alertPadding: EdgeInsets.all(16.0),
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
          color: blueColor,
          // width: 120,
          radius: BorderRadius.circular(8.0),
        ),
      ],
    ).show();
  }

  return Padding(
    padding:
        const EdgeInsets.only(top: 8.0, left: 28.0, right: 28.0, bottom: 8.0),
    child: Container(
      //  width: MediaQuery.of(context).size.width * .78,
      // height: MediaQuery.of(context).size.height * ,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black,
            width: 1,
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(21, 43, 81, 1),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Image.asset(
                  "assets/icons/plan_icon.png",
                  height: 20,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "${plan.planName}",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("\$${plan.planPrice} / ${plan.billingInterval}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(21, 43, 81, 1)))
              ],
            ),
          ),
          ...plan.features!
              .map((feature) => Row(
                    children: [
                      const SizedBox(width: 15),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: const Icon(Icons.fiber_manual_record, size: 15),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 4,
                          ),
                          Text(feature.features!,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(21, 43, 81, 1))),
                        ],
                      )),
                    ],
                  ))
              .toList(),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () async {
              GetCardDetailService service = GetCardDetailService();
              final response = await service.fetchSubscriptionData();

              if (response['data'] == null) {
                _showEnhancedAlert(context);
                return;
              }
              await Future.delayed(Duration(seconds: 3));
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreminumPlanForm(
                            plan: plan,
                          )));
            },
            child: Center(
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(21, 43, 81, 1),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Center(
                      child: Text(
                    "Get Started",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Center(
              child: Text(
            "Term Apply",
            style: TextStyle(
                color: Color.fromRGBO(21, 43, 81, 1),
                fontWeight: FontWeight.bold),
          )),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    ),
  );
}
