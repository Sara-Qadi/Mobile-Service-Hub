import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widget/booking_widgets/booking_form_fields.dart';
import '../widget/bottom_nav_bar.dart';

class BookingForm extends StatefulWidget {
  final Map<String, dynamic> service;

  const BookingForm({super.key, required this.service});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _dateController = TextEditingController();

  late String serviceName;
  late String serviceProvider;
  late String serviceId;
  late String providerId;

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_validateForm);
    _locationController.addListener(_validateForm);
    _timeController.addListener(_validateForm);
    _dateController.addListener(_validateForm);

    serviceName = widget.service['name'] ?? 'Service Name';
    serviceProvider = widget.service['user'] ?? 'Service Provider Name';
    serviceId = widget.service['id'] ?? '';
    providerId = widget.service['userId'] ?? '';

    _validateForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _locationController.text.isNotEmpty &&
          _timeController.text.isNotEmpty &&
          _dateController.text.isNotEmpty;
    });
  }

  void _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  DateTime? parseSelectedDateTime(String dateText, String timeText) {
    try {
      final parts = dateText.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final timeOfDay = _parseTimeOfDay(timeText);
      if (timeOfDay == null) return null;

      return DateTime(year, month, day, timeOfDay.hour, timeOfDay.minute);
    } catch (e) {
      return null;
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final format = timeString.toLowerCase().trim();
      final isPm = format.contains('pm');
      final cleanStr = format.replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = cleanStr.split(':');
      if (parts.length != 2) return null;
      int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);

      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book a service.')),
      );
      return;
    }

    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final bookingDateTime = parseSelectedDateTime(_dateController.text, _timeController.text);
    if (bookingDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid date or time')),
      );
      return;
    }

    try {
      final bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
        'name': _nameController.text,
        'location': _locationController.text,
        'time': Timestamp.fromDate(bookingDateTime),
        'date': _dateController.text,
        'service': serviceName,
        'serviceId': serviceId,
        'provider': serviceProvider,
        'providerId': providerId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'clientId': user.uid,
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'New Booking Request',
        'message': '${_nameController.text} requested a $serviceName service',
        'time': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'clientRequest',
        'receiver': serviceProvider,
        'providerId': providerId,
        'bookingId': bookingRef.id,
        'clientId': user.uid,
        'clientData': {
          'name': _nameController.text,
          'location': _locationController.text,
          'service': serviceName,
          'date': _dateController.text,
          'time': _timeController.text,
          'notes': '',
              'clientId': user.uid,
        },
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking request sent! Awaiting provider approval.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Error creating booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking failed. Please try again')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The service: $serviceName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'The service Provider: $serviceProvider',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              LabeledTextField(
                label: 'Name',
                hintText: 'Enter your name',
                controller: _nameController,
              ),
              LabeledTextField(
                label: 'Location',
                hintText: 'Enter your location',
                controller: _locationController,
              ),
              LabeledTextField(
                label: 'Time',
                hintText: 'Enter the time you want',
                controller: _timeController,
                readOnly: true,
                onTap: _selectTime,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: _selectTime,
                ),
              ),
              LabeledTextField(
                label: 'Date',
                hintText: 'Enter the date you want',
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
              const SizedBox(height: 16),
              ActionButton(
                text: 'Book Now',
                onPressed: _submitBooking,
                isEnabled: _isFormValid,
                backgroundColor: Colors.teal,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
