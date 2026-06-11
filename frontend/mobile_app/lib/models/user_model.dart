class UserModel {
  final int id;
  final String username;
  final String fullName;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'],
    );
  }
}