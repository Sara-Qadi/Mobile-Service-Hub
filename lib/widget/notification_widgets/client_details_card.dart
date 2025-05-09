import 'package:flutter/material.dart';

class ClientDetailsCard extends StatelessWidget {
  final Map<String, String> clientData;

  const ClientDetailsCard({
    Key? key,
    required this.clientData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', clientData['name'] ?? ''),
            _buildInfoRow('Email', clientData['email'] ?? ''),
            _buildInfoRow('Phone', clientData['phone'] ?? ''),
            _buildInfoRow('Service', clientData['service'] ?? ''),
            _buildInfoRow('Date', clientData['date'] ?? ''),
            _buildInfoRow('Time', clientData['time'] ?? ''),
            _buildInfoRow('Notes', clientData['notes'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}