class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String time;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.time,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? dataParser) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: dataParser != null && json['data'] != null ? dataParser(json['data']) : null,
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson(Object Function(T)? dataSerializer) {
    return {
      'success': success,
      'message': message,
      'data': dataSerializer != null && data != null ? dataSerializer(data as T) : null,
      'time': time,
    };
  }
}