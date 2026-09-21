import 'dart:convert';

class MetaQueryModel {
  final int skip;
  final int take;
  final List<MetaQueryFilterModel>? filteringExpressions;
  final List<MetaQuerySortModel>? sortingExpressions;

  MetaQueryModel({
    this.skip = 0,
    this.take = 10,
    this.filteringExpressions,
    this.sortingExpressions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'Skip': skip,
      'Take': take,
    };
    final filtering = filteringExpressions;
    if (filtering != null) {
      data['FilteringExpressionsJson'] = jsonEncode(filtering.map((e) => e.toJson()).toList());
    }
    final sorting = sortingExpressions;
    if (sorting != null) {
      data['SortingExpressionsJson'] = jsonEncode(sorting.map((e) => e.toJson()).toList());
    }
    return data;
  }
}

class MetaQueryFilterModel {
  final String propertyName;
  final String operator;
  final dynamic value;

  MetaQueryFilterModel({
    required this.propertyName,
    required this.operator,
    this.value,
  });

  Map<String, dynamic> toJson() => {
    'PropertyName': propertyName,
    'Operator': operator,
    'Value': value,
  };
}

class MetaQuerySortModel {
  final String propertyName;
  final bool isAscending;

  MetaQuerySortModel({
    required this.propertyName,
    this.isAscending = true,
  });

  Map<String, dynamic> toJson() => {
    'PropertyName': propertyName,
    'IsAscending': isAscending,
  };
}
