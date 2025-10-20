/* ====================== CART SCREEN ====================== */
import 'package:flutter/material.dart';
import 'package:pos_calculator_ai/app_pallete.dart';
import 'package:pos_calculator_ai/main.dart';
import 'package:pos_calculator_ai/payment_screen.dart';

/* --------------------------------- Cart ----------------------------------- */
/* CART SCREEN */
/* ====================== CART SCREEN ====================== */

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.items, this.onChanged});

  final List<CartItem> items; // same instance as parent
  final VoidCallback? onChanged;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static String _f(int v) => QuickSaleScreenState.formatInt(v);

  List<CartItem> get items => widget.items;
  int get _subtotal => items.fold(0, (s, it) => s + it.price);

  void _clearCart() {
    setState(() => items.clear());
    widget.onChanged?.call(); // notify parent
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cart cleared'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeAt(int i) {
    setState(() => items.removeAt(i));
    widget.onChanged?.call(); // notify parent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: AppPalette.green800,
        foregroundColor: Colors.white,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Clear cart',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmClearCart(context),
            ),
        ],
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (items.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final it = items[i];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppPalette.green400.withOpacity(0.2),
                        child: Text(
                          it.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppPalette.green800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        it.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Rp ${_f(it.price)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => _removeAt(i),
                            tooltip: 'Remove',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          // Subtotal + Payment button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(fontSize: 16)),
                    Text(
                      'Rp ${_f(_subtotal)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.green600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: _subtotal == 0
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  items: items,
                                ), // <-- kirim list yang sama
                              ),
                            );
                          },
                    child: const Text(
                      'Payment',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
    );
  }

  Future<void> _confirmClearCart(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text(
          'This will remove all items from your current cart.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (res == true) _clearCart();
  }
}
