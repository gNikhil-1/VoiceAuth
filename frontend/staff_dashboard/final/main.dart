import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const VoiceAuthDashboardApp());
}

class VoiceAuthDashboardApp extends StatelessWidget {
  const VoiceAuthDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiceAuth Staff Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black26),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5001';

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? data['error'] ?? 'Login failed',
    };
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 201,
      'message': data['message'] ?? data['error'] ?? 'Registration failed',
    };
  }

  static Future<List<Map<String, dynamic>>> fetchList(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load data from $endpoint');
  }
}

class DemoData {
  static final List<Map<String, dynamic>> students = [
    {'id': 1, 'username': 'student_01'},
    {'id': 2, 'username': 'student_02'},
    {'id': 3, 'username': 'student_03'},
    {'id': 4, 'username': 'student_04'},
  ];

  static final List<Map<String, dynamic>> orders = [
    {
      'index_number': 1,
      'username': 'student_01',
      'order_id': 'ORD-1001',
      'delivery_app': 'Sample Delivery App 1',
      'order_item': 'Textbooks & Notebooks',
      'expected_date': '2026-11-22',
      'status': 'Arrived at Gate',
    },
    {
      'index_number': 2,
      'username': 'student_02',
      'order_id': 'ORD-1002',
      'delivery_app': 'Sample Delivery App 2',
      'order_item': 'Lunch Box',
      'expected_date': '2026-11-22',
      'status': 'Not Arrived',
    },
    {
      'index_number': 3,
      'username': 'student_03',
      'order_id': 'ORD-1003',
      'delivery_app': 'Sample Delivery App 3',
      'order_item': 'USB-C Charger',
      'expected_date': '2026-11-23',
      'status': 'Arrived at Gate',
    },
    {
      'index_number': 4,
      'username': 'student_04',
      'order_id': 'ORD-1004',
      'delivery_app': 'Sample Delivery App 1',
      'order_item': 'Grocery Pack',
      'expected_date': '2026-11-23',
      'status': 'Not Arrived',
    },
  ];

  static final List<Map<String, dynamic>> deliveryLogs = [
    {
      'order_index': 1,
      'order_number': 'ORD-1001',
      'delivery_app': 'Sample Delivery App 1',
      'entry_time': '09:10 AM',
      'exit_time': '09:22 AM',
    },
    {
      'order_index': 2,
      'order_number': 'ORD-1002',
      'delivery_app': 'Sample Delivery App 2',
      'entry_time': '10:05 AM',
      'exit_time': null,
    },
    {
      'order_index': 3,
      'order_number': 'ORD-1003',
      'delivery_app': 'Sample Delivery App 3',
      'entry_time': '11:30 AM',
      'exit_time': '11:41 AM',
    },
  ];

  static List<Map<String, dynamic>> getTab(int index) {
    switch (index) {
      case 0:
        return students;
      case 1:
        return orders;
      default:
        return deliveryLogs;
    }
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(
              staffUsername: _usernameController.text.trim(),
            ),
          ),
        );
      } else {
        setState(() => _errorMessage = result['message']);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Cannot connect to Flask server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleDemoLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardPage(
          staffUsername: 'Demo Staff',
          isDemoMode: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          size: 36,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'VoiceAuth Staff Dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleDemoLogin,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Test Demo Login'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      child: const Text('New staff member? Register here'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please log in.')),
        );
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage = result['message']);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Cannot connect to Flask server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Staff Registration',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Register'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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






























