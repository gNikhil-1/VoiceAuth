

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'demo_data.dart';
import 'login_page.dart';


class DashboardPage extends StatefulWidget {
  final String staffUsername;
  final bool isDemoMode;


  const DashboardPage({
    super.key,
    required this.staffUsername,
    this.isDemoMode = false,
  });


  @override
  State<DashboardPage> createState() => _DashboardPageState();
}




class _DashboardPageState extends State<DashboardPage> {
  
  int _selectedIndex = 1;


  final _endpoints = ['/students', '/orders', '/delivery-logs'];
  final _titles = ['Students List', 'Orders List', 'Delivery Person Logs'];
  final _searchHints = [
    'Search students by ID or username...',
    'Search orders by user, order ID, app, item, date or status...',
    'Search logs by order number, app or time...',
  ];


  final _searchController = TextEditingController();
  String _query = '';


  late Future<List<Map<String, dynamic>>> _dataFuture;


  @override
  void initState() {
    super.initState();
    _loadCurrentTab();
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _loadCurrentTab() {
    setState(() {
      if (widget.isDemoMode) {
        _dataFuture = Future.value(DemoData.getTab(_selectedIndex));
      } else {
        _dataFuture = ApiService.fetchList(_endpoints[_selectedIndex]);
      }
    });
  }


  
  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> items) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where((row) =>
            row.values.any((v) => '${v ?? ''}'.toLowerCase().contains(q)))
        .toList();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VoiceAuth Staff Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Signed in as ${widget.staffUsername}'),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentTab,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.white,
            extended: MediaQuery.of(context).size.width > 800,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              _selectedIndex = index;
              _searchController.clear();
              _query = '';
              _loadCurrentTab();
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Students'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Orders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping),
                label: Text('Delivery Logs'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titles[_selectedIndex],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: _searchHints[_selectedIndex],
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _dataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        final allItems = snapshot.data ?? [];
                        if (allItems.isEmpty) {
                          return const Center(child: Text('No records found.'));
                        }
                        final items = _filter(allItems);
                        if (items.isEmpty) {
                          return const Center(
                            child: Text('No matching records.'),
                          );
                        }
                        return Card(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _buildTable(items),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }





  DataTable _buildTable(List<Map<String, dynamic>> items) {
    if (_selectedIndex == 0) {
      return DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Username')),
        ],
        rows: items.map((s) {
          return DataRow(cells: [
            DataCell(Text('${s['id'] ?? ''}')),
            DataCell(Text('${s['username'] ?? ''}')),
          ]);
        }).toList(),
      );
    } else if (_selectedIndex == 1) {
      return DataTable(
        columns: const [
          DataColumn(label: Text('Index')),
          DataColumn(label: Text('User Name')),
          DataColumn(label: Text('Order ID')),
          DataColumn(label: Text('Delivery App')),
          DataColumn(label: Text('Order Item')),
          DataColumn(label: Text('Expected Date')),
          DataColumn(label: Text('Status')),
        ],
        rows: items.map((o) {
          final status = '${o['status'] ?? 'Pending'}';
          final arrived = status.toLowerCase().contains('arrived') &&
              !status.toLowerCase().contains('not');
          return DataRow(cells: [
            DataCell(Text('${o['index_number'] ?? ''}')),
            DataCell(Text('${o['username'] ?? ''}')),
            DataCell(Text('${o['order_id'] ?? ''}')),
            DataCell(Text('${o['delivery_app'] ?? ''}')),
            DataCell(Text('${o['order_item'] ?? ''}')),
            DataCell(Text('${o['expected_date'] ?? ''}')),
            DataCell(
              Chip(
                label: Text(status),
                backgroundColor: arrived
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
              ),
            ),
          ]);
        }).toList(),
      );
    } else {
      return DataTable(
        columns: const [
          DataColumn(label: Text('Order Index')),
          DataColumn(label: Text('Order Number')),
          DataColumn(label: Text('Delivery App')),
          DataColumn(label: Text('Entry Time')),
          DataColumn(label: Text('Exit Time')),
        ],
        rows: items.map((d) {
          return DataRow(cells: [
            DataCell(Text('${d['order_index'] ?? ''}')),
            DataCell(Text('${d['order_number'] ?? ''}')),
            DataCell(Text('${d['delivery_app'] ?? ''}')),
            DataCell(Text('${d['entry_time'] ?? '-'}')),
            DataCell(Text('${d['exit_time'] ?? 'Inside Campus'}')),
          ]);
        }).toList(),
      );
    }
  }
}








































































































































































