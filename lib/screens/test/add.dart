import 'package:flutter/material.dart';

import '../../Model/propertytype.dart';
import '../../repository/Property_type.dart';



class PropertyForm extends StatefulWidget {
  @override
  _PropertyFormState createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  String? selectedPropertyType;
  List<List<Widget>> propertyGroups = [];



  Future<List<propertytype>>? futureProperties;
  String? selectedProperty;
  @override
  void initState() {
    super.initState();
    // Initialize with one group
    futureProperties = PropertyTypeRepository().fetchPropertyTypes();

    addPropertyGroup();
  }

  void addPropertyGroup() {
    List<Widget> fields = [];

    if (selectedPropertyType == 'Residential') {
      fields = [
        TextFormField(
          decoration: InputDecoration(labelText: 'SQft'),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Bed'),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Room'),
        ),
      ];
    } else if (selectedPropertyType == 'Commercial') {
      fields = [
        TextFormField(
          decoration: InputDecoration(labelText: 'SQft'),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Unit'),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Unit Address'),
        ),

      ];
    }
    else if (selectedPropertyType == 'Commercial') {
      fields = [
        TextFormField(
          decoration: InputDecoration(labelText: 'SQft'),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Unit'),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Unit Address'),
        ),

      ];
    }
    else if (selectedPropertyType == 'Commercial') {
      fields = [
        TextFormField(
          decoration: InputDecoration(labelText: 'SQft'),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Unit'),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Unit Address'),
        ),

      ];
    }

    setState(() {
      propertyGroups.add(fields);
    });
  }

  void removePropertyGroup(int index) {
    setState(() {
      propertyGroups.removeAt(index);
    });
  }

  Map<String, List<propertytype>> groupPropertiesByType(
      List<propertytype> properties) {
    Map<String, List<propertytype>> groupedProperties = {};
    for (var property in properties) {
      if (!groupedProperties.containsKey(property.propertyType)) {
        groupedProperties[property.propertyType!] = [];
      }
      groupedProperties[property.propertyType!]!.add(property);
    }
    return groupedProperties;
  }
  String? selectedSubProperty;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedPropertyType,
              hint: Text('Select Property Type'),
              items: <String>['Residential', 'Commercial']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPropertyType = newValue;
                  propertyGroups = [];
                  addPropertyGroup();
                });
              },
            ),
            // FutureBuilder<List<propertytype>>(
            //   future: futureProperties,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState ==
            //         ConnectionState.waiting) {
            //       return CircularProgressIndicator();
            //     } else if (snapshot.hasError) {
            //       return Text('Error: ${snapshot.error}');
            //     } else if (!snapshot.hasData ||
            //         snapshot.data!.isEmpty) {
            //       return Text('No properties found');
            //     } else {
            //       Map<String, List<propertytype>>
            //       groupedProperties =
            //       groupPropertiesByType(snapshot.data!);
            //       return Padding(
            //         padding: const EdgeInsets.all(10.0),
            //         child: Container(
            //           height:
            //           MediaQuery.of(context).size.height *
            //               .05,
            //           width:
            //           MediaQuery.of(context).size.width *
            //               .36,
            //           padding: EdgeInsets.symmetric(
            //               horizontal: 8, vertical: 4),
            //           decoration: BoxDecoration(
            //             border:
            //             Border.all(color: Color(0xFF8A95A8),),
            //             borderRadius:
            //             BorderRadius.circular(5),
            //           ),
            //           child:
            //           DropdownButtonHideUnderline(
            //             child:
            //             DropdownButton<String>(
            //               value: selectedPropertyType,
            //               hint: Text('Select Property Type'),
            //               items: [
            //                 ...groupedProperties.entries
            //                     .expand((entry) {
            //                   return [
            //                     DropdownMenuItem<String>(
            //                       enabled: false,
            //                       child: Text(
            //                         entry.key,
            //                         style: TextStyle(
            //                             fontWeight:
            //                             FontWeight.bold, color: Color.fromRGBO(21, 43, 81, 1)),
            //                       ),
            //                     ),
            //                     ...entry.value.map((item) {
            //                       return DropdownMenuItem<
            //                           String>(
            //                         value:
            //                         item.propertysubType,
            //                         child: Padding(
            //                           padding:
            //                           const EdgeInsets
            //                               .only(
            //                               left: 16.0),
            //                           child: Text(
            //                             item.propertysubType ??
            //                                 '',style:TextStyle(
            //                             color: Colors.black,
            //                             fontWeight: FontWeight.w400,
            //                           ),),
            //                         ),
            //
            //                       );
            //                     }).toList(),
            //                   ];
            //                 }).toList(),
            //                 DropdownMenuItem<String>(
            //                   value: 'add_new_property',
            //                   child: Row(
            //                     children: [
            //                       Icon(Icons.add,
            //                           size:
            //                           15), // Adjusted icon size
            //                       SizedBox(width: 6),
            //                       Text('Add New properties',
            //                           style: TextStyle(
            //                               fontSize:
            //                               MediaQuery.of(context).size.width * .03)), // Adjusted text size
            //                     ],
            //                   ),
            //                 ),
            //               ],
            //               onChanged: (String? newValue) {
            //                 setState(() {
            //                   selectedPropertyType = newValue;
            //                   propertyGroups = [];
            //                   addPropertyGroup();
            //                 });
            //               },
            //             ),
            //           ),
            //         ),
            //       );
            //     }
            //   },
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: propertyGroups.length,
                itemBuilder: (context, index) {
                  print(propertyGroups);
                  return Column(
                    children: [
                      ...propertyGroups[index],
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => removePropertyGroup(index),
                        child: Text('Remove'),
                      ),
                      Divider(),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedPropertyType != null) {
                            addPropertyGroup();
                          }
                        },
                        child: Text('Add More'),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (selectedPropertyType != null) {
                  addPropertyGroup();
                }
              },
              child: Text('Add More'),
            ),
          ],
        ),
      ),
    );
  }
}






