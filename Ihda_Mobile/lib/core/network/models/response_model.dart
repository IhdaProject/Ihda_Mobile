class ResponseModel<T> {
  final String id;
  final int code;
  final T? content;
  final String? error;
  final int? total;
  final List<ModelErrorState>? modelStateError;

  ResponseModel({
    required this.id,
    required this.code,
    this.content,
    this.error,
    this.total,
    this.modelStateError,
  });

  bool get isSuccess => code >= 200 && code < 300;

  factory ResponseModel.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return ResponseModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as int? ?? 500,
      content: json['content'] != null ? fromJsonT(json['content']) : null,
      error: json['error'] as String?,
      total: json['total'] as int?,
      modelStateError: (json['modelStateError'] as List?)
          ?.map((e) => ModelErrorState.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ModelErrorState {
  final String key;
  final String? errorMessage;

  ModelErrorState({required this.key, this.errorMessage});

  factory ModelErrorState.fromJson(Map<String, dynamic> json) {
    return ModelErrorState(
      key: json['key'] as String? ?? '',
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
