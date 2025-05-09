
class BookingModel {
  final String name;
  final String location;
  final String time;
  final String date;
  final String service;
  final String provider;

  BookingModel({
    required this.name,
    required this.location,
    required this.time,
    required this.date,
    required this.service,
    required this.provider,
  });

  Map<String, String> toMap() {
    return {
      'name': name,
      'location': location,
      'time': time,
      'date': date,
      'service': service,
      'provider': provider,
    };
  }

  factory BookingModel.fromMap(Map<String, String> map) {
    return BookingModel(
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
      service: map['service'] ?? '',
      provider: map['provider'] ?? '',
    );
  }
}