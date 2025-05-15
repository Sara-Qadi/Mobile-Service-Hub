import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../widget/bottom_nav_bar.dart';

class ProviderClientsTableView extends StatefulWidget {
  const ProviderClientsTableView({Key? key}) : super(key: key);

  @override
  State<ProviderClientsTableView> createState() => _ProviderClientsTableViewState();
}

class _ProviderClientsTableViewState extends State<ProviderClientsTableView> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _clientBookings = [];
  String _errorMessage = '';
  String _providerName = '';

  @override
  void initState() {
    super.initState();
    _getCurrentProviderAndFetchClients();
  }

  Future<void> _getCurrentProviderAndFetchClients() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      print('Current Firebase user UID: ${user.uid}');

      final providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .get();

      if (!providerDoc.exists) {
        throw Exception('Provider profile not found');
      }

      final providerData = providerDoc.data();
      _providerName = providerData?['name'] ?? 'Unknown Provider';

      print('Fetched provider name: $_providerName');

      await _fetchClientBookingsFromFirebase();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error loading provider data: $e';
      });
    }
  }

  Future<void> _fetchClientBookingsFromFirebase() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookingnow')
          .get()
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Connection timed out');
      });

      print('Looking for bookings for provider: $_providerName');

      List<Map<String, dynamic>> bookings = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['provider']?.toString() != _providerName) {
          print('Skipped booking with provider: ${data['provider']}');
          continue;
        }

        print('Matched booking for provider: ${data['provider']}');

        Map<String, dynamic> bookingMap = {
          'bookingId': doc.id,
          'name': data['name']?.toString() ?? '',
          'service': data['service']?.toString() ?? '',
          'date': data['date']?.toString() ?? '',
          'time': data['time']?.toString() ?? '',
          'location': data['location']?.toString() ?? '',
          'serviceId': data['serviceId']?.toString() ?? '',
          'timestamp': data['timestamp'],
        };

        try {
          final clientQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('firstName', isEqualTo: data['name']?.toString().split(' ')[0])
              .limit(1)
              .get();

          if (clientQuery.docs.isNotEmpty) {
            Map<String, dynamic> clientData = clientQuery.docs.first.data();
            bookingMap['email'] = clientData['email']?.toString() ?? 'No email found';
            bookingMap['clientId'] = clientQuery.docs.first.id;
            bookingMap['notificationsEnabled'] = clientData['notificationsEnabled'] ?? false;
          } else {
            bookingMap['email'] = 'Client data not found';
            bookingMap['clientId'] = '';
            bookingMap['notificationsEnabled'] = false;
          }
        } catch (_) {
          bookingMap['email'] = 'Error retrieving client data';
          bookingMap['clientId'] = '';
          bookingMap['notificationsEnabled'] = false;
        }

        bookings.add(bookingMap);
      }

      // Sort by timestamp (newest first)
      bookings.sort((a, b) {
        var aTimestamp = a['timestamp'];
        var bTimestamp = b['timestamp'];
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;
        return bTimestamp.compareTo(aTimestamp);
      });

      if (mounted) {
        setState(() {
          _clientBookings = bookings;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      String errorMsg = 'Unknown error occurred';
      if (e is TimeoutException) {
        errorMsg = 'Connection timed out. Please check your internet connection.';
      } else if (e is FirebaseException) {
        errorMsg = 'Firebase error: ${e.message ?? 'Unknown Firebase error'}';
      } else {
        errorMsg = 'Error fetching client bookings: $e';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = errorMsg;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteClientBooking(String bookingId, String clientName) async {
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the booking for $clientName?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ?? false;

      if (!confirmDelete) return;

      setState(() => _isLoading = true);

      await FirebaseFirestore.instance.collection('bookingnow').doc(bookingId).delete();

      await _fetchClientBookingsFromFirebase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking for $clientName has been deleted'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete booking: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _retryFetch() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    _fetchClientBookingsFromFirebase();
  }

  Future<void> _sendNotification(String clientId, String clientName) async {
    if (clientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot send notification: Client ID not available'), backgroundColor: Colors.red),
      );
      return;
    }

    final TextEditingController messageController = TextEditingController();

    bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Send Notification to $clientName'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'Enter your notification message',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (result == true && messageController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': clientId,
          'message': messageController.text,
          'sender': _providerName,
          'read': false,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification sent to $clientName'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send notification: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait, data is loading...'), duration: Duration(seconds: 2)),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Clients', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => !_isLoading ? Navigator.pop(context) : null),
          actions: [
            IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _isLoading ? null : _retryFetch, tooltip: 'Refresh'),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)))
            : _hasError
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 100),
                      const SizedBox(height: 16),
                      Text('Error Loading Client Data', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(_errorMessage, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _retryFetch, style: ElevatedButton.styleFrom(backgroundColor: Colors.teal), child: const Text('Retry')),
                    ],
                  ))
                : _clientBookings.isEmpty
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey, size: 80),
                          const SizedBox(height: 16),
                          Text('No Client Bookings Found', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text('You have no client bookings at the moment.', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text('Your Client Bookings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListView(
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 16,
                                          dataRowHeight: 65,
                                          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.teal.shade50),
                                          columns: const [
                                            DataColumn(label: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Service', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                          ],
                                          rows: _clientBookings.map((booking) {
                                            return DataRow(cells: [
                                              DataCell(Text(booking['name'] ?? '')),
                                              DataCell(Text(booking['email'] ?? '')),
                                              DataCell(Text(booking['service'] ?? '')),
                                              DataCell(Text(booking['date'] ?? '')),
                                              DataCell(Text(booking['time'] ?? '')),
                                              DataCell(Text(booking['location'] ?? '')),
                                              DataCell(Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                    onPressed: () => _deleteClientBooking(booking['bookingId'], booking['name']),
                                                    tooltip: 'Delete booking',
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.notifications, color: Colors.amber),
                                                    onPressed: booking['notificationsEnabled']
                                                        ? () => _sendNotification(booking['clientId'], booking['name'])
                                                        : null,
                                                    tooltip: booking['notificationsEnabled']
                                                        ? 'Send notification'
                                                        : 'Notifications disabled',
                                                  ),
                                                ],
                                              )),
                                            ]);
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }
}
