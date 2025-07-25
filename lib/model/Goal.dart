class GoalModel {
  final int? id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime time;
  final int? userId;
  final String? updatedAt;
  final String? createdAt;

  GoalModel({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.time,
    this.userId,
    this.updatedAt,
    this.createdAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      name: json['name'],
      targetAmount: json['target_amount'].toDouble(),
      savedAmount: json['saved_amount'].toDouble(),
      time: DateTime.parse(json['time']),
      userId: json['user_id'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'time': time.toIso8601String(),
    };
  }

  GoalModel copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? time,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      time: time ?? this.time,
    );
  }
}
