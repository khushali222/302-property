import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Model/history_item_model.dart';
import '../enums/history_type.dart';
import '../services/history_service.dart';
import '../provider/dateProvider.dart';

class CustomHistoryTable extends StatefulWidget {
  final HistoryType historyType;
  final String entityId;
  final String title;
  final Color blueColor;
  final int itemsPerPage;

  const CustomHistoryTable({
    Key? key,
    required this.historyType,
    required this.entityId,
    this.title = 'History',
    required this.blueColor,
    this.itemsPerPage = 10,
  }) : super(key: key);

  @override
  State<CustomHistoryTable> createState() => _CustomHistoryTableState();
}

class _CustomHistoryTableState extends State<CustomHistoryTable> {
  int _currentPage = 1;
  int? _expandedIndex;
  late Future<HistoryResponse> _historyFuture;
  List<HistoryItem>?
      _allHistoryItems; // Store all items for frontend pagination
  bool _isFrontendPagination = false;

  @override
  void initState() {
    super.initState();
    print(
        '🔵 CustomHistoryTable initState - Type: ${widget.historyType}, EntityId: ${widget.entityId}');
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = HistoryService.fetchHistory(
      historyType: widget.historyType,
      entityId: widget.entityId,
      page: _currentPage,
      limit: widget.itemsPerPage,
    );
    _historyFuture.then((response) {
      print(
          '🔵 History API Response - Status: ${response.pagination.total} items, Page: ${response.pagination.page}');
      print('🔵 History Data Count: ${response.data.length}');

      // For lease history, always use frontend pagination (API returns all data)
      if (widget.historyType == HistoryType.lease) {
        print('🔵 Lease history detected - using frontend pagination');
        setState(() {
          _allHistoryItems = response.data;
          _isFrontendPagination = true;
          print('🔵 Stored ${_allHistoryItems!.length} lease history items');
        });
      } else {
        // For other types, check if data length > limit (frontend pagination)
        // or if pagination info suggests backend pagination
        if (response.data.length > widget.itemsPerPage &&
            response.pagination.totalPages == 1) {
          print(
              '🔵 Frontend pagination detected - data length (${response.data.length}) > limit (${widget.itemsPerPage})');
          setState(() {
            _allHistoryItems = response.data;
            _isFrontendPagination = true;
          });
        } else {
          print('🔵 Backend pagination detected');
          _isFrontendPagination = false;
          _allHistoryItems = null;
        }
      }
    }).catchError((error) {
      print('🔴 History API Error: $error');
    });
  }

