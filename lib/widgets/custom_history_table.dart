import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../Model/history_item_model.dart';
import '../enums/history_type.dart';
import '../services/history_service.dart';

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

      // Format to match web format: MM/dd/yyyy HH:mm:ss
      // Example: "12/22/2025 10:24:58"
      String formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);
      String formattedTime = DateFormat('HH:mm:ss').format(parsedDate);

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

  /// Parse description into structured format for better display
  List<String> _parseDescription(String description) {
    if (description.isEmpty) return [];

    // Clean HTML entities
    String cleanDescription = description
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();

    List<String> details = [];

    // Pattern 0: Special handling for Body preview - extract it first to prevent nested parsing
    // Find "Body preview:" and extract everything after it as a single value
    final bodyPreviewMatch =
        RegExp(r'Body preview:\s*(.+)$', caseSensitive: false, dotAll: true)
            .firstMatch(cleanDescription);
    String bodyPreviewValue = '';
    String descriptionWithoutBodyPreview = cleanDescription;

    if (bodyPreviewMatch != null) {
      bodyPreviewValue = bodyPreviewMatch.group(1)?.trim() ?? '';
      // Remove body preview from description for parsing other fields
      descriptionWithoutBodyPreview =
          cleanDescription.substring(0, bodyPreviewMatch.start).trim();
    }

    // Pattern 0.5: For lease history, show full description as-is without parsing
    // This MUST come before other patterns to prevent parsing
    // User wants to see the complete description text exactly as it comes from API
    if (widget.historyType == HistoryType.lease) {
      // Return the full description as a single item, only add body preview if exists
      List<String> details = [];
      details.add(descriptionWithoutBodyPreview);

      // Add body preview at the end if it exists
      if (bodyPreviewValue.isNotEmpty) {
        bodyPreviewValue = bodyPreviewValue.replaceAll(RegExp(r'<[^>]+>'), '');
        bodyPreviewValue = bodyPreviewValue.replaceAll('**', '');
        bodyPreviewValue = bodyPreviewValue.replaceAll('&nbsp;', ' ');
        details.add('Body preview: $bodyPreviewValue');
      }

      return details;
    }

    // Pattern 1: Check for "Changes:" which indicates field changes
    final changesIndex = descriptionWithoutBodyPreview.indexOf('Changes:');
    if (changesIndex != -1) {
      final header =
          descriptionWithoutBodyPreview.substring(0, changesIndex).trim();
      final changesText = descriptionWithoutBodyPreview
          .substring(changesIndex + 'Changes:'.length)
          .trim();

      if (header.isNotEmpty) {
        details.add(header);
      }

      // Split changes by semicolon or comma, but be smart about it
      final changes = _smartSplit(changesText, [';', ',']);
      details.addAll(changes);

      // Add body preview at the end if it exists
      if (bodyPreviewValue.isNotEmpty) {
        bodyPreviewValue = bodyPreviewValue.replaceAll(RegExp(r'<[^>]+>'), '');
        bodyPreviewValue = bodyPreviewValue.replaceAll('**', '');
        bodyPreviewValue = bodyPreviewValue.replaceAll('&nbsp;', ' ');
        details.add('Body preview: $bodyPreviewValue');
      }

      return details;
    }

    // Pattern 1.5: Check for Utility Added/Deleted patterns BEFORE other patterns
    // Format: "Utility Added (Unit X): utilityname (Provider: X, Account: Y)" or
    //         "Utility Deleted (Unit X): utilityname (Provider: X, Account: Y)"
    // Only check if it STARTS with "Utility Added" or "Utility Deleted" to avoid false matches
    final lowerDesc = descriptionWithoutBodyPreview.toLowerCase().trim();
    if (lowerDesc.startsWith('utility added') ||
        lowerDesc.startsWith('utility deleted')) {
      // More flexible pattern to handle variations
      final utilityActionPattern = RegExp(
          r'Utility\s+(Added|Deleted)\s*\(([^)]+)\):\s*(.+?)(?:\s*\(([^)]+)\))?\s*$',
          caseSensitive: false,
          dotAll: true);
      final utilityActionMatch =
          utilityActionPattern.firstMatch(descriptionWithoutBodyPreview);

      if (utilityActionMatch != null) {
        final action =
            utilityActionMatch.group(1)?.trim() ?? ''; // Added or Deleted
        var unit = utilityActionMatch.group(2)?.trim() ?? '';
        var utilityName = utilityActionMatch.group(3)?.trim() ?? '';
        var detailsStr = utilityActionMatch.group(4)?.trim() ??
            ''; // "Provider: X, Account: Y"

        // Clean up unit - remove duplicate "Unit" if present (e.g., "Unit Unit t1022" -> "t1022")
        if (unit.toLowerCase().startsWith('unit ')) {
          unit = unit.substring(5).trim();
        }

        // Check if utilityName contains key-value pairs (format: "Utility Name: testsd, Provider: ...")
        // This happens when details are not in parentheses but comma-separated after colon
        if (utilityName.contains(':') && utilityName.contains(',')) {
          // Extract utility name from first part
          final firstColon = utilityName.indexOf(':');
          if (firstColon > 0) {
            final utilityNameValue =
                utilityName.substring(firstColon + 1).trim();

            // Get the value before first comma
            final firstComma = utilityNameValue.indexOf(',');
            final actualUtilityName = firstComma > 0
                ? utilityNameValue.substring(0, firstComma).trim()
                : utilityNameValue.trim();

            // Build header
            final header = 'Utility $action (Unit $unit): $actualUtilityName';
            details.add(header);

            // Parse remaining details (everything after first comma)
            if (firstComma > 0) {
              final remainingDetails =
                  utilityNameValue.substring(firstComma + 1).trim();
              if (remainingDetails.isNotEmpty) {
                final detailParts = _smartSplit(remainingDetails, [',']);
                for (var part in detailParts) {
                  part = part.trim();
                  if (part.isNotEmpty) {
                    final colonIdx = part.indexOf(':');
                    if (colonIdx > 0 && colonIdx < part.length - 1) {
                      final key = part.substring(0, colonIdx).trim();
                      final value = part.substring(colonIdx + 1).trim();
                      if (key.isNotEmpty && value.isNotEmpty) {
                        details.add('$key: $value');
                      }
                    }
                  }
                }
              }
            }
          }
        } else {
          // Clean up utility name - remove trailing parentheses if any
          utilityName =
              utilityName.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '').trim();

          // Build header
          final header = 'Utility $action (Unit $unit): $utilityName';
          details.add(header);

          // Parse details from parentheses if they exist
          if (detailsStr.isNotEmpty) {
            // Split by comma, but be smart about it
            final detailParts = _smartSplit(detailsStr, [',']);
            for (var part in detailParts) {
              part = part.trim();
              if (part.isNotEmpty) {
                // Check if it's a key-value pair
                final colonIdx = part.indexOf(':');
                if (colonIdx > 0 && colonIdx < part.length - 1) {
                  final key = part.substring(0, colonIdx).trim();
                  final value = part.substring(colonIdx + 1).trim();
                  if (key.isNotEmpty && value.isNotEmpty) {
                    details.add('$key: $value');
                  }
                } else {
                  details.add(part);
                }
              }
            }
          }
        }

        // Add body preview at the end if it exists
        if (bodyPreviewValue.isNotEmpty) {
          bodyPreviewValue =
              bodyPreviewValue.replaceAll(RegExp(r'<[^>]+>'), '');
          bodyPreviewValue = bodyPreviewValue.replaceAll('**', '');
          bodyPreviewValue = bodyPreviewValue.replaceAll('&nbsp;', ' ');
          details.add('Body preview: $bodyPreviewValue');
        }

        return details;
      }

      // Fallback: Try manual parsing if regex doesn't match
      final lowerDesc = descriptionWithoutBodyPreview.toLowerCase();
      final isAdded = lowerDesc.startsWith('utility added');
      final action = isAdded ? 'Added' : 'Deleted';

      // Extract unit from parentheses: "Utility X (Unit Y): ..."
      final unitMatch = RegExp(r'\(Unit\s+([^)]+)\)', caseSensitive: false)
          .firstMatch(descriptionWithoutBodyPreview);
      final unit = unitMatch?.group(1)?.trim() ?? '';

      // Extract utility name - everything after ": " until next "(" or end
      final colonIndex = descriptionWithoutBodyPreview.indexOf(':');
      if (colonIndex > 0) {
        var utilityName =
            descriptionWithoutBodyPreview.substring(colonIndex + 1).trim();

        // Extract details from last parentheses if exists
        final lastParenMatch = RegExp(r'\(([^)]+)\)\s*$')
            .firstMatch(descriptionWithoutBodyPreview);
        String? detailsStr;

        if (lastParenMatch != null) {
          detailsStr = lastParenMatch.group(1)?.trim();
          // Remove details part from utility name
          final detailsStart = descriptionWithoutBodyPreview.lastIndexOf('(');
          if (detailsStart > colonIndex) {
            utilityName = descriptionWithoutBodyPreview
                .substring(colonIndex + 1, detailsStart)
                .trim();
          }
        }

        // Build header
        final header = unit.isNotEmpty
            ? 'Utility $action (Unit $unit): $utilityName'
            : 'Utility $action: $utilityName';
        details.add(header);

        // Parse details if they exist
        if (detailsStr != null && detailsStr.isNotEmpty) {
          final detailParts = _smartSplit(detailsStr, [',']);
          for (var part in detailParts) {
            part = part.trim();
            if (part.isNotEmpty) {
              final colonIdx = part.indexOf(':');
              if (colonIdx > 0 && colonIdx < part.length - 1) {
                final key = part.substring(0, colonIdx).trim();
                final value = part.substring(colonIdx + 1).trim();
                if (key.isNotEmpty && value.isNotEmpty) {
                  details.add('$key: $value');
                }
              } else {
                details.add(part);
              }
            }
          }
        }

        // Add body preview at the end if it exists
        if (bodyPreviewValue.isNotEmpty) {
          bodyPreviewValue =
              bodyPreviewValue.replaceAll(RegExp(r'<[^>]+>'), '');
          bodyPreviewValue = bodyPreviewValue.replaceAll('**', '');
          bodyPreviewValue = bodyPreviewValue.replaceAll('&nbsp;', ' ');
          details.add('Body preview: $bodyPreviewValue');
        }

        if (details.isNotEmpty) {
          return details;
        }
      }
    }

    // Pattern 2: Check for arrow format FIRST (old → new) - like "Utility Gas Updated: Provider Name: HPdsef → HP"
    // This needs to be checked before key-value parsing to avoid incorrect splitting
    if (descriptionWithoutBodyPreview.contains('→') ||
        descriptionWithoutBodyPreview.contains('->')) {
      // Check if it's a utility/property update with arrow format
      // Pattern: "Utility X Updated: Field Name: old → new"
      final utilityUpdatePattern = RegExp(
          r'([A-Za-z\s]+(?:Updated|updated)):\s*([A-Za-z\s]+):\s*(.+?)\s*(?:→|->)\s*(.+?)$',
          caseSensitive: false);
      final utilityMatch =
          utilityUpdatePattern.firstMatch(descriptionWithoutBodyPreview);

      if (utilityMatch != null) {
        // Utility update format detected
        final action = utilityMatch.group(1)?.trim() ?? '';
        final fieldName = utilityMatch.group(2)?.trim() ?? '';
        final oldValue = utilityMatch.group(3)?.trim() ?? '';
        final newValue = utilityMatch.group(4)?.trim() ?? '';

        if (action.isNotEmpty && fieldName.isNotEmpty) {
          details.add('$action: $fieldName: $oldValue → $newValue');

          // Add body preview at the end if it exists
          if (bodyPreviewValue.isNotEmpty) {
            bodyPreviewValue =
                bodyPreviewValue.replaceAll(RegExp(r'<[^>]+>'), '');
            bodyPreviewValue = bodyPreviewValue.replaceAll('**', '');
            bodyPreviewValue = bodyPreviewValue.replaceAll('&nbsp;', ' ');
            details.add('Body preview: $bodyPreviewValue');
          }

          return details;
        }
      }
    }

    // Pattern 3: Enhanced Key-Value pair detection
    // Look for patterns like "Key: Value" but handle nested content better
    // Parse description WITHOUT body preview first
    final keyValuePattern = RegExp(
        r'([A-Za-z][A-Za-z\s]+?):\s*([^:]+?)(?=\s+[A-Za-z][A-Za-z\s]+?:|$)',
        dotAll: true);
    final matches = keyValuePattern.allMatches(descriptionWithoutBodyPreview);

    if (matches.length >= 1) {
      // Multiple key-value pairs found
      for (var match in matches) {
        final key = match.group(1)?.trim() ?? '';
        var value = match.group(2)?.trim() ?? '';

        // Clean up value - remove trailing commas/semicolons
        value = value.replaceAll(RegExp(r'^[,;]\s*'), '');
        value = value.replaceAll(RegExp(r'\s*[,;]$'), '');

        if (key.isNotEmpty && value.isNotEmpty) {
          details.add('$key: $value');
        }
      }

      // Add body preview at the end if it exists (as plain text, not parsed)
      if (bodyPreviewValue.isNotEmpty) {
        bodyPreviewValue = bodyPreviewValue.replaceAll(RegExp(r'<[^>]+>'), '');
        bodyPreviewValue = bodyPreviewValue.replaceAll('**', '');
        bodyPreviewValue = bodyPreviewValue.replaceAll('&nbsp;', ' ');
        details.add('Body preview: $bodyPreviewValue');
      }

      // If we found structured pairs, return them
      if (details.isNotEmpty) {
        return details;
      }
    }

    // Pattern 5: Check for lease/property patterns
    if (cleanDescription.toLowerCase().contains('lease created') ||
        cleanDescription.toLowerCase().contains('property:') ||
        cleanDescription.toLowerCase().contains('lease type:')) {
      return _parseLeaseDescription(cleanDescription);
    }

    // Pattern 6: Very long description - split intelligently
    if (cleanDescription.length > 150) {
      // Try splitting by periods first
      final sentences = cleanDescription
          .split(RegExp(r'\.\s+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s.length > 10)
          .toList();

      if (sentences.length >= 2) {
        return sentences;
      }

      // Try splitting by line breaks or double spaces
      if (cleanDescription.contains('\n') || cleanDescription.contains('  ')) {
        final lines = cleanDescription
            .split(RegExp(r'\n+|  +'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (lines.length >= 2) {
          return lines;
        }
      }

      // Last resort: split by commas, but be smart about it
      if (cleanDescription.length > 200) {
        final parts = _smartSplit(cleanDescription, [',']);
        if (parts.length >= 2) {
          return parts;
        }
      }
    }

    // Default: Return as single item if no pattern matches
    return [cleanDescription];
  }

  /// Smart split that handles nested content (like parentheses, quotes)
  List<String> _smartSplit(String text, List<String> delimiters) {
    List<String> parts = [];
    String currentPart = '';
    int parenDepth = 0;
    bool inQuotes = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '"' || char == "'") {
        inQuotes = !inQuotes;
        currentPart += char;
      } else if (char == '(') {
        parenDepth++;
        currentPart += char;
      } else if (char == ')') {
        parenDepth--;
        currentPart += char;
      } else if (!inQuotes && parenDepth == 0 && delimiters.contains(char)) {
        // Check if next non-space char starts a new key-value pair
        final remaining = text.substring(i + 1).trim();
        if (remaining.isNotEmpty) {
          // Check if it looks like a new key-value pair
          final looksLikeNewKey =
              RegExp(r'^[A-Za-z][A-Za-z\s]*:').hasMatch(remaining);

          if (looksLikeNewKey && currentPart.trim().isNotEmpty) {
            parts.add(currentPart.trim());
            currentPart = '';
            continue;
          }
        }
        currentPart += char;
      } else {
        currentPart += char;
      }
    }

    if (currentPart.trim().isNotEmpty) {
      parts.add(currentPart.trim());
    }

    return parts.where((p) => p.isNotEmpty).toList();
  }

  /// Parse lease charge description
  List<String> _parseLeaseChargeDescription(
      String description, String bodyPreviewValue) {
    List<String> details = [];

    // Extract main charge line: "Charge added: $X for Y"
    final chargeMatch = RegExp(
            r'Charge added:\s*\$?([\d,]+\.?\d*)\s+for\s+(.+?)(?:\.|Breakdown:|Updated by:|$)',
            caseSensitive: false)
        .firstMatch(description);

    if (chargeMatch != null) {
      final amount = chargeMatch.group(1)?.trim() ?? '';
      final chargeType = chargeMatch.group(2)?.trim() ?? '';
      details.add('Charge added: \$$amount for $chargeType');
    } else {
      // Fallback: just get "Charge added: ..." part until period or Breakdown
      final simpleMatch = RegExp(
              r'Charge added:\s*(.+?)(?:\.|Breakdown:|Updated by:|$)',
              caseSensitive: false)
          .firstMatch(description);
      if (simpleMatch != null) {
        details.add('Charge added: ${simpleMatch.group(1)?.trim() ?? ''}');
      }
    }

    // Extract Breakdown section if exists
    final breakdownMatch = RegExp(r'Breakdown:\s*(.+?)(?:\s+Updated by:|$)',
            caseSensitive: false, dotAll: true)
        .firstMatch(description);
    if (breakdownMatch != null) {
      final breakdown = breakdownMatch.group(1)?.trim() ?? '';
      if (breakdown.isNotEmpty) {
        // Clean up breakdown - remove trailing periods and "Updated by" text
        var cleanBreakdown = breakdown.replaceAll(RegExp(r'\.\s*$'), '').trim();
        cleanBreakdown =
            cleanBreakdown.replaceAll(RegExp(r'\s+Updated by:.*$'), '').trim();
        if (cleanBreakdown.isNotEmpty) {
          details.add('Breakdown: $cleanBreakdown');
        }
      }
    }

    // Extract Due date from brackets: [Due: 01/05/2026]
    final dueMatch = RegExp(r'\[Due:\s*([^\]]+)\]', caseSensitive: false)
        .firstMatch(description);
    if (dueMatch != null) {
      details.add('Due: ${dueMatch.group(1)?.trim() ?? ''}');
    }

    // Extract Type from parentheses: (Type: Charge)
    final typeMatch = RegExp(r'\(Type:\s*([^)]+)\)', caseSensitive: false)
        .firstMatch(description);
    if (typeMatch != null) {
      details.add('Type: ${typeMatch.group(1)?.trim() ?? ''}');
    }

    // Extract "Updated by" if exists
    final updatedByMatch = RegExp(r'Updated by:\s*(.+?)$', caseSensitive: false)
        .firstMatch(description);
    if (updatedByMatch != null) {
      details.add('Updated by: ${updatedByMatch.group(1)?.trim() ?? ''}');
    }

    // Add body preview at the end if it exists
    if (bodyPreviewValue.isNotEmpty) {
      bodyPreviewValue = bodyPreviewValue.replaceAll(RegExp(r'<[^>]+>'), '');
      bodyPreviewValue = bodyPreviewValue.replaceAll('**', '');
      bodyPreviewValue = bodyPreviewValue.replaceAll('&nbsp;', ' ');
      details.add('Body preview: $bodyPreviewValue');
    }

    return details.isNotEmpty ? details : [description];
  }

  /// Parse lease payment description
  List<String> _parseLeasePaymentDescription(
      String description, String bodyPreviewValue) {
    List<String> details = [];

    // Extract payment amount and method: "Payment of $X via Y"
    final paymentMatch = RegExp(
            r'Payment\s+of\s+\$?([\d,]+\.?\d*)\s+via\s+([^(]+?)(?:\(|\.|Updated by:|$)',
            caseSensitive: false)
        .firstMatch(description);

    if (paymentMatch != null) {
      final amount = paymentMatch.group(1)?.trim() ?? '';
      final method = paymentMatch.group(2)?.trim() ?? '';
      details.add('Payment: \$$amount via $method');
    }

    // Extract Transaction ID
    final txIdMatch =
        RegExp(r'Transaction ID:\s*([^\s.]+)', caseSensitive: false)
            .firstMatch(description);
    if (txIdMatch != null) {
      details.add('Transaction ID: ${txIdMatch.group(1)?.trim() ?? ''}');
    }

    // Extract "Applied to:" section
    final appliedMatch = RegExp(r'Applied to:\s*(.+?)(?:\s+Updated by:|$)',
            caseSensitive: false, dotAll: true)
        .firstMatch(description);
    if (appliedMatch != null) {
      final appliedTo = appliedMatch.group(1)?.trim() ?? '';
      if (appliedTo.isNotEmpty) {
        // Clean up - remove trailing periods
        var cleanAppliedTo = appliedTo.replaceAll(RegExp(r'\.\s*$'), '').trim();
        // Parse comma-separated charges: "Charge1: $X, Charge2: $Y"
        final charges = _smartSplit(cleanAppliedTo, [',']);
        if (charges.length > 1) {
          details.add('Applied to:');
          for (var charge in charges) {
            charge = charge.trim();
            if (charge.isNotEmpty) {
              details.add('  $charge');
            }
          }
        } else {
          details.add('Applied to: $cleanAppliedTo');
        }
      }
    }

    // Extract "Updated by" if exists
    final updatedByMatch = RegExp(r'Updated by:\s*(.+?)$', caseSensitive: false)
        .firstMatch(description);
    if (updatedByMatch != null) {
      details.add('Updated by: ${updatedByMatch.group(1)?.trim() ?? ''}');
    }

    // Add body preview at the end if it exists
    if (bodyPreviewValue.isNotEmpty) {
      bodyPreviewValue = bodyPreviewValue.replaceAll(RegExp(r'<[^>]+>'), '');
      bodyPreviewValue = bodyPreviewValue.replaceAll('**', '');
      bodyPreviewValue = bodyPreviewValue.replaceAll('&nbsp;', ' ');
      details.add('Body preview: $bodyPreviewValue');
    }

    return details.isNotEmpty ? details : [description];
  }

  /// Parse lease insurance description
  List<String> _parseLeaseInsuranceDescription(
      String description, String bodyPreviewValue) {
    List<String> details = [];

    // Extract policy info: "Renters insurance policy X added from Y"
    final policyMatch = RegExp(
            r'Renters insurance policy\s+([^\s]+)\s+added from\s+(.+?)(?:\(|with|Updated by:|$)',
            caseSensitive: false)
        .firstMatch(description);

    if (policyMatch != null) {
      final policyNumber = policyMatch.group(1)?.trim() ?? '';
      final company = policyMatch.group(2)?.trim() ?? '';
      details.add('Policy: $policyNumber');
      details.add('Company: $company');
    }

    // Extract Effective date
    final effectiveMatch = RegExp(r'Effective:\s*([^-]+)', caseSensitive: false)
        .firstMatch(description);
    if (effectiveMatch != null) {
      details.add('Effective: ${effectiveMatch.group(1)?.trim() ?? ''}');
    }

    // Extract Expires date
    final expiresMatch = RegExp(r'Expires:\s*([^\s)]+)', caseSensitive: false)
        .firstMatch(description);
    if (expiresMatch != null) {
      details.add('Expires: ${expiresMatch.group(1)?.trim() ?? ''}');
    }

    // Extract liability coverage
    final coverageMatch = RegExp(r'liability coverage of\s+\$?([\d,]+\.?\d*)',
            caseSensitive: false)
        .firstMatch(description);
    if (coverageMatch != null) {
      details
          .add('Liability Coverage: \$${coverageMatch.group(1)?.trim() ?? ''}');
    }

    // Extract "Updated by" if exists
    final updatedByMatch = RegExp(r'Updated by:\s*(.+?)$', caseSensitive: false)
        .firstMatch(description);
    if (updatedByMatch != null) {
      details.add('Updated by: ${updatedByMatch.group(1)?.trim() ?? ''}');
    }

    // Add body preview at the end if it exists
    if (bodyPreviewValue.isNotEmpty) {
      bodyPreviewValue = bodyPreviewValue.replaceAll(RegExp(r'<[^>]+>'), '');
      bodyPreviewValue = bodyPreviewValue.replaceAll('**', '');
      bodyPreviewValue = bodyPreviewValue.replaceAll('&nbsp;', ' ');
      details.add('Body preview: $bodyPreviewValue');
    }

    return details.isNotEmpty ? details : [description];
  }

  /// Parse lease email description
  List<String> _parseLeaseEmailDescription(
      String description, String bodyPreviewValue) {
    List<String> details = [];

    // Extract subject: "Email sent: "subject" to email@domain.com"
    final emailMatch = RegExp(r'Email sent:\s*"([^"]+)"\s+to\s+([^\s.]+)',
            caseSensitive: false)
        .firstMatch(description);

    if (emailMatch != null) {
      final subject = emailMatch.group(1)?.trim() ?? '';
      final recipient = emailMatch.group(2)?.trim() ?? '';
      details.add('Email sent: "$subject"');
      details.add('To: $recipient');
    } else {
      // Fallback: simpler format - "Email sent: subject to email@domain.com"
      final simpleMatch = RegExp(r'Email sent:\s*(.+?)(?:\s+Updated by:|$)',
              caseSensitive: false)
          .firstMatch(description);
      if (simpleMatch != null) {
        var emailText = simpleMatch.group(1)?.trim() ?? '';
        // Remove trailing period
        emailText = emailText.replaceAll(RegExp(r'\.\s*$'), '').trim();
        details.add('Email sent: $emailText');
      }
    }

    // Extract "Updated by" if exists
    final updatedByMatch = RegExp(r'Updated by:\s*(.+?)$', caseSensitive: false)
        .firstMatch(description);
    if (updatedByMatch != null) {
      details.add('Updated by: ${updatedByMatch.group(1)?.trim() ?? ''}');
    }

    // Add body preview at the end if it exists
    if (bodyPreviewValue.isNotEmpty) {
      bodyPreviewValue = bodyPreviewValue.replaceAll(RegExp(r'<[^>]+>'), '');
      bodyPreviewValue = bodyPreviewValue.replaceAll('**', '');
      bodyPreviewValue = bodyPreviewValue.replaceAll('&nbsp;', ' ');
      details.add('Body preview: $bodyPreviewValue');
    }

    return details.isNotEmpty ? details : [description];
  }

  /// Parse lease description with structured fields
  List<String> _parseLeaseDescription(String description) {
    List<String> details = [];

    // Extract main action
    final actionMatch = RegExp(r'^([^:]+?):').firstMatch(description);
    if (actionMatch != null) {
      details.add('${actionMatch.group(1)?.trim() ?? ''}:');
    }

    // Extract all key-value pairs
    final keyValuePattern = RegExp(
        r'([A-Za-z][A-Za-z\s]+?):\s*([^,;]+?)(?=\s+[A-Za-z][A-Za-z\s]+?:|$)');
    final matches = keyValuePattern.allMatches(description);

    for (var match in matches) {
      final key = match.group(1)?.trim() ?? '';
      final value = match.group(2)?.trim() ?? '';
      if (key.isNotEmpty &&
          value.isNotEmpty &&
          !key.toLowerCase().contains('lease created')) {
        details.add('$key: $value');
      }
    }

    if (details.isEmpty) {
      return _parseGeneralDescription(description);
    }

    return details;
  }

  /// General description parser as fallback
  List<String> _parseGeneralDescription(String description) {
    List<String> details = [];

    // Try to find key-value pairs
    final keyValuePattern = RegExp(
        r'([A-Za-z][A-Za-z\s]+?):\s*([^:]+?)(?=\s+[A-Za-z][A-Za-z\s]+?:|$)',
        dotAll: true);
    final matches = keyValuePattern.allMatches(description);

    if (matches.length >= 1) {
      for (var match in matches) {
        final key = match.group(1)?.trim() ?? '';
        var value = match.group(2)?.trim() ?? '';
        value = value
            .replaceAll(RegExp(r'^[,;]\s*'), '')
            .replaceAll(RegExp(r'\s*[,;]$'), '');

        if (key.isNotEmpty && value.isNotEmpty) {
          // Special handling: Body preview should not be parsed further
          if (key.toLowerCase().contains('body preview')) {
            // Clean HTML but don't parse further
            value = value.replaceAll(RegExp(r'<[^>]+>'), '');
            value = value.replaceAll('**', '');
            value = value.replaceAll('&nbsp;', ' ');
          }
          details.add('$key: $value');
        }
      }
    }

    // If no key-value pairs found, split by common patterns
    if (details.isEmpty) {
      final parts = _smartSplit(description, [',', ';', '.']);
      if (parts.length > 1) {
        return parts;
      }
    }

    return details.isEmpty ? [description] : details;
  }

  /// Build description widget with parsed details
  Widget _buildDescriptionWidget(String description) {
    final parsedDetails = _parseDescription(description);

    if (parsedDetails.isEmpty) {
      return const SizedBox.shrink();
    }

    if (parsedDetails.length == 1) {
      // Single item - show as simple text
      // For lease history, show full description text
      return Text(
        parsedDetails[0],
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontSize: 14,
        ),
      );
    }

    // For lease history with body preview, show description first, then body preview
    if (widget.historyType == HistoryType.lease && parsedDetails.length == 2) {
      final description = parsedDetails[0];
      final bodyPreview = parsedDetails[1];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          if (bodyPreview.toLowerCase().startsWith('body preview')) ...[
            const SizedBox(height: 8),
            Text(
              'Body preview:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                bodyPreview.substring('Body preview:'.length).trim(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Multiple items - show as list
    // Check if first item is a header (like "Utility Added (Unit X): utilityname")
    // and rest are details (like "Provider: X", "Account: Y")
    bool hasHeader = false;
    String? headerText;
    List<String> detailItems = [];

    if (parsedDetails.length > 1) {
      final firstItem = parsedDetails[0];
      // Check if first item looks like a header (STARTS with "Utility Added" or "Utility Deleted")
      // Only apply header format for actual utility entries to avoid breaking other sections
      final firstItemLower = firstItem.toLowerCase().trim();
      if (firstItemLower.startsWith('utility added') ||
          firstItemLower.startsWith('utility deleted')) {
        hasHeader = true;
        headerText = firstItem;
        detailItems = parsedDetails.sublist(1);
      }
    }

    if (hasHeader && headerText != null) {
      // Display header with expandable details
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            headerText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // Details (indented)
          if (detailItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: detailItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final detail = entry.value;

                  // Check if it's a key-value pair
                  final colonIndex = detail.indexOf(':');
                  if (colonIndex > 0 && colonIndex < detail.length - 1) {
                    final key = detail.substring(0, colonIndex).trim();
                    final value = detail.substring(colonIndex + 1).trim();

                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: index < detailItems.length - 1 ? 4 : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$key: ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index < detailItems.length - 1 ? 4 : 0),
                    child: Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
    }

    // Regular list display (no special header)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parsedDetails.asMap().entries.map((entry) {
        final index = entry.key;
        final detail = entry.value;

        // Check if this is an indented item (starts with spaces) - used for "Applied to:" sub-items
        final isIndented = detail.startsWith('  ');
        final displayDetail = isIndented ? detail.substring(2) : detail;

        // Check if it's a key-value pair
        final colonIndex = displayDetail.indexOf(':');
        if (colonIndex > 0 && colonIndex < displayDetail.length - 1) {
          final key = displayDetail.substring(0, colonIndex).trim();
          final value = displayDetail.substring(colonIndex + 1).trim();

          // Special handling: Body preview value should be displayed as plain text
          // Don't parse nested key-values inside it (like Email Address:, Password:, etc.)
          if (key.toLowerCase().contains('body preview')) {
            return Padding(
              padding: EdgeInsets.only(
                  left: isIndented ? 16.0 : 0.0,
                  bottom: index < parsedDetails.length - 1 ? 6 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$key:',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Check if value contains arrow format (old → new)
          if (value.contains('→') || value.contains('->')) {
            final arrowIndex = value.indexOf('→') != -1
                ? value.indexOf('→')
                : value.indexOf('->');
            if (arrowIndex > 0) {
              final oldValue = value.substring(0, arrowIndex).trim();
              final arrowSymbol = value.contains('→') ? '→' : '->';
              final newValue =
                  value.substring(arrowIndex + arrowSymbol.length).trim();

              return Padding(
                padding: EdgeInsets.only(
                    left: isIndented ? 16.0 : 0.0,
                    bottom: index < parsedDetails.length - 1 ? 6 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$key: ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              oldValue,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ),
                          const Text(
                            '→',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              newValue,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }

          return Padding(
            padding: EdgeInsets.only(
                left: isIndented ? 16.0 : 0.0,
                bottom: index < parsedDetails.length - 1 ? 6 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$key: ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Regular text item
        return Padding(
          padding: EdgeInsets.only(
              left: isIndented ? 16.0 : 0.0,
              bottom: index < parsedDetails.length - 1 ? 6 : 0),
          child: Text(
            '• $displayDetail',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        );
      }).toList(),
    );
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
                                  widget.historyType == HistoryType.lease
                                      ? "     Action"
                                      : "     User",
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
                                        widget.historyType == HistoryType.lease
                                            ? (historyItem.action.isNotEmpty
                                                ? historyItem.action
                                                : (historyItem
                                                        .category.isNotEmpty
                                                    ? historyItem.category
                                                    : historyItem.type))
                                            : historyItem.username,
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
                                                // Description with parsed details
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Description :',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: widget.blueColor,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 20),
                                                      child: Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                12, 12, 12, 16),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[100],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .grey[300]!),
                                                        ),
                                                        child:
                                                            _buildDescriptionWidget(
                                                                historyItem
                                                                    .description),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // For lease history: show Type and Updated by
                                                // For other history types: show only Description (no Type, no Details)
                                                if (widget.historyType ==
                                                    HistoryType.lease) ...[
                                                  if (historyItem.type
                                                          .toString()
                                                          .isNotEmpty ||
                                                      historyItem
                                                          .username.isNotEmpty)
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
                                                                  FontWeight
                                                                      .bold,
                                                              color: widget
                                                                  .blueColor,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: historyItem
                                                                .type,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (historyItem
                                                        .username.isNotEmpty)
                                                      const SizedBox(height: 8),
                                                  ],
                                                  if (historyItem
                                                      .username.isNotEmpty) ...[
                                                    Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                'Updated by : ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: widget
                                                                  .blueColor,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: historyItem
                                                                .username,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
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
