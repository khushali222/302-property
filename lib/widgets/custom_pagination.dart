import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final Function(int) onItemsPerPageChanged;
  final Color blueColor;

  const CustomPagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
    required this.blueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("Rows per page: "),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: itemsPerPage,
              items: [5, 10, 20].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onItemsPerPageChanged(value);
                }
              },
              icon: Icon(Icons.arrow_drop_down, size: 40),
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
            color: currentPage == 0 ? Colors.grey : blueColor,
          ),
          onPressed:
              currentPage == 0 ? null : () => onPageChanged(currentPage - 1),
        ),
        Text(
          'Page ${currentPage + 1} of $totalPages',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronRight,
            size: 30,
            color: currentPage >= totalPages - 1 ? Colors.grey : blueColor,
          ),
          onPressed: currentPage >= totalPages - 1
              ? null
              : () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }
}
