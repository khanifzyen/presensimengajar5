import 'package:pocketbase/pocketbase.dart';

class ErrorHandler {
  static String parseError(dynamic error) {
    if (error is ClientException) {
      final response = error.response;

      // Try to get 'details' from 'data' as requested by user
      // Structure based on user input: data -> details
      if (response.containsKey('data') && response['data'] is Map) {
        final data = response['data'] as Map<String, dynamic>;
        if (data.containsKey('details') && data['details'] != null) {
          return data['details'].toString();
        }
      }

      // Fallback to standard PocketBase error message
      if (response.containsKey('message') && response['message'] != null) {
        return response['message'].toString();
      }

      // Fallback to top level error/details if exists (sometimes happens)
      if (response.containsKey('error') && response['error'] != null) {
        return response['error'].toString();
      }
    }

    return error.toString();
  }
}
