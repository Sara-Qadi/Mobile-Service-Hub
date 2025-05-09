
enum NotificationType {
  booking,
  reminder,
  promotion,
  info,
  provider,
  clientRequest,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final NotificationType type;
  final Map<String, String>? bookingData;
  final Map<String, String>? providerData;
  final Map<String, String>? clientData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
    this.bookingData,
    this.providerData,
    this.clientData,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? isRead,
    NotificationType? type,
    Map<String, String>? bookingData,
    Map<String, String>? providerData,
    Map<String, String>? clientData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      bookingData: bookingData ?? this.bookingData,
      providerData: providerData ?? this.providerData,
      clientData: clientData ?? this.clientData,
    );
  }
}