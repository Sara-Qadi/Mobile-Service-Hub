
// class ProviderModel {
//   final String name;
//   final String email;
//   final String phone;
//   final String specialty;
//   final String experience;
//   final String location;
//   final String rating;
//   final String availability;

//   ProviderModel({
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.specialty,
//     required this.experience,
//     required this.location,
//     required this.rating,
//     required this.availability,
//   });

//   Map<String, String> toMap() {
//     return {
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'specialty': specialty,
//       'experience': experience,
//       'location': location,
//       'rating': rating,
//       'availability': availability,
//     };
//   }

//   factory ProviderModel.fromMap(Map<String, String> map) {
//     return ProviderModel(
//       name: map['name'] ?? '',
//       email: map['email'] ?? '',
//       phone: map['phone'] ?? '',
//       specialty: map['specialty'] ?? '',
//       experience: map['experience'] ?? '',
//       location: map['location'] ?? '',
//       rating: map['rating'] ?? '',
//       availability: map['availability'] ?? '',
//     );
//   }
// }