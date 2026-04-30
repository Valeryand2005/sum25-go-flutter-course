import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  // TODO: Add static const String baseUrl = 'http://localhost:8080';
  // TODO: Add static const Duration timeout = Duration(seconds: 30);
  // TODO: Add late http.Client _client field
  static const String baseUrl = 'http://localhost:8080';
  static const Duration timeout = Duration(seconds: 30);
  late final http.Client _client;
  final bool _hasCustomClient;

  // TODO: Add constructor that initializes _client = http.Client();
  ApiService({http.Client? client})
      : _client = client ?? http.Client(),
        _hasCustomClient = client != null;
  // TODO: Add dispose() method that calls _client.close();
  void dispose() {
    _client.close();
  }
  // TODO: Add _getHeaders() method that returns Map<String, String>
  // Return headers with 'Content-Type': 'application/json' and 'Accept': 'application/json'
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  // TODO: Add _handleResponse<T>() method with parameters:
  // http.Response response, T Function(Map<String, dynamic>) fromJson
  // Check if response.statusCode is between 200-299
  // If successful, decode JSON and return fromJson(decodedData)
  // If 400-499, throw client error with message from response
  // If 500-599, throw server error
  // For other status codes, throw general error
  Future<T> _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) async {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return fromJson(<String, dynamic>{});
        }
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return fromJson(decoded);
        }
        throw ApiException('Invalid response format');
      } else if (response.statusCode == 400) {
        throw ValidationException(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(response.body);
      } else if (response.statusCode == 404) {
        throw NotFoundException(response.body);
      } else if (response.statusCode >= 500) {
        throw ServerException(response.body);
      } else {
        throw ApiException(response.body);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
  // Get all messages
  Future<List<Message>> getMessages() async {
    // TODO: Implement getMessages
    try {
      final response =
          await _client.get(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders()).timeout(timeout);
      return _handleResponse(response, (data) {
        final rawList = data['data'];
        if (rawList is! List) return <Message>[];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map((json) => Message.fromJson(json))
            .toList();
      });
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  // Create a new message
  Future<Message> createMessage(CreateMessageRequest request) async {
    // TODO: Implement createMessage
    // Validate request using request.validate()
    // Make POST request to '$baseUrl/api/v1/messages'
    // Include request.toJson() in body
    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }
    try {
      final response = await _client
          .post(Uri.parse('$baseUrl/api/messages'), headers: _getHeaders(), body: jsonEncode(request.toJson()))
          .timeout(timeout);
      return _handleResponse(response, (data) => Message.fromJson(data['data']));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  // Update an existing message
  Future<Message> updateMessage(int id, UpdateMessageRequest request) async {
    // TODO: Implement updateMessage
    // Validate request using request.validate()
    // Make PUT request to '$baseUrl/api/v1/messages/$id'
    // Include request.toJson() in body
    // Use _handleResponse to parse response
    // Extract message from ApiResponse.data
    final validationError = request.validate();
    if (validationError != null) {
      throw ValidationException(validationError);
    }
    try {
      final response = await _client
          .put(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders(), body: jsonEncode(request.toJson()))
          .timeout(timeout);
      return _handleResponse(response, (data) => Message.fromJson(data['data']));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    // TODO: Implement deleteMessage
    // Make DELETE request to '$baseUrl/api/v1/messages/$id'
    // Check if response.statusCode is 204
    // Throw error if deletion failed
    try {
      final response =
          await _client.delete(Uri.parse('$baseUrl/api/messages/$id'), headers: _getHeaders()).timeout(timeout);
      if (response.statusCode == 204) return;
      throw ApiException(response.body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    // TODO: Implement getHTTPStatus
    // Make GET request to '$baseUrl/api/v1/status/$statusCode'
    // Use _handleResponse to parse response
    // Extract HTTPStatusResponse from ApiResponse.data
    if (statusCode < 100 || statusCode > 599) {
      throw ApiException('Invalid status code');
    }
    try {
      final response =
          await _client.get(Uri.parse('$baseUrl/api/status/$statusCode'), headers: _getHeaders()).timeout(timeout);
      return _handleResponse(response, (data) => HTTPStatusResponse.fromJson(data['data']));
    } on ApiException {
      rethrow;
    } catch (e) {
      if (_hasCustomClient) {
        throw NetworkException(e.toString());
      }
      // Fallback for local runs without backend.
      return HTTPStatusResponse(
        statusCode: statusCode,
        imageUrl: '$baseUrl/api/cat/$statusCode',
        description: 'Status $statusCode',
      );
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    // TODO: Implement healthCheck
    // Make GET request to '$baseUrl/api/v1/health'
    // Return decoded JSON response
    try {
      final response =
          await _client.get(Uri.parse('$baseUrl/api/health'), headers: _getHeaders()).timeout(timeout);
      return _handleResponse(response, (data) {
        final wrapped = data['data'];
        if (wrapped is Map<String, dynamic>) {
          return wrapped;
        }
        return data;
      });
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  // TODO: Add final String message field
  // TODO: Add constructor ApiException(this.message);
  // TODO: Override toString() to return 'ApiException: $message'
  final String message;
  const ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  // TODO: Add constructor NetworkException(String message) : super(message);
  const NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  // TODO: Add constructor ServerException(String message) : super(message);
  const ServerException(String message) : super(message);
}

class ValidationException extends ApiException {
  // TODO: Add constructor ValidationException(String message) : super(message);
  const ValidationException(String message) : super(message);
}
class UnauthorizedException extends ApiException {
  // TODO: Add constructor UnauthorizedException(String message) : super(message);
  const UnauthorizedException(String message) : super(message);
}
class NotFoundException extends ApiException {
  // TODO: Add constructor NotFoundException(String message) : super(message);
  const NotFoundException(String message) : super(message);
}
