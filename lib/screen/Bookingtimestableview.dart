import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../widget/booking_widgets/booking_details_card.dart';
import '../widget/bottom_nav_bar.dart';

class BookingTimesTableView extends StatefulWidget {
  final Map<String, String> bookingData;

  const BookingTimesTableView({
    Key? key,
    required this.bookingData,
  }) : super(key: key);

  @override
  State<BookingTimesTableView> createState() => _BookingTimesTableViewState();
}

class _BookingTimesTableViewState extends State<BookingTimesTableView> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, String>> _allBookings = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBookingsFromFirebase();
  }

  Future<void> _fetchBookingsFromFirebase() async {
    try {
      final fetchOperation = FirebaseFirestore.instance
          .collection('bookingnow')
          .orderBy('timestamp', descending: true)
          .get();

      final querySnapshot = await fetchOperation.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      List<Map<String, String>> bookings = [];
      
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        Map<String, String> bookingMap = {
          'name': data['name']?.toString() ?? '',
          'time': data['time']?.toString() ?? '',
          'service': data['service']?.toString() ?? '',
          'date': data['date']?.toString() ?? '',
          'location': data['location']?.toString() ?? '',
          'provider': data['provider']?.toString() ?? '',
          'serviceId': data['serviceId']?.toString() ?? '',
          'id': doc.id,
        };
        
        bookings.add(bookingMap);
      }

      if (mounted) {
        setState(() {
          _allBookings = bookings;
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
        errorMsg = 'Error fetching bookings: $e';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = errorMsg;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
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
    _fetchBookingsFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait, data is loading...'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Booking Times',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.teal,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (!_isLoading) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              )
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 100,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Bookings',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _retryFetch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return ListView(
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 16,
                                          dataRowHeight: 60,
                                          headingRowColor: MaterialStateColor.resolveWith(
                                            (states) => Colors.teal.shade50,
                                          ),
                                          columns: const [
                                            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Service', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Provider', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                                          ],
                                          rows: [
                                            DataRow(
                                              color: MaterialStateColor.resolveWith(
                                                (states) => Colors.teal.withOpacity(0.1),
                                              ),
                                              cells: [
                                                DataCell(Text(widget.bookingData['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                                                DataCell(Text(widget.bookingData['service'] ?? '')),
                                                DataCell(Text(widget.bookingData['provider'] ?? '')),
                                                DataCell(Text(widget.bookingData['location'] ?? '')),
                                                DataCell(Text(widget.bookingData['date'] ?? '')),
                                                DataCell(Text(widget.bookingData['time'] ?? '')),
                                              ],
                                            ),
                                            for (var booking in _allBookings)
                                              if (booking['id'] != widget.bookingData['id'])
                                                DataRow(
                                                  cells: [
                                                    DataCell(Text(booking['name'] ?? '')),
                                                    DataCell(Text(booking['service'] ?? '')),
                                                    DataCell(Text(booking['provider'] ?? '')),
                                                    DataCell(Text(booking['location'] ?? '')),
                                                    DataCell(Text(booking['date'] ?? '')),
                                                    DataCell(Text(booking['time'] ?? '')),
                                                  ],
                                                ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        BookingDetailsCard(
                          bookingData: widget.bookingData,
                          title: 'Booking Information',
                        ),
                      ],
                    ),
                  ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }
}
