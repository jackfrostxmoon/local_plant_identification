// screens/search/plant_search_screen.dart
import 'dart:async'; // For Timer (debouncing)

import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/plant_configs/plant_detail_screen.dart'; // Import detail screen
import 'package:local_plant_identification/screens/search/plant_grid_item.dart';
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:local_plant_identification/widgets/custom_loading_indicator.dart'; // Your loading indicator
// --- Import the new widget ---

// Define constants for filter types to avoid typos
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
  String _selectedFilterType = _filterAll;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isLoading = false;
            _error = null;
          });
        }
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _appwriteService.searchPlants(query);
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
          _error = "Failed to perform search. Please try again.";
          _searchResults = [];
        });
      }
    }
  }

  void _navigateToDetail(Map<String, dynamic> plantData) {
    // Keep navigation logic here as it uses context and PlantDetailScreen
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
          content: Text('Error: Could not open plant details (Missing ID).'),
          backgroundColor: Colors.red,
        ),
      );
      print("Error: Missing '\$id' in plant data for navigation.");
      print("Data: $plantData");
    }
  }

  // --- REMOVED _buildSearchPlantCard helper method ---

  @override
  Widget build(BuildContext context) {
    // Main build method remains largely the same
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // --- Row for Search Bar and Filter Button (Stays the same) ---
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Search plants...',
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
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                  _isLoading = false;
                                  _error = null;
                                });
                              },
                            )
                            : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25.0),
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.filter_list,
                    color:
                        _selectedFilterType == _filterAll
                            ? Colors.black54
                            : Theme.of(context).primaryColor,
                  ),
                  tooltip: 'Filter by plant type',
                  onSelected: (String result) {
                    // Clear results when changing filter to avoid flicker
                    if (result != _selectedFilterType) {
                      _searchController.clear();
                      setState(() {
                        _selectedFilterType = result;
                        _searchResults = [];
                        _isLoading = false;
                        _error = null;
                      });
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        CheckedPopupMenuItem<String>(
                          value: _filterAll,
                          checked: _selectedFilterType == _filterAll,
                          child: const Text('All Types'),
                        ),
                        const PopupMenuDivider(),
                        CheckedPopupMenuItem<String>(
                          value: _filterFlower,
                          checked: _selectedFilterType == _filterFlower,
                          child: const Text('Flowers'),
                        ),
                        CheckedPopupMenuItem<String>(
                          value: _filterHerb,
                          checked: _selectedFilterType == _filterHerb,
                          child: const Text('Herbs'),
                        ),
                        CheckedPopupMenuItem<String>(
                          value: _filterTree,
                          checked: _selectedFilterType == _filterTree,
                          child: const Text('Trees'),
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
          // --- Results Area (using GridView) ---
          Expanded(child: _buildResultsArea()),
        ],
      ),
    );
  }

  // --- Updated results area applying the filter ---
  Widget _buildResultsArea() {
    // Logic for loading, error, filtering remains the same
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> displayedResults;
    if (_selectedFilterType == _filterAll) {
      displayedResults = _searchResults;
    } else {
      displayedResults =
          _searchResults.where((plant) {
            return plant['item_type'] == _selectedFilterType;
          }).toList();
    }

    if (_searchController.text.isNotEmpty && displayedResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _selectedFilterType == _filterAll
                ? 'No plants found matching your search.'
                : 'No $_selectedFilterType plants found matching your search.',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_searchController.text.isEmpty && displayedResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Enter text to search for plants.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // --- Display Filtered Results using GridView ---
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
        // --- Use the new PlantGridItem widget ---
        return PlantGridItem(
          plant: plant,
          onTap: () => _navigateToDetail(plant), // Pass navigation logic
        );
        // --- End widget usage ---
      },
    );
  }
}
