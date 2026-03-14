class UserModel {
  final String name;
  final String password;
  final String email;
  String? uId;
  String? pic;
  UserModel({
    required this.name,
    required this.password,
    required this.email,
    this.uId,
    this.pic,
  });
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      pic: map['pic'] ?? '',
      uId: map['uId'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'password': password,
      'email': email,
      'pic': pic,
      'uId': uId,
    };
  }
}
