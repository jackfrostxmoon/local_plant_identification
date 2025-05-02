import 'dart:async'; // For Timer (debouncing)

import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/plant_configs/plant_detail_screen.dart';
import 'package:local_plant_identification/screens/search/plant_grid_item.dart'; // Assuming this handles localization internally
import 'package:local_plant_identification/services/appwrite_service.dart';
import 'package:local_plant_identification/widgets/custom_loading_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

// Constants defining the different filter types. These are internal identifiers.
const String _filterAll = 'All';
const String _filterFlower = 'Flower';
const String _filterHerb = 'Herb';
const String _filterTree = 'Tree';

// A screen for searching and displaying plant information.
class PlantSearchScreen extends StatefulWidget {
  const PlantSearchScreen({super.key});

  @override
  State<PlantSearchScreen> createState() => _PlantSearchScreenState();
}

class _PlantSearchScreenState extends State<PlantSearchScreen> {
  // Instance of AppwriteService to interact with the backend.
  final AppwriteService _appwriteService = AppwriteService();
  // Controller for the search input field.
  final TextEditingController _searchController = TextEditingController();
  // List to hold the search results (list of plant data maps).
  List<Map<String, dynamic>> _searchResults = [];
  // Flag to indicate if a search operation is currently in progress.
  bool _isLoading = false;
  // Variable to store any error message that occurs during search.
  String? _error;
  // Timer used for debouncing the search input.
  Timer? _debounce;
  // The currently selected plant type filter, defaulting to 'All'.
  String _selectedFilterType = _filterAll;

  @override
  void initState() {
    super.initState();
    // Add a listener to the search controller to react to text changes.
    _searchController.addListener(_onSearchChanged);
    // Optional: Perform an initial search on screen load.
    // _performSearch('');
  }

  @override
  void dispose() {
    // Remove the listener to prevent memory leaks.
    _searchController.removeListener(_onSearchChanged);
    // Dispose of the text editing controller.
    _searchController.dispose();
    // Cancel the debounce timer if it's active.
    _debounce?.cancel();
    super.dispose();
  }

