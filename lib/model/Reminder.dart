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
    final utcTime = DateTime.parse(json['time'] as String);
    print(" Time from API raw: ${json['time']}");

    return ReminderModel(
      id: json['id'],
      name: json['name'],
      time: utcTime.toLocal(),
      price: double.parse(json['price'].toString()),
      collectedoprice: double.parse(json['collectedoprice'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'collectedoprice': collectedoprice,
      'time': time.toUtc().toIso8601String(),
    };
  }
}
