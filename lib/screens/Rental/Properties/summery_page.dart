import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/provider/property_summery.dart';

import '../../../constant/constant.dart';
import '../../../model/properties.dart';
import '../../../model/properties_summery.dart';
import '../../../repository/properties_summery.dart';

class Summery_page extends StatefulWidget {
  Rentals properties;
 TenantData? tenants;

  Summery_page({super.key, required this.properties, this.tenants});
  @override
  _Summery_pageState createState() => _Summery_pageState();
}

class _Summery_pageState extends State<Summery_page>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late Future<List<TenantData>> futurePropertysummery;

  @override
  void initState() {
    super.initState();
    futurePropertysummery = Properies_summery_Repo().fetchPropertiessummery(widget.properties.rentalId!);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Custom Tabs'),
      // ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text('${widget.properties.rentalAddress}',
                  style: TextStyle(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text('${widget.properties.propertyTypeData?.propertyType}',
                  style: TextStyle(
                      color: Color(0xFF8A95A8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
              // color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorWeight: 5,
              //indicatorPadding: EdgeInsets.symmetric(horizontal: 1),
              indicatorColor: Color.fromRGBO(21, 43, 81, 1),
              labelColor: Color.fromRGBO(21, 43, 81, 1),
              unselectedLabelColor: Color.fromRGBO(21, 43, 81, 1),
              tabs: [
                Tab(text: 'Summary'),
                Tab(text: '     Units     '),
                Tab(text: '  Tenant(${Provider.of<Tenants_counts>(context,listen: false).count})  '),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Summary_page(),
                Center(child: Text('Content of Tab 2')),
                Tenants(context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Summary_page() {
    print("$image_url${widget.properties.rentalImage}");
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              height: 250,
              width: MediaQuery.of(context).size.width * .94,
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        // height: 150,
                        width: 150,
                        decoration: BoxDecoration(color: Colors.blue),
                        child: Image.network(

                          "$image_url${widget.properties.rentalImage}"??'https://st.depositphotos.com/1763233/3344/i/450/depositphotos_33445577-stock-photo-wooden-house.jpg',
                          fit: BoxFit.fill,
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Property Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(21, 43, 81, 1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('Address',
                          style: TextStyle(
                              color: Color(0xFF8A95A8),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                          '${widget.properties.propertyTypeData?.propertyType}',
                          style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('${widget.properties.rentalAddress}',
                          style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${widget.properties.rentalCity},',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      SizedBox(width: 3),
                      Text(
                        '${widget.properties.rentalState},',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${widget.properties.rentalCountry},',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      SizedBox(width: 3),
                      Text(
                        '${widget.properties.rentalPostcode}',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Rental Owners",
              style: TextStyle(
                  color: Color.fromRGBO(21, 43, 81, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: IntrinsicColumnWidth(),
                border: TableBorder.all(color: Colors.black),
                children: [
                  TableRow(
                    decoration: BoxDecoration(),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Field Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Company Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('E-mail',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Phone Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Home Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Business Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border.symmetric(horizontal: BorderSide.none),
                    ),
                    children: [
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerFirstName}',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                            child: Text(
                              '${widget.properties.rentalOwnerData?.rentalOwnerCompanyName}',
                              style: TextStyle(
                                color: Color.fromRGBO(21, 43, 81, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerPrimaryEmail}',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerPhoneNumber}',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerHomeNumber}',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerBuisinessNumber}',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                  // TableRow(
                  //   children: [
                  //     TableCell(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Text('Field 1'),
                  //       ),
                  //     ),
                  //     TableCell(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Text('Company A'),
                  //       ),
                  //     ),
                  //     TableCell(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Text('email@example.com'),
                  //       ),
                  //     ),
                  //     TableCell(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Text('123-456-7890'),
                  //       ),
                  //     ),
                  //     TableCell(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Text('987-654-3210'),
                  //       ),
                  //     ),
                  //     TableCell(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Text('123-987-6543'),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            /* SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                decoration: BoxDecoration(
                  border: Border.all()
                ),
                columnSpacing: 15,
                //border: TableBorder.all(),
                columns:  [
                  DataColumn(
                    label: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text('Field Name'),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text('Company Name'),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text('E-mail'),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text('Phone Number'),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text('Home Number'),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text('Business Number'),
                    ),
                  ),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Container()),
                      DataCell(Container()),
                      DataCell(Container()),
                      DataCell(Container()),
                      DataCell(Container()),
                      DataCell(Container()),
                    ],
                  ),
                  const DataRow(
                    cells: [
                      DataCell(
                        Text('Field 1'),
                      ),
                      DataCell(
                        Text('Company A'),
                      ),
                      DataCell(
                        mailto:text('email@example.com'),
                      ),
                      DataCell(
                        Text('123-456-7890'),
                      ),
                      DataCell(
                        Text('987-654-3210'),
                      ),
                      DataCell(
                        Text('123-987-6543'),
                      ),
                    ],
                  ),
                  const DataRow(
                    cells: [
                      DataCell(
                        Text('Field 2'),
                      ),
                      DataCell(
                        Text('Company B'),
                      ),
                      DataCell(
                        mailto:text('email2@example.com'),
                      ),
                      DataCell(
                        Text('234-567-8901'),
                      ),
                      DataCell(
                        Text('876-543-2109'),
                      ),
                      DataCell(
                        Text('234-876-5432'),
                      ),
                    ],
                  ),
                ],
              ),
            ),*/
            SizedBox(
              height: 10,
            ),
            Text(
              "Staff Details",
              style: TextStyle(
                  color: Color.fromRGBO(21, 43, 81, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Staff Member'),
                    ),
                  ),
                ]),
                TableRow(children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          '${widget.properties.staffMemberData!.staffmemberName}'),
                    ),
                  ),
                ])
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Tenants(BuildContext context) {
    return FutureBuilder<List<TenantData>>(
      future: Properies_summery_Repo().fetchPropertiessummery(widget.properties.rentalId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<TenantData> tenants = snapshot.data ?? [];
          Provider.of<Tenants_counts>(context,listen: false).setOwnerDetails(tenants.length);
          return
            ListView.builder(
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              String fullName = '${tenants[index].tenantFirstName} ${tenants[index].tenantLastName}';
              return
               Container(
                 child:
                 Column(
                   children: [
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Container(
                         height: 165,
                         width: MediaQuery.of(context).size.width * .9,
                         margin: EdgeInsets.symmetric(horizontal: 10),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(5),
                           border: Border.all(
                             color: Color.fromRGBO(21, 43, 81, 1),
                           ),
                         ),
                         child:
                         Column(
                           children: [
                             SizedBox(
                               height: 10,
                             ),
                             Row(
                               children: [
                                 SizedBox(
                                   width: 15,
                                 ),
                                 Container(
                                   height: 30,
                                   width: 30,
                                   // width: MediaQuery.of(context).size.width * .4,
                                   decoration: BoxDecoration(
                                     color: Color.fromRGBO(21, 43, 81, 1),
                                     border: Border.all(
                                         color: Color.fromRGBO(21, 43, 81, 1)),
                                     // color: Colors.blue,
                                     borderRadius: BorderRadius.circular(5),
                                   ),
                                   child: Center(
                                     child:   FaIcon(
                                       FontAwesomeIcons.user,
                                       size: 16,
                                       color: Colors.white,
                                     ),),
                                 ),
                                 SizedBox(
                                   width: 20,
                                 ),
                                 Column(

                                   children: [
                                     SizedBox(
                                       height: 4,
                                     ),
                                     Row(
                                       children: [

                                         Text(
                                           '${tenants[index].tenantFirstName} ${tenants[index].tenantLastName}',
                                           style: TextStyle(
                                             fontSize: 14,
                                             fontWeight: FontWeight.bold,
                                             color: Color.fromRGBO(21, 43, 81, 1),
                                           ),
                                         ),
                                       ],
                                     ),
                                     Row(
                                       children: [

                                         Text(
                                           '${widget.properties.rentalAddress}' ,
                                           style: TextStyle(
                                             fontSize: 11,
                                             color: Color(0xFF8A95A8),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
                                 ),
                                 Spacer(),
                                 InkWell(
                                   onTap: () {
                                     showDialog(
                                       context: context,
                                       builder: (BuildContext context) {
                                         bool isChecked =
                                         false; // Moved isChecked inside the StatefulBuilder
                                         return StatefulBuilder(
                                           builder: (BuildContext context,
                                               StateSetter setState) {
                                             return AlertDialog(
                                               backgroundColor: Colors.white,
                                               surfaceTintColor: Colors.white,
                                               content: SingleChildScrollView(
                                                 child: Column(
                                                   children: [
                                                     Row(
                                                       children: [
                                                         SizedBox(
                                                           width: 0,
                                                         ),
                                                         Text(
                                                           "Move out Tenants",
                                                           style: TextStyle(
                                                               fontWeight:
                                                               FontWeight
                                                                   .bold,
                                                               color: Color
                                                                   .fromRGBO(
                                                                   21,
                                                                   43,
                                                                   81,
                                                                   1),
                                                               fontSize: 15),
                                                         ),
                                                       ],
                                                     ),
                                                     SizedBox(
                                                       height: 10,
                                                     ),
                                                     Row(
                                                       children: [
                                                         SizedBox(
                                                           width: 0,
                                                         ),
                                                         Expanded(
                                                           child: Text(
                                                             "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
                                                             style: TextStyle(
                                                               fontWeight:
                                                               FontWeight.w500,
                                                               fontSize: 13,
                                                               color: Color(
                                                                   0xFF8A95A8),
                                                             ),
                                                           ),
                                                         ),
                                                         SizedBox(
                                                           width: 0,
                                                         ),
                                                       ],
                                                     ),
                                                     SizedBox(
                                                       height: 15,
                                                     ),
                                                     Material(
                                                       elevation: 3,
                                                       borderRadius:
                                                       BorderRadius.circular(
                                                           10),
                                                       child: Container(
                                                         height: 240,
                                                         width: MediaQuery.of(
                                                             context)
                                                             .size
                                                             .width *
                                                             .65,
                                                         decoration:
                                                         BoxDecoration(
                                                           border: Border.all(
                                                               color: Color
                                                                   .fromRGBO(
                                                                   21,
                                                                   43,
                                                                   81,
                                                                   1)),
                                                           // color: Colors.blue,
                                                           borderRadius:
                                                           BorderRadius
                                                               .circular(5),
                                                         ),
                                                         child: Column(
                                                           children: [
                                                             SizedBox(
                                                               height: 10,
                                                             ),
                                                             Padding(
                                                               padding:
                                                               const EdgeInsets.only(left: 5,right: 5),
                                                               child: Table(
                                                                 border: TableBorder.all(
                                                                     color: Color
                                                                         .fromRGBO(
                                                                         21,
                                                                         43,
                                                                         81,
                                                                         1)),
                                                                 children: [
                                                                   TableRow(
                                                                       children: [
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               'Address/Unit',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               'Lease Type',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               'Start End',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                       ]),
                                                                   TableRow(
                                                                       children: [
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               '${widget.properties.staffMemberData!.staffmemberName}',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               '${widget.properties.staffMemberData!.staffmemberName}',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               '${widget.properties.staffMemberData!.staffmemberName}',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                       ])
                                                                 ],
                                                               ),
                                                             ),
                                                             SizedBox(
                                                               height: 10,
                                                             ),
                                                             Padding(
                                                               padding:
                                                               const EdgeInsets.only(left: 5,right: 5),
                                                               child: Table(
                                                                 border: TableBorder.all(
                                                                     color: Color
                                                                         .fromRGBO(
                                                                         21,
                                                                         43,
                                                                         81,
                                                                         1)),
                                                                 children: [
                                                                   TableRow(
                                                                       children: [
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               'Address/Unit',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               'Lease Type',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               'Start End',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                       ]),
                                                                   TableRow(
                                                                       children: [
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               '${widget.properties.staffMemberData!.staffmemberName}',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               '${widget.properties.staffMemberData!.staffmemberName}',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                         TableCell(
                                                                           child:
                                                                           Padding(
                                                                             padding:
                                                                             const EdgeInsets.all(8.0),
                                                                             child:
                                                                             Text(
                                                                               '${widget.properties.staffMemberData!.staffmemberName}',
                                                                               style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                       ])
                                                                 ],
                                                               ),
                                                             ),
                                                             SizedBox(
                                                               height: 10,
                                                             ),
                                                           ],
                                                         ),
                                                       ),
                                                     ),
                                                     SizedBox(
                                                       height: 20,
                                                     ),
                                                     Row(
                                                       mainAxisAlignment: MainAxisAlignment.end,
                                                       crossAxisAlignment: CrossAxisAlignment.end,
                                                       children: [

                                                         GestureDetector(
                                                           onTap:(){
                                                             Navigator.pop(context);
                                                           },
                                                           child: Material(
                                                             elevation:3,
                                                             borderRadius: BorderRadius.all(Radius.circular(5),),
                                                             child: Container(
                                                               height: 30,
                                                               width:60,
                                                               decoration: BoxDecoration(
                                                                 color: Colors.white,
                                                                 borderRadius: BorderRadius.all(Radius.circular(5),),
                                                               ),
                                                               child: Center(child: Text("Close",style: TextStyle(fontWeight: FontWeight.w500,color: Color
                                                                   .fromRGBO(
                                                                   21,
                                                                   43,
                                                                   81,
                                                                   1)),)),
                                                             ),
                                                           ),
                                                         ),
                                                         SizedBox(width: 10,),
                                                         Material(
                                                           elevation:3,
                                                           borderRadius: BorderRadius.all(Radius.circular(5),),
                                                           child: Container(
                                                             height: 30,
                                                             width:80,
                                                             decoration: BoxDecoration(
                                                               color: Color
                                                                   .fromRGBO(
                                                                   21,
                                                                   43,
                                                                   81,
                                                                   1),
                                                               borderRadius: BorderRadius.all(Radius.circular(5),),
                                                             ),
                                                             child: Center(child: Text("Move Out",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 13),)),
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                     SizedBox(
                                                       height: 15,
                                                     ),
                                                   ],
                                                 ),
                                               ),
                                             );
                                           },
                                         );
                                       },
                                     );
                                   },
                                   child: Row(
                                     children: [
                                       FaIcon(
                                         FontAwesomeIcons.rightFromBracket,
                                         size: 17,
                                         color: Color.fromRGBO(21, 43, 81, 1),
                                       ),
                                       SizedBox(
                                         width: 5,
                                       ),
                                       Text(
                                         "Move out",
                                         style: TextStyle(
                                           fontSize: 11,
                                           fontWeight: FontWeight.w500, color:Color.fromRGBO(21, 43, 81, 1),),
                                       ),
                                     ],
                                   ),
                                 ),
                                 SizedBox(
                                   width: 15,
                                 ),
                               ],
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             Row(
                               children: [
                                 SizedBox(
                                   width: 65,
                                 ),
                                 Text(
                                   "Start date",
                                   style: TextStyle(
                                       fontSize: 12,
                                       color: Color.fromRGBO(21, 43, 81, 1),
                                       fontWeight: FontWeight.w500),
                                 ),
                               ],
                             ),
                             Row(
                               children: [
                                 SizedBox(
                                   width: 65,
                                 ),
                                 Text(
                                   "End date",
                                   style: TextStyle(
                                       fontSize: 12,
                                       color: Color.fromRGBO(21, 43, 81, 1),
                                       fontWeight: FontWeight.w500),
                                 ),
                               ],
                             ),
                             SizedBox(
                               height: 10,
                             ),
                             Row(
                               children: [
                                 SizedBox(
                                   width: 65,
                                 ),
                                 FaIcon(
                                   FontAwesomeIcons.phone,
                                   size: 15,
                                   color: Color.fromRGBO(21, 43, 81, 1),
                                 ),
                                 SizedBox(
                                   width: 5,
                                 ),
                                 Text(
                                   "358790293",
                                   style: TextStyle(
                                       fontSize: 12,
                                       color: Color.fromRGBO(21, 43, 81, 1),
                                       fontWeight: FontWeight.w500),
                                 ),
                               ],
                             ),
                             SizedBox(
                               height: 10,
                             ),
                             Row(
                               // mainAxisAlignment: MainAxisAlignment.center,
                               // crossAxisAlignment: CrossAxisAlignment.center,
                               children: [
                                 SizedBox(
                                   width: 65,
                                 ),
                                 FaIcon(
                                   FontAwesomeIcons.solidEnvelope,
                                   size: 15,
                                   color: Color.fromRGBO(21, 43, 81, 1),
                                 ),
                                 SizedBox(
                                   width: 5,
                                 ),
                                 Text(
                                   "alex@properties.com",
                                   style: TextStyle(
                                       fontSize: 12,
                                       color: Color.fromRGBO(21, 43, 81, 1),
                                       fontWeight: FontWeight.w500),
                                 ),
                               ],
                             ),
                           ],
                         ),

                         // Column(
                         //       children: [
                         //         SizedBox(
                         //           height: 10,
                         //         ),
                         //         Row(
                         //           mainAxisAlignment: MainAxisAlignment.center,
                         //           crossAxisAlignment: CrossAxisAlignment.center,
                         //           children: [
                         //             // SizedBox(
                         //             //   width: 5,
                         //             // ),
                         //             Material(
                         //               elevation: 3,
                         //               borderRadius: BorderRadius.circular(10),
                         //               child: Container(
                         //                 height: 165,
                         //                 width: MediaQuery.of(context).size.width * .9,
                         //                 decoration: BoxDecoration(
                         //                   border:
                         //                   Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                         //                   // color: Colors.blue,
                         //                   borderRadius: BorderRadius.circular(10),
                         //                 ),
                         //                 child: Column(
                         //                   children: [
                         //                     SizedBox(
                         //                       height: 10,
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 15,
                         //                         ),
                         //                         Container(
                         //                           height: 30,
                         //                           width: 30,
                         //                           // width: MediaQuery.of(context).size.width * .4,
                         //                           decoration: BoxDecoration(
                         //                             color: Color.fromRGBO(21, 43, 81, 1),
                         //                             border: Border.all(
                         //                                 color: Color.fromRGBO(21, 43, 81, 1)),
                         //                             // color: Colors.blue,
                         //                             borderRadius: BorderRadius.circular(5),
                         //                           ),
                         //                           child: Center(
                         //                             child:   FaIcon(
                         //                               FontAwesomeIcons.user,
                         //                               size: 16,
                         //                               color: Colors.white,
                         //                             ),),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 20,
                         //                         ),
                         //                         Column(
                         //                           mainAxisAlignment: MainAxisAlignment.center,
                         //                           crossAxisAlignment: CrossAxisAlignment.center,
                         //                           children: [
                         //
                         //
                         //                             Text(
                         //                               '${widget.properties.rentalAddress}',
                         //                               style: TextStyle(
                         //                                 fontSize: 10,
                         //                                 color: Color(0xFF8A95A8),
                         //                               ),
                         //                             ),
                         //                           ],
                         //                         ),
                         //                         Spacer(),
                         //                         InkWell(
                         //                           onTap: () {
                         //                             showDialog(
                         //                               context: context,
                         //                               builder: (BuildContext context) {
                         //                                 bool isChecked =
                         //                                 false; // Moved isChecked inside the StatefulBuilder
                         //                                 return StatefulBuilder(
                         //                                   builder: (BuildContext context,
                         //                                       StateSetter setState) {
                         //                                     return AlertDialog(
                         //                                       backgroundColor: Colors.white,
                         //                                       surfaceTintColor: Colors.white,
                         //                                       content: SingleChildScrollView(
                         //                                         child: Column(
                         //                                           children: [
                         //                                             Row(
                         //                                               children: [
                         //                                                 SizedBox(
                         //                                                   width: 0,
                         //                                                 ),
                         //                                                 Text(
                         //                                                   "Move out Tenants",
                         //                                                   style: TextStyle(
                         //                                                       fontWeight:
                         //                                                       FontWeight
                         //                                                           .bold,
                         //                                                       color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1),
                         //                                                       fontSize: 15),
                         //                                                 ),
                         //                                               ],
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 10,
                         //                                             ),
                         //                                             Row(
                         //                                               children: [
                         //                                                 SizedBox(
                         //                                                   width: 0,
                         //                                                 ),
                         //                                                 Expanded(
                         //                                                   child: Text(
                         //                                                     "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
                         //                                                     style: TextStyle(
                         //                                                       fontWeight:
                         //                                                       FontWeight.w500,
                         //                                                       fontSize: 13,
                         //                                                       color: Color(
                         //                                                           0xFF8A95A8),
                         //                                                     ),
                         //                                                   ),
                         //                                                 ),
                         //                                                 SizedBox(
                         //                                                   width: 0,
                         //                                                 ),
                         //                                               ],
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 15,
                         //                                             ),
                         //                                             Material(
                         //                                               elevation: 3,
                         //                                               borderRadius:
                         //                                               BorderRadius.circular(
                         //                                                   10),
                         //                                               child: Container(
                         //                                                 height: 240,
                         //                                                 width: MediaQuery.of(
                         //                                                     context)
                         //                                                     .size
                         //                                                     .width *
                         //                                                     .65,
                         //                                                 decoration:
                         //                                                 BoxDecoration(
                         //                                                   border: Border.all(
                         //                                                       color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1)),
                         //                                                   // color: Colors.blue,
                         //                                                   borderRadius:
                         //                                                   BorderRadius
                         //                                                       .circular(5),
                         //                                                 ),
                         //                                                 child: Column(
                         //                                                   children: [
                         //                                                     SizedBox(
                         //                                                       height: 10,
                         //                                                     ),
                         //                                                     Padding(
                         //                                                       padding:
                         //                                                       const EdgeInsets.only(left: 5,right: 5),
                         //                                                       child: Table(
                         //                                                         border: TableBorder.all(
                         //                                                             color: Color
                         //                                                                 .fromRGBO(
                         //                                                                 21,
                         //                                                                 43,
                         //                                                                 81,
                         //                                                                 1)),
                         //                                                         children: [
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Address/Unit',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Lease Type',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Start End',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ]),
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ])
                         //                                                         ],
                         //                                                       ),
                         //                                                     ),
                         //                                                     SizedBox(
                         //                                                       height: 10,
                         //                                                     ),
                         //                                                     Padding(
                         //                                                       padding:
                         //                                                       const EdgeInsets.only(left: 5,right: 5),
                         //                                                       child: Table(
                         //                                                         border: TableBorder.all(
                         //                                                             color: Color
                         //                                                                 .fromRGBO(
                         //                                                                 21,
                         //                                                                 43,
                         //                                                                 81,
                         //                                                                 1)),
                         //                                                         children: [
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Address/Unit',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Lease Type',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Start End',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ]),
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ])
                         //                                                         ],
                         //                                                       ),
                         //                                                     ),
                         //                                                     SizedBox(
                         //                                                       height: 10,
                         //                                                     ),
                         //                                                   ],
                         //                                                 ),
                         //                                               ),
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 20,
                         //                                             ),
                         //                                             Row(
                         //                                               mainAxisAlignment: MainAxisAlignment.end,
                         //                                               crossAxisAlignment: CrossAxisAlignment.end,
                         //                                               children: [
                         //
                         //                                                 GestureDetector(
                         //                                                   onTap:(){
                         //                                                     Navigator.pop(context);
                         //                                                   },
                         //                                                   child: Material(
                         //                                                     elevation:3,
                         //                                                     borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                     child: Container(
                         //                                                       height: 30,
                         //                                                       width:60,
                         //                                                       decoration: BoxDecoration(
                         //                                                         color: Colors.white,
                         //                                                         borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                       ),
                         //                                                       child: Center(child: Text("Close",style: TextStyle(fontWeight: FontWeight.w500,color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1)),)),
                         //                                                     ),
                         //                                                   ),
                         //                                                 ),
                         //                                                 SizedBox(width: 10,),
                         //                                                 Material(
                         //                                                   elevation:3,
                         //                                                   borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                   child: Container(
                         //                                                     height: 30,
                         //                                                     width:80,
                         //                                                     decoration: BoxDecoration(
                         //                                                       color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1),
                         //                                                       borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                     ),
                         //                                                     child: Center(child: Text("Move Out",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 13),)),
                         //                                                   ),
                         //                                                 ),
                         //                                               ],
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 15,
                         //                                             ),
                         //                                           ],
                         //                                         ),
                         //                                       ),
                         //                                     );
                         //                                   },
                         //                                 );
                         //                               },
                         //                             );
                         //                           },
                         //                           child: Row(
                         //                             children: [
                         //                               FaIcon(
                         //                                 FontAwesomeIcons.rightFromBracket,
                         //                                 size: 17,
                         //                                 color: Color.fromRGBO(21, 43, 81, 1),
                         //                               ),
                         //                               SizedBox(
                         //                                 width: 5,
                         //                               ),
                         //                               Text(
                         //                                 "Move out",
                         //                                 style: TextStyle(
                         //                                   fontSize: 11,
                         //                                   fontWeight: FontWeight.w500, color:Color.fromRGBO(21, 43, 81, 1),),
                         //                               ),
                         //                             ],
                         //                           ),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 15,
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     SizedBox(
                         //                       height: 15,
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         Text(
                         //                           "Start date",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         Text(
                         //                           "End date",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     SizedBox(
                         //                       height: 10,
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         FaIcon(
                         //                           FontAwesomeIcons.phone,
                         //                           size: 15,
                         //                           color: Color.fromRGBO(21, 43, 81, 1),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 5,
                         //                         ),
                         //                         Text(
                         //                           "358790293",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     SizedBox(
                         //                       height: 10,
                         //                     ),
                         //                     Row(
                         //                       // mainAxisAlignment: MainAxisAlignment.center,
                         //                       // crossAxisAlignment: CrossAxisAlignment.center,
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         FaIcon(
                         //                           FontAwesomeIcons.solidEnvelope,
                         //                           size: 15,
                         //                           color: Color.fromRGBO(21, 43, 81, 1),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 5,
                         //                         ),
                         //                         Text(
                         //                           "alex@properties.com",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                   ],
                         //                 ),
                         //               ),
                         //             ),
                         //             SizedBox(
                         //               width: 3,
                         //             ),
                         //           ],
                         //         ),
                         //         SizedBox(
                         //           height: 15,
                         //         ),
                         //         Row(
                         //           mainAxisAlignment: MainAxisAlignment.center,
                         //           crossAxisAlignment: CrossAxisAlignment.center,
                         //           children: [
                         //
                         //             Material(
                         //               elevation: 3,
                         //               borderRadius: BorderRadius.circular(10),
                         //               child: Container(
                         //                 height: 165,
                         //                 width: MediaQuery.of(context).size.width * .9,
                         //                 decoration: BoxDecoration(
                         //                   border:
                         //                   Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                         //                   // color: Colors.blue,
                         //                   borderRadius: BorderRadius.circular(10),
                         //                 ),
                         //                 child: Column(
                         //                   children: [
                         //                     SizedBox(
                         //                       height: 10,
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 15,
                         //                         ),
                         //                         Container(
                         //                           height: 30,
                         //                           width: 30,
                         //                           // width: MediaQuery.of(context).size.width * .4,
                         //                           decoration: BoxDecoration(
                         //                             color: Color.fromRGBO(21, 43, 81, 1),
                         //                             border: Border.all(
                         //                                 color: Color.fromRGBO(21, 43, 81, 1)),
                         //                             // color: Colors.blue,
                         //                             borderRadius: BorderRadius.circular(5),
                         //                           ),
                         //                           child: Center(
                         //                             child:   FaIcon(
                         //                               FontAwesomeIcons.user,
                         //                               size: 16,
                         //                               color: Colors.white,
                         //                             ),),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 20,
                         //                         ),
                         //                         Column(
                         //                           mainAxisAlignment: MainAxisAlignment.center,
                         //                           crossAxisAlignment: CrossAxisAlignment.center,
                         //                           children: [
                         //                             Text(
                         //                               "Alex Wilkins",
                         //                               style: TextStyle(
                         //                                   fontSize: 13,
                         //                                   color: Color.fromRGBO(21, 43, 81, 1),
                         //                                   fontWeight: FontWeight.bold),
                         //                             ),
                         //                             Text(
                         //                               '${widget.properties.rentalAddress}',
                         //                               style: TextStyle(
                         //                                 fontSize: 10,
                         //                                 color: Color(0xFF8A95A8),
                         //                               ),
                         //                             ),
                         //                           ],
                         //                         ),
                         //                         Spacer(),
                         //                         InkWell(
                         //                           onTap: () {
                         //                             showDialog(
                         //                               context: context,
                         //                               builder: (BuildContext context) {
                         //                                 bool isChecked =
                         //                                 false; // Moved isChecked inside the StatefulBuilder
                         //                                 return StatefulBuilder(
                         //                                   builder: (BuildContext context,
                         //                                       StateSetter setState) {
                         //                                     return AlertDialog(
                         //                                       backgroundColor: Colors.white,
                         //                                       surfaceTintColor: Colors.white,
                         //                                       content: SingleChildScrollView(
                         //                                         child: Column(
                         //                                           children: [
                         //                                             Row(
                         //                                               children: [
                         //                                                 SizedBox(
                         //                                                   width: 0,
                         //                                                 ),
                         //                                                 Text(
                         //                                                   "Move out Tenants",
                         //                                                   style: TextStyle(
                         //                                                       fontWeight:
                         //                                                       FontWeight
                         //                                                           .bold,
                         //                                                       color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1),
                         //                                                       fontSize: 15),
                         //                                                 ),
                         //                                               ],
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 10,
                         //                                             ),
                         //                                             Row(
                         //                                               children: [
                         //                                                 SizedBox(
                         //                                                   width: 0,
                         //                                                 ),
                         //                                                 Expanded(
                         //                                                   child: Text(
                         //                                                     "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
                         //                                                     style: TextStyle(
                         //                                                       fontWeight:
                         //                                                       FontWeight.w500,
                         //                                                       fontSize: 13,
                         //                                                       color: Color(
                         //                                                           0xFF8A95A8),
                         //                                                     ),
                         //                                                   ),
                         //                                                 ),
                         //                                                 SizedBox(
                         //                                                   width: 0,
                         //                                                 ),
                         //                                               ],
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 15,
                         //                                             ),
                         //                                             Material(
                         //                                               elevation: 3,
                         //                                               borderRadius:
                         //                                               BorderRadius.circular(
                         //                                                   10),
                         //                                               child: Container(
                         //                                                 height: 240,
                         //                                                 width: MediaQuery.of(
                         //                                                     context)
                         //                                                     .size
                         //                                                     .width *
                         //                                                     .65,
                         //                                                 decoration:
                         //                                                 BoxDecoration(
                         //                                                   border: Border.all(
                         //                                                       color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1)),
                         //                                                   // color: Colors.blue,
                         //                                                   borderRadius:
                         //                                                   BorderRadius
                         //                                                       .circular(5),
                         //                                                 ),
                         //                                                 child: Column(
                         //                                                   children: [
                         //                                                     SizedBox(
                         //                                                       height: 10,
                         //                                                     ),
                         //                                                     Padding(
                         //                                                       padding:
                         //                                                       const EdgeInsets.only(left: 5,right: 5),
                         //                                                       child: Table(
                         //                                                         border: TableBorder.all(
                         //                                                             color: Color
                         //                                                                 .fromRGBO(
                         //                                                                 21,
                         //                                                                 43,
                         //                                                                 81,
                         //                                                                 1)),
                         //                                                         children: [
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Address/Unit',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Lease Type',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Start End',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ]),
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ])
                         //                                                         ],
                         //                                                       ),
                         //                                                     ),
                         //                                                     SizedBox(
                         //                                                       height: 10,
                         //                                                     ),
                         //                                                     Padding(
                         //                                                       padding:
                         //                                                       const EdgeInsets.only(left: 5,right: 5),
                         //                                                       child: Table(
                         //                                                         border: TableBorder.all(
                         //                                                             color: Color
                         //                                                                 .fromRGBO(
                         //                                                                 21,
                         //                                                                 43,
                         //                                                                 81,
                         //                                                                 1)),
                         //                                                         children: [
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Address/Unit',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Lease Type',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Start End',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ]),
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ])
                         //                                                         ],
                         //                                                       ),
                         //                                                     ),
                         //                                                     SizedBox(
                         //                                                       height: 10,
                         //                                                     ),
                         //                                                   ],
                         //                                                 ),
                         //                                               ),
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 20,
                         //                                             ),
                         //                                             Row(
                         //                                               mainAxisAlignment: MainAxisAlignment.end,
                         //                                               crossAxisAlignment: CrossAxisAlignment.end,
                         //                                               children: [
                         //
                         //                                                 GestureDetector(
                         //                                                   onTap:(){
                         //                                                     Navigator.pop(context);
                         //                                                   },
                         //                                                   child: Material(
                         //                                                     elevation:3,
                         //                                                     borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                     child: Container(
                         //                                                       height: 30,
                         //                                                       width:60,
                         //                                                       decoration: BoxDecoration(
                         //                                                         color: Colors.white,
                         //                                                         borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                       ),
                         //                                                       child: Center(child: Text("Close",style: TextStyle(fontWeight: FontWeight.w500,color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1)),)),
                         //                                                     ),
                         //                                                   ),
                         //                                                 ),
                         //                                                 SizedBox(width: 10,),
                         //                                                 Material(
                         //                                                   elevation:3,
                         //                                                   borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                   child: Container(
                         //                                                     height: 30,
                         //                                                     width:80,
                         //                                                     decoration: BoxDecoration(
                         //                                                       color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1),
                         //                                                       borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                     ),
                         //                                                     child: Center(child: Text("Move Out",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 13),)),
                         //                                                   ),
                         //                                                 ),
                         //                                               ],
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 15,
                         //                                             ),
                         //                                           ],
                         //                                         ),
                         //                                       ),
                         //                                     );
                         //                                   },
                         //                                 );
                         //                               },
                         //                             );
                         //                           },
                         //                           child: Row(
                         //                             children: [
                         //                               FaIcon(
                         //                                 FontAwesomeIcons.rightFromBracket,
                         //                                 size: 17,
                         //                                 color: Color.fromRGBO(21, 43, 81, 1),
                         //                               ),
                         //                               SizedBox(
                         //                                 width: 5,
                         //                               ),
                         //                               Text(
                         //                                 "Move out",
                         //                                 style: TextStyle(
                         //                                   fontSize: 11,
                         //                                   fontWeight: FontWeight.w500, color:Color.fromRGBO(21, 43, 81, 1),),
                         //                               ),
                         //                             ],
                         //                           ),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 15,
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     SizedBox(
                         //                       height: 15,
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         Text(
                         //                           "Start date",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         Text(
                         //                           "End date",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     SizedBox(
                         //                       height: 10,
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         FaIcon(
                         //                           FontAwesomeIcons.phone,
                         //                           size: 15,
                         //                           color: Color.fromRGBO(21, 43, 81, 1),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 5,
                         //                         ),
                         //                         Text(
                         //                           "358790293",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     SizedBox(
                         //                       height: 10,
                         //                     ),
                         //                     Row(
                         //                       // mainAxisAlignment: MainAxisAlignment.center,
                         //                       // crossAxisAlignment: CrossAxisAlignment.center,
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         FaIcon(
                         //                           FontAwesomeIcons.solidEnvelope,
                         //                           size: 15,
                         //                           color: Color.fromRGBO(21, 43, 81, 1),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 5,
                         //                         ),
                         //                         Text(
                         //                           "alex@properties.com",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                   ],
                         //                 ),
                         //               ),
                         //             ),
                         //             SizedBox(
                         //               width: 3,
                         //             ),
                         //           ],
                         //         ),
                         //         SizedBox(
                         //           height: 15,
                         //         ),
                         //         Row(
                         //           mainAxisAlignment: MainAxisAlignment.center,
                         //           crossAxisAlignment: CrossAxisAlignment.center,
                         //           children: [
                         //             // SizedBox(
                         //             //   width: 5,
                         //             // ),
                         //             Material(
                         //               elevation: 3,
                         //               borderRadius: BorderRadius.circular(10),
                         //               child: Container(
                         //                 height: 165,
                         //                 width: MediaQuery.of(context).size.width * .9,
                         //                 decoration: BoxDecoration(
                         //                   border:
                         //                   Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                         //                   // color: Colors.blue,
                         //                   borderRadius: BorderRadius.circular(10),
                         //                 ),
                         //                 child: Column(
                         //                   children: [
                         //                     SizedBox(
                         //                       height: 10,
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 15,
                         //                         ),
                         //                         Container(
                         //                           height: 30,
                         //                           width: 30,
                         //                           // width: MediaQuery.of(context).size.width * .4,
                         //                           decoration: BoxDecoration(
                         //                             color: Color.fromRGBO(21, 43, 81, 1),
                         //                             border: Border.all(
                         //                                 color: Color.fromRGBO(21, 43, 81, 1)),
                         //                             // color: Colors.blue,
                         //                             borderRadius: BorderRadius.circular(5),
                         //                           ),
                         //                           child: Center(
                         //                             child:   FaIcon(
                         //                               FontAwesomeIcons.user,
                         //                               size: 16,
                         //                               color: Colors.white,
                         //                             ),),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 20,
                         //                         ),
                         //                         Column(
                         //                           mainAxisAlignment: MainAxisAlignment.center,
                         //                           crossAxisAlignment: CrossAxisAlignment.center,
                         //                           children: [
                         //                             Text(
                         //                               "Alex Wilkins",
                         //                               style: TextStyle(
                         //                                   fontSize: 13,
                         //                                   color: Color.fromRGBO(21, 43, 81, 1),
                         //                                   fontWeight: FontWeight.bold),
                         //                             ),
                         //                             Text(
                         //                               '${widget.properties.rentalAddress}',
                         //                               style: TextStyle(
                         //                                 fontSize: 10,
                         //                                 color: Color(0xFF8A95A8),
                         //                               ),
                         //                             ),
                         //                           ],
                         //                         ),
                         //                         Spacer(),
                         //                         InkWell(
                         //                           onTap: () {
                         //                             showDialog(
                         //                               context: context,
                         //                               builder: (BuildContext context) {
                         //                                 bool isChecked =
                         //                                 false; // Moved isChecked inside the StatefulBuilder
                         //                                 return StatefulBuilder(
                         //                                   builder: (BuildContext context,
                         //                                       StateSetter setState) {
                         //                                     return AlertDialog(
                         //                                       backgroundColor: Colors.white,
                         //                                       surfaceTintColor: Colors.white,
                         //                                       content: SingleChildScrollView(
                         //                                         child: Column(
                         //                                           children: [
                         //                                             Row(
                         //                                               children: [
                         //                                                 SizedBox(
                         //                                                   width: 0,
                         //                                                 ),
                         //                                                 Text(
                         //                                                   "Move out Tenants",
                         //                                                   style: TextStyle(
                         //                                                       fontWeight:
                         //                                                       FontWeight
                         //                                                           .bold,
                         //                                                       color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1),
                         //                                                       fontSize: 15),
                         //                                                 ),
                         //                                               ],
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 10,
                         //                                             ),
                         //                                             Row(
                         //                                               children: [
                         //                                                 SizedBox(
                         //                                                   width: 0,
                         //                                                 ),
                         //                                                 Expanded(
                         //                                                   child: Text(
                         //                                                     "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
                         //                                                     style: TextStyle(
                         //                                                       fontWeight:
                         //                                                       FontWeight.w500,
                         //                                                       fontSize: 13,
                         //                                                       color: Color(
                         //                                                           0xFF8A95A8),
                         //                                                     ),
                         //                                                   ),
                         //                                                 ),
                         //                                                 SizedBox(
                         //                                                   width: 0,
                         //                                                 ),
                         //                                               ],
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 15,
                         //                                             ),
                         //                                             Material(
                         //                                               elevation: 3,
                         //                                               borderRadius:
                         //                                               BorderRadius.circular(
                         //                                                   10),
                         //                                               child: Container(
                         //                                                 height: 240,
                         //                                                 width: MediaQuery.of(
                         //                                                     context)
                         //                                                     .size
                         //                                                     .width *
                         //                                                     .65,
                         //                                                 decoration:
                         //                                                 BoxDecoration(
                         //                                                   border: Border.all(
                         //                                                       color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1)),
                         //                                                   // color: Colors.blue,
                         //                                                   borderRadius:
                         //                                                   BorderRadius
                         //                                                       .circular(5),
                         //                                                 ),
                         //                                                 child: Column(
                         //                                                   children: [
                         //                                                     SizedBox(
                         //                                                       height: 10,
                         //                                                     ),
                         //                                                     Padding(
                         //                                                       padding:
                         //                                                       const EdgeInsets.only(left: 5,right: 5),
                         //                                                       child: Table(
                         //                                                         border: TableBorder.all(
                         //                                                             color: Color
                         //                                                                 .fromRGBO(
                         //                                                                 21,
                         //                                                                 43,
                         //                                                                 81,
                         //                                                                 1)),
                         //                                                         children: [
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Address/Unit',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Lease Type',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Start End',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ]),
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ])
                         //                                                         ],
                         //                                                       ),
                         //                                                     ),
                         //                                                     SizedBox(
                         //                                                       height: 10,
                         //                                                     ),
                         //                                                     Padding(
                         //                                                       padding:
                         //                                                       const EdgeInsets.only(left: 5,right: 5),
                         //                                                       child: Table(
                         //                                                         border: TableBorder.all(
                         //                                                             color: Color
                         //                                                                 .fromRGBO(
                         //                                                                 21,
                         //                                                                 43,
                         //                                                                 81,
                         //                                                                 1)),
                         //                                                         children: [
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Address/Unit',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Lease Type',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       'Start End',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ]),
                         //                                                           TableRow(
                         //                                                               children: [
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                                 TableCell(
                         //                                                                   child:
                         //                                                                   Padding(
                         //                                                                     padding:
                         //                                                                     const EdgeInsets.all(8.0),
                         //                                                                     child:
                         //                                                                     Text(
                         //                                                                       '${widget.properties.staffMemberData!.staffmemberName}',
                         //                                                                       style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                         //                                                                     ),
                         //                                                                   ),
                         //                                                                 ),
                         //                                                               ])
                         //                                                         ],
                         //                                                       ),
                         //                                                     ),
                         //                                                     SizedBox(
                         //                                                       height: 10,
                         //                                                     ),
                         //                                                   ],
                         //                                                 ),
                         //                                               ),
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 20,
                         //                                             ),
                         //                                             Row(
                         //                                               mainAxisAlignment: MainAxisAlignment.end,
                         //                                               crossAxisAlignment: CrossAxisAlignment.end,
                         //                                               children: [
                         //                                                 GestureDetector(
                         //                                                   onTap:(){
                         //                                                     Navigator.pop(context);
                         //                                                   },
                         //                                                   child: Material(
                         //                                                     elevation:3,
                         //                                                     borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                     child: Container(
                         //                                                       height: 30,
                         //                                                       width:60,
                         //                                                       decoration: BoxDecoration(
                         //                                                         color: Colors.white,
                         //                                                         borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                       ),
                         //                                                       child: Center(child: Text("Close",style: TextStyle(fontWeight: FontWeight.w500,color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1)),)),
                         //                                                     ),
                         //                                                   ),
                         //                                                 ),
                         //                                                 SizedBox(width: 10,),
                         //                                                 Material(
                         //                                                   elevation:3,
                         //                                                   borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                   child: Container(
                         //                                                     height: 30,
                         //                                                     width:80,
                         //                                                     decoration: BoxDecoration(
                         //                                                       color: Color
                         //                                                           .fromRGBO(
                         //                                                           21,
                         //                                                           43,
                         //                                                           81,
                         //                                                           1),
                         //                                                       borderRadius: BorderRadius.all(Radius.circular(5),),
                         //                                                     ),
                         //                                                     child: Center(child: Text("Move Out",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 13),)),
                         //                                                   ),
                         //                                                 ),
                         //                                               ],
                         //                                             ),
                         //                                             SizedBox(
                         //                                               height: 15,
                         //                                             ),
                         //                                           ],
                         //                                         ),
                         //                                       ),
                         //                                     );
                         //                                   },
                         //                                 );
                         //                               },
                         //                             );
                         //                           },
                         //                           child: Row(
                         //                             children: [
                         //                               FaIcon(
                         //                                 FontAwesomeIcons.rightFromBracket,
                         //                                 size: 17,
                         //                                 color: Color.fromRGBO(21, 43, 81, 1),
                         //                               ),
                         //                               SizedBox(
                         //                                 width: 5,
                         //                               ),
                         //                               Text(
                         //                                 "Move out",
                         //                                 style: TextStyle(
                         //                                   fontSize: 11,
                         //                                   fontWeight: FontWeight.w500, color:Color.fromRGBO(21, 43, 81, 1),),
                         //                               ),
                         //                             ],
                         //                           ),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 15,
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     SizedBox(
                         //                       height: 15,
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         Text(
                         //                           "Start date",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         Text(
                         //                           "End date",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     SizedBox(
                         //                       height: 10,
                         //                     ),
                         //                     Row(
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         FaIcon(
                         //                           FontAwesomeIcons.phone,
                         //                           size: 15,
                         //                           color: Color.fromRGBO(21, 43, 81, 1),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 5,
                         //                         ),
                         //                         Text(
                         //                           "358790293",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                     SizedBox(
                         //                       height: 10,
                         //                     ),
                         //                     Row(
                         //                       // mainAxisAlignment: MainAxisAlignment.center,
                         //                       // crossAxisAlignment: CrossAxisAlignment.center,
                         //                       children: [
                         //                         SizedBox(
                         //                           width: 65,
                         //                         ),
                         //                         FaIcon(
                         //                           FontAwesomeIcons.solidEnvelope,
                         //                           size: 15,
                         //                           color: Color.fromRGBO(21, 43, 81, 1),
                         //                         ),
                         //                         SizedBox(
                         //                           width: 5,
                         //                         ),
                         //                         Text(
                         //                           "alex@properties.com",
                         //                           style: TextStyle(
                         //                               fontSize: 12,
                         //                               color: Color.fromRGBO(21, 43, 81, 1),
                         //                               fontWeight: FontWeight.w500),
                         //                         ),
                         //                       ],
                         //                     ),
                         //                   ],
                         //                 ),
                         //               ),
                         //             ),
                         //             SizedBox(
                         //               width: 3,
                         //             ),
                         //           ],
                         //         ),
                         //         SizedBox(
                         //           height: 15,
                         //         ),
                         //       ],
                         //     ),

                       ),
                     ),
                   ],
                 ),
               );
            },
          );
        }
      },
    );
   return SingleChildScrollView(
      child:
       Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),


        Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SizedBox(
                    //   width: 5,
                    // ),
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 165,
                        width: MediaQuery.of(context).size.width * .9,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                          // color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  height: 30,
                                  width: 30,
                                  // width: MediaQuery.of(context).size.width * .4,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    border: Border.all(
                                        color: Color.fromRGBO(21, 43, 81, 1)),
                                    // color: Colors.blue,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                      child:   FaIcon(
                                        FontAwesomeIcons.user,
                                        size: 16,
                                        color: Colors.white,
                                      ),),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //
                                    // FutureBuilder<List<TenantData>>(
                                    //   future: Properies_summery_Repo().fetchPropertiessummery(),
                                    //   builder:
                                    //       (context, snapshot) {
                                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                                    //       return CircularProgressIndicator();
                                    //     } else if (snapshot.hasError) {
                                    //       return Text('Error: ${snapshot.error}');
                                    //     } else {
                                    //       List<TenantData> tenants = snapshot.data ?? [];
                                    //       return ListView.builder(
                                    //         itemCount: tenants.length,
                                    //         itemBuilder: (context, index) {
                                    //           String fullName = '${tenants[index].tenantFirstName} ${tenants[index].tenantLastName}';
                                    //           return  Text(
                                    //             fullName,
                                    //             style: TextStyle(
                                    //                 fontSize: 13,
                                    //                 color: Color.fromRGBO(21, 43, 81, 1),
                                    //                 fontWeight: FontWeight.bold),
                                    //           );
                                    //             // Add more UI elements or customize the ListTile as needed
                                    //         },
                                    //       );
                                    //     }
                                    //   },
                                    // ),

                                    FutureBuilder<List<TenantData>>(
                                      future: null,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else {
                                          List<TenantData> tenants = snapshot.data ?? [];
                                          return ListView.builder(
                                            itemCount: tenants.length,
                                            itemBuilder: (context, index) {
                                              String fullName = '${tenants[index].tenantFirstName} ${tenants[index].tenantLastName}';
                                              return  Text(
                                                fullName,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color.fromRGBO(21, 43, 81, 1),
                                                    fontWeight: FontWeight.bold),
                                              );
                                              // Add more UI elements or customize the ListTile as needed
                                            },
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                      '${widget.properties.rentalAddress}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF8A95A8),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        bool isChecked =
                                            false; // Moved isChecked inside the StatefulBuilder
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              surfaceTintColor: Colors.white,
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 0,
                                                        ),
                                                        Text(
                                                          "Move out Tenants",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      81,
                                                                      1),
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 0,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
                                                            style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 13,
                                                              color: Color(
                                                                  0xFF8A95A8),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 0,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Material(
                                                      elevation: 3,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Container(
                                                        height: 240,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .65,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      81,
                                                                      1)),
                                                          // color: Colors.blue,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(left: 5,right: 5),
                                                              child: Table(
                                                                border: TableBorder.all(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1)),
                                                                children: [
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Text(
                                                                              'Address/Unit',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Text(
                                                                              'Lease Type',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Text(
                                                                              'Start End',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ])
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(left: 5,right: 5),
                                                              child: Table(
                                                                border: TableBorder.all(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1)),
                                                                children: [
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Address/Unit',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Lease Type',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Start End',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ])
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [

                                                        GestureDetector(
                                                          onTap:(){
                                                            Navigator.pop(context);
                                                          },
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.all(Radius.circular(5),),
                                                            child: Container(
                                                              height: 30,
                                                              width:60,
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.all(Radius.circular(5),),
                                                              ),
                                                              child: Center(child: Text("Close",style: TextStyle(fontWeight: FontWeight.w500,color: Color
                                                                  .fromRGBO(
                                                                  21,
                                                                  43,
                                                                  81,
                                                                  1)),)),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Material(
                                                          elevation:3,
                                                          borderRadius: BorderRadius.all(Radius.circular(5),),
                                                          child: Container(
                                                            height: 30,
                                                            width:80,
                                                            decoration: BoxDecoration(
                                                                color: Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    81,
                                                                    1),
                                                              borderRadius: BorderRadius.all(Radius.circular(5),),
                                                            ),
                                                            child: Center(child: Text("Move Out",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 13),)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.rightFromBracket,
                                        size: 17,
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Move out",
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500, color:Color.fromRGBO(21, 43, 81, 1),),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                Text(
                                  "Start date",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                Text(
                                  "End date",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                FaIcon(
                                  FontAwesomeIcons.phone,
                                  size: 15,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "358790293",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                FaIcon(
                                  FontAwesomeIcons.solidEnvelope,
                                  size: 15,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "alex@properties.com",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 165,
                        width: MediaQuery.of(context).size.width * .9,
                        decoration: BoxDecoration(
                          border:
                          Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                          // color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  height: 30,
                                  width: 30,
                                  // width: MediaQuery.of(context).size.width * .4,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    border: Border.all(
                                        color: Color.fromRGBO(21, 43, 81, 1)),
                                    // color: Colors.blue,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child:   FaIcon(
                                      FontAwesomeIcons.user,
                                      size: 16,
                                      color: Colors.white,
                                    ),),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Alex Wilkins",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color.fromRGBO(21, 43, 81, 1),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${widget.properties.rentalAddress}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF8A95A8),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        bool isChecked =
                                        false; // Moved isChecked inside the StatefulBuilder
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              surfaceTintColor: Colors.white,
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 0,
                                                        ),
                                                        Text(
                                                          "Move out Tenants",
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              color: Color
                                                                  .fromRGBO(
                                                                  21,
                                                                  43,
                                                                  81,
                                                                  1),
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 0,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
                                                            style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 13,
                                                              color: Color(
                                                                  0xFF8A95A8),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 0,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Material(
                                                      elevation: 3,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                      child: Container(
                                                        height: 240,
                                                        width: MediaQuery.of(
                                                            context)
                                                            .size
                                                            .width *
                                                            .65,
                                                        decoration:
                                                        BoxDecoration(
                                                          border: Border.all(
                                                              color: Color
                                                                  .fromRGBO(
                                                                  21,
                                                                  43,
                                                                  81,
                                                                  1)),
                                                          // color: Colors.blue,
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(5),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(left: 5,right: 5),
                                                              child: Table(
                                                                border: TableBorder.all(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1)),
                                                                children: [
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Address/Unit',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Lease Type',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Start End',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ])
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(left: 5,right: 5),
                                                              child: Table(
                                                                border: TableBorder.all(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1)),
                                                                children: [
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Address/Unit',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Lease Type',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Start End',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ])
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [

                                                        GestureDetector(
                                                          onTap:(){
                                                            Navigator.pop(context);
                                                          },
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.all(Radius.circular(5),),
                                                            child: Container(
                                                              height: 30,
                                                              width:60,
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.all(Radius.circular(5),),
                                                              ),
                                                              child: Center(child: Text("Close",style: TextStyle(fontWeight: FontWeight.w500,color: Color
                                                                  .fromRGBO(
                                                                  21,
                                                                  43,
                                                                  81,
                                                                  1)),)),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Material(
                                                          elevation:3,
                                                          borderRadius: BorderRadius.all(Radius.circular(5),),
                                                          child: Container(
                                                            height: 30,
                                                            width:80,
                                                            decoration: BoxDecoration(
                                                              color: Color
                                                                  .fromRGBO(
                                                                  21,
                                                                  43,
                                                                  81,
                                                                  1),
                                                              borderRadius: BorderRadius.all(Radius.circular(5),),
                                                            ),
                                                            child: Center(child: Text("Move Out",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 13),)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.rightFromBracket,
                                        size: 17,
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Move out",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500, color:Color.fromRGBO(21, 43, 81, 1),),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                Text(
                                  "Start date",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                Text(
                                  "End date",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                FaIcon(
                                  FontAwesomeIcons.phone,
                                  size: 15,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "358790293",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                FaIcon(
                                  FontAwesomeIcons.solidEnvelope,
                                  size: 15,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "alex@properties.com",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SizedBox(
                    //   width: 5,
                    // ),
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 165,
                        width: MediaQuery.of(context).size.width * .9,
                        decoration: BoxDecoration(
                          border:
                          Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                          // color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  height: 30,
                                  width: 30,
                                  // width: MediaQuery.of(context).size.width * .4,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    border: Border.all(
                                        color: Color.fromRGBO(21, 43, 81, 1)),
                                    // color: Colors.blue,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child:   FaIcon(
                                      FontAwesomeIcons.user,
                                      size: 16,
                                      color: Colors.white,
                                    ),),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Alex Wilkins",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color.fromRGBO(21, 43, 81, 1),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${widget.properties.rentalAddress}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF8A95A8),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        bool isChecked =
                                        false; // Moved isChecked inside the StatefulBuilder
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              surfaceTintColor: Colors.white,
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 0,
                                                        ),
                                                        Text(
                                                          "Move out Tenants",
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              color: Color
                                                                  .fromRGBO(
                                                                  21,
                                                                  43,
                                                                  81,
                                                                  1),
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 0,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
                                                            style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 13,
                                                              color: Color(
                                                                  0xFF8A95A8),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 0,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Material(
                                                      elevation: 3,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                      child: Container(
                                                        height: 240,
                                                        width: MediaQuery.of(
                                                            context)
                                                            .size
                                                            .width *
                                                            .65,
                                                        decoration:
                                                        BoxDecoration(
                                                          border: Border.all(
                                                              color: Color
                                                                  .fromRGBO(
                                                                  21,
                                                                  43,
                                                                  81,
                                                                  1)),
                                                          // color: Colors.blue,
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(5),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(left: 5,right: 5),
                                                              child: Table(
                                                                border: TableBorder.all(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1)),
                                                                children: [
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Address/Unit',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Lease Type',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Start End',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ])
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(left: 5,right: 5),
                                                              child: Table(
                                                                border: TableBorder.all(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1)),
                                                                children: [
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Address/Unit',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Lease Type',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              'Start End',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.bold,fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(8.0),
                                                                            child:
                                                                            Text(
                                                                              '${widget.properties.staffMemberData!.staffmemberName}',
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ])
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        GestureDetector(
                                                          onTap:(){
                                                            Navigator.pop(context);
                                                          },
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.all(Radius.circular(5),),
                                                            child: Container(
                                                              height: 30,
                                                              width:60,
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.all(Radius.circular(5),),
                                                              ),
                                                              child: Center(child: Text("Close",style: TextStyle(fontWeight: FontWeight.w500,color: Color
                                                                  .fromRGBO(
                                                                  21,
                                                                  43,
                                                                  81,
                                                                  1)),)),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Material(
                                                          elevation:3,
                                                          borderRadius: BorderRadius.all(Radius.circular(5),),
                                                          child: Container(
                                                            height: 30,
                                                            width:80,
                                                            decoration: BoxDecoration(
                                                              color: Color
                                                                  .fromRGBO(
                                                                  21,
                                                                  43,
                                                                  81,
                                                                  1),
                                                              borderRadius: BorderRadius.all(Radius.circular(5),),
                                                            ),
                                                            child: Center(child: Text("Move Out",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 13),)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.rightFromBracket,
                                        size: 17,
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Move out",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500, color:Color.fromRGBO(21, 43, 81, 1),),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                Text(
                                  "Start date",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                Text(
                                  "End date",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                FaIcon(
                                  FontAwesomeIcons.phone,
                                  size: 15,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "358790293",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                                FaIcon(
                                  FontAwesomeIcons.solidEnvelope,
                                  size: 15,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "alex@properties.com",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
