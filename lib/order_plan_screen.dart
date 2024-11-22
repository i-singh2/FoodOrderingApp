import 'package:flutter/material.dart';
import 'package:foodordering/database_helper.dart';

class OrderPlanScreen extends StatefulWidget {
  @override
  _OrderPlanScreenState createState() => _OrderPlanScreenState();
}

class _OrderPlanScreenState extends State<OrderPlanScreen> {
  // Manage Inputs
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _targetCostController = TextEditingController();

  // Stores the queried order plan and selected items for editing
  Map<String, dynamic>? _orderPlan;
  List<Map<String, dynamic>> foodItems = [];
  List<String> selectedItems = [];
  double selectedCost = 0.0;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchFoodItems(); 
  }

  // Load all food items
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

  // Queries the database for an order plan by the searched date
  Future<void> fetchOrderPlanByDate(String date) async {
    final plans = await DatabaseHelper.instance.fetchOrderPlansByDate(date);
    if (plans.isNotEmpty) {
      setState(() {
        _orderPlan = plans.first;
        selectedItems = (_orderPlan!['food_items'] as String).split(', ');
        selectedCost = double.parse(_orderPlan!['target_cost'].toString());
        _targetCostController.text = selectedCost.toStringAsFixed(2);
      });
    } else {
      setState(() {
        _orderPlan = null;
        selectedItems = [];
        selectedCost = 0.0;
      });
    }
  }

  // Logic for including or excluding items 
  void toggleItem(String itemName, double itemCost, bool isAdding) {
    setState(() {
      if (isAdding) {
        // Check if adding the item exceeds the target cost
        final targetCost = double.tryParse(_targetCostController.text) ?? 0.0;
        if (selectedCost + itemCost <= targetCost) {
          if (!selectedItems.contains(itemName)) {
            selectedItems.add(itemName);
            selectedCost += itemCost;
          }
        } else {
          // Show a message if adding the item exceeds the target cost
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot add this item. Total cost exceeds target cost.'),
            ),
          );
        }
      } else {
        // Remove the item
        if (selectedItems.contains(itemName)) {
          selectedItems.remove(itemName);
          selectedCost -= itemCost;
        }
      }
    });
  }

  // Updates the database with changes to the order plan
  Future<void> updateOrderPlan() async {
    if (_orderPlan != null) {
      final newTargetCost = selectedCost;

      final updatedPlan = {
        'date': _orderPlan!['date'],
        'food_items': selectedItems.join(', '),
        'target_cost': newTargetCost,
      };

      await DatabaseHelper.instance.updateOrderPlan(_orderPlan!['id'], updatedPlan);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order plan updated successfully!')),
      );

      await fetchOrderPlanByDate(_orderPlan!['date']);

      setState(() {
        _targetCostController.text = newTargetCost.toStringAsFixed(2);
        _isEditing = false;
      });
    }
  }

  // Deletes the queried order plan from the database
  Future<void> deleteOrderPlan() async {
    if (_orderPlan != null) {
      await DatabaseHelper.instance.deleteOrderPlan(_orderPlan!['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order plan deleted successfully!')),
      );

      setState(() {
        _orderPlan = null;
        selectedItems = [];
        selectedCost = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Query and Edit Order Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Enter Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_dateController.text.isNotEmpty) {
                  fetchOrderPlanByDate(_dateController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid date.')),
                  );
                }
              },
              child: Text('Search'),
            ),
            SizedBox(height: 16),
            if (_orderPlan != null) ...[
              _isEditing
                  ? Expanded(
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
                          Expanded(
                            child: foodItems.isEmpty
                                ? Center(child: Text('No food items available.'))
                                : ListView.builder(
                                    itemCount: foodItems.length,
                                    itemBuilder: (context, index) {
                                      final item = foodItems[index];
                                      final isSelected =
                                          selectedItems.contains(item['name']);
                                      return ListTile(
                                        title: Text(item['name']),
                                        subtitle: Text(
                                            '\$${item['cost'].toStringAsFixed(2)}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.green),
                                              onPressed: () {
                                                toggleItem(item['name'],
                                                    item['cost'], true);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.remove,
                                                  color: Colors.red),
                                              onPressed: () {
                                                toggleItem(item['name'],
                                                    item['cost'], false);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          Text(
                            'Total Selected Cost: \$${selectedCost.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: updateOrderPlan,
                            child: Text('Save Changes'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Plan Details:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Date: ${_orderPlan!['date']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Target Cost: \$${_orderPlan!['target_cost'].toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Food Items: ${selectedItems.join(', ')}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              child: Text('Edit'),
                            ),
                            ElevatedButton(
                              onPressed: deleteOrderPlan,
                              child: Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
            ] else
              Expanded(
                child: Center(
                  child: Text(
                    'No order plan found.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
