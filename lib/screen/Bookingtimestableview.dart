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
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Table header
                              Row(
                                children: [
                                  _buildHeaderCell('Name'),
                                  _buildHeaderCell('Time'),
                                  _buildHeaderCell('Name Service'),
                                  _buildHeaderCell('Date'),
                                ],
                              ),
                              
                              // First data row with booking data
                              _buildDataRow([
                                bookingData['name'] ?? '',
                                bookingData['time'] ?? '',
                                bookingData['service'] ?? '',
                                bookingData['date'] ?? '',
                              ]),
                              
                              // Empty rows
                              for (int i = 0; i < 5; i++)
                                _buildDataRow(['', '', '', '']),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
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

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
            right: BorderSide(color: Colors.grey.shade300),
            bottom: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 56),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buildDataRow(List<String> cells) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cells.map((text) => _buildDataCell(text)).toList(),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
            bottom: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 50),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }
}