import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { 
  provider, 
  booking, 
  reminder, 
  promotion, 
  info, 
  clientRequest,
  approval,   // Added approval here
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final NotificationType type;
  final Map<String, String>? providerData;
  final Map<String, String>? bookingData;
  final Map<String, String>? clientData;
  final String? userId;
  final String? clientId;
  final String? providerId;
  final String? bookingId;
  final Timestamp? createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
    this.providerData,
    this.bookingData,
    this.clientData,
    this.userId,
    this.clientId,
    this.providerId,
    this.bookingId,
    this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? isRead,
    NotificationType? type,
    Map<String, String>? providerData,
    Map<String, String>? bookingData,
    Map<String, String>? clientData,
    String? userId,
    String? clientId,
    String? providerId,
    String? bookingId,
    Timestamp? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      providerData: providerData ?? this.providerData,
      bookingData: bookingData ?? this.bookingData,
      clientData: clientData ?? this.clientData,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      providerId: providerId ?? this.providerId,
      bookingId: bookingId ?? this.bookingId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    NotificationType notificationType = NotificationType.info;
    switch (data['type']) {
      case 'provider':
        notificationType = NotificationType.provider;
        break;
      case 'booking':
        notificationType = NotificationType.booking;
        break;
      case 'approval':
        notificationType = NotificationType.approval;  // Added here
        break;
      case 'reminder':
        notificationType = NotificationType.reminder;
        break;
      case 'promotion':
        notificationType = NotificationType.promotion;
        break;
      case 'info':
        notificationType = NotificationType.info;
        break;
      case 'clientRequest':
        notificationType = NotificationType.clientRequest;
        break;
    }

    String formattedTime = 'Just now';
    if (data['createdAt'] != null) {
      final timestamp = data['createdAt'] as Timestamp;
      final now = Timestamp.now();
      final difference = now.seconds - timestamp.seconds;
      
      if (difference < 60) {
        formattedTime = 'Just now';
      } else if (difference < 3600) {
        final minutes = (difference / 60).floor();
        formattedTime = '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      } else if (difference < 86400) {
        final hours = (difference / 3600).floor();
        formattedTime = '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference < 172800) {
        formattedTime = 'Yesterday';
      } else {
        final days = (difference / 86400).floor();
        formattedTime = '$days ${days == 1 ? 'day' : 'days'} ago';
      }
    }

    Map<String, String>? providerData;
    Map<String, String>? bookingData;
    Map<String, String>? clientData;
    
    if (data['providerData'] != null) {
      providerData = Map<String, String>.from(
        (data['providerData'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value.toString())
        )
      );
    }
    
    if (data['bookingData'] != null) {
      bookingData = Map<String, String>.from(
        (data['bookingData'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value.toString())
        )
      );
    }
    
    if (data['clientData'] != null) {
      clientData = Map<String, String>.from(
        (data['clientData'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value.toString())
        )
      );
    }

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      time: formattedTime,
      isRead: data['isRead'] ?? false,
      type: notificationType,
      providerData: providerData,
      bookingData: bookingData,
      clientData: clientData,
      userId: data['userId'],
      clientId: data['clientId'],
      providerId: data['providerId'],
      bookingId: data['bookingId'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    String typeString;
    switch (type) {
      case NotificationType.provider:
        typeString = 'provider';
        break;
      case NotificationType.booking:
        typeString = 'booking';
        break;
      case NotificationType.approval:
        typeString = 'approval';  // Added here
        break;
      case NotificationType.reminder:
        typeString = 'reminder';
        break;
      case NotificationType.promotion:
        typeString = 'promotion';
        break;
      case NotificationType.info:
        typeString = 'info';
        break;
      case NotificationType.clientRequest:
        typeString = 'clientRequest';
        break;
    }

    return {
      'title': title,
      'message': message,
      'isRead': isRead,
      'type': typeString,
      'providerData': providerData,
      'bookingData': bookingData,
      'clientData': clientData,
      'userId': userId,
      'clientId': clientId,
      'providerId': providerId,
      'bookingId': bookingId,
      'createdAt': createdAt ?? Timestamp.now(),
    };
  }
}