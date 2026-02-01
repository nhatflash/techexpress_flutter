
class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? gender;
  final String? address;
  final String? ward;
  final String? province;
  final String? postalCode;
  final String? avatarImage;
  final String? identity;
  final double? salary;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.gender,
    this.address,
    this.ward,
    this.province,
    this.postalCode,
    this.avatarImage,
    this.identity,
    this.salary
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      gender: json['gender'],
      address: json['address'],
      ward: json['ward'],
      province: json['province'],
      postalCode: json['postalCode'],
      avatarImage: json['avatarImage'],
      identity: json['identity'],
      salary: json['salary']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'gender': gender,
      'address': address,
      'ward': ward,
      'province': province,
      'postalCode': postalCode,
      'avatarImage': avatarImage,
      'identity': identity,
      'salary': salary,
    };
  }
}

