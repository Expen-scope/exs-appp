import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? geminiApiKey;
  final String? aiApiKey;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.geminiApiKey,
    this.aiApiKey,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      geminiApiKey: json['gemini_api_key'],
      aiApiKey: json['ai_api_key'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gemini_api_key': geminiApiKey,
      'ai_api_key': aiApiKey,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory UserModel.fromJsonString(String source) =>
      UserModel.fromJson(json.decode(source));
}
