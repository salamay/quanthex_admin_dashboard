class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final List<String> packageNames;

  PaginatedResponse({
    required this.data,
    required this.total,
    this.packageNames = const [],
  });
}
