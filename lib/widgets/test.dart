import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Add Rental Owner'),
        ),
        body: RentalOwnerTable(),
      ),
    );
  }
}

class RentalOwnerTable extends StatefulWidget {
  @override
  _RentalOwnerTableState createState() => _RentalOwnerTableState();
}

class _RentalOwnerTableState extends State<RentalOwnerTable> {
  List<RentalOwner> owners = [
    RentalOwner(name: 'Michal Patrick', id: '23456789', processorIds: ['ccprocessora', 'ccprocessorb']),
    RentalOwner(name: 'Erik Ohline', id: '3023790401', processorIds: []),
    RentalOwner(name: 'Brian Raboin', id: '15551234567', processorIds: []),
    RentalOwner(name: 'NDG 302 LLC', id: '4596235689', processorIds: []),
  ];

  late List<RentalOwner> filteredOwners;
  late List<bool> selected;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredOwners = owners;
    selected = List<bool>.generate(owners.length, (index) => false);
    searchController.addListener(_filterOwners);
  }

  void _filterOwners() {
    setState(() {
      filteredOwners = owners
          .where((owner) =>
      owner.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
          owner.id.contains(searchController.text))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: (value) {},
                ),
                Text('Choose an existing rental owner'),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by first and last name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  border: TableBorder.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  columns: [
                    DataColumn(label: Text('RentalOwner Name')),
                    DataColumn(label: Text('Processor ID')),
                    DataColumn(label: Text('Select')),
                  ],
                  rows: List<DataRow>.generate(
                    filteredOwners.length,
                        (index) => DataRow(
                      cells: [
                        DataCell(Text('${filteredOwners[index].name} (${filteredOwners[index].id})')),
                        DataCell(Text(filteredOwners[index].processorIds.join('\n'))),
                        DataCell(
                          Checkbox(
                            value: selected[owners.indexOf(filteredOwners[index])],
                            onChanged: (bool? value) {
                              setState(() {
                                selected[owners.indexOf(filteredOwners[index])] = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add your add logic here
                  },
                  child: Text('Add'),
                ),
                SizedBox(width: 8.0),
                OutlinedButton(
                  onPressed: () {
                    // Add your cancel logic here
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RentalOwner {
  final String name;
  final String id;
  final List<String> processorIds;

  RentalOwner({
    required this.name,
    required this.id,
    required this.processorIds,
  });
}

// import 'package:flutter/material.dart';
//
//
//
// class MyHomePage extends StatefulWidget {
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Data Table with Scrollbar'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             TextField(
//               decoration: InputDecoration(
//                 labelText: 'Search here...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 8.0),
//             DropdownButton<String>(
//               hint: Text('Type'),
//               items: <String>['Residential', 'Commercial', 'All']
//                   .map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (_) {},
//             ),
//             SizedBox(height: 8.0),
//             Expanded(
//               child: Scrollbar(
//                 thumbVisibility: true,
//                 thickness: 10,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.vertical,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: DataTable(
//                       columns: <DataColumn>[
//                         DataColumn(
//                           label: Text('Property'),
//                         ),
//                         DataColumn(
//                           label: Text('Property Type'),
//                         ),
//                         DataColumn(
//                           label: Text('Subtypes'),
//                         ),
//                         DataColumn(
//                           label: Text('Rental Owner Name'),
//                         ),
//                       ],
//                       rows: List<DataRow>.generate(
//                         100,
//                             (index) => DataRow(
//                           cells: <DataCell>[
//                             DataCell(Text('Property $index')),
//                             DataCell(Text(index % 2 == 0 ? 'Commercial' : 'Residential')),
//                             DataCell(Text('Subtype ${index % 3}')),
//                             DataCell(Text('Owner $index')),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