  void _refreshHistory() {
    setState(() {
      _loadHistory();
    });
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
      _expandedIndex = null; // Reset expanded row when changing pages

      // For lease history or frontend pagination, we don't need to refresh API
      // The data is already loaded and pagination is handled in build method
      if (widget.historyType == HistoryType.lease ||
          (_isFrontendPagination && _allHistoryItems != null)) {
        // Pagination will be handled in the build method by slicing data
        print('🔵 Page changed to $page - Using frontend pagination');
        return;
      }

      // Backend pagination - refresh API call
      _refreshHistory();
    });
  }

  String _formatDateTimeWithAMPM(String dateTimeString) {
    if (dateTimeString.isEmpty) return '';

    try {
      List<String> dateFormats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd HH:mm',
        'yyyy-MM-dd h:mm:ss a',
        'yyyy-MM-dd h:mm a',
        'yyyy-MM-dd',
        'yyyy-M-d HH:mm:ss',
        'yyyy-M-d HH:mm',
        'MM/dd/yyyy HH:mm:ss',
        'MM/dd/yyyy HH:mm',
        'MM/dd/yyyy h:mm:ss a',
        'MM/dd/yyyy h:mm a',
        'MM/dd/yyyy',
        'dd-MM-yyyy HH:mm:ss',
        'dd-MM-yyyy HH:mm',
        'dd-MM-yyyy h:mm:ss a',
        'dd-MM-yyyy h:mm a',
        'dd-MM-yyyy',
        'M/d/yyyy, h:mm:ss a',
        'M/d/yyyy, h:mm a',
        'yyyy-MM-ddTHH:mm:ss',
        'yyyy-MM-ddTHH:mm:ssZ',
        'yyyy-MM-ddTHH:mm:ss.SSSZ',
      ];

      DateTime? parsedDate;

      for (String format in dateFormats) {
        try {
          parsedDate = DateFormat(format).parse(dateTimeString);
          break;
        } catch (e) {
          continue;
        }
      }

      if (parsedDate == null) {
        return dateTimeString;
      }

      final dateProvider = Provider.of<DateProvider>(context, listen: false);
      String formattedDate = dateProvider
          .formatCurrentDate(DateFormat('yyyy-MM-dd').format(parsedDate));
      String formattedTime = DateFormat('h:mm a').format(parsedDate);

      return '$formattedDate $formattedTime';
    } catch (e) {
      print('Error formatting date: $e');
      return dateTimeString;
    }
  }

  Widget _buildMetadataContent(HistoryItem item) {
    if (item.metadata == null || item.metadata!.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> metadataWidgets = [];

    // Check if metadata has old_values and new_values (for updates)
    if (item.metadata!['old_values'] != null &&
        item.metadata!['new_values'] != null) {
      // Handle update comparison (old → new)
      Map<String, dynamic> oldValues = item.metadata!['old_values'];
      Map<String, dynamic> newValues = item.metadata!['new_values'];

      oldValues.forEach((key, oldValue) {
        // Skip ID fields
        if (_isIdField(key)) return;

        if (newValues.containsKey(key) && oldValue != newValues[key]) {
          metadataWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${_formatKey(key)}: ${_formatValue(oldValue, key: key)} → ${_formatValue(newValues[key], key: key)}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          );
        }
      });

      // Add any new fields that don't exist in old_values
      newValues.forEach((key, newValue) {
        if (_isIdField(key)) return;
        if (!oldValues.containsKey(key) && newValue != null) {
          metadataWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${_formatKey(key)}: ${_formatValue(newValue, key: key)}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          );
        }
      });
    } else {
      // Dynamic metadata display - iterate through all fields
      item.metadata!.forEach((key, value) {
        // Skip ID fields
        if (_isIdField(key)) return;

        // Skip old_values and new_values if they're not maps (already handled above)
        if (key == 'old_values' || key == 'new_values') return;

        if (value != null && value.toString().isNotEmpty) {
          metadataWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildMetadataRow(key, value),
            ),
          );
        }
      });
    }

    if (metadataWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: metadataWidgets,
    );
  }

  /// Check if a field key contains "id" (case-insensitive)
  bool _isIdField(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('_id') ||
        lowerKey == 'id' ||
        lowerKey.endsWith('id') ||
        lowerKey.startsWith('id_');
  }

  /// Build a metadata row widget based on value type
  Widget _buildMetadataRow(String key, dynamic value) {
    if (value is Map) {
      // Handle nested objects - recursively process all fields
      final mapValue = value as Map<String, dynamic>;
      final nestedWidgets = <Widget>[];

      mapValue.forEach((nestedKey, nestedValue) {
        if (_isIdField(nestedKey)) return;
        if (nestedValue == null || nestedValue.toString().isEmpty) return;

        nestedWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildMetadataRow(nestedKey, nestedValue),
          ),
        );
      });

      if (nestedWidgets.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatKey(key)}:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: nestedWidgets,
            ),
          ),
        ],
      );
    } else if (value is List) {
      // Handle arrays
      if (value.isEmpty) return const SizedBox.shrink();

      // Special handling for entries arrays (common in lease history)
      // Also handle payments, charges, and other array types
      if ((key == 'entries' || key == 'payments' || key == 'charges') &&
          value.isNotEmpty &&
          value[0] is Map) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatKey(key)}:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: value.asMap().entries.map((entry) {
                  final entryMap = entry.value as Map<String, dynamic>;
                  final entryWidgets = <Widget>[];

                  entryMap.forEach((entryKey, entryValue) {
                    if (_isIdField(entryKey)) return;
                    if (entryValue == null || entryValue.toString().isEmpty)
                      return;

                    // Recursively handle nested structures
                    if (entryValue is Map || entryValue is List) {
                      entryWidgets.add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _buildMetadataRow(entryKey, entryValue),
                        ),
                      );
                    } else {
                      entryWidgets.add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${_formatKey(entryKey)}: ${_formatValue(entryValue, key: entryKey)}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      );
                    }
                  });

                  if (entryWidgets.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_formatKey(key)} ${entry.key + 1}:',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...entryWidgets,
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }

      // Regular array handling
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatKey(key)}:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: value.asMap().entries.map((entry) {
                if (entry.value is Map) {
                  // If array contains maps, display them nicely
                  final mapValue = entry.value as Map<String, dynamic>;
                  final mapWidgets = <Widget>[];
                  mapValue.forEach((mapKey, mapVal) {
                    if (_isIdField(mapKey)) return;
                    if (mapVal != null && mapVal.toString().isNotEmpty) {
                      mapWidgets.add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${_formatKey(mapKey)}: ${_formatValue(mapVal, key: mapKey)}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      );
                    }
                  });
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• Entry ${entry.key + 1}:',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: mapWidgets,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• ${_formatValue(entry.value, key: key)}',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      // Simple value
      return Text(
        '${_formatKey(key)}: ${_formatValue(value, key: key)}',
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      );
    }
  }

  /// Format a value for display
  String _formatValue(dynamic value, {String? key}) {
    if (value == null) return 'N/A';
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is num) {
      // Format as currency if key suggests it's an amount
      final lowerKey = key?.toLowerCase() ?? '';
      final isAmountField = lowerKey.contains('amount') ||
          lowerKey.contains('price') ||
          lowerKey.contains('cost') ||
          lowerKey.contains('fee') ||
          lowerKey.contains('charge') ||
          lowerKey.contains('payment') ||
          lowerKey.contains('deposit') ||
          lowerKey.contains('rent');

      if (isAmountField && value >= 0) {
        // Format as currency with commas
        final formatted = value.toStringAsFixed(2);
        final parts = formatted.split('.');
        final integerPart = parts[0];
        final decimalPart = parts.length > 1 ? parts[1] : '00';

        // Add commas to integer part
        final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
        final formattedInteger = integerPart.replaceAllMapped(
          regex,
          (Match m) => '${m[1]},',
        );

        return '\$$formattedInteger.$decimalPart';
      }

      // Format regular numbers
      if (value is double && value == value.truncateToDouble()) {
        return value.toInt().toString();
      }
      return value.toString();
    }
    if (value is String) {
      // Check if it's a date string and format it nicely
      if (_looksLikeDate(value)) {
        return _formatDateString(value);
      }
      // Return as-is for strings
      return value;
    }
    return value.toString();
  }

  /// Check if a string looks like a date
  bool _looksLikeDate(String value) {
    // Common date patterns
    final datePatterns = [
      RegExp(r'^\d{4}-\d{2}-\d{2}'), // YYYY-MM-DD
      RegExp(r'^\d{2}/\d{2}/\d{4}'), // MM/DD/YYYY
      RegExp(r'^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}'), // YYYY-MM-DD HH:MM
    ];
    return datePatterns.any((pattern) => pattern.hasMatch(value));
  }

  /// Format a date string for display
  String _formatDateString(String dateStr) {
    try {
      // Try common date formats
      final formats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd',
        'MM/dd/yyyy HH:mm:ss',
        'MM/dd/yyyy',
      ];

      for (var format in formats) {
        try {
          final date = DateFormat(format).parse(dateStr);
          return DateFormat('MM/dd/yyyy HH:mm').format(date);
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // If parsing fails, return original
    }
    return dateStr;
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    print(
        '🔵 CustomHistoryTable build - Type: ${widget.historyType}, EntityId: ${widget.entityId}, Title: ${widget.title}');

    return FutureBuilder<HistoryResponse>(
      future: _historyFuture,
      builder: (context, snapshot) {
        print(
            '🔵 History FutureBuilder - ConnectionState: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, HasError: ${snapshot.hasError}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ History loading...');
          return const SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          print('🔴 History Error: ${snapshot.error}');
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Error loading history: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _refreshHistory();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          print(
              '⚠️ History - No data or empty data. Data count: ${snapshot.hasData ? snapshot.data!.data.length : 0}');
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'No history data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          print(
              '✅ History loaded successfully - ${snapshot.data!.data.length} items');

          // Handle frontend pagination if we have all items stored
          List<HistoryItem> displayData = snapshot.data!.data;
          PaginationInfo pagination = snapshot.data!.pagination;

          // For lease history or frontend pagination, slice the data based on current page
          if (widget.historyType == HistoryType.lease) {
            // Lease history: use stored all items if available, otherwise use snapshot data
            final allItems = _allHistoryItems ?? snapshot.data!.data;
            final startIndex = (_currentPage - 1) * widget.itemsPerPage;
            final endIndex = startIndex + widget.itemsPerPage;

            // Only slice if we have more items than per page
            if (allItems.length > widget.itemsPerPage) {
              displayData = allItems.sublist(
                startIndex,
                endIndex > allItems.length ? allItems.length : endIndex,
              );
            } else {
              displayData = allItems;
            }

            final totalPages = (allItems.length / widget.itemsPerPage).ceil();
            pagination = PaginationInfo(
              total: allItems.length,
              page: _currentPage,
              limit: widget.itemsPerPage,
              totalPages: totalPages > 0 ? totalPages : 1,
            );
            print(
                '🔵 Lease History Pagination - Total: ${allItems.length}, Showing items ${startIndex + 1}-${endIndex > allItems.length ? allItems.length : endIndex}, Page: $_currentPage of $totalPages');
          } else if (_isFrontendPagination &&
              _allHistoryItems != null &&
              _allHistoryItems!.isNotEmpty) {
            // Other frontend pagination - slice the stored data
            final startIndex = (_currentPage - 1) * widget.itemsPerPage;
            final endIndex = startIndex + widget.itemsPerPage;
            displayData = _allHistoryItems!.sublist(
              startIndex,
              endIndex > _allHistoryItems!.length
                  ? _allHistoryItems!.length
                  : endIndex,
            );
            final totalPages =
                (_allHistoryItems!.length / widget.itemsPerPage).ceil();
            pagination = PaginationInfo(
              total: _allHistoryItems!.length,
              page: _currentPage,
              limit: widget.itemsPerPage,
              totalPages: totalPages > 0 ? totalPages : 1,
            );
            print(
                '🔵 Frontend Pagination - Showing items ${startIndex + 1}-${endIndex > _allHistoryItems!.length ? _allHistoryItems!.length : endIndex} of ${_allHistoryItems!.length}');
          }

          final historyData =
              HistoryResponse(data: displayData, pagination: pagination);
          final finalPagination = pagination;

          return RepaintBoundary(
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 2),
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Header
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDBE0E5)),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () {},
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    width < 400
                                        ? "Date & Time"
                                        : "     Date & Time",
                                    style: TextStyle(
                                      color: widget.blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () {},
                            child: Row(
                              children: [
                                Text(
                                  "     User",
                                  style: TextStyle(
                                    color: widget.blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Data Rows
                Container(
                  child: Column(
                    children: historyData.data.asMap().entries.map((entry) {
                      int index = entry.key;
                      HistoryItem historyItem = entry.value;
                      bool isExpandedLocal = _expandedIndex == index;
                      String formattedDate =
                          _formatDateTimeWithAMPM(historyItem.date);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: index % 2 != 0
                              ? const Color(0xFFF4F8FF)
                              : Colors.white,
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
                                          if (_expandedIndex == index) {
                                            _expandedIndex = null;
                                          } else {
                                            _expandedIndex = index;
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        padding: !isExpandedLocal
                                            ? const EdgeInsets.only(bottom: 10)
                                            : const EdgeInsets.only(top: 10),
                                        child: FaIcon(
                                          isExpandedLocal
                                              ? FontAwesomeIcons.sortUp
                                              : FontAwesomeIcons.sortDown,
                                          size: 20,
                                          color: widget.blueColor,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (_expandedIndex == index) {
                                              _expandedIndex = null;
                                            } else {
                                              _expandedIndex = index;
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            formattedDate,
                                            style: TextStyle(
                                              color: widget.blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        historyItem.username,
                                        style: TextStyle(
                                          color: widget.blueColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpandedLocal)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                margin: const EdgeInsets.only(bottom: 20),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          FaIcon(
                                            isExpandedLocal
                                                ? FontAwesomeIcons.sortUp
                                                : FontAwesomeIcons.sortDown,
                                            size: 20,
                                            color: Colors.transparent,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                // Description
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Description : ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              widget.blueColor,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: historyItem
                                                            .description,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (historyItem.type
                                                        .toString()
                                                        .isNotEmpty ||
                                                    (historyItem.metadata !=
                                                            null &&
                                                        historyItem.metadata!
                                                            .isNotEmpty))
                                                  const SizedBox(height: 10),
                                                if (historyItem.type
                                                    .toString()
                                                    .isNotEmpty) ...[
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Type : ',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: widget
                                                                .blueColor,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              historyItem.type,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (historyItem.metadata !=
                                                          null &&
                                                      historyItem
                                                          .metadata!.isNotEmpty)
                                                    const SizedBox(height: 8),
                                                ],
                                                if (historyItem.metadata !=
                                                        null &&
                                                    historyItem.metadata!
                                                        .isNotEmpty) ...[
                                                  const Text(
                                                    'Details:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 20),
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          12, 12, 12, 16),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey[300]!),
                                                      ),
                                                      child:
                                                          _buildMetadataContent(
                                                              historyItem),
                                                    ),
                                                  ),
                                                ],
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
                // Pagination Controls
                if (finalPagination.totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.circleChevronLeft,
                            size: 30,
                            color: _currentPage <= 1
                                ? Colors.grey
                                : widget.blueColor,
                          ),
                          onPressed: _currentPage <= 1
                              ? null
                              : () {
                                  _goToPage(_currentPage - 1);
                                },
                        ),
                        Text(
                          'Page ${finalPagination.page} of ${finalPagination.totalPages}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.circleChevronRight,
                            size: 30,
                            color: _currentPage >= finalPagination.totalPages
                                ? Colors.grey
                                : widget.blueColor,
                          ),
                          onPressed: _currentPage >= finalPagination.totalPages
                              ? null
                              : () {
                                  _goToPage(_currentPage + 1);
                                },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}
