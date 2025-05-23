
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? get currentUserId => _auth.currentUser?.uid;
  
  Stream<List<NotificationModel>> getProviderNotifications() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('notifications')
        .where('providerId', isEqualTo: currentUserId) 
        .where('type', whereIn: ['clientRequest', 'booking_rejected', 'info']) 
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .where((notification) => 
                notification.providerId == currentUserId
              )
              .toList();
        });
  }
  
  Stream<List<NotificationModel>> getClientNotifications() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('notifications')
        .where('clientId', isEqualTo: currentUserId)
        .where('type', whereIn: ['booking', 'approval', 'info', 'booking_rejected']) 
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .where((notification) => 
                notification.clientId == currentUserId
              )
              .toList();
        });
  }
  
  
  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({'isRead': true});
  }
  
  Future<void> markAllAsRead(List<NotificationModel> notifications) async {
    final batch = _firestore.batch();
    for (var notification in notifications) {
      if (!notification.isRead) { 
        batch.update(
          _firestore.collection('notifications').doc(notification.id),
          {'isRead': true},
        );
      }
    }
    await batch.commit();
  }
  
  Future<void> deleteNotification(String id) async {
    await _firestore.collection('notifications').doc(id).delete();
  }
  
  Future<void> sendNotificationToClient({
    required String clientId,
    required String message,
    String? title,
    Map<String, dynamic>? bookingData,
    String? type,
    String? bookingId
  }) async {
    await _firestore.collection('notifications').add({
      'clientId': clientId, 
      'providerId': currentUserId, 
      'title': title ?? 'Booking Update',
      'message': message,
      'isRead': false,
      'time': FieldValue.serverTimestamp(),
      'type': type ?? 'booking',
      'bookingData': bookingData,
      'bookingId': bookingId,
      'createdAt': FieldValue.serverTimestamp(),
      'notificationFor': 'client', 
    });
  }
  
  Future<void> sendNotificationToProvider({
    required String providerId,
    required String message,
    String? title,
    Map<String, dynamic>? clientData,
    String? type,
    String? bookingId
  }) async {
    await _firestore.collection('notifications').add({
      'clientId': currentUserId,
      'providerId': providerId, 
      'title': title ?? 'New Request',
      'message': message,
      'isRead': false,
      'time': FieldValue.serverTimestamp(),
      'type': type ?? 'clientRequest',
      'clientData': clientData,
      'bookingId': bookingId,
      'createdAt': FieldValue.serverTimestamp(),
      'notificationFor': 'provider',   
    });
  }
  
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({'status': status});
  }
  
  Future<void> cleanUpOldNotifications() async {
    final thirtyDaysAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 30))
    );
    
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('createdAt', isLessThan: thirtyDaysAgo)
        .where('isRead', isEqualTo: true)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    if (querySnapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }
}