import 'package:flutter/material.dart';
import '../widget/booking_widgets/booking_details_card.dart';
import '../widget/bottom_nav_bar.dart';

class BookingTimesTableView extends StatelessWidget {
  final Map<String, String> bookingData;

  const BookingTimesTableView({
    Key? key,
    required this.bookingData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Times',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  _buildHeaderCell('Name', flex: 1),
                  _buildHeaderCell('Time', flex: 1),
                  _buildHeaderCell('Name Service', flex: 1),
                  _buildHeaderCell('Date', flex: 1),
                ],
              ),
            ),
            
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                  right: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  _buildDataCell(bookingData['name'] ?? '', flex: 1),
                  _buildDataCell(bookingData['time'] ?? '', flex: 1),
                  _buildDataCell(bookingData['service'] ?? '', flex: 1),
                  _buildDataCell(bookingData['date'] ?? '', flex: 1),
                ],
              ),
            ),
            
            for (int i = 0; i < 5; i++)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    right: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    _buildDataCell('', flex: 1),
                    _buildDataCell('', flex: 1),
                    _buildDataCell('', flex: 1),
                    _buildDataCell('', flex: 1),
                  ],
                ),
              ),
            
            const Spacer(),
            
            BookingDetailsCard(
              bookingData: bookingData,
              title: 'Booking Information',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        alignment: Alignment.center,
        height: 50,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}