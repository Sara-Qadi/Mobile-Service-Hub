// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'dart:async';
// // import '../widget/booking_widgets/booking_details_card.dart';
// // import '../widget/bottom_nav_bar.dart';

// // class BookingTimesTableView extends StatefulWidget {
// //   final Map<String, String> bookingData;
// //   const BookingTimesTableView({
// //     Key? key,
// //     required this.bookingData,
// //   }) : super(key: key);

// //   @override
// //   State<BookingTimesTableView> createState() => _BookingTimesTableViewState();
// // }

// // class _BookingTimesTableViewState extends State<BookingTimesTableView> {
// //   bool _isLoading = true;
// //   bool _hasError = false;
// //   List<Map<String, String>> _allBookings = [];
// //   String _errorMessage = '';
// //   static Map<String, String> _providerNames = {}; 
// //   static bool _dataFetched = false; 
// //   static List<Map<String, String>> _cachedBookings = []; 

// //   @override
// //   void initState() {
// //     super.initState();
    
// //     if (!_dataFetched) {
// //       _fetchBookingsFromFirebase();
// //     } else {
// //       setState(() {
// //         _allBookings = List.from(_cachedBookings);
// //         _isLoading = false;
// //         _hasError = false;
// //       });
// //       _resolveCurrentBookingProvider();
// //     }
// //   }

// //   Future<void> _resolveCurrentBookingProvider() async {
// //     String currentProviderId = widget.bookingData['provider'] ?? '';
// //     if (currentProviderId.isNotEmpty && !_providerNames.containsKey(currentProviderId)) {
// //       String currentProviderName = await _getProviderName(currentProviderId);
// //       widget.bookingData['provider'] = currentProviderName;
// //       if (mounted) {
// //         setState(() {});  
// //       }
// //     } else if (_providerNames.containsKey(currentProviderId)) {
// //       widget.bookingData['provider'] = _providerNames[currentProviderId]!;
// //     }
// //   }

// //   Future<String> _getProviderName(String providerId) async {
    
// //     if (_providerNames.containsKey(providerId)) {
// //       return _providerNames[providerId]!;
// //     }

// //     try {
// //       final userDoc = await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(providerId)
// //           .get()
// //           .timeout(const Duration(seconds: 10));

// //       if (userDoc.exists) {
// //         final data = userDoc.data();
// //         String fullName = _extractFullName(data);
// //         _providerNames[providerId] = fullName;
// //         return fullName;
// //       }

// //       final providerDoc = await FirebaseFirestore.instance
// //           .collection('providers')
// //           .doc(providerId)
// //           .get()
// //           .timeout(const Duration(seconds: 10));

// //       if (providerDoc.exists) {
// //         final data = providerDoc.data();
// //         String fullName = _extractFullName(data);
// //         _providerNames[providerId] = fullName;
// //         return fullName;
// //       }

// //       _providerNames[providerId] = providerId;
// //       return providerId;
// //     } catch (e) {
// //       print('Error fetching provider name for ID $providerId: $e');
// //       _providerNames[providerId] = providerId;
// //       return providerId;
// //     }
// //   }

// //   String _extractFullName(Map<String, dynamic>? data) {
// //     if (data == null) return '';
    
// //     String firstName = data['firstName']?.toString() ?? '';
// //     String lastName = data['lastName']?.toString() ?? '';
    
// //     if (firstName.isNotEmpty && lastName.isNotEmpty) {
// //       return '$firstName $lastName';
// //     } else if (firstName.isNotEmpty) {
// //       return firstName;
// //     } else if (lastName.isNotEmpty) {
// //       return lastName;
// //     } else {
// //       return data['name']?.toString() ?? '';
// //     }
// //   }

// //   Future<void> _fetchBookingsFromFirebase() async {
// //     try {
// //       final fetchOperation = FirebaseFirestore.instance
// //           .collection('bookingnow')
// //           .orderBy('timestamp', descending: true)
// //           .get();

// //       final querySnapshot = await fetchOperation.timeout(
// //         const Duration(seconds: 15),
// //         onTimeout: () {
// //           throw TimeoutException('Connection timed out');
// //         },
// //       );

// //       List<Map<String, String>> bookings = [];
      
// //       for (var doc in querySnapshot.docs) {
// //         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
// //         String providerId = data['provider']?.toString() ?? '';
// //         String providerName = '';
        
// //         if (providerId.isNotEmpty) {
// //           providerName = await _getProviderName(providerId);
// //         }

