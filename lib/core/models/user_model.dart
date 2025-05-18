// lib/models/user_model.dart
class UserModel {
  final int? id;
  final String? name;
  final String? type;
  final String? email;
  final String? phone;
  final String? image;
  final String? address;
  final String? createdAt;
  final String? updatedAt;
  final String? token;

  UserModel({
    this.id,
    this.name,
    this.type,
    this.email,
    this.phone,
    this.image,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      address: json['address'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'email': email,
      'phone': phone,
      'image': image,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'token': token,
    };
  }

}
