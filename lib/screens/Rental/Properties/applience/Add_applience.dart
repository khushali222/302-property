import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Added for json.encode

import '../../../../Model/All_categories_model.dart';
import '../../../../constant/constant.dart';
import '../../../../widgets/appbar.dart';
import '../../../../widgets/custom_drawer.dart';
import '../summery_page.dart';
import '../../../../Model/All_categories_model.dart';
import '../../../../constant/constant.dart';
import '../../../../model/properties.dart';
import '../../../../model/unitsummery_propeties.dart';
import '../../../../provider/dateProvider.dart';
import '../../../../repository/fetch_allcategories.dart';
import '../../../../repository/properties_summery.dart';
import '../../../../repository/unit_data.dart';
import '../../../../Model/unit.dart';

class AddApplience extends StatefulWidget {
  Rentals? properties;
  unit_properties? unit;
  AddApplience({
    this.unit,
    this.properties,
  });

  @override
  State<AddApplience> createState() => _AddApplienceState();
}

class _AddApplienceState extends State<AddApplience> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _installedDate = TextEditingController();

  TextEditingController _type = TextEditingController();
  TextEditingController _model = TextEditingController();
  TextEditingController _serialNumber = TextEditingController();

  TextEditingController _warrantyExpiry = TextEditingController();
  TextEditingController _lastMaintenanceDate = TextEditingController();
  TextEditingController _maintenanceNotes = TextEditingController();

  final UnitData leaseRepository = UnitData();
  List<unit_appliance> leases = [];
  late Future<List<unit_appliance>> futureAppliences;
  Future<void> fetchLeases() async {
    //  try {
    final fetchedLeases =
        await leaseRepository.fetchApplianceData(widget.unit!.unitId!);
    print(widget.unit!.unitId!);
    print('hello');
    setState(() {
      print(widget.unit!.unitId!);
      print('hello');
      leases = fetchedLeases;
      isLoading = false;
    });
    //} catch (e) {
    setState(() {
      isLoading = false;
    });
    //print('Failed to load leases: $e');
    //}
  }

  reload_screen() {
    setState(() {
      futureAppliences =
          UnitData().fetchApplianceData(widget.unit?.unitId ?? "");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDropdownCategories();
    fetchLeases();
    futureAppliences = UnitData().fetchApplianceData(widget.unit?.unitId ?? "");
  }

  Future<void> _loadDropdownCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final cats = await FetchAllcategories().fetchAllCategories();
      print('Fetched categories in AddWorkOrderForMobile: ' + cats.toString());
      setState(() {
        _dropdownCategories = cats;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error fetching categories in AddWorkOrderForMobile: ' +
          e.toString());
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  bool isLoading = false;
  bool iserror = false;
  List<allcategories_model> _dropdownCategories = [];
  allcategories_model? _selectedDropdownCategory;
  bool _isLoadingCategories = false;

  List<String> brandList = [
    'Amana',
    'Badger',
    'Bosch',
    'Carrier',
    'Daikin',
    'Frigidaire',
    'GE',
    'Goodman',
    'InSinkErator',
    'KitchenAid',
    'Lennox',
    'LG',
    'Maytag',
    'Mitsubishi Electric',
    'Moen',
    'Rheem',
    'Samsung',
    'Trane',
    'Waste King',
    'Whirlpool',
    'York',
    'Other',
  ];
  List<String> statusList = ['Working', 'Needs Repair', "Out of Service"];

  String? _selectedBrand;
  String? _selectedStatus;
  // Add these to your state class
  List<Map<String, TextEditingController>> filterControllers = [];
  bool showFilters = false;

// Add this method to handle adding new filter
  void addNewFilter() {
    setState(() {
      filterControllers.add({
        'name': TextEditingController(),
        'size': TextEditingController(),
      });
    });
  }

// Add this method to remove filter
  void removeFilter(int index) {
    setState(() {
      filterControllers[index]['name']?.dispose();
      filterControllers[index]['size']?.dispose();
      filterControllers.removeAt(index);
    });
  }

  bool showFiltersSection = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Properties",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: 800,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                      height: 50.0,
                      padding: EdgeInsets.only(top: 10, left: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: blueColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Text(
                        "Add Home Systems",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CustomTextFormField(
                    labelText: '',
                    hintText: 'Enter Name',
                    controller: _name,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CustomTextFormField(
                    labelText: '',
                    hintText: 'Enter description',
                    controller: _description,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 4),
                  //categories dropdwoun
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<allcategories_model>(
                        isExpanded: true,
                        hint: Text(_isLoadingCategories
                            ? 'Loading categories...'
                            : 'Select Category'),
                        value: _dropdownCategories
                                .contains(_selectedDropdownCategory)
                            ? _selectedDropdownCategory
                            : null,
                        items: _dropdownCategories.map((cat) {
                          return DropdownMenuItem<allcategories_model>(
                            value: cat,
                            child: Text(cat.name ?? ''),
                          );
                        }).toList(),
                        // onChanged: _isLoadingCategories
                        //     ? null // disables dropdown while loading
                        //     : (allcategories_model? newValue) {
                        //   setState(() {
                        //     _selectedDropdownCategory = newValue;
                        //     // _showTextField =
                        //     //     newValue?.name == 'Other';
                        //   });
                        // },
                        onChanged: _isLoadingCategories
                            ? null // disables dropdown while loading
                            : (allcategories_model? newValue) {
                                setState(() {
                                  _selectedDropdownCategory = newValue;
                                  // Don't show filters section immediately for HVAC
                                  showFiltersSection = false;
                                  // Clear any existing filters
                                  for (var controllers in filterControllers) {
                                    controllers['name']?.dispose();
                                    controllers['size']?.dispose();
                                  }
                                  filterControllers.clear();
                                });
                              },
                        buttonStyleData: ButtonStyleData(
                          height: 45,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                          elevation: 2,
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          iconEnabledColor: Color(0xFFb0b6c3),
                          iconDisabledColor: Colors.grey,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(6),
                            thickness: MaterialStateProperty.all(6),
                            thumbVisibility: MaterialStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 50,
                          padding: EdgeInsets.only(left: 14, right: 14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CustomTextFormField(
                    labelText: '',
                    hintText: 'Enter type',
                    controller: _type,
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Brand',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Text('Select Brand'),
                        value: brandList.contains(_selectedBrand)
                            ? _selectedBrand
                            : null,
                        items: brandList.map((brand) {
                          return DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedBrand = newValue;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                          elevation: 2,
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          iconEnabledColor: Color(0xFFb0b6c3),
                          iconDisabledColor: Colors.grey,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(6),
                            thickness: MaterialStateProperty.all(6),
                            thumbVisibility: MaterialStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Model',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CustomTextFormField(
                    labelText: '',
                    hintText: 'Enter model',
                    controller: _model,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Serial Number',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CustomTextFormField(
                    labelText: '',
                    hintText: 'Enter serial number',
                    controller: _serialNumber,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Installed Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  dateField(
                      'Installed Date', _installedDate, context, setState),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Warranty Expiry',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  dateField(
                      'Warranty Expiry', _warrantyExpiry, context, setState),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Last Maintenance Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  dateField('Last Maintenance Date', _lastMaintenanceDate,
                      context, setState),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Text('Select Status'),
                        value: statusList.contains(_selectedStatus)
                            ? _selectedStatus
                            : null,
                        items: statusList.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                          elevation: 2,
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          iconEnabledColor: Color(0xFFb0b6c3),
                          iconDisabledColor: Colors.grey,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(6),
                            thickness: MaterialStateProperty.all(6),
                            thumbVisibility: MaterialStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Maintenance Notes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CustomTextFormField(
                    labelText: '',
                    hintText: 'Enter notes',
                    controller: _maintenanceNotes,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  // Add this after your Status dropdown
                  if (_selectedDropdownCategory?.name == 'HVAC') ...[
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showFiltersSection = true;
                              // Always add a new filter when button is clicked
                              filterControllers.add({
                                'name': TextEditingController(),
                                'size': TextEditingController(),
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Add Filter',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    Text(
                      'Optional: Add filters for HVAC systems',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (showFiltersSection) ...[
                      ...filterControllers.asMap().entries.map((entry) {
                        int index = entry.key;
                        var controllers = entry.value;
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Filter ${index + 1}'),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        removeFilter(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              CustomTextFormField(
                                labelText: '',
                                hintText: 'Filter Name',
                                controller: controllers['name']!,
                                keyboardType: TextInputType.text,
                              ),
                              SizedBox(height: 8),
                              CustomTextFormField(
                                labelText: '',
                                hintText: 'Filter Size (e.g., 16x20x1)',
                                controller: controllers['size']!,
                                keyboardType: TextInputType.text,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ]
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (_name.text.isEmpty ||
                                _description.text.isEmpty ||
                                _installedDate.text.isEmpty ||
                                _selectedDropdownCategory ==
                                    null || // Add validation for required fields
                                _selectedStatus == null ||
                                _selectedBrand == null) {
                              setState(() => iserror = true);
                            } else {
                              setState(() {
                                isLoading = true;
                                iserror = false;
                              });

                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? id = prefs.getString("adminId");

                              // Create a single filters list
                              List<Map<String, dynamic>> filters = [];

                              if (_selectedDropdownCategory?.name == 'HVAC' &&
                                  showFiltersSection) {
                                print('Creating filters for HVAC appliance');
                                for (int i = 0;
                                    i < filterControllers.length;
                                    i++) {
                                  final controller = filterControllers[i];
                                  final filterName =
                                      controller['name']?.text.trim() ?? '';
                                  final filterSize =
                                      controller['size']?.text.trim() ?? '';

                                  print('Processing Filter ${i + 1}:');
                                  print('  Name: $filterName');
                                  print('  Size: $filterSize');

                                  // Only add filter if either name or size is not empty
                                  if (filterName.isNotEmpty ||
                                      filterSize.isNotEmpty) {
                                    final uniqueId = DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString();
                                    final filterData = {
                                      "filter_id":
                                          uniqueId, // Add back the filter_id
                                      "filter_name": filterName,
                                      "filter_size": filterSize,
                                    };
                                    filters.add(filterData);
                                    print('Added filter to list: $filterData');

                                    // Add a small delay to ensure unique timestamps for filter_ids
                                    await Future.delayed(
                                        Duration(milliseconds: 2));
                                  }
                                }

                                print(
                                    'Final filters list before API call: ${json.encode(filters)}');
                              }

                              try {
                                // Prepare the API data
                                final Map<String, dynamic> apiData = {
                                  'admin_id': id,
                                  'unit_id': widget.unit?.unitId,
                                  'appliance_name': _name.text,
                                  'appliance_description': _description.text,
                                  'installed_date': _installedDate.text,
                                  'type': _type.text,
                                  'brand': _selectedBrand,
                                  'model': _model.text,
                                  'serial_number': _serialNumber.text,
                                  'warranty_expiry':
                                      _warrantyExpiry.text.isNotEmpty
                                          ? _warrantyExpiry.text
                                          : null,
                                  'last_maintenance_date':
                                      _lastMaintenanceDate.text.isNotEmpty
                                          ? _lastMaintenanceDate.text
                                          : null,
                                  'maintenance_notes': _maintenanceNotes.text,
                                  'status': _selectedStatus,
                                  'category_id':
                                      _selectedDropdownCategory?.categoryId ??
                                          "",
                                  'filters':
                                      filters, // The filters now include filter_id
                                };

                                print(
                                    'Sending API data: ${json.encode(apiData)}');

                                final response = await Properies_summery_Repo()
                                    .addappliances(
                                  adminId: id,
                                  unitId: widget.unit?.unitId,
                                  appliancename: _name.text,
                                  appliancedescription: _description.text,
                                  installeddate: _installedDate.text,
                                  type: _type.text,
                                  brand: _selectedBrand,
                                  model: _model.text,
                                  serialNumber: _serialNumber.text,
                                  warrantyExpiry:
                                      _warrantyExpiry.text.isNotEmpty
                                          ? _warrantyExpiry.text
                                          : null,
                                  lastMaintenanceDate:
                                      _lastMaintenanceDate.text.isNotEmpty
                                          ? _lastMaintenanceDate.text
                                          : null,
                                  maintenanceNotes: _maintenanceNotes.text,
                                  status: _selectedStatus,
                                  categoryId:
                                      _selectedDropdownCategory?.categoryId ??
                                          "",
                                  filters: filters.isNotEmpty ? filters : [],
                                );

                                print('API Response: $response');

                                setState(() {
                                  isLoading = false;
                                  leases.add(unit_appliance(
                                    applianceName: _name.text,
                                    applianceDescription: _description.text,
                                    installedDate: _installedDate.text,
                                    adminId: id,
                                    unitId: widget.unit?.unitId,
                                    type: _type.text,
                                    brand: _selectedBrand,
                                    model: _model.text,
                                    serialNumber: _serialNumber.text,
                                    warrantyExpiry: _warrantyExpiry.text,
                                    lastMaintenanceDate:
                                        _lastMaintenanceDate.text,
                                    maintenanceNotes: _maintenanceNotes.text,
                                    status: _selectedStatus,
                                    categoryId:
                                        _selectedDropdownCategory?.categoryId,
                                    filters: filters,
                                  ));
                                });

                                reload_screen();
                                Navigator.pop(context, true);
                              } catch (e) {
                                print('Error adding appliance: $e');
                                setState(() => isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to add appliance: ${e.toString()}')),
                                );
                              }
                            }
                          },
                          child: const Text('Save',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                  if (iserror)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Please fill in all fields correctly.",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dateField(String label, TextEditingController controller,
      BuildContext context, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: blueColor,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        ).then((date) {
          if (date != null) {
            setState(() {
              controller.text = formatDate(date.toString());
            });
          }
        });
      },
      child: AbsorbPointer(
        child: CustomTextFormField(
          labelText: label,
          hintText: 'Select $label',
          controller: controller,
          keyboardType: TextInputType.datetime,
          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: TextFormField(
          focusNode: _focusNode,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            // labelText: widget.labelText,
            hintText: widget.hintText,
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}
