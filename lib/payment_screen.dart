import 'package:flutter/material.dart';
import 'main.dart';
import 'payment_success_screen.dart';
import 'package:flutter/material.dart';
import 'app_pallete.dart';
import 'main.dart';
import 'payment_success_screen.dart';

/// Payment screen that consumes the real cart items (CartItem) from CartScreen.
/// It groups identical items (same name & price), shows the summary,
/// lets user choose a method (QRIS / Cash), and simulates processing.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.items});

  /// The same instance of the cart list passed from CartScreen.
  final List<CartItem> items;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = '';
  bool _isProcessingPayment = false;

  // Format helper reused across screens
  String _f(int amount) => QuickSaleScreenState.formatInt(amount);

  /// Collapse identical items into lines with quantity.
  /// Key = name|price
  List<_Line> get _lines {
    final map = <String, _Line>{};
    for (final it in widget.items) {
      final key = '${it.name}|${it.price}';
      map.update(key, (l) {
        l.qty++;
        return l;
      }, ifAbsent: () => _Line(it.name, it.price, 1));
    }
    return map.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  int get _totalAmount => _lines.fold<int>(0, (s, l) => s + l.price * l.qty);

  String _generateTransactionId() {
    final now = DateTime.now();
    return 'TXN${now.millisecondsSinceEpoch.toString().substring(6)}';
  }

  void _processPayment() {
    if (_selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            totalAmount: _totalAmount,
            changeAmount: 0,
            paymentMethod: _selectedPaymentMethod,
            transactionId: _generateTransactionId(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient to match the app palette
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              decoration: const BoxDecoration(
                gradient: AppPalette.headerGradient,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isProcessingPayment ? 'Processing Payment' : 'Payment',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isProcessingPayment ? _buildProcessing() : _buildForm(),
            ),

            if (!_isProcessingPayment)
              Container(
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  boxShadow: AppPalette.shadow,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payment',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppPalette.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Rp ${_f(_totalAmount)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.green600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _processPayment,
                        child: Text(
                          'Pay Rp ${_f(_totalAmount)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ----------------------------- Views ---------------------------------

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purchase summary
          Container(
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppPalette.shadow,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Pembelian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ..._lines.map(
                  (l) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppPalette.green400.withOpacity(.15),
                          child: Text(
                            l.name.isNotEmpty ? l.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: AppPalette.green800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppPalette.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${_f(l.price)} x ${l.qty}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppPalette.green800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rp ${_f(l.price * l.qty)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment methods
          Container(
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppPalette.shadow,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _paymentMethodTile(
                        label: 'QRIS',
                        isSelected: _selectedPaymentMethod == 'QRIS',
                        onTap: () =>
                            setState(() => _selectedPaymentMethod = 'QRIS'),
                        imageUrl:
                            'https://images.seeklogo.com/logo-png/39/1/quick-response-code-indonesia-standard-qris-logo-png_seeklogo-391791.png',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _paymentMethodTile(
                        icon: Icons.payments_outlined,
                        label: 'Cash',
                        isSelected: _selectedPaymentMethod == 'Cash',
                        onTap: () =>
                            setState(() => _selectedPaymentMethod = 'Cash'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessing() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppPalette.shadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://qris.interactive.co.id/homepage/images/assets/pay/harga/csan-qr-a.jpg',
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.qr_code,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scan QR Code to Pay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${_f(_totalAmount)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppPalette.green800,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppPalette.green800,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Waiting for payment...',
                  style: TextStyle(fontSize: 14, color: AppPalette.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodTile({
    IconData? icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? imageUrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7F8F7) : AppPalette.surface,
          border: Border.all(
            color: isSelected ? AppPalette.green800 : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppPalette.green800.withOpacity(.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            if (imageUrl != null)
              SizedBox(
                width: 40,
                height: 40,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: isSelected
                        ? AppPalette.green800
                        : AppPalette.textPrimary,
                  ),
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 40,
                color: isSelected
                    ? AppPalette.green800
                    : AppPalette.textPrimary,
              ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppPalette.green800
                    : AppPalette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple line model for grouped cart items.
class _Line {
  _Line(this.name, this.price, this.qty);
  final String name;
  final int price;
  int qty;
}
