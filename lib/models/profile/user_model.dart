class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String location;
  final String role;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.location,
    required this.role,
  });

  Map<String, dynamic> toMap(String uid, double latitude, double longitude) {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        'address': location,
      },
      'role': role,
      'status': role == 'Service Provider' ? 'pending' : 'approved',
      'createdAt': DateTime.now(),
    };
  }
}
