part of 'network_client.dart';

class NetworkResponse {
  final int statusCode;
  final Map<String, dynamic>? responseData;
  final String? errorMassage;
  final bool isSuccess;

  NetworkResponse(
      {required this.isSuccess,
        required this.statusCode,
        this.responseData,
        this.errorMassage});
}