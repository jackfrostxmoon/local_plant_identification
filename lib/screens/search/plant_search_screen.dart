// screens/search/plant_search_screen.dart
import 'dart:async'; // For Timer (debouncing)

import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/plant_configs/plant_detail_screen.dart';
import 'package:local_plant_identification/screens/search/plant_grid_item.dart'; // Assuming this handles localization internally
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:local_plant_identification/widgets/custom_loading_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

// Constants for filter types (internal logic, no localization needed)
const String _filterAll = 'All';
const String _filterFlower = 'Flower';
const String _filterHerb = 'Herb';
const String _filterTree = 'Tree';

class PlantSearchScreen extends StatefulWidget {
  const PlantSearchScreen({super.key});

  @override
  State<PlantSearchScreen> createState() => _PlantSearchScreenState();
}

class _PlantSearchScreenState extends State<PlantSearchScreen> {
  final AppwriteService _appwriteService = AppwriteService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;
  String _selectedFilterType = _filterAll; // Default filter

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // _performSearch(''); // Optional: Initial fetch
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Debounce search input
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text.trim());
    });
  }

  // Perform the actual search using AppwriteService
  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = query.isEmpty
          ? await _appwriteService.fetchAllPlants()
          : await _appwriteService.searchPlants(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Search Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          // --- Hardcoded English error message (key missing in template) ---
          _error = "Failed to perform search. Please try again.";
          _searchResults = [];
        });
      }
    }
  }

  // Navigate to plant detail screen
  void _navigateToDetail(Map<String, dynamic> plantData) {
    // final l10n = AppLocalizations.of(context)!; // Not needed for hardcoded message
    if (plantData.containsKey('\$id')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantDetailScreen(plantData: plantData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // --- Hardcoded English error message (key missing in template) ---
          content: Text('Error: Could not open plant details (Missing ID).'),
          backgroundColor: Colors.red,
        ),
      );
      print("Error: Missing '\$id' in plant data for navigation.");
      print("Data: $plantData");
    }
  }

  // Helper to get localized filter name (Uses keys from template)
  String _getLocalizedFilterName(BuildContext context, String filterType) {
    final l10n = AppLocalizations.of(context)!;
    switch (filterType) {
      case _filterFlower:
        return l10n.filterFlowers;
      case _filterHerb:
        return l10n.filterHerbs;
      case _filterTree:
        return l10n.filterTrees;
      case _filterAll:
      default:
        return l10n.filterAllTypes;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get l10n instance for keys that exist in the template
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // --- Row for Search Bar and Filter Button ---
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: l10n.searchHintText, // Localized (Key exists)
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            tooltip: l10n
                                .clearSearchTooltip, // Localized (Key exists)
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // --- Filter Button ---
              Material(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25.0),
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.filter_list,
                    color: _selectedFilterType == _filterAll
                        ? Colors.black54
                        : Theme.of(context).primaryColor,
                  ),
                  tooltip: l10n.filterTooltip, // Localized (Key exists)
                  onSelected: (String result) {
                    if (result != _selectedFilterType) {
                      setState(() {
                        _selectedFilterType = result;
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    CheckedPopupMenuItem<String>(
                      value: _filterAll,
                      checked: _selectedFilterType == _filterAll,
                      child:
                          Text(l10n.filterAllTypes), // Localized (Key exists)
                    ),
                    const PopupMenuDivider(),
                    CheckedPopupMenuItem<String>(
                      value: _filterFlower,
                      checked: _selectedFilterType == _filterFlower,
                      child: Text(l10n.filterFlowers), // Localized (Key exists)
                    ),
                    CheckedPopupMenuItem<String>(
                      value: _filterHerb,
                      checked: _selectedFilterType == _filterHerb,
                      child: Text(l10n.filterHerbs), // Localized (Key exists)
                    ),
                    CheckedPopupMenuItem<String>(
                      value: _filterTree,
                      checked: _selectedFilterType == _filterTree,
                      child: Text(l10n.filterTrees), // Localized (Key exists)
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // --- Results Area ---
          Expanded(child: _buildResultsArea()),
        ],
      ),
    );
  }

  // Build the results area (GridView or messages)
  Widget _buildResultsArea() {
    // final l10n = AppLocalizations.of(context)!; // Not needed for hardcoded messages

    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!, // Already hardcoded in _performSearch
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Apply client-side filtering
    final List<Map<String, dynamic>> displayedResults;
    if (_selectedFilterType == _filterAll) {
      displayedResults = _searchResults;
    } else {
      displayedResults = _searchResults.where((plant) {
        return plant['item_type'] == _selectedFilterType;
      }).toList();
    }

    // Handle empty states with hardcoded messages
    if (displayedResults.isEmpty) {
      String message;
      if (_searchController.text.isNotEmpty) {
        if (_selectedFilterType == _filterAll) {
          // --- Hardcoded English message (key missing) ---
          message = 'No plants found matching your search.';
        } else {
          // --- Hardcoded English message (key missing) ---
          // Use the localized filter name helper for better context
          message =
              'No ${_getLocalizedFilterName(context, _selectedFilterType).toLowerCase()} plants found matching your search.';
        }
      } else {
        // --- Hardcoded English message (key missing) ---
        message = 'Enter text to search for plants.';
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Display Filtered Results using GridView
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.8,
      ),
      itemCount: displayedResults.length,
      itemBuilder: (context, index) {
        final plant = displayedResults[index];
        // PlantGridItem uses getLocalizedValue internally for dynamic name
        return PlantGridItem(
          plant: plant,
          onTap: () => _navigateToDetail(plant),
        );
      },
    );
  }
}
