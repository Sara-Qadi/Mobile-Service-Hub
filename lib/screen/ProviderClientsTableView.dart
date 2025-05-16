import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../widget/bottom_nav_bar.dart';

class ClientTable extends StatefulWidget {
  final String providerId;
  final String providerName;

  const ClientTable({
    Key? key,
    required this.providerId,
    required this.providerName,
  }) : super(key: key);

  @override
  State<ClientTable> createState() => _ClientTableState();
}

class _ClientTableState extends State<ClientTable> {
  final CollectionReference _clientsCollection = FirebaseFirestore.instance.collection('clients');
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _clients = [];

  @override
  void initState() {
    super.initState();
    _createClientsCollectionIfNotExists();
    _fetchClients();
  }

  Future<void> _createClientsCollectionIfNotExists() async {
    try {
      // Check if collection exists
      final checkCollection = await _clientsCollection.limit(1).get();
      
      // If empty, add a sample client to initialize collection
      if (checkCollection.docs.isEmpty) {
        await _clientsCollection.add({
          'name': 'Sample Client',
          'email': 'sample@example.com',
          'phone': '123-456-7890',
          'providerId': widget.providerId,
          'providerName': widget.providerName,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Silently handle this error, as we'll show errors in _fetchClients
    }
  }

  Future<void> _fetchClients() async {
    try {
      // First, fetch clients from the clients collection linked to this provider
      final clientsQuery = _clientsCollection
          .where('providerId', isEqualTo: widget.providerId)
          .orderBy('timestamp', descending: true)
          .get();

      final clientsSnapshot = await clientsQuery.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      List<Map<String, dynamic>> allClients = [];
      
      for (var doc in clientsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add document ID to the data
        data['id'] = doc.id;
        data['source'] = 'clients';
        allClients.add(data);
      }

      // Now fetch clients from bookingnow collection
      final bookingQuery = FirebaseFirestore.instance
          .collection('bookingnow')
          .where('provider', isEqualTo: widget.providerName)
          .get();

      final bookingSnapshot = await bookingQuery.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Connection timed out while fetching bookings');
        },
      );

      // Extract unique clients from bookings 
      for (var doc in bookingSnapshot.docs) {
        Map<String, dynamic> bookingData = doc.data();
        String clientName = bookingData['name']?.toString() ?? '';
        
        // Check if this client is already in our clients collection
        bool existsInClients = allClients.any((client) => 
          client['name'] == clientName && client['source'] == 'clients'
        );
        
        if (clientName.isNotEmpty && !existsInClients) {
          Map<String, dynamic> clientData = {
            'name': clientName,
            'email': bookingData['email'] ?? '',
            'phone': bookingData['phone'] ?? '',
            'service': bookingData['service'] ?? '',
            'date': bookingData['date'] ?? '',
            'time': bookingData['time'] ?? '',
            'location': bookingData['location'] ?? '',
            'id': doc.id,
            'source': 'bookings',
            'providerId': widget.providerId,
            'providerName': widget.providerName,
          };
          
          allClients.add(clientData);
        }
      }

      if (mounted) {
        setState(() {
          _clients = allClients;
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
        errorMsg = 'Error fetching clients: $e';
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

  Future<void> _addClient() async {
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => AddClientDialog(),
    );
    
    if (result != null) {
      setState(() => _isLoading = true);
      
      try {
        await _clientsCollection.add({
          'name': result['name'],
          'email': result['email'],
          'phone': result['phone'],
          'providerId': widget.providerId,
          'providerName': widget.providerName,
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        _fetchClients(); // Refresh the list
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Client added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to add client: $e';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add client: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteClient(String clientId, String clientName, String source) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete client $clientName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirmDelete) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (source == 'clients') {
        await _clientsCollection.doc(clientId).delete();
      } else if (source == 'bookings') {
        // When deleting from bookings, we don't delete the booking record
        // Just update the list for user interface purposes
        setState(() {
          _clients.removeWhere((client) => client['id'] == clientId && client['source'] == 'bookings');
        });
      }
      
      // Refresh the list
      if (source == 'clients') {
        _fetchClients();
      } else {
        setState(() => _isLoading = false);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Client $clientName removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to delete client: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete client: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveToClients(Map<String, dynamic> bookingClient) async {
    setState(() => _isLoading = true);
    
    try {
      // Check if this client already exists in clients collection
      final checkExisting = await _clientsCollection
          .where('name', isEqualTo: bookingClient['name'])
          .where('providerId', isEqualTo: widget.providerId)
          .limit(1)
          .get();
      
      if (checkExisting.docs.isEmpty) {
        // Add as new client
        await _clientsCollection.add({
          'name': bookingClient['name'],
          'email': bookingClient['email'] ?? '',
          'phone': bookingClient['phone'] ?? '',
          'service': bookingClient['service'] ?? '',
          'lastBooking': bookingClient['date'] ?? '',
          'providerId': widget.providerId,
          'providerName': widget.providerName,
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Client saved to your client list'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Client already exists in your client list'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      
      _fetchClients(); // Refresh the list
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to save client: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save client: $e'),
            backgroundColor: Colors.red,
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
    _fetchClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Clients',
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
            onPressed: _isLoading ? null : _retryFetch,
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
                        'Error Loading Clients',
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
              : _clients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Clients Found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first client to get started.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addClient,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Client'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'All Clients for ${widget.providerName}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _addClient,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Client'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                ),
                              ),
                            ],
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
                                              DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                              DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                                              DataColumn(label: Text('Service', style: TextStyle(fontWeight: FontWeight.bold))),
                                              DataColumn(label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold))),
                                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                            ],
                                            rows: _clients.map((client) {
                                              String source = client['source'] ?? '';
                                              
                                              return DataRow(
                                                color: source == 'bookings' ? MaterialStateColor.resolveWith(
                                                  (states) => Colors.amber.withOpacity(0.1),
                                                ) : null,
                                                cells: [
                                                  DataCell(Text(client['name'] ?? 'Unknown')),
                                                  DataCell(Text(client['email'] ?? 'Not provided')),
                                                  DataCell(Text(client['phone'] ?? 'Not provided')),
                                                  DataCell(Text(client['service'] ?? 'Not provided')),
                                                  DataCell(
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: source == 'clients' 
                                                            ? Colors.green.withOpacity(0.2) 
                                                            : Colors.orange.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        source == 'clients' ? 'Client List' : 'Booking',
                                                        style: TextStyle(
                                                          color: source == 'clients' ? Colors.green[800] : Colors.orange[800],
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if (source == 'clients')
                                                          IconButton(
                                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                                            onPressed: () async {
                                                              final result = await showDialog<Map<String, String>?>(
                                                                context: context,
                                                                builder: (context) => EditClientDialog(
                                                                  initialName: client['name'] ?? '',
                                                                  initialEmail: client['email'] ?? '',
                                                                  initialPhone: client['phone'] ?? '',
                                                                ),
                                                              );
                                                              
                                                              if (result != null) {
                                                                setState(() => _isLoading = true);
                                                                
                                                                try {
                                                                  await _clientsCollection.doc(client['id']).update({
                                                                    'name': result['name'],
                                                                    'email': result['email'],
                                                                    'phone': result['phone'],
                                                                  });
                                                                  
                                                                  _fetchClients(); // Refresh the list
                                                                } catch (e) {
                                                                  setState(() {
                                                                    _isLoading = false;
                                                                    _hasError = true;
                                                                    _errorMessage = 'Failed to update client: $e';
                                                                  });
                                                                  
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text('Failed to update client: $e'),
                                                                      backgroundColor: Colors.red,
                                                                    ),
                                                                  );
                                                                }
                                                              }
                                                            },
                                                            tooltip: 'Edit client',
                                                          ),
                                                        IconButton(
                                                          icon: const Icon(Icons.delete, color: Colors.red),
                                                          onPressed: () => _deleteClient(client['id'], client['name'] ?? 'Unknown', source),
                                                          tooltip: source == 'clients' ? 'Delete client' : 'Remove from view',
                                                        ),
                                                        if (source == 'bookings')
                                                          IconButton(
                                                            icon: const Icon(Icons.person_add, color: Colors.green),
                                                            onPressed: () => _saveToClients(client),
                                                            tooltip: 'Save to client list',
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
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
                          _buildSummaryCard(),
                        ],
                      ),
                    ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildSummaryCard() {
    // Calculate summary statistics
    int totalClients = _clients.length;
    int clientListCount = _clients.where((c) => c['source'] == 'clients').length;
    int bookingClientsCount = _clients.where((c) => c['source'] == 'bookings').length;
    
    // Get unique services
    Set<String> uniqueServices = _clients
        .map((client) => client['service']?.toString() ?? '')
        .where((service) => service.isNotEmpty)
        .toSet();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text('Total Clients: $totalClients'),
            Text('Clients in List: $clientListCount'),
            Text('Clients from Bookings: $bookingClientsCount'),
            Text('Unique Services: ${uniqueServices.length}'),
          ],
        ),
      ),
    );
  }
}

// Dialog for adding a new client
class AddClientDialog extends StatefulWidget {
  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Client'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Client Name',
                  icon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter client name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  icon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  icon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'email': _emailController.text,
                'phone': _phoneController.text,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
          child: const Text('Add Client'),
        ),
      ],
    );
  }
}

// Dialog for editing an existing client
class EditClientDialog extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;

  const EditClientDialog({
    Key? key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
  }) : super(key: key);

  @override
  State<EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<EditClientDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Client'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Client Name',
                  icon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter client name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  icon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  icon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'email': _emailController.text,
                'phone': _phoneController.text,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}