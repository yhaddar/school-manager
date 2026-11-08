import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/search_result_model.dart';
import '../../services/search_service.dart';
import '../../main.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _searchService = SearchService();
  List<SearchResult> _results = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _error = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final results = await _searchService.search(
        query: query,
        types: SearchService.allSearchableTypes,
      );
      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _error = 'Search failed: $e';
        _results = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getTypeIcon(SearchResult result) {
    switch (result.type) {
      case 'notification':
        return Iconsax.notification;
      case 'message':
        return Iconsax.message;
      case 'calendar_event':
        return Iconsax.calendar;
      case 'event':
        return Iconsax.calendar;
      default:
        return Iconsax.search_normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.space16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notifications, messages, events...',
                prefixIcon: Icon(Iconsax.search_normal, color: AppTheme.primary),
                suffixIcon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      ),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primary),
                ),
              ),
              style: TextStyle(color: AppTheme.onSurface),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 48, color: AppTheme.warning),
            const SizedBox(height: AppTheme.space16),
            Text(
              _error,
              style: TextStyle(color: AppTheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_results.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.search_normal, size: 48, color: AppTheme.muted),
            const SizedBox(height: AppTheme.space16),
            Text(
              'No results found',
              style: TextStyle(color: AppTheme.muted),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.search_normal, size: 48, color: AppTheme.muted),
            const SizedBox(height: AppTheme.space16),
            Text(
              'Start typing to search',
              style: TextStyle(color: AppTheme.muted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return ListTile(
          leading: Icon(_getTypeIcon(result), color: AppTheme.primary),
          title: Text(
            result.title,
            style: TextStyle(color: AppTheme.onSurface),
          ),
          subtitle: Text(
            result.subtitle,
            style: TextStyle(color: AppTheme.muted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            result.date != null ? '${result.date!.month}/${result.date!.day}' : '',
            style: TextStyle(color: AppTheme.muted),
          ),
          onTap: () {
            // Navigate to the specific item
            switch (result.type) {
              case 'notification':
                Navigator.pushNamed(context, '/communications/notifications/${result.id}');
                break;
              case 'message':
                Navigator.pushNamed(context, '/communications/messages/${result.id}');
                break;
              case 'calendar_event':
                Navigator.pushNamed(context, '/communications/calendar-events/${result.id}');
                break;
              case 'event':
                Navigator.pushNamed(context, '/communications/events/${result.id}');
                break;
              default:
                // Generic navigation
                break;
            }
          },
        );
      },
    );
  }
}
