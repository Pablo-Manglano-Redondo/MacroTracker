import 'package:flutter/material.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/usecase/search_products_usecase.dart';

class MealReplacementDialog extends StatefulWidget {
  final String initialQuery;

  const MealReplacementDialog({
    super.key,
    required this.initialQuery,
  });

  @override
  State<MealReplacementDialog> createState() => _MealReplacementDialogState();
}

class _MealReplacementDialogState extends State<MealReplacementDialog> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  List<MealEntity> _results = const [];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    if (widget.initialQuery.trim().length >= 2) {
      _search(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Replace ingredient'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_outlined),
                hintText: 'Search foods',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _search,
            ),
            const SizedBox(height: 12.0),
            Flexible(child: _buildResults()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _search(_searchController.text),
          child: const Text('Search'),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            _errorText!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Search for a food to replace this ingredient.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final meal = _results[index];
        final subtitle = [
          if (meal.brands != null && meal.brands!.trim().isNotEmpty)
            meal.brands!.trim(),
          if (meal.servingSize != null && meal.servingSize!.trim().isNotEmpty)
            meal.servingSize!.trim(),
        ].join(' - ');

        return ListTile(
          dense: true,
          title: Text(meal.name ?? 'Unnamed meal'),
          subtitle: subtitle.isEmpty ? null : Text(subtitle),
          onTap: () => Navigator.of(context).pop(meal),
        );
      },
    );
  }

  Future<void> _search(String query) async {
    final normalized = query.trim();
    if (normalized.length < 2) {
      setState(() {
        _results = const [];
        _errorText = 'Type at least 2 characters.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final usecase = locator<SearchProductsUseCase>();
      final results = await Future.wait([
        usecase.searchOFFProductsByString(normalized),
        usecase.searchFDCFoodByString(normalized),
      ]);

      final merged = <String, MealEntity>{};
      for (final meal in [...results[0], ...results[1]]) {
        final key = (meal.code ?? meal.name ?? '').trim().toLowerCase();
        if (key.isEmpty || merged.containsKey(key)) {
          continue;
        }
        merged[key] = meal;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _results = merged.values.take(12).toList(growable: false);
        _isLoading = false;
        _errorText = _results.isEmpty ? 'No matches found.' : null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _results = const [];
        _isLoading = false;
        _errorText = 'Could not search foods right now.';
      });
    }
  }
}
