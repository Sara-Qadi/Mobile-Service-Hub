
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../widget/bottom_nav_bar.dart';

class EnhancedProviderClientsTableView extends StatefulWidget {
  const EnhancedProviderClientsTableView({Key? key}) : super(key: key);

  @override
  State<EnhancedProviderClientsTableView> createState() => _EnhancedProviderClientsTableViewState();
}

class _EnhancedProviderClientsTableViewState extends State<EnhancedProviderClientsTableView> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> clients = [];
  bool isLoading = true;
  String? errorMessage;
  bool isTableView = true;
  String searchQuery = '';
  
  String sortColumn = 'timestamp';
  bool sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    if (currentUser == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final bookingsSnapshot = await FirebaseFirestore.instance
          .collection('bookingnow')
          .where('provider', isEqualTo: currentUser!.uid)
          .get();

      final List<Map<String, dynamic>> loadedBookings = [];
      for (var doc in bookingsSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        loadedBookings.add(data);
      }

      final List<Map<String, dynamic>> loadedClients = [];
      for (var booking in loadedBookings) {
        if (booking['clientId'] != null) {
          try {
            final clientDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(booking['clientId'])
                .get();
                
            if (clientDoc.exists) {
              final clientData = clientDoc.data() ?? {};
              booking['email'] = clientData['email'] ?? 'N/A';
              booking['phone'] = clientData['phone'] ?? 'N/A';
              booking['profileImage'] = clientData['profileImage'];
            }
            
          } catch (e) {
            print('Error fetching client details: $e');
          }
        }
        
        loadedClients.add(booking);
      }

      _sortClients(loadedClients);

      setState(() {
        clients = loadedClients;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load clients: $e";
        isLoading = false;
      });
    }
  }

  void _sortClients(List<Map<String, dynamic>> clientsList) {
    clientsList.sort((a, b) {
      if (sortColumn == 'name') {
        final aName = a['name'] ?? '';
        final bName = b['name'] ?? '';
        return sortAscending ? aName.compareTo(bName) : bName.compareTo(aName);
      } else if (sortColumn == 'service') {
        final aService = a['service'] ?? '';
        final bService = b['service'] ?? '';
        return sortAscending ? aService.compareTo(bService) : bService.compareTo(aService);
      } else if (sortColumn == 'date') {
        final aDate = a['date'] ?? '';
        final bDate = b['date'] ?? '';
        return sortAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
      } else {
        final aTimestamp = a['timestamp'] as Timestamp?;
        final bTimestamp = b['timestamp'] as Timestamp?;
        if (aTimestamp == null || bTimestamp == null) return 0;
        return sortAscending ? aTimestamp.compareTo(bTimestamp) : bTimestamp.compareTo(aTimestamp);
      }
    });
  }

  List<Map<String, dynamic>> _getFilteredClients() {
    if (searchQuery.isEmpty) return clients;
    
    return clients.where((client) {
      final name = (client['name'] ?? '').toLowerCase();
      final service = (client['service'] ?? '').toLowerCase();
      final location = (client['location'] ?? '').toLowerCase();
      final date = (client['date'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();
      
      return name.contains(query) || 
             service.contains(query) || 
             location.contains(query) || 
             date.contains(query);
    }).toList();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    if (date is Timestamp) {
      final dateTime = date.toDate();
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } 
    
    return date.toString();
  }

  Future<void> _completeBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookingnow')
          .doc(bookingId)
          .update({'status': 'completed'});
          
      final docRef = FirebaseFirestore.instance.collection('bookingnow').doc(bookingId);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        data['completedAt'] = FieldValue.serverTimestamp();
        
        await FirebaseFirestore.instance.collection('completedBookings').add(data);
        
        await docRef.delete();
      }
      
      _loadClients();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking marked as complete')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing booking: $e')),
      );
    }
  }

  Future<void> _deleteBooking(String bookingId, String clientName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Booking'),
          content: Text('Are you sure you want to delete the booking for $clientName?'),
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
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('bookingnow')
          .doc(bookingId)
          .delete();
      
      _loadClients();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking for $clientName deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredClients = _getFilteredClients();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Clients',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isTableView ? Icons.view_list : Icons.grid_view),
            tooltip: isTableView ? 'Switch to Card View' : 'Switch to Table View',
            onPressed: () {
              setState(() {
                isTableView = !isTableView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadClients,
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
              : clients.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search clients...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${filteredClients.length} client(s)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: isTableView
                              ? _buildClientsTable(filteredClients)
                              : _buildClientsCardList(filteredClients),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Clients Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You don\'t have any confirmed bookings',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            onPressed: _loadClients,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientsTable(List<Map<String, dynamic>> filteredClients) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        showCheckboxColumn: false,
        columns: [
          DataColumn2(
            label: const Text('CLIENT', style: TextStyle(fontWeight: FontWeight.bold)),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) {
              setState(() {
                sortColumn = 'name';
                sortAscending = ascending;
                _sortClients(clients);
              });
            },
          ),
          DataColumn2(
            label: const Text('SERVICE', style: TextStyle(fontWeight: FontWeight.bold)),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              setState(() {
                sortColumn = 'service';
                sortAscending = ascending;
                _sortClients(clients);
              });
            },
          ),
          DataColumn2(
            label: const Text('DATE/TIME', style: TextStyle(fontWeight: FontWeight.bold)),
            size: ColumnSize.M,
            onSort: (columnIndex, ascending) {
              setState(() {
                sortColumn = 'date';
                sortAscending = ascending;
                _sortClients(clients);
              });
            },
          ),
          DataColumn2(
            label: const Text('LOCATION', style: TextStyle(fontWeight: FontWeight.bold)),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: const Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold)),
            size: ColumnSize.M,
          ),
        ],
        rows: filteredClients.map<DataRow>((client) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: client['profileImage'] != null 
                          ? NetworkImage(client['profileImage']) 
                          : null,
                      child: client['profileImage'] == null 
                          ? Text((client['name'] ?? 'U')[0].toUpperCase()) 
                          : null,
                      radius: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            client['name'] ?? 'Unknown Client',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (client['email'] != null && client['email'] != 'N/A')
                            Text(
                              client['email'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () => _showClientDetailsDialog(context, client),
              ),
              DataCell(
                Text(client['service'] ?? 'N/A'),
                onTap: () => _showClientDetailsDialog(context, client),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(client['date'] ?? 'N/A'),
                    Text(
                      client['time'] ?? 'N/A',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                onTap: () => _showClientDetailsDialog(context, client),
              ),
              DataCell(
                Text(
                  client['location'] ?? 'N/A',
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _showClientDetailsDialog(context, client),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete Booking',
                      onPressed: () => _deleteBooking(client['id'], client['name'] ?? 'Client'),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      tooltip: 'Mark Complete',
                      onPressed: () => _completeBooking(client['id']),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
            onSelectChanged: (selected) {
              if (selected == true) {
                _showClientDetailsDialog(context, client);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildClientsCardList(List<Map<String, dynamic>> filteredClients) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredClients.length,
      itemBuilder: (context, index) {
        final client = filteredClients[index];
        return _buildClientCard(client);
      },
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: client['profileImage'] != null 
                      ? NetworkImage(client['profileImage']) 
                      : null,
                  child: client['profileImage'] == null 
                      ? Text((client['name'] ?? 'U')[0].toUpperCase()) 
                      : null,
                  radius: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client['name'] ?? 'Unknown Client',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (client['email'] != null && client['email'] != 'N/A')
                        Text(
                          client['email'],
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      if (client['phone'] != null && client['phone'] != 'N/A')
                        Text(
                          client['phone'],
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Text(
                    client['status'] ?? 'Active',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Service', client['service'] ?? 'N/A'),
            _buildInfoRow('Date', client['date'] ?? 'N/A'),
            _buildInfoRow('Time', client['time'] ?? 'N/A'),
            _buildInfoRow('Location', client['location'] ?? 'N/A'),
            _buildInfoRow('Booked on', _formatDate(client['timestamp'])),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () => _deleteBooking(client['id'], client['name'] ?? 'Client'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Complete'),
                  onPressed: () => _completeBooking(client['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showClientDetailsDialog(BuildContext context, Map<String, dynamic> client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(client['name'] ?? 'Client Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (client['profileImage'] != null)
                Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(client['profileImage']),
                    radius: 40,
                  ),
                ),
              if (client['profileImage'] == null)
                Center(
                  child: CircleAvatar(
                    child: Text((client['name'] ?? 'U')[0].toUpperCase()),
                    radius: 40,
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Full Name', client['name'] ?? 'N/A'),
              _buildDetailRow('Email', client['email'] ?? 'N/A'),
              _buildDetailRow('Phone', client['phone'] ?? 'N/A'),
              _buildDetailRow('Service', client['service'] ?? 'N/A'),
              _buildDetailRow('Date', client['date'] ?? 'N/A'),
              _buildDetailRow('Time', client['time'] ?? 'N/A'),
              _buildDetailRow('Location', client['location'] ?? 'N/A'),
              _buildDetailRow('Booked on', _formatDate(client['timestamp'])),
              if (client['notes'] != null && client['notes'].isNotEmpty)
                _buildDetailRow('Notes', client['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              _deleteBooking(client['id'], client['name'] ?? 'Client');
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Complete'),
            onPressed: () {
              Navigator.pop(context);
              _completeBooking(client['id']);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}