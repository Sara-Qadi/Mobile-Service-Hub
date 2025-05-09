import 'package:flutter/material.dart';
import '../widget/booking_widgets/booking_form_fields.dart';
import '../widget/bottom_nav_bar.dart';
import 'Bookingconfirmation.dart';

class BookingForm extends StatefulWidget {
  const BookingForm({super.key});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _dateController = TextEditingController();

  final String serviceName = "Service Name";
  final String serviceProvider = "Service Provider Name";
  
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _locationController.addListener(_validateForm);
    _timeController.addListener(_validateForm);
    _dateController.addListener(_validateForm);
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
        _dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  void _submitBooking() {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmation(
          name: _nameController.text,
          location: _locationController.text,
          time: _timeController.text,
          date: _dateController.text,
          service: serviceName,
          provider: serviceProvider,
        ),
      ),
    );
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The service Provider: $serviceProvider',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
                text: 'Booking now',
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