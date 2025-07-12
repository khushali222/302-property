import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Model/Properties_revenue_model.dart';
import '../../constant/constant.dart';

class CustomStaffRevenueTable extends StatefulWidget {
  final List<Properties_Revenu_model> revenueData;
  final Function(int) onSort;
  final Color blueColor;

  const CustomStaffRevenueTable({
    Key? key,
    required this.revenueData,
    required this.onSort,
    required this.blueColor,
  }) : super(key: key);

  @override
  State<CustomStaffRevenueTable> createState() =>
      _CustomAdminRevenueTableState();
}

class _CustomAdminRevenueTableState extends State<CustomStaffRevenueTable> {
  int? expandedIndex;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;

  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 4,
            ),
            Container(
              child: Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting1) {
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = !ascending1;
                      ascending2 = false;
                      ascending3 = false;
                    } else {
                      sorting1 = true;
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = true;
                      ascending2 = false;
                      ascending3 = false;
                    }
                    widget.onSort(1);
                  });
                },
                child: Row(
                  children: [
                    width < 400
                        ? Text("Date",
                            textAlign: TextAlign.center,
                            style: TextStyle( color: blueColor, fontWeight: FontWeight.bold, fontSize: 15))
                        : Text("Date",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle( color: blueColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(width: 3),
                  ],
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * .08),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting2) {
                      sorting1 = false;
                      sorting3 = false;
                      ascending2 = !ascending2;
                      ascending1 = false;
                      ascending3 = false;
                    } else {
                      sorting1 = false;
                      sorting2 = true;
                      sorting3 = false;
                      ascending2 = true;
                      ascending1 = false;
                      ascending3 = false;
                    }
                    widget.onSort(2);
                  });
                },
                child: Row(
                  children: [
                    Text("Tenant\nNames",
                        textAlign: TextAlign.center,
                        style: TextStyle( color: blueColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * .06),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting3) {
                      sorting1 = false;
                      sorting2 = false;
                      ascending3 = !ascending3;
                      ascending2 = false;
                      ascending1 = false;
                    } else {
                      sorting1 = false;
                      sorting2 = false;
                      sorting3 = true;
                      ascending3 = true;
                      ascending2 = false;
                      ascending1 = false;
                    }
                    widget.onSort(3);
                  });
                },
                child: Row(
                  children: [
                    Text("  Status",
                        textAlign: TextAlign.center,
                        style: TextStyle( color: blueColor, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * .02),
          ],
        ),
      ),
    );
  }
  String formatDate(String? date) {
    if (date == null || date.trim().isEmpty) return 'Invalid Date';
    return date;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          _buildHeaders(),
          SizedBox(height: 10),
          Container(
            child: Column(
              children: widget.revenueData.asMap().entries.map((entry) {
                int index = entry.key;
                bool isExpanded = expandedIndex == index;
                Properties_Revenu_model lease = entry.value;
                return Container(
                  margin:
                  EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: index % 2 != 0
                        ? Color(0xFFF4F8FF)
                        : Colors.white,
                    border: Border.all(
                        color: Color(0xFFDBE0E5)),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    expandedIndex =
                                        expandedIndex == index ? null : index;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  padding: !isExpanded
                                      ? EdgeInsets.only(bottom: 10)
                                      : EdgeInsets.only(top: 10),
                                  child: FaIcon(
                                    isExpanded
                                        ? FontAwesomeIcons.sortUp
                                        : FontAwesomeIcons.sortDown,
                                    size: 20,
                                    color: widget.blueColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      expandedIndex =
                                          expandedIndex == index ? null : index;
                                    });
                                  },
                                  child: Text(
                                    formatDate(lease.entry?.first.date),
                                    style: TextStyle(
                                      color: widget.blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .099),
                              Expanded(
                                child: Text(
                                  "${lease.tenantData?.tenantFirstName ?? 'N/A'} ${lease.tenantData?.tenantLastName ?? 'N/A'}",
                                  style: TextStyle(
                                    color: widget.blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .09),
                              Expanded(
                                child: Text(
                                  lease.response ?? 'N/A',
                                  style: TextStyle(
                                    color: widget.blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .02),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          margin: EdgeInsets.only(bottom: 5),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    FaIcon(
                                      isExpanded
                                          ? FontAwesomeIcons.sortUp
                                          : FontAwesomeIcons.sortDown,
                                      size: 50,
                                      color: Colors.transparent,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .01),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Amount : ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: widget.blueColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: lease.totalAmount !=
                                                          null
                                                      ? "\$${lease.formattedTotalAmount}"
                                                      : 'N/A',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .01),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Payment Type : ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: widget.blueColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${lease.paymentType ?? ""}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .01),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
