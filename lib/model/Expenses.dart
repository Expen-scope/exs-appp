class Expense {
  final int? id;
  final String source;
  final double price;
  final String category;
  final String currency;
  final String? description;
  final String date;

  Expense({
    this.id,
    required this.source,
    required this.price,
    required this.category,
    required this.currency,
    this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      source: json['source'] ?? 'Unknown Source',
      price: double.parse(json['price'].toString()),
      category: json['category'] ?? 'Uncategorized',
      currency: json['currency'] ?? 'N/A',
      description: json['description'],
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_transaction': 'expense',
      'source': source,
      'category': category,
      'price': price,
      'currency': currency,
      'description': description,
      'date': date,
    };
  }
}