// //         Map<String, String> bookingMap = {
// //           'name': data['name']?.toString() ?? '',
// //           'time': data['time']?.toString() ?? '',
// //           'service': data['service']?.toString() ?? '',
// //           'date': data['date']?.toString() ?? '',
// //           'location': data['location']?.toString() ?? '',
// //           'provider': providerName, 
// //           'providerId': providerId, 
// //           'serviceId': data['serviceId']?.toString() ?? '',
// //           'id': doc.id,
// //         };
        
// //         if (doc.id != widget.bookingData['id']) {
// //           bookings.add(bookingMap);
// //         }
// //       }

// //       _cachedBookings = List.from(bookings);
// //       _dataFetched = true;

// //       String currentProviderId = widget.bookingData['provider'] ?? '';
// //       if (currentProviderId.isNotEmpty && !_providerNames.containsKey(currentProviderId)) {
// //         String currentProviderName = await _getProviderName(currentProviderId);
// //         widget.bookingData['provider'] = currentProviderName;
// //       } else if (_providerNames.containsKey(currentProviderId)) {
// //         widget.bookingData['provider'] = _providerNames[currentProviderId]!;
// //       }

// //       if (mounted) {
// //         setState(() {
// //           _allBookings = bookings;
// //           _isLoading = false;
// //           _hasError = false;
// //         });
// //       }
// //     } catch (e) {
// //       String errorMsg = _getErrorMessage(e);

