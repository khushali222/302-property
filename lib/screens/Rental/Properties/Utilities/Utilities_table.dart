import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constant/constant.dart';
import '../../../../model/unitsummery_propeties.dart';
import '../../../../repository/properties_summery.dart';
import 'Add_Edit_Utility.dart';

class Utilities_table extends StatefulWidget {
  final String rentalId;
  Utilities_table({super.key, required this.rentalId});

  @override
  State<Utilities_table> createState() => _Utilities_tableState();
}

class _Utilities_tableState extends State<Utilities_table> {
  late Future<List<Map<String, dynamic>>> _futureUtilities;
  bool isLoading = true;
  String? errorMessage;
  Map<String, List<Map<String, dynamic>>>? utilitiesByUnit;
  List<unit_properties>? units;
  unit_properties? selectedUnit;
  bool isMultiUnit = false;
  int? expandedRowIndex;
  String? expandedUnitKey;
  final Properies_summery_Repo _unitRepository = Properies_summery_Repo();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _loadUnits();
    _futureUtilities = fetchUtilitiesData();
  }

  Future<void> _loadUnits() async {
    try {
      final fetchedUnits = await _unitRepository.fetchunit(widget.rentalId);
      setState(() {
        units = fetchedUnits;
        // Set isMultiUnit based on number of units - this determines if dropdown should show
        isMultiUnit = fetchedUnits.length > 1;
        if (fetchedUnits.isNotEmpty) {
          selectedUnit = fetchedUnits.first;
        }
      });
    } catch (e) {
      logError('Error loading units: $e');
      setState(() {
        units = [];
        isMultiUnit = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredUtilities() {
    if (utilitiesByUnit == null || utilitiesByUnit!.isEmpty) {
      return [];
    }

    // Check if utilities have unit_id (grouped by unit)
    bool utilitiesHaveUnitId =
        utilitiesByUnit!.keys.any((key) => key != 'single');

    if (!utilitiesHaveUnitId || selectedUnit == null) {
      // No unit_id in utilities or no unit selected - return all utilities
      return utilitiesByUnit!['single'] ??
          utilitiesByUnit!.values.expand((list) => list).toList();
    }

    // Utilities have unit_id - return utilities for selected unit
    String unitId = selectedUnit!.unitId ?? '';
    return utilitiesByUnit![unitId] ?? [];
  }

  Future<List<Map<String, dynamic>>> fetchUtilitiesData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");
      String? token = prefs.getString('token');

      if (adminId == null || token == null) {
        throw Exception('Admin ID or token not found');
      }

      final response = await apiGet(
        Uri.parse(
            '$Api_url/api/utilities/rental/${widget.rentalId}?admin_id=$adminId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $adminId",
        },
      );

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);

        if (parsedJson['data'] != null && parsedJson['data'] is List) {
          List<Map<String, dynamic>> utilities =
              List<Map<String, dynamic>>.from(parsedJson['data']);

          // Check if any utility has unit_id
          bool hasUnitId = utilities.any((util) =>
              util['unit_id'] != null && util['unit_id'].toString().isNotEmpty);

          setState(() {
            isLoading = false;
            // Don't change isMultiUnit here - it's set by _loadUnits based on unit count
            // This allows dropdown to show even when no utilities exist yet
            if (hasUnitId) {
              // Group by unit_id
              utilitiesByUnit = {};
              for (var utility in utilities) {
                String unitId = utility['unit_id']?.toString() ?? 'no_unit';
                if (!utilitiesByUnit!.containsKey(unitId)) {
                  utilitiesByUnit![unitId] = [];
                }
                utilitiesByUnit![unitId]!.add(utility);
              }
              // Update selectedUnit to match utilities if needed
              if (units != null && units!.isNotEmpty) {
                // Find the first unit that has utilities
                for (var unit in units!) {
                  if (utilitiesByUnit!.containsKey(unit.unitId)) {
                    selectedUnit = unit;
                    break;
                  }
                }
                // If no matching unit found, keep current selectedUnit or use first unit
                if (selectedUnit == null) {
                  selectedUnit = units!.first;
                }
              }
            } else {
              // No unit_id in utilities - store all utilities under a single key
              utilitiesByUnit = {'single': utilities};
              // Keep selectedUnit so dropdown can still work for adding new utilities
            }
            isLoading = false;
            errorMessage = null;
          });

          return utilities;
        } else {
          setState(() {
            isLoading = false;
            utilitiesByUnit = {};
          });
          return [];
        }
      } else {
        throw Exception('Failed to load utilities: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load utilities data. Please try again later.';
      });
      logError('Error fetching utilities: $e');
      return [];
    }
  }

  Widget _buildHeaders() {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 0, right: 5),
                width: 15,
              ),
              Expanded(
                // flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Utility Name",
                    style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Expanded(
                //  flex: 2,
                child: Text(
                  "Provider Name",
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Expanded(
                // flex: 2,
                child: Text(
                  "Account Number",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String leftLabel, String leftValue, String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                const SizedBox(height: 2.0),
                Text(
                  leftValue,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                const SizedBox(height: 2.0),
                Text(
                  rightValue,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUtilityRow(
      Map<String, dynamic> utility, int rowIndex, String unitKey) {
    bool isRowExpanded =
        expandedRowIndex == rowIndex && expandedUnitKey == unitKey;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: rowIndex % 2 != 0 ? const Color(0xFFF4F8FF) : Colors.white,
        border: Border.all(color: const Color(0xFFDBE0E5)),
        borderRadius: BorderRadius.circular(10),
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
                        if (isRowExpanded) {
                          expandedRowIndex = null;
                          expandedUnitKey = null;
                        } else {
                          expandedRowIndex = rowIndex;
                          expandedUnitKey = unitKey;
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      padding: !isRowExpanded
                          ? const EdgeInsets.only(bottom: 10)
                          : const EdgeInsets.only(top: 10),
                      child: FaIcon(
                        isRowExpanded
                            ? FontAwesomeIcons.sortUp
                            : FontAwesomeIcons.sortDown,
                        size: 20,
                        color: blueColor,
                      ),
                    ),
                  ),
                  Expanded(
                    //flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isRowExpanded) {
                              expandedRowIndex = null;
                              expandedUnitKey = null;
                            } else {
                              expandedRowIndex = rowIndex;
                              expandedUnitKey = unitKey;
                            }
                          });
                        },
                        child: Text(
                          utility['utility_name']?.toString() ?? '-',
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: blueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    //   flex: 2,
                    child: Text(
                      utility['provider_name']?.toString() ?? '-',
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    //  flex: 2,
                    child: Text(
                      utility['account_number']?.toString() ?? '-',
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isRowExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              margin: const EdgeInsets.only(bottom: 2),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        FaIcon(
                          isRowExpanded
                              ? FontAwesomeIcons.sortUp
                              : FontAwesomeIcons.sortDown,
                          size: 40,
                          color: Colors.transparent,
                        ),
                        Flexible(
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(),
                              1: FlexColumnWidth(),
                            },
                            children: [
                              _buildTableRow(
                                'CUSTOMER SERVICE PHONE:',
                                utility['customer_service_phone'] != null &&
                                        utility['customer_service_phone']
                                            .toString()
                                            .isNotEmpty &&
                                        utility['customer_service_phone']
                                                .toString() !=
                                            'null'
                                    ? formatPhoneNumber(
                                        utility['customer_service_phone']
                                            .toString()
                                            .trim())
                                    : 'N/A',
                                '',
                                '',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showEditDialog(utility);
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.edit,
                                  size: 15,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _showDeleteAlert(
                                context, utility['_id']?.toString() ?? '');
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red.shade50,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.trashCan,
                                  size: 15,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnitHeader(String unitName, String? unitId) {
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: blueColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: blueColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.home,
            color: blueColor,
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            unitName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          Text(
            "Utilities",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
          if (isMultiUnit && units != null && units!.length > 1) ...[
            SizedBox(width: 20),
            Expanded(
              child: Container(
                height: 36,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border.all(color: blueColor.withOpacity(0.3), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<unit_properties>(
                    isExpanded: true,
                    value: selectedUnit,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: blueColor,
                      size: 20,
                    ),
                    elevation: 3,
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    items: units!
                        .map((unit) => DropdownMenuItem<unit_properties>(
                              value: unit,
                              child: Text(
                                unit.rentalunit ?? 'Unit ${unit.unitId ?? ''}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (unit) {
                      setState(() {
                        selectedUnit = unit;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
          Spacer(),
          GestureDetector(
            onTap: () {
              _showAddUtilityDialog(selectedUnit?.unitId);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "Add Utility",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          // SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureUtilities,
            builder: (context, snapshot) {
              if (isLoading ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitFadingCircle(
                          color: blueColor,
                          size: 50.0,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading utilities...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError || errorMessage != null) {
                return Center(
                    child: Text(errorMessage ?? 'Unknown error occurred'));
              } else if (utilitiesByUnit == null || utilitiesByUnit!.isEmpty) {
                return Container(
                  height: MediaQuery.of(context).size.height * .45,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/no_data.jpg",
                          height: 200,
                          width: 200,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "No Utilities Available",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: blueColor,
                              fontSize: 16),
                        )
                      ],
                    ),
                  ),
                );
              }

              final filteredUtilities = _getFilteredUtilities();
              final currentUnitKey = selectedUnit?.unitId ?? 'single';

              // Get unit name for header
              String? unitName;
              if (selectedUnit != null) {
                unitName = selectedUnit!.rentalunit ??
                    'Unit ${selectedUnit!.unitId ?? ''}';
              } else if (utilitiesByUnit != null &&
                  utilitiesByUnit!.containsKey('single')) {
                unitName = 'All Units';
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeaderSection(),
                    SizedBox(height: 10),
                    if (filteredUtilities.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            if (unitName != null && isMultiUnit)
                              _buildUnitHeader(unitName, selectedUnit?.unitId),
                            _buildHeaders(),
                            SizedBox(height: 10),
                            if (filteredUtilities.isEmpty) kNoSearchResults(context),
                            ...filteredUtilities.asMap().entries.map((entry) {
                              return _buildUtilityRow(
                                  entry.value, entry.key, currentUnitKey);
                            }).toList(),
                          ],
                        ),
                      ),
                    ] else
                      Container(
                        padding: EdgeInsets.all(20),
                        height: MediaQuery.of(context).size.height * .3,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/no_data.jpg",
                                height: 150,
                                width: 150,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "No utilities available",
                                style: TextStyle(
                                  color: grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddUtilityDialog(String? unitId) {
    // Only pass unit information if it's a multi-unit property
    String? unitName;
    String? finalUnitId;

    if (isMultiUnit && unitId != null) {
      finalUnitId = unitId;
      if (selectedUnit != null && selectedUnit!.unitId == unitId) {
        unitName = selectedUnit!.rentalunit ?? unitId;
      } else if (units != null) {
        try {
          unitName = units!
                  .firstWhere(
                    (u) => u.unitId == unitId,
                  )
                  .rentalunit ??
              unitId;
        } catch (e) {
          unitName = unitId;
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Add_Edit_Utility(
          rentalId: widget.rentalId,
          unitId: finalUnitId,
          unitName: unitName,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the data
        setState(() {
          isLoading = true;
          _futureUtilities = fetchUtilitiesData();
        });
      }
    });
  }

  void _showEditDialog(Map<String, dynamic> utility) {
    String? unitId = utility['unit_id']?.toString();
    String? unitName;
    if (unitId != null &&
        selectedUnit != null &&
        selectedUnit!.unitId == unitId) {
      unitName = selectedUnit!.rentalunit ?? unitId;
    } else if (unitId != null && units != null) {
      try {
        unitName = units!
                .firstWhere(
                  (u) => u.unitId == unitId,
                )
                .rentalunit ??
            unitId;
      } catch (e) {
        unitName = unitId;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Add_Edit_Utility(
          rentalId: widget.rentalId,
          unitId: unitId,
          unitName: unitName,
          utilityData: utility,
          utilityId: utility['_id']?.toString(),
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the data
        setState(() {
          isLoading = true;
          _futureUtilities = fetchUtilitiesData();
        });
      }
    });
  }

  void _showDeleteAlert(BuildContext context, String utilityId) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Do you want to delete this utility?",
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            // deleteUtility rethrows on a failed delete, which skipped the
            // pop below and left this dialog stuck — and its barrier is not
            // dismissible, so Cancel was the only way out. The repo has
            // already toasted the reason; close either way.
            try {
              await deleteUtility(utilityId: utilityId);
            } catch (_) {
              // reason already surfaced by deleteUtility
            } finally {
              if (mounted) Navigator.pop(context);
            }
          },
          color: blueColor,
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: blueColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8),
          border: Border.all(
            color: blueColor,
            width: 1.5,
          ),
        ),
      ],
    ).show();
  }

  Future<Map<String, dynamic>> deleteUtility(
      {required String utilityId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        throw Exception('Token or Admin ID not found');
      }

      final Uri uri = Uri.parse('$Api_url/api/utilities/$utilityId');

      final http.Response response = await apiDelete(
        uri,
        headers: <String, String>{
          "authorization": "CRM $token",
          "id": "CRM $adminId",
          'Content-Type': 'application/json',
        },
      );

      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: responseData["message"] ?? "Utility deleted successfully",
            backgroundColor: Colors.green);
        // Refresh the data
        setState(() {
          isLoading = true;
          _futureUtilities = fetchUtilitiesData();
        });
        return responseData;
      } else {
        Fluttertoast.showToast(
            msg: responseData["message"] ?? "Failed to delete utility",
            backgroundColor: Colors.red);
        throw Exception('Failed to delete utility');
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error deleting utility: ${e.toString()}",
          backgroundColor: Colors.red);
      throw Exception('Failed to delete utility: $e');
    }
  }
}
