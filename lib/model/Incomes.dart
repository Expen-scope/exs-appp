class Income {
  final int? id;
  final String source;
  final double price;
  final String category;
  final String currency;
  final String? description;
  final String date;

  Income({
    this.id,
    required this.source,
    required this.price,
    required this.category,
    required this.currency,
    this.description,
    required this.date,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      source: json['source'] ?? 'Unknown Source',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      category: json['category_name'] ?? json['category'] ?? 'Uncategorized',
      currency: json['currency'] ?? 'N/A',
      description: json['description'],
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_transaction': 'income',
      'source': source,
      'category': category,
      'price': price,
      'currency': currency,
      'description': description,
      'date': date,
    };
  }
}
