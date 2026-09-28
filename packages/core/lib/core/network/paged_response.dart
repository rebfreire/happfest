/// Envelope de paginação genérico — mapeia a estrutura `Page<T>` do Spring
/// usada em `/search/products` e outros endpoints paginados da API.
class PagedResponse<T> {
  const PagedResponse({
    required this.content,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResponse<T>(
      content: (json['content'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      page: json['number'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      isLast: json['last'] as bool? ?? true,
    );
  }

  final List<T> content;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool isLast;
}
