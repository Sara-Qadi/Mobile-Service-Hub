
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/booking_confirmation_controller.dart';
import '../views/booking_times_table_view.dart';
import '../widget/booking_widgets/booking_details_card.dart';
import '../widget/bottom_nav_bar.dart';

class BookingConfirmationView extends StatefulWidget {
  final String name;
  final String location;
  final String time;
  final String date;
  final String service;
  final String provider; 
  final String serviceId;

  const BookingConfirmationView({
    Key? key,
    required this.name,
    required this.location,
    required this.time,
    required this.date,
    required this.service,
    required this.provider,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<BookingConfirmationView> createState() => _BookingConfirmationViewState();
}

class _BookingConfirmationViewState extends State<BookingConfirmationView> {
  late BookingConfirmationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BookingConfirmationController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBooking();
    });
  }

  Future<void> _initializeBooking() async {
    await _controller.initializeBooking(
      name: widget.name,
      location: widget.location,
      time: widget.time,
      date: widget.date,
      service: widget.service,
      provider: widget.provider,
      serviceId: widget.serviceId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<BookingConfirmationController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: _buildAppBar(controller),
            body: _buildBody(controller),
            bottomNavigationBar: const BottomNavBar(currentIndex: 1),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BookingConfirmationController controller) {
    String title = 'Booking';
    Color backgroundColor = Colors.teal;
    Color foregroundColor = Colors.white;
    bool centerTitle = false;

    if (!controller.isLoading && !controller.hasError) {
      title = 'Booking Confirmed';
      centerTitle = true;
    }

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: centerTitle,
    );
  }

  Widget _buildBody(BookingConfirmationController controller) {
    if (controller.isLoading) {
      return _buildLoadingState();
    }

    if (controller.hasError) {
      return _buildErrorState(controller);
    }

    return _buildSuccessState(controller);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
          SizedBox(height: 16),
          Text('Processing your booking...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BookingConfirmationController controller) {
    return Center(
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
            'Error Processing Booking',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.retryInitialization(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BookingConfirmationController controller) {
    final bookingData = controller.getDisplayData();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSuccessIcon(),
            const SizedBox(height: 20),
            
            _buildSuccessTitle(),
            const SizedBox(height: 16),
            
            _buildSuccessSubtitle(),
            const SizedBox(height: 30),
            
            BookingDetailsCard(
              bookingData: bookingData,
              title: 'Booking Information',
            ),
            const SizedBox(height: 30),
            
            _buildActionButton(bookingData),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle,
        size: 60,
        color: Colors.green.shade600,
      ),
    );
  }

  Widget _buildSuccessTitle() {
    return const Text(
      'Your Booking is Confirmed!',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSuccessSubtitle() {
    return const Text(
      'Thank you for trusting us with your service needs',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(Map<String, String> bookingData) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.view_list),
        label: const Text('View All Bookings'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingTimesTableView(
                bookingData: bookingData,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}