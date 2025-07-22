class ReminderModel {
  final int? id;
  final String? name;
  final DateTime time;
  final double price;
  final double collectedoprice;

  ReminderModel({
    this.id,
    this.name,
    required this.time,
    required this.price,
    required this.collectedoprice,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      name: json['name'],
      time: DateTime.parse(json['time']),
      price: double.parse(json['price'].toString()),
      collectedoprice: double.parse(json['collectedoprice'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price.toString(),
      'collectedoprice': collectedoprice.toString(),
      'time': time.toIso8601String(),
    };
  }
}
