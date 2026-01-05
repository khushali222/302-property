class HistoryItem {
  final String id;
  final String type;
  final String description;
  final String username;
  final String category;
  final String date;
  final int timestamp;
  final Map<String, dynamic>? metadata;

  HistoryItem({
    required this.id,
    required this.type,
    required this.description,
    required this.username,
    required this.category,
    required this.date,
    required this.timestamp,
    this.metadata,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json,
      {bool isLeaseHistory = false}) {
    // Handle different field names for lease history
    final username = isLeaseHistory
        ? (json['performed_by'] ?? json['username'] ?? '')
        : (json['username'] ?? '');

    final metadata = isLeaseHistory
        ? (json['details'] as Map<String, dynamic>? ??
            json['metadata'] as Map<String, dynamic>?)
        : (json['metadata'] as Map<String, dynamic>?);

    // Calculate timestamp from date if not provided
    int timestamp = json['timestamp'] ?? 0;
    if (timestamp == 0 && json['date'] != null) {
      try {
        final dateStr = json['date'] as String;
        final dateTime = DateTime.parse(dateStr.replaceAll(' ', 'T'));
        timestamp = dateTime.millisecondsSinceEpoch;
      } catch (e) {
        timestamp = 0;
      }
    }

    return HistoryItem(
      id: json['id'] ?? json['_id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      username: username,
      category: json['category'] ?? '',
      date: json['date'] ?? '',
      timestamp: timestamp,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'username': username,
      'category': category,
      'date': date,
      'timestamp': timestamp,
      'metadata': metadata,
    };
  }
}

class HistoryResponse {
  final List<HistoryItem> data;
  final PaginationInfo pagination;

  HistoryResponse({
    required this.data,
    required this.pagination,
  });

  factory HistoryResponse.fromJson(
    Map<String, dynamic> json, {
    bool isLeaseHistory = false,
    bool isFrontendPagination = false,
    int currentPage = 1,
    int itemsPerPage = 10,
  }) {
    List<HistoryItem> historyItems = [];
    if (json['data'] != null && json['data'] is List) {
      final allItems = (json['data'] as List)
          .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>,
              isLeaseHistory: isLeaseHistory))
          .toList();

      // For lease history (frontend pagination), don't slice here - return all items
      // The widget will handle slicing based on current page
      // For backend pagination, use the data as-is (already paginated by backend)
      if (isLeaseHistory) {
        // Lease history: return all items, widget will paginate
        historyItems = allItems;
      } else if (isFrontendPagination && allItems.length > itemsPerPage) {
        // Other frontend pagination: slice here
        final startIndex = (currentPage - 1) * itemsPerPage;
        final endIndex = startIndex + itemsPerPage;
        historyItems = allItems.sublist(
          startIndex,
          endIndex > allItems.length ? allItems.length : endIndex,
        );
      } else {
        // Backend pagination: use data as-is
        historyItems = allItems;
      }
    }

    // Calculate pagination info
    PaginationInfo pagination;
    if (isLeaseHistory && json['data'] != null && json['data'] is List) {
      // Lease history: calculate pagination from all items
      final totalItems = (json['data'] as List).length;
      final totalPages = (totalItems / itemsPerPage).ceil();
      pagination = PaginationInfo(
        total: totalItems,
        page: currentPage,
        limit: itemsPerPage,
        totalPages: totalPages > 0 ? totalPages : 1,
      );
      print(
          '🔵 Lease History Pagination - Total: $totalItems, Pages: $totalPages, Current Page: $currentPage');
    } else if (isFrontendPagination &&
        json['data'] != null &&
        json['data'] is List) {
      final totalItems = (json['data'] as List).length;
      final totalPages = (totalItems / itemsPerPage).ceil();
      pagination = PaginationInfo(
        total: totalItems,
        page: currentPage,
        limit: itemsPerPage,
        totalPages: totalPages > 0 ? totalPages : 1,
      );
    } else if (json['pagination'] != null) {
      pagination = PaginationInfo.fromJson(json['pagination']);
    } else {
      // No pagination info provided, assume all data is returned
      final totalItems = historyItems.length;
      final totalPages = (totalItems / itemsPerPage).ceil();
      pagination = PaginationInfo(
        total: totalItems,
        page: 1,
        limit: itemsPerPage,
        totalPages: totalPages > 0 ? totalPages : 1,
      );
    }

    return HistoryResponse(
      data: historyItems,
      pagination: pagination,
    );
  }
}

class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