// //       if (mounted) {
// //         setState(() {
// //           _isLoading = false;
// //           _hasError = true;
// //           _errorMessage = errorMsg;
// //         });
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(errorMsg),
// //             backgroundColor: Colors.red,
// //             duration: const Duration(seconds: 5),
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   String _getErrorMessage(dynamic error) {
// //     if (error is TimeoutException) {
// //       return 'Connection timed out. Please check your internet connection.';
// //     } else if (error is FirebaseException) {
// //       return 'Firebase error: ${error.message ?? 'Unknown Firebase error'}';
// //     } else {
// //       return 'Error fetching bookings: $error';
// //     }
// //   }

// //   void _retryFetch() {
// //     setState(() {
// //       _isLoading = true;
// //       _hasError = false;
// //       _errorMessage = '';
// //     });
// //     _dataFetched = false;
// //     _cachedBookings.clear();
// //     _providerNames.clear(); 
// //     _fetchBookingsFromFirebase();
// //   }

// //   void refreshData() {
// //     _dataFetched = false;
// //     _cachedBookings.clear();
// //     _retryFetch();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () async {
// //         if (_isLoading) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text('Please wait, data is loading...'),
// //               duration: Duration(seconds: 2),
// //             ),
// //           );
// //           return false;
// //         }
// //         return true;
// //       },
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: Text(
// //             'Booking Times',
// //             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
// //               color: Colors.white,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           backgroundColor: Colors.teal,
// //           centerTitle: true,
// //           elevation: 0,
// //           leading: IconButton(
// //             icon: const Icon(Icons.arrow_back, color: Colors.white),
// //             onPressed: () {
// //               if (!_isLoading) {
// //                 Navigator.pop(context);
// //               }
// //             },
// //           ),
// //           actions: [
// //             IconButton(
// //               icon: const Icon(Icons.refresh, color: Colors.white),
// //               onPressed: _isLoading ? null : refreshData,
// //               tooltip: 'Refresh bookings',
// //             ),
// //           ],
// //         ),
// //         body: _isLoading
// //             ? const Center(
// //                 child: CircularProgressIndicator(
// //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
// //                 ),
// //               )
// //             : _hasError
// //                 ? Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         const Icon(
// //                           Icons.error_outline,
// //                           color: Colors.red,
// //                           size: 100,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         Text(
// //                           'Error Loading Bookings',
// //                           style: Theme.of(context).textTheme.headlineSmall,
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Text(
// //                           _errorMessage,
// //                           textAlign: TextAlign.center,
// //                           style: Theme.of(context).textTheme.bodyMedium,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         ElevatedButton(
// //                           onPressed: _retryFetch,
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: Colors.teal,
// //                           ),
// //                           child: const Text('Retry'),
// //                         ),
// //                       ],
// //                     ),
// //                   )
// //                 : Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       children: [
// //                         BookingDetailsCard(
// //                           bookingData: widget.bookingData,
// //                           title: 'Your Booking',
// //                         ),
// //                         const SizedBox(height: 16),
// //                         Expanded(
// //                           child: Card(
// //                             elevation: 4,
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: Padding(
// //                               padding: const EdgeInsets.all(8.0),
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Padding(
// //                                     padding: const EdgeInsets.all(8.0),
// //                                     child: Text(
// //                                       'Other Bookings (${_allBookings.length})',
// //                                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
// //                                         fontWeight: FontWeight.bold,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   Expanded(
// //                                     child: _allBookings.isEmpty
// //                                         ? Center(
// //                                             child: Column(
// //                                               mainAxisAlignment: MainAxisAlignment.center,
// //                                               children: [
// //                                                 Icon(
// //                                                   Icons.event_busy,
// //                                                   size: 64,
// //                                                   color: Colors.grey,
// //                                                 ),
// //                                                 SizedBox(height: 16),
// //                                                 Text(
// //                                                   'No other bookings found',
// //                                                   style: TextStyle(
// //                                                     fontSize: 16,
// //                                                     color: Colors.grey,
// //                                                   ),
// //                                                 ),
// //                                               ],
// //                                             ),
// //                                           )
// //                                         : _buildBookingsTable(),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //         bottomNavigationBar: const BottomNavBar(currentIndex: 1),
// //       ),
// //     );
// //   }

// //   Widget _buildBookingsTable() {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         if (constraints.maxWidth < 600) {
// //           return ListView.builder(
// //             itemCount: _allBookings.length,
// //             itemBuilder: (context, index) {
// //               final booking = _allBookings[index];
// //               return Card(
// //                 margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
// //                 child: ExpansionTile(
// //                   title: Text(
// //                     booking['name'] ?? 'Unknown',
// //                     style: const TextStyle(fontWeight: FontWeight.bold),
// //                   ),
// //                   subtitle: Text(
// //                     '${booking['service'] ?? 'Unknown Service'} - ${booking['date'] ?? 'Unknown Date'}'
// //                   ),
// //                   children: [
// //                     Padding(
// //                       padding: const EdgeInsets.all(16.0),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           _buildInfoRow('Service', booking['service'] ?? 'N/A'),
// //                           _buildInfoRow('Provider', booking['provider'] ?? 'N/A'),
// //                           _buildInfoRow('Location', booking['location'] ?? 'N/A'),
// //                           _buildInfoRow('Date', booking['date'] ?? 'N/A'),
// //                           _buildInfoRow('Time', booking['time'] ?? 'N/A'),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             },
// //           );
// //         }
// //         return SingleChildScrollView(
// //           scrollDirection: Axis.horizontal,
// //           child: DataTable(
// //             columnSpacing: 16,
// //             dataRowHeight: 60,
// //             headingRowColor: MaterialStateColor.resolveWith(
// //               (states) => Colors.teal.shade50,
// //             ),
// //             columns: const [
// //               DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
// //               DataColumn(label: Text('Service', style: TextStyle(fontWeight: FontWeight.bold))),
// //               DataColumn(label: Text('Provider', style: TextStyle(fontWeight: FontWeight.bold))),
// //               DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
// //               DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
// //               DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
// //             ],
// //             rows: _allBookings.map((booking) {
// //               return DataRow(
// //                 cells: [
// //                   DataCell(Text(booking['name'] ?? 'N/A')),
// //                   DataCell(Text(booking['service'] ?? 'N/A')),
// //                   DataCell(Text(booking['provider'] ?? 'N/A')), 
// //                   DataCell(Text(booking['location'] ?? 'N/A')),
// //                   DataCell(Text(booking['date'] ?? 'N/A')),
// //                   DataCell(Text(booking['time'] ?? 'N/A')),
// //                 ],
// //               );
// //             }).toList(),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildInfoRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8.0),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //             width: 80,
// //             child: Text(
// //               '$label:',
// //               style: const TextStyle(fontWeight: FontWeight.bold),
// //             ),
// //           ),
// //           Expanded(
// //             child: Text(value),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }




// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:async';
// import '../widget/booking_widgets/booking_details_card.dart';
// import '../widget/bottom_nav_bar.dart';

// class BookingTimesTableView extends StatefulWidget {
//   final Map<String, String> bookingData;
//   const BookingTimesTableView({
//     Key? key,
//     required this.bookingData,
//   }) : super(key: key);

//   @override
//   State<BookingTimesTableView> createState() => _BookingTimesTableViewState();
// }

// class _BookingTimesTableViewState extends State<BookingTimesTableView> {
//   bool _isLoading = true;
//   bool _hasError = false;
//   List<Map<String, String>> _allBookings = [];
//   String _errorMessage = '';
//   static Map<String, String> _providerNames = {}; 
//   static bool _dataFetched = false; 
//   static List<Map<String, String>> _cachedBookings = [];
  
//   // متغير منفصل لحفظ بيانات الـ current booking بعد تحويل الـ provider ID إلى اسم
//   Map<String, String> _currentBookingData = {};

//   @override
//   void initState() {
//     super.initState();
    
//     // نسخ بيانات الـ booking الحالي
//     _currentBookingData = Map.from(widget.bookingData);
    
//     if (!_dataFetched) {
//       _fetchBookingsFromFirebase();
//     } else {
//       setState(() {
//         _allBookings = List.from(_cachedBookings);
//         _isLoading = false;
//         _hasError = false;
//       });
//       _resolveCurrentBookingProvider();
//     }
//   }

//   Future<void> _resolveCurrentBookingProvider() async {
//     String currentProviderId = _currentBookingData['provider'] ?? '';
//     if (currentProviderId.isNotEmpty) {
//       String currentProviderName = await _getProviderName(currentProviderId);
//       setState(() {
//         _currentBookingData['provider'] = currentProviderName;
//       });
//     }
//   }

//   Future<String> _getProviderName(String providerId) async {
//     // التحقق من الـ cache أولاً
//     if (_providerNames.containsKey(providerId)) {
//       return _providerNames[providerId]!;
//     }

//     try {
//       // البحث في مجموعة users فقط لأنك قلت ما عندك providers collection
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(providerId)
//           .get()
//           .timeout(const Duration(seconds: 10));

//       if (userDoc.exists) {
//         final data = userDoc.data();
//         String fullName = _extractFullName(data);
//         _providerNames[providerId] = fullName;
//         return fullName;
//       }

//       // إذا لم يوجد، نحفظ الـ ID كما هو
//       _providerNames[providerId] = providerId;
//       return providerId;
//     } catch (e) {
//       print('Error fetching provider name for ID $providerId: $e');
//       _providerNames[providerId] = providerId;
//       return providerId;
//     }
//   }

//   String _extractFullName(Map<String, dynamic>? data) {
//     if (data == null) return '';
    
//     String firstName = data['firstName']?.toString() ?? '';
//     String lastName = data['lastName']?.toString() ?? '';
    
//     if (firstName.isNotEmpty && lastName.isNotEmpty) {
//       return '$firstName $lastName';
//     } else if (firstName.isNotEmpty) {
//       return firstName;
//     } else if (lastName.isNotEmpty) {
//       return lastName;
//     } else {
//       return data['name']?.toString() ?? '';
//     }
//   }

//   Future<void> _fetchBookingsFromFirebase() async {
//     try {
//       final fetchOperation = FirebaseFirestore.instance
//           .collection('bookingnow')
//           .orderBy('timestamp', descending: true)
//           .get();

//       final querySnapshot = await fetchOperation.timeout(
//         const Duration(seconds: 15),
//         onTimeout: () {
//           throw TimeoutException('Connection timed out');
//         },
//       );

//       List<Map<String, String>> bookings = [];
      
//       for (var doc in querySnapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
//         String providerId = data['provider']?.toString() ?? '';
//         String providerName = '';
        
//         if (providerId.isNotEmpty) {
//           providerName = await _getProviderName(providerId);
//         }

//         Map<String, String> bookingMap = {
//           'name': data['name']?.toString() ?? '',
//           'time': data['time']?.toString() ?? '',
//           'service': data['service']?.toString() ?? '',
//           'date': data['date']?.toString() ?? '',
//           'location': data['location']?.toString() ?? '',
//           'provider': providerName, 
//           'providerId': providerId, 
//           'serviceId': data['serviceId']?.toString() ?? '',
//           'id': doc.id,
//         };
        
//         // استبعاد الـ current booking من القائمة
//         if (doc.id != _currentBookingData['id']) {
//           bookings.add(bookingMap);
//         }
//       }

//       _cachedBookings = List.from(bookings);
//       _dataFetched = true;

//       // حل اسم الـ provider للـ current booking
//       await _resolveCurrentBookingProvider();

//       if (mounted) {
//         setState(() {
//           _allBookings = bookings;
//           _isLoading = false;
//           _hasError = false;
//         });
//       }
//     } catch (e) {
//       String errorMsg = _getErrorMessage(e);

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _hasError = true;
//           _errorMessage = errorMsg;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMsg),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       }
//     }
//   }

//   String _getErrorMessage(dynamic error) {
//     if (error is TimeoutException) {
//       return 'Connection timed out. Please check your internet connection.';
//     } else if (error is FirebaseException) {
//       return 'Firebase error: ${error.message ?? 'Unknown Firebase error'}';
//     } else {
//       return 'Error fetching bookings: $error';
//     }
//   }

//   void _retryFetch() {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       _errorMessage = '';
//     });
//     _dataFetched = false;
//     _cachedBookings.clear();
//     _providerNames.clear(); 
//     _fetchBookingsFromFirebase();
//   }

//   void refreshData() {
//     _dataFetched = false;
//     _cachedBookings.clear();
//     _retryFetch();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_isLoading) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Please wait, data is loading...'),
//               duration: Duration(seconds: 2),
//             ),
//           );
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Booking Times',
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: Colors.teal,
//           centerTitle: true,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () {
//               if (!_isLoading) {
//                 Navigator.pop(context);
//               }
//             },
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh, color: Colors.white),
//               onPressed: _isLoading ? null : refreshData,
//               tooltip: 'Refresh bookings',
//             ),
//           ],
//         ),
//         body: _isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
//                 ),
//               )
//             : _hasError
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.error_outline,
//                           color: Colors.red,
//                           size: 100,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Error Loading Bookings',
//                           style: Theme.of(context).textTheme.headlineSmall,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _errorMessage,
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _retryFetch,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.teal,
//                           ),
//                           child: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         BookingDetailsCard(
//                           bookingData: _currentBookingData, // استخدام البيانات المحدثة
//                           title: 'Your Booking',
//                         ),
//                         const SizedBox(height: 16),
//                         Expanded(
//                           child: Card(
//                             elevation: 4,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       'Other Bookings (${_allBookings.length})',
//                                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: _allBookings.isEmpty
//                                         ? Center(
//                                             child: Column(
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               children: [
//                                                 Icon(
//                                                   Icons.event_busy,
//                                                   size: 64,
//                                                   color: Colors.grey,
//                                                 ),
//                                                 SizedBox(height: 16),
//                                                 Text(
//                                                   'No other bookings found',
//                                                   style: TextStyle(
//                                                     fontSize: 16,
//                                                     color: Colors.grey,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           )
//                                         : _buildBookingsTable(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//         bottomNavigationBar: const BottomNavBar(currentIndex: 1),
//       ),
//     );
//   }

//   Widget _buildBookingsTable() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.maxWidth < 600) {
//           return ListView.builder(
//             itemCount: _allBookings.length,
//             itemBuilder: (context, index) {
//               final booking = _allBookings[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
//                 child: ExpansionTile(
//                   title: Text(
//                     booking['name'] ?? 'Unknown',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     '${booking['service'] ?? 'Unknown Service'} - ${booking['date'] ?? 'Unknown Date'}'
//                   ),
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildInfoRow('Service', booking['service'] ?? 'N/A'),
//                           _buildInfoRow('Provider', booking['provider'] ?? 'N/A'),
//                           _buildInfoRow('Location', booking['location'] ?? 'N/A'),
//                           _buildInfoRow('Date', booking['date'] ?? 'N/A'),
//                           _buildInfoRow('Time', booking['time'] ?? 'N/A'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         }
//         return SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             columnSpacing: 16,
//             dataRowHeight: 60,
//             headingRowColor: MaterialStateColor.resolveWith(
//               (states) => Colors.teal.shade50,
//             ),
//             columns: const [
//               DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Service', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Provider', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
//             ],
//             rows: _allBookings.map((booking) {
//               return DataRow(
//                 cells: [
//                   DataCell(Text(booking['name'] ?? 'N/A')),
//                   DataCell(Text(booking['service'] ?? 'N/A')),
//                   DataCell(Text(booking['provider'] ?? 'N/A')), 
//                   DataCell(Text(booking['location'] ?? 'N/A')),
//                   DataCell(Text(booking['date'] ?? 'N/A')),
//                   DataCell(Text(booking['time'] ?? 'N/A')),
//                 ],
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 80,
//             child: Text(
//               '$label:',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }
// }



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
  static Map<String, String> _providerNames = {}; 
  static bool _dataFetched = false; 
  static List<Map<String, String>> _cachedBookings = [];
  
  // Current booking data with resolved provider name
  Map<String, String> _currentBookingData = {};

  @override
  void initState() {
    super.initState();
    
    // Copy current booking data
    _currentBookingData = Map.from(widget.bookingData);
    
    // Clear cache to avoid duplicates
    _clearCache();
    
    _fetchBookingsFromFirebase();
  }

  void _clearCache() {
    _dataFetched = false;
    _cachedBookings.clear();
    _providerNames.clear();
  }

  Future<String> _getProviderName(String providerId) async {
    // Check cache first
    if (_providerNames.containsKey(providerId)) {
      return _providerNames[providerId]!;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(providerId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        final data = userDoc.data();
        String fullName = _extractFullName(data);
        _providerNames[providerId] = fullName;
        return fullName;
      }

      // If not found, save ID as is
      _providerNames[providerId] = providerId;
      return providerId;
    } catch (e) {
      print('Error fetching provider name for ID $providerId: $e');
      _providerNames[providerId] = providerId;
      return providerId;
    }
  }

  String _extractFullName(Map<String, dynamic>? data) {
    if (data == null) return '';
    
    String firstName = data['firstName']?.toString() ?? '';
    String lastName = data['lastName']?.toString() ?? '';
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else {
      return data['name']?.toString() ?? '';
    }
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
      Set<String> processedIds = {}; // To avoid duplicates
      
      for (var doc in querySnapshot.docs) {
        // Skip if already processed
        if (processedIds.contains(doc.id)) {
          continue;
        }
        processedIds.add(doc.id);
        
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        String providerId = data['provider']?.toString() ?? '';
        String providerName = '';
        
        if (providerId.isNotEmpty) {
          providerName = await _getProviderName(providerId);
        }

        Map<String, String> bookingMap = {
          'name': data['name']?.toString() ?? '',
          'time': data['time']?.toString() ?? '',
          'service': data['service']?.toString() ?? '',
          'date': data['date']?.toString() ?? '',
          'location': data['location']?.toString() ?? '',
          'provider': providerName, 
          'providerId': providerId, 
          'serviceId': data['serviceId']?.toString() ?? '',
          'id': doc.id,
        };
        
        // Exclude current booking from the list
        if (doc.id != _currentBookingData['id']) {
          bookings.add(bookingMap);
        }
      }

      _cachedBookings = List.from(bookings);
      _dataFetched = true;

      if (mounted) {
        setState(() {
          _allBookings = bookings;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      String errorMsg = _getErrorMessage(e);

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

  String _getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Connection timed out. Please check your internet connection.';
    } else if (error is FirebaseException) {
      return 'Firebase error: ${error.message ?? 'Unknown Firebase error'}';
    } else {
      return 'Error fetching bookings: $error';
    }
  }

  void _retryFetch() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    _clearCache();
    _fetchBookingsFromFirebase();
  }

  void refreshData() {
    _clearCache();
    _retryFetch();
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _isLoading ? null : refreshData,
              tooltip: 'Refresh bookings',
            ),
          ],
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
                        BookingDetailsCard(
                          bookingData: _currentBookingData,
                          title: 'Your Booking',
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Other Bookings (${_allBookings.length})',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _allBookings.isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.event_busy,
                                                  size: 64,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  'No other bookings found',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : _buildBookingsTable(),
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

  Widget _buildBookingsTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return ListView.builder(
            itemCount: _allBookings.length,
            itemBuilder: (context, index) {
              final booking = _allBookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: ExpansionTile(
                  title: Text(
                    booking['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${booking['service'] ?? 'Unknown Service'} - ${booking['date'] ?? 'Unknown Date'}'
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Service', booking['service'] ?? 'N/A'),
                          _buildInfoRow('Provider', booking['provider'] ?? 'N/A'),
                          _buildInfoRow('Location', booking['location'] ?? 'N/A'),
                          _buildInfoRow('Date', booking['date'] ?? 'N/A'),
                          _buildInfoRow('Time', booking['time'] ?? 'N/A'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return SingleChildScrollView(
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
            rows: _allBookings.map((booking) {
              return DataRow(
                cells: [
                  DataCell(Text(booking['name'] ?? 'N/A')),
                  DataCell(Text(booking['service'] ?? 'N/A')),
                  DataCell(Text(booking['provider'] ?? 'N/A')), 
                  DataCell(Text(booking['location'] ?? 'N/A')),
                  DataCell(Text(booking['date'] ?? 'N/A')),
                  DataCell(Text(booking['time'] ?? 'N/A')),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}