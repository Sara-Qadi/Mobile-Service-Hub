import 'package:flutter/material.dart';
import '../main.dart';

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
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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

          const SizedBox(height: 24),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Name', bookingData['name'] ?? ''),
                  _buildInfoRow('Service', bookingData['service'] ?? ''),
                  _buildInfoRow('Provider', bookingData['provider'] ?? ''),
                  _buildInfoRow('Location', bookingData['location'] ?? ''),
                  _buildInfoRow('Date', bookingData['date'] ?? ''),
                  _buildInfoRow('Time', bookingData['time'] ?? ''),
                ],
              ),
            ),
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
      height: 60, 
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
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: 2,
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
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: null, 
      ),
    ),
  );
}

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}