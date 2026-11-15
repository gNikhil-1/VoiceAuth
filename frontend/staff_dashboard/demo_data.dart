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




































