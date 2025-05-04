import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screen/Bookingform.dart';

class ChooseProviderPage extends StatelessWidget {
  final String serviceName;
  final List<Map<String, dynamic>> allServices;

  const ChooseProviderPage({
    Key? key,
    required this.serviceName,
    required this.allServices,
  }) : super(key: key);

 @override
Widget build(BuildContext context) {
  final matchingServices = allServices
      .where((service) => service['name'] == serviceName)
      .toList();

  return Scaffold(
    appBar: AppBar(
      title: Text('Choose Provider'),
    ),
    body: matchingServices.isEmpty
        ? Center(child: Text('No providers found for "$serviceName".'))
        : Column(
            children: [
              const SizedBox(height: 40),
       const Padding(
  padding: EdgeInsets.symmetric(horizontal: 16.0),
  child: Text(
    'Pick one to provide you the service',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
),

              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: matchingServices.length,
                  itemBuilder: (context, index) {
                    final service = matchingServices[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.teal),
                      ),
                      child: ListTile(
                        leading: service['imageBytes'] != null &&
                                service['imageBytes'].isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(
                                  base64Decode(service['imageBytes']),
                                ),
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(service['user']),
                        subtitle: Text('${service['details']}'),
                        trailing: Text('${service['price']}\$'),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingForm(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
  );
}

}
