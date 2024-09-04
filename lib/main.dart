import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ItemsProvider(), // Create an instance of ItemsProvider
      child: MyApp(), // MyApp widget is created
    ),
  );
}

class ItemsProvider with ChangeNotifier {
  List<String> _items = [];
  List<String> _filteredItems = [];
  bool _isLoading = true;

  // Constructor that initializes the provider and loads items
  ItemsProvider() {
    _loadItems(); // Load items from SharedPreferences
  }

  // Getters for the list of items and loading state
  List<String> get items => _filteredItems.isEmpty ? _items : _filteredItems;
  bool get isLoading => _isLoading;

  // Private method to load items from SharedPreferences
  Future<void> _loadItems() async {
    final prefs =
        await SharedPreferences.getInstance(); // Access SharedPreferences
    _items = prefs.getStringList('savedItems') ??
        []; // Load saved items or an empty list
    _filteredItems = _items;
    _isLoading = false; // Set loading to false
    notifyListeners(); // Notify listeners that data has been loaded
  }

  // Private method to save items to SharedPreferences
  Future<void> _saveItems() async {
    final prefs =
        await SharedPreferences.getInstance(); // Access SharedPreferences
    await prefs.setStringList('savedItems', _items); // Save the updated list
  }

  // Method to add an item to the list
  void addItem(String item) {
    _items.add(item);
    _saveItems(); // Save the updated list to SharedPreferences
    notifyListeners(); // Notify listeners (UI) about the change
  }

  // Method to remove an item from the list
  void removeItem(String item) {
    _items.remove(item);
    _saveItems(); // Save the updated list to SharedPreferences
    _filteredItems.remove(item);
    notifyListeners(); // Notify listeners (UI) about the change
  }

  void searchItems(String query) {
    if (query.isEmpty) {
      _filteredItems = _items;
    }
    else {
      _filteredItems = _items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SharedPreferences Example',
      home: ItemsScreen(), // Display the ItemsScreen widget
    );
  }
}

class ItemsScreen extends StatelessWidget {
  final TextEditingController _controller =
      TextEditingController(); // Controller for the input field
  final TextEditingController _searchController =
      TextEditingController(); // Controller for the search field

  @override
  Widget build(BuildContext context) {
    // Getting Screen Dimensions
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final itemsProvider =
        Provider.of<ItemsProvider>(context); // Access the ItemsProvider

    // App starts from here
    return Scaffold(
      appBar: AppBar(
        elevation: height * 0.014,
        shadowColor: Colors.black,
        backgroundColor: Colors.black87,
        // Make appBar title in center
        title: Center(
            child: Text(
          'Save Items',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: height * 0.05),
        )),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height * 0.01),
        ),
      ),
      // Here checking the condition if its true then it gives value after ? and if false it give value after :
      body: itemsProvider.isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while data is loading
          : Padding(
              padding: EdgeInsets.only(top: height * 0.01),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(height * 0.008),
                    // Adding Card Property
                    child: Card(
                      color: Colors.white54,
                      child: Padding(
                        padding: EdgeInsets.all(height * 0.008),
                        // Adding TextField to add Items
                        child: TextField(
                          // Controller to hold the Items
                          controller: _controller,
                          // Decoration the TextField
                          decoration: InputDecoration(
                              labelText: 'Add Item',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  // Show message if TextField is Empty
                                  if (_controller.text.isEmpty) {
                                    // Hiding the current SnackBar
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    // Showing the SnackBar message
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      // SnackBar message
                                      content: Text(
                                          "Please enter name to add items."),
                                      // Setting the Time Duration of SnackBar
                                      duration: Duration(seconds: 2),
                                    ));
                                  }

                                  // Adding Items in "SavedItems" folder and showing snackbar
                                  if (_controller.text.isNotEmpty) {
                                    itemsProvider.addItem(_controller
                                        .text); // Add item to the list
                                    _controller
                                        .clear(); // Clear the TextField after adding
                                    // Hiding the current SnackBar
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    // Showing the SnackBar message
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      // SnackBar message
                                      content: Text("Item Added!"),
                                      // Setting the Time Duration
                                      duration: Duration(seconds: 2),
                                    ));
                                  }
                                },
                              ),
                              // Default border for TextField
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(height * 0.008),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: width * 0.006,
                                  )),
                              // Border when it is not taped
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(height * 0.008),
                                borderSide: BorderSide(
                                  color: Colors.black54,
                                  width: width *
                                      0.006, // Width of the border when the TextField is enabled but not focused
                                ),
                              ),
                              // Border when it is tapped to Add Items
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(height * 0.008),
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: width * 0.006,
                                ),
                              )),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(height * 0.008),
                    child: Card(
                      color: Colors.white54,
                      child: Padding(
                        padding: EdgeInsets.all(height * 0.008),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: "Search Items",
                            suffixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(height * 0.008),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: width * 0.006,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(height * 0.008),
                              borderSide: BorderSide(
                                color: Colors.black54,
                                width: width * 0.006,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(height * 0.008),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: width * 0.006,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            itemsProvider.searchItems(value);
                          },
                        ),
                      ),
                    ),
                  ),
                  // Dividing the content
                  Divider(
                    height: height * 0.03,
                    endIndent: height * 0.04,
                    thickness: height * 0.002,
                    color: Colors.black,
                    indent: height * 0.04,
                  ),
                  Text(
                    "Saved Items:",
                    style: TextStyle(
                        fontSize: height * 0.024, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  // Checking the condition, if it is true it gives the value after ? and if false it gives values after :
                  itemsProvider._filteredItems.isEmpty
                      ? Center(
                          child: Padding(
                          padding: EdgeInsets.only(top: height * 0.1),
                          child: Text(
                            "No Data Available!",
                            style: TextStyle(fontSize: height * 0.025),
                          ),
                        ))
                      : Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(height * 0.009,
                                height * 0.01, height * 0.009, height * 0.009),
                            // Adding the List to show the Items
                            child: ListView.builder(
                              itemCount: itemsProvider.items.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(top: height * 0.006),
                                  // Adding the Card Property
                                  child: Card(
                                    color: Colors.white54,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          height * 0.006,
                                          height * 0.009,
                                          0,
                                          height * 0.009),
                                      child: ListTile(
                                        // Adding the sort numbers
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.black87,
                                          child: Text(
                                            (index + 1).toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                        title: Text(itemsProvider.items[index]),
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            size: height * 0.035,
                                          ),
                                          onPressed: () {
                                            itemsProvider.removeItem(itemsProvider
                                                    .items[
                                                index]); // Remove item from the list
                                            // Hiding the current SnackBar
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar();
                                            // Showing the SnackBar after removing the Item
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text("Item Removed!"),
                                              // Set the Time Duration
                                              duration: Duration(seconds: 2),
                                            ));
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
