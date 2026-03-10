class AppUser {
  final String name;
  final String email;
  final String phone;
  final String uid;
  final String address;
  final String? pic;

  // جعلنا الحقول final لزيادة الأمان (Immutable)
  AppUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.uid,
    required this.address,
    this.pic,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'uid': uid,
      'address': address,
      'pic': pic,
    };
  }

  // استخدام الـ factory مع التعامل مع الـ Nulls بحذر
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      name: map['name'] ?? '', // لو الاسم مش موجود حط نص فاضي بدل ما يضرب
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      uid: map['uid'] ?? '',
      address: map['address'] ?? '',
      pic: map['pic'], // اختياري فممكن يكون null عادي
    );
  }

  @override
  String toString() =>
      'AppUser(name: $name, email: $email, phone: $phone, uid: $uid, address: $address)';
}
