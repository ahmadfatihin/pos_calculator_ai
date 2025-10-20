// history_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pos_calculator_ai/app_pallete.dart';
import 'package:pos_calculator_ai/main.dart'; // for CartItem

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.cartItems, // <-- live items from app
  });

  /// Live cart items coming from your app state
  final List<CartItem> cartItems;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = '7 Days';

  // Build "transactions" from cart items (qty is always 1; id hard-coded)
  late final List<Transaction> _transactions = widget.cartItems.map((c) {
    final now = DateTime.now();
    return Transaction(
      id: 'WARM-LOCAL-0001', // hard-coded ID per request
      time: _fmtTime(now),
      total: c.price,
      paymentMethod: 'QRIS', // or anything you prefer
      date: now,
      itemName: c.name,
    );
  }).toList();

  void _onFilterChanged(String filter) =>
      setState(() => _selectedFilter = filter);

  void _onNavigationTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pop(); // back to Calculator
        break;
      case 1:
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings screen coming soon!')),
        );
        break;
    }
  }

  // === AI summary posting ===
  // === AI summary posting ===
  Future<void> _postWeeklyReport() async {
    // Choose correct host depending on platform
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    final uri = Uri.parse('http://$host:8081/ai-report');

    // Generate start/end dates (yesterday → today)
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 1));

    String d(DateTime x) =>
        '${x.year.toString().padLeft(4, '0')}-'
        '${x.month.toString().padLeft(2, '0')}-'
        '${x.day.toString().padLeft(2, '0')}';

    // Construct the payload body
    final payload = {
      'type': 'weekly',
      'salesData': {
        'startDate': d(start),
        'endDate': d(now),
        'sales': widget.cartItems.map((it) {
          return {
            'product': it.name,
            'price': it.price,
            'quantitySold': 1,
            'date': d(now),
          };
        }).toList(),
      },
    };

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI summary posted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(_transactions);

    return Scaffold(
      backgroundColor: AppPalette.bg,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: 1,
        onDestinationSelected: _onNavigationTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDateFilterPills(),
            Expanded(child: _buildTransactionList(grouped)),
            // Two buttons: Send to AI + Download
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.green600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: widget.cartItems.isEmpty
                      ? null
                      : _postWeeklyReport,
                  label: const Text(
                    'Send AI Summary',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            _buildDownloadButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==== UI bits ====

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppPalette.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Quick Sale',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.history, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterPills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _filterPill('Today'),
          const SizedBox(width: 8),
          _filterPill('7 Days'),
          const SizedBox(width: 8),
          _filterPill('30 Days'),
          const SizedBox(width: 8),
          _filterPill('Custom'),
        ],
      ),
    );
  }

  Widget _filterPill(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onFilterChanged(label),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppPalette.green800 : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppPalette.green800 : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Downloading report...')),
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppPalette.green800, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Download Report',
            style: TextStyle(
              color: AppPalette.green800,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(Map<DateTime, List<Transaction>> grouped) {
    if (_transactions.isEmpty) {
      return Center(
        child: Text(
          'No transactions yet',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped.keys.elementAt(index);
        final transactions = grouped[date]!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _formatDate(date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
            ),
            ...transactions.map(_buildTransactionCard),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ID / time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.id,
                style: const TextStyle(
                  color: AppPalette.green800,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                t.time,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Item name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              Text(
                t.itemName,
                style: const TextStyle(
                  color: AppPalette.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              Text(
                'Rp ${_formatPrice(t.total)}',
                style: const TextStyle(
                  color: AppPalette.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Payment method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              Text(
                t.paymentMethod,
                style: const TextStyle(
                  color: AppPalette.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==== helpers ====

  Map<DateTime, List<Transaction>> _groupByDate(List<Transaction> list) {
    final map = <DateTime, List<Transaction>>{};
    for (final t in list) {
      final k = DateTime(t.date.year, t.date.month, t.date.day);
      (map[k] ??= []).add(t);
    }
    return map;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}.'
      '${dt.minute.toString().padLeft(2, '0')}.'
      '${dt.second.toString().padLeft(2, '0')}';

  String _formatPrice(int price) {
    final s = price.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      b.write(s[i]);
      if (idx > 1 && idx % 3 == 1) b.write('.');
    }
    return b.toString();
  }
}

class Transaction {
  final String id;
  final String time;
  final int total;
  final String paymentMethod;
  final DateTime date;
  final String itemName;

  Transaction({
    required this.id,
    required this.time,
    required this.total,
    required this.paymentMethod,
    required this.date,
    required this.itemName,
  });
}
