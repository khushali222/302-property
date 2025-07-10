import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Model/properties_Lease_model.dart';

class CustomLeaseTable extends StatefulWidget {
  final List<Properties_lease_model> leaseData;
  final Function(int) onSort;
  final Color blueColor;

  const CustomLeaseTable({
    Key? key,
    required this.leaseData,
    required this.onSort,
    required this.blueColor,
  }) : super(key: key);

  @override
  State<CustomLeaseTable> createState() => _CustomLeaseTableState();
}

class _CustomLeaseTableState extends State<CustomLeaseTable> {
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
        color: widget.blueColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 4,),
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
                        ? Text("Tenant\nNames",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 14))
                        : Text("Tenant\nNames",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
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
                    Text("Lease End",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14)),
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
                    Text("Rent Cycle",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14)),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          _buildHeaders(),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
            ),
            child: Column(
              children: widget.leaseData.asMap().entries.map((entry) {
                int index = entry.key;
                bool isExpanded = expandedIndex == index;
                Properties_lease_model lease = entry.value;
                return Container(
                  decoration: BoxDecoration(
                    color: index % 2 != 0
                        ? Colors.white
                        : widget.blueColor.withOpacity(0.09),
                    border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
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
                                    lease.tenantNames ?? 'N/A',
                                    style: TextStyle(
                                      color: widget.blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width * .099),
                              Expanded(
                                child: Text(
                                  lease.endDate ?? 'N/A',
                                  style: TextStyle(
                                    color: widget.blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width * .09),
                              Expanded(
                                child: Text(
                                  lease.rentCycle ?? 'N/A',
                                  style: TextStyle(
                                    color: widget.blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width * .02),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          margin: EdgeInsets.only(bottom: 20),
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
                                                  text: 'Remaining Days : ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: widget.blueColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                  "${lease.remainingDays ?? 0} days",
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
                                                  text: 'Current Balance : ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: widget.blueColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "\$${lease.totalBalance ?? 0.0}",
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
                                                  text: 'Rent : ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: widget.blueColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\$${lease.amount ?? 0.0} days",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
