class FoodItem {
  final int? id;
  final String name;
  final double cost;

  // Represents a food item with a name and cost
  FoodItem({this.id, required this.name, required this.cost});

  // Converts a FoodItem to a map for database storage
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'cost': cost};
  }

  static FoodItem fromMap(Map<String, dynamic> map) {
    return FoodItem(id: map['id'], name: map['name'], cost: map['cost']);
  }
}

class OrderPlan {
  final int? id;
  final String date;
  final String foodItems; // Comma-separated list of food item names
  final double targetCost;

  // Represents an order plan with a date, food items, and target cost
  OrderPlan({this.id, required this.date, required this.foodItems, required this.targetCost});

  // Converts an Order Plan to a map for database storage
  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date, 'food_items': foodItems, 'target_cost': targetCost};
  }

  static OrderPlan fromMap(Map<String, dynamic> map) {
    return OrderPlan(id: map['id'], date: map['date'], foodItems: map['food_items'], targetCost: map['target_cost']);
  }
}
