import 'dart:convert';
import 'api_client.dart';
import '../models/search_result_model.dart';

class SearchService {
  final ApiClient _apiClient = ApiClient();

  static const List<String> allSearchableTypes = [
    'notifications',
    'messages',
    'calendar-events',
    'events',
  ];

  Future<List<SearchResult>> search({
    required String query,
    List<String>? types,
    int limit = 20,
  }) async {
    final queryParameters = <String, String>{
      'query': query,
      'limit': limit.toString(),
    };

    if (types != null && types.isNotEmpty) {
      queryParameters['types'] = types.join(',');
    }

    final response = await _apiClient.get('/api/v1/search', queryParameters: queryParameters);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => SearchResult.fromJson(json)).toList();
    }
    throw Exception('Failed to search: ${response.statusCode}');
  }
}