  // Implements debouncing for the search input.
  // Waits for a brief period after the user stops typing before triggering a search.
  void _onSearchChanged() {
    // Cancel the previous debounce timer if it exists and is active.
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Start a new debounce timer.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Trim leading/trailing whitespace from the search query before searching.
      _performSearch(_searchController.text.trim());
    });
  }

  // Asynchronously performs the search operation by calling the AppwriteService.
  Future<void> _performSearch(String query) async {
    // Check if the widget is still mounted before updating the state.
    if (!mounted) return;
    // Update the state to show the loading indicator and clear previous errors.
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Call the AppwriteService to fetch or search for plants.
      // If the query is empty, fetch all plants; otherwise, perform a search.
      final results = query.isEmpty
          ? await _appwriteService.fetchAllPlants()
          : await _appwriteService.searchPlants(query);

      // Check if the widget is still mounted before updating the state.
      if (mounted) {
        // Update the state with the search results and hide the loading indicator.
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Log any search errors.
      print("Search Error: $e");
      // Check if the widget is still mounted before updating the state.
      if (mounted) {
        // Update the state to hide loading, show the error message, and clear results.
        setState(() {
          _isLoading = false;
          // Hardcoded English error message as requested previously.
          _error = "Failed to perform search. Please try again.";
          _searchResults = [];
        });
      }
    }
  }

  // Navigates to the PlantDetailScreen when a plant item is tapped.
  void _navigateToDetail(Map<String, dynamic> plantData) {
    // Ensure the plant data contains the Appwrite document ID before navigating.
    if (plantData.containsKey('\$id')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantDetailScreen(plantData: plantData),
        ),
      );
    } else {
      // Show a SnackBar with an error message if the ID is missing.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // Hardcoded English error message as requested previously.
          content: Text('Error: Could not open plant details (Missing ID).'),
          backgroundColor: Colors.red,
        ),
      );
      // Log the error and the data for debugging.
      print("Error: Missing '\$id' in plant data for navigation.");
      print("Data: $plantData");
    }
  }

  // Helper function to get the localized name for a filter type.
  // Uses keys from the AppLocalizations template.
  String _getLocalizedFilterName(BuildContext context, String filterType) {
    // Get the AppLocalizations instance for accessing localized strings.
    final l10n = AppLocalizations.of(context)!;
    // Return the appropriate localized string based on the filter type.
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
    // Get the AppLocalizations instance for keys that exist in the template.
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Row containing the search bar and the filter button.
          Row(
            children: [
              // Expanded widget makes the search bar take up most of the available width.
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus:
                      false, // Prevents the keyboard from opening automatically.
                  decoration: InputDecoration(
                    hintText: l10n
                        .searchHintText, // Localized hint text for the search field.
                    prefixIcon:
                        const Icon(Icons.search), // Search icon at the start.
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
                        color: Theme.of(context)
                            .primaryColor, // Highlight border when focused.
                        width: 1.5,
                      ),
                    ),
                    filled: true, // Fill the text field background.
                    fillColor: Colors.white, // White background color.
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0,
                    ),
                    // Display a clear button only if the search field has text.
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            tooltip: l10n
                                .clearSearchTooltip, // Localized tooltip for the clear button.
                            onPressed: () {
                              // Clear the search field and perform an empty search to show all plants.
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null, // No suffix icon if the search field is empty.
                  ),
                ),
              ),
              const SizedBox(
                  width: 8), // Space between the search bar and filter button.
              // Filter Button implemented as a PopupMenuButton.
              Material(
                color: Colors.grey[200], // Background color of the button.
                borderRadius: BorderRadius.circular(
                    25.0), // Rounded corners for the button.
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.filter_list,
                    // Change icon color based on whether a filter is applied.
                    color: _selectedFilterType == _filterAll
                        ? Colors.black54
                        : Theme.of(context).primaryColor,
                  ),
                  tooltip: l10n
                      .filterTooltip, // Localized tooltip for the filter button.
                  onSelected: (String result) {
                    // Update the selected filter type if a new one is chosen.
                    if (result != _selectedFilterType) {
                      setState(() {
                        _selectedFilterType = result;
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    // Menu item for the "All" filter.
                    PopupMenuItem<String>(
                      value: _filterAll,
                      child: Text(
                          l10n.filterAllTypes), // Localized text for "All".
                    ),
                    const PopupMenuDivider(), // A visual separator in the menu.
                    // Menu item for the "Flower" filter.
                    PopupMenuItem<String>(
                      value: _filterFlower,
                      child: Text(
                          l10n.filterFlowers), // Localized text for "Flowers".
                    ),
                    // Menu item for the "Herb" filter.
                    PopupMenuItem<String>(
                      value: _filterHerb,
                      child:
                          Text(l10n.filterHerbs), // Localized text for "Herbs".
                    ),
                    // Menu item for the "Tree" filter.
                    PopupMenuItem<String>(
                      value: _filterTree,
                      child:
                          Text(l10n.filterTrees), // Localized text for "Trees".
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
              height: 16), // Space between the row and the results area.
          // Expanded widget makes the results area take up the remaining vertical space.
          Expanded(child: _buildResultsArea()),
        ],
      ),
    );
  }

  // Builds the area where search results or messages are displayed.
  Widget _buildResultsArea() {
    // Get the AppLocalizations instance for localized messages.
    final l10n = AppLocalizations.of(context)!;

    // Display a loading indicator if a search is in progress.
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    // Display an error message if an error occurred during search.
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!, // The hardcoded error message.
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Apply client-side filtering based on the selected filter type.
    final List<Map<String, dynamic>> displayedResults;
    if (_selectedFilterType == _filterAll) {
      // If 'All' is selected, display all search results.
      displayedResults = _searchResults;
    } else {
      // Filter the results based on the 'item_type' field matching the selected filter.
      displayedResults = _searchResults.where((plant) {
        return plant['item_type'] == _selectedFilterType;
      }).toList();
    }

    // Handle cases where there are no results to display.
    if (displayedResults.isEmpty) {
      String message;
      // Determine the appropriate message based on the search state.
      if (_searchController.text.isNotEmpty) {
        if (_selectedFilterType == _filterAll) {
          // Display a localized message when a search query has no results for all types.
          message = l10n.searchNoResultsGeneric; // Use the defined key.
        } else {
          // Display a localized message when a search query has no results for a specific filter.
          try {
            // Get the localized name of the currently selected filter type.
            String localizedFilterName =
                _getLocalizedFilterName(context, _selectedFilterType);
            // Use the localized message with the filter name inserted.
            message =
                l10n.searchNoResultsFiltered(localizedFilterName.toLowerCase());
          } catch (e) {
            // Fallback to a hardcoded English message if localization fails.
            print("Localization error for searchNoResultsFiltered: $e");
            message =
                "No ${_getLocalizedFilterName(context, _selectedFilterType).toLowerCase()} plants found matching your search.";
          }
        }
      } else {
        // Display a localized message prompting the user to enter text when the search is empty.
        message = l10n.searchEnterTextPrompt;
      }
      // Return a centered Text widget displaying the determined message.
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message, // Display the correct localized or fallback message.
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // If there are results, display them in a GridView.
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Display 2 items per row in the grid.
        crossAxisSpacing: 10.0, // Horizontal space between grid items.
        mainAxisSpacing: 10.0, // Vertical space between grid items.
        childAspectRatio:
            0.8, // Aspect ratio of each grid item (width / height).
      ),
      itemCount: displayedResults.length, // Number of items in the grid.
      itemBuilder: (context, index) {
        // Get the plant data for the current index.
        final plant = displayedResults[index];
        // Create a PlantGridItem widget for the plant.
        // PlantGridItem is assumed to handle its own localization of the name internally.
        return PlantGridItem(
          plant: plant,
          // Set the onTap callback to navigate to the detail screen.
          onTap: () => _navigateToDetail(plant),
        );
      },
    );
  }
}
