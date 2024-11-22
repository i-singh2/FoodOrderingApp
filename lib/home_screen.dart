import 'package:flutter/material.dart';
import 'package:foodordering/database_helper.dart';
import 'order_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Target cost and date inputs
  final TextEditingController _targetCostController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Lists to manage food items and selections
  List<Map<String, dynamic>> foodItems = [];
  List<String> selectedItems = [];
  double selectedCost = 0.0;

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  // gets food items from database
  Future<void> fetchFoodItems() async {
    try {
      final items = await DatabaseHelper.instance.fetchAllFoodItems();
      setState(() {
        foodItems = items;
      });
    } catch (e) {
      print('Error fetching food items: $e');
    }
  }

  // Logic for including or excluding items 
  void toggleItem(String itemName, double itemCost, bool isAdding) {
    setState(() {
      if (isAdding) {
        // Prevent adding item if it exceeds the target cost
        final targetCost = double.tryParse(_targetCostController.text) ?? 0.0;
        if (selectedCost + itemCost <= targetCost) {
          if (!selectedItems.contains(itemName)) {
            selectedItems.add(itemName);
            selectedCost += itemCost;
          }
        } else {
          // Show warning if adding item exceeds target cost
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot add this item. Total cost exceeds target cost.'),
            ),
          );
        }
      } else {
        // Remove item and reduce selected cost
        if (selectedItems.contains(itemName)) {
          selectedItems.remove(itemName);
          selectedCost -= itemCost;
        }
      }
    });
  }

  // Saves Order Plan to Database
  Future<void> saveOrderPlan() async {
    final date = _dateController.text.trim();
    final targetCost = double.tryParse(_targetCostController.text) ?? 0.0;

    // Makes sure fields are filled out appropriately
    if (date.isEmpty || targetCost == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid date and target cost.')),
      );
      return;
    }

    final orderPlan = {
      'date': date,
      'food_items': selectedItems.join(', '),
      'target_cost': selectedCost, // Save selectedCost as targetCost
    };

    await DatabaseHelper.instance.insertOrderPlan(orderPlan);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order plan saved successfully!')),
    );

    setState(() {
      selectedItems.clear();
      selectedCost = 0.0;
      _targetCostController.clear();
      _dateController.clear();
    });
  }

  // Navigation for the order plan screen to query, edit, delete order plan
  void navigateToOrderPlanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPlanScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOFE Eats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _targetCostController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Cost',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: foodItems.isEmpty
                  ? Center(child: Text('No food items available.'))
                  : ListView.builder(
                      itemCount: foodItems.length,
                      itemBuilder: (context, index) {
                        final item = foodItems[index];
                        final isSelected = selectedItems.contains(item['name']);
                        return ListTile(
                          title: Text(item['name']),
                          subtitle: Text('\$${item['cost'].toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.green),
                                onPressed: () {
                                  toggleItem(item['name'], item['cost'], true);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.red),
                                onPressed: () {
                                  toggleItem(item['name'], item['cost'], false);
                                },
                              ),
                            ],
                          ),
                          selected: isSelected,
                          selectedTileColor: const Color.fromARGB(96, 243, 236, 236),
                        );
                      },
                    ),
            ),
            Text(
              'Total Selected Cost: \$${selectedCost.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: saveOrderPlan,
                  child: Text('Save Order Plan'),
                ),
                ElevatedButton(
                  onPressed: navigateToOrderPlanScreen,
                  child: Text('Query Order Plan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
