import 'package:flutter/material.dart';
import 'package:pos_calculator_ai/app_pallete.dart';
import 'package:pos_calculator_ai/cart_screen.dart';
import 'package:pos_calculator_ai/history_screen.dart';

void main() => runApp(const PosApp());

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Quick Sale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.green800,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppPalette.bg,
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppPalette.textPrimary),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppPalette.green800,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const QuickSaleScreen(),
    );
  }
}

/* ----------------------------- Simple models ------------------------------ */

class Product {
  final String name;
  final int price;
  final String image;
  const Product(this.name, this.price, this.image);
}

class CartItem {
  final String name;
  final int price;
  const CartItem(this.name, this.price);
}

/* ------------------------------ Main screen ------------------------------- */

class QuickSaleScreen extends StatefulWidget {
  const QuickSaleScreen({super.key});
  @override
  State<QuickSaleScreen> createState() => QuickSaleScreenState();
}

class QuickSaleScreenState extends State<QuickSaleScreen> {
  // Calculator display (formatted with thousands separators)
  String _display = '0';

  // Pending terms: queued by tapping + or −; all committed to cart on =
  final List<CartItem> _pendingTerms = [];

  // --- Multiply mode state ---
  int? _mulBase; // harga satuan (mis. 5000)
  bool _inMul = false; // setelah tekan 'X', input berikutnya = qty

  // Demo catalog
  final List<Product> _products = const [
    Product('Fried Noodle - Indomie', 3000,
        'https://www.indomie.co.id/Content/Product/indomie-goreng-spesial-plus_big.png'),
    Product('Rice', 5000,
        'https://upload.wikimedia.org/wikipedia/commons/2/2d/Nasi_dibentuk_bulat.jpg'),
    Product('Ice Tea', 5000,
        'https://d1vbn70lmn1nqe.cloudfront.net/prod/wp-content/uploads/2021/06/15093247/Ketahui-Fakta-Es-Teh-Manis.jpg'),
    Product('Lemon Tea', 5000,
        'https://d1vbn70lmn1nqe.cloudfront.net/prod/wp-content/uploads/2021/06/15093247/Ketahui-Fakta-Es-Teh-Manis.jpg'),
    Product('Noodle with Egg', 12000,
        'https://blue.kumparan.com/image/upload/fl_progressive,fl_lossy,c_fill,f_auto,q_auto:best,w_640/v1538128192/ffjpp4pme8zszmcz3rzr.png'),
    Product(
      'Special Noodle - Indomie',
      7000,
      'https://www.indomie.com/uploads/product/indomie-mi-goreng-special_detail_094906814.png',
    ),
    Product('Uduk Rice', 15000,
        'https://asset.kompas.com/crops/cnjJ8a2_lEamvP1OkUClN1Oi0Dg=/100x67:900x600/1200x800/data/photo/2021/02/21/603203834f00f.jpg'),
    Product('Teh Botol', 5000,
        'https://c.alfagift.id/product/1/1_A12790005980_20200513221105857_base.jpg'),
    Product(
      'Yoshinoya Chicken Meal',
      50000,
      'https://caripromo.id/images/makanan/promo-makanan-yoshinoya-paket-hemat-ayam.jpg',
    ),
    Product(
      'Ivan',
      500000,
      'https://media.licdn.com/dms/image/v2/D5622AQGyx9vARTLB5A/feedshare-shrink_800/B56ZmpSI7nKMAg-/0/1759481730198?e=2147483647&v=beta&t=dXBlVwiUp4gyf2M54Tg45ff3cBTymK6arCozCS0OQLo',
    ),
  ];

  // Cart state
  final List<CartItem> _cart = [];

  // Navigation handling
  void _onNavigationTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HistoryScreen(cartItems: _cart),
          ),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings screen coming soon!')),
        );
        break;
    }
  }

  // Subtotal cart (tidak termasuk pending terms)
  int get _cartSubtotal => _cart.fold<int>(0, (sum, it) => sum + it.price);

  /* --------------------------- Formatting helpers -------------------------- */

  int _parse(String s) => int.tryParse(s.replaceAll('.', '')) ?? 0;

  static String formatInt(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      b.write(s[i]);
      if (idx > 1 && idx % 3 == 1) b.write('.');
    }
    return b.toString();
  }

  void _queueCurrentAsUnknown() {
    final v = _parse(_display);
    if (v > 0) {
      _pendingTerms.add(
          const CartItem('Unknown item', 0)); // placeholder, corrected below
      _pendingTerms.removeLast(); // ensure not double add if logic changes
      _pendingTerms.add(CartItem('Unknown item', v));
    }
  }

  /* ---------------------------- Key actions -------------------------------- */

  void _onKey(String k) {
    switch (k) {
      case 'CLEAR':
        setState(() {
          _display = '0';
          _pendingTerms.clear();
          _inMul = false;
          _mulBase = null;
        });
        return;

      case '⌫':
        setState(() {
          var raw = _display.replaceAll('.', '');
          if (raw.isEmpty) {
            _display = '0';
          } else {
            raw = raw.substring(0, raw.length - 1);
            _display = raw.isEmpty ? '0' : formatInt(int.parse(raw));
          }
        });
        return;

      case '000':
        setState(() {
          final v = _parse(_display);
          _display = formatInt(v * 1000);
        });
        return;

      case '+':
      case '-':
        setState(() {
          if (_inMul) {
            // Commit mulBase x qty ke pending terms
            final qty = _parse(_display);
            final base = _mulBase ?? 0;
            if (base > 0 && qty > 0) {
              final capped = qty.clamp(1, 999);
              for (int i = 0; i < capped; i++) {
                _pendingTerms.add(CartItem('Unknown item', base));
              }
            }
            // reset multiply mode
            _inMul = false;
            _mulBase = null;
            _display = '0';
          } else {
            _queueCurrentAsUnknown();
            _display = '0';
          }
        });
        return;

      case 'X':
        setState(() {
          final v = _parse(_display);
          if (v > 0) {
            _mulBase = v; // simpan harga satuan
            _inMul = true; // input selanjutnya = qty
            _display = '0'; // siap terima qty
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Multiply mode: Rp ${formatInt(v)} × qty')),
            );
          }
        });
        return;

      case '=':
        setState(() {
          if (_inMul) {
            // Selesaikan mulBase x qty ke cart
            final qty = _parse(_display);
            final base = _mulBase ?? 0;
            if (base > 0 && qty > 0) {
              final capped = qty.clamp(1, 999);
              for (int i = 0; i < capped; i++) {
                _cart.add(CartItem('Unknown item', base));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Added $qty × Unknown item • Rp ${formatInt(base)}')),
              );
            }
            _inMul = false;
            _mulBase = null;
            _display = '0';

            if (_pendingTerms.isNotEmpty) {
              _cart.addAll(_pendingTerms);
              _pendingTerms.clear();
            }
          } else {
            // perilaku lama
            _queueCurrentAsUnknown();
            if (_pendingTerms.isNotEmpty) {
              _cart.addAll(_pendingTerms);
              _pendingTerms.clear();
              _display = '0';
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Items added to cart')),
              );
            }
          }
        });
        return;

      default:
        // Digits
        if (RegExp(r'^\d+$').hasMatch(k)) {
          setState(() {
            if (_display == '0') {
              _display = k;
            } else {
              _display += k;
            }
            _display = formatInt(_parse(_display));
          });
        }
    }
  }

  void _addProductToCart(Product p) {
    setState(() {
      // A named product is a direct add; queued terms remain as-is
      _cart.add(CartItem(p.name, p.price));
      _display = '0';
      // keluar dari multiply jika ada
      _inMul = false;
      _mulBase = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${p.name} • Rp ${formatInt(p.price)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputVal = _parse(_display);
    final matched = _products.where((p) => p.price == inputVal).toList();
    final subtotal = _cartSubtotal;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: 0,
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
        child: Stack(
          children: [
            // Header & matched product list (when present)
            Column(
              children: [
                _Header(
                  amountText: 'Rp ${formatInt(inputVal)}',
                  onOpenCart: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CartScreen(
                          items: _cart,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    );
                  },
                ),
                if (matched.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 150),
                      itemCount: matched.length,
                      itemBuilder: (_, i) {
                        final p = matched[i];
                        return _ProductCard(
                          title: p.name,
                          price: p.price,
                          imageUrl: p.image,
                          onTap: () => _addProductToCart(p),
                        );
                      },
                    ),
                  ),
              ],
            ),

            // Draggable calculator – every child has bounded height
            DraggableScrollableSheet(
              initialChildSize: 0.37,
              minChildSize: 0.25,
              maxChildSize: 0.95,
              builder: (context, controller) {
                return SafeArea(
                  top: false,
                  child: LayoutBuilder(
                    builder: (context, cons) {
                      const handleAndGaps = 10.0 + 16.0 + 16.0 + 56.0 + 20.0;
                      final available = cons.maxHeight - handleAndGaps;

                      const targetKeypad = 58.0 * 5 + 8.0 * 4;
                      final keypadH = available.clamp(270.0, targetKeypad);

                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: CustomScrollView(
                          controller: controller,
                          physics: const ClampingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Center(
                                child: Container(
                                  width: 40,
                                  height: 5,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: keypadH,
                                child: _Keypad(onKey: _onKey),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: GestureDetector(
                                  onTap: subtotal > 0
                                      ? () async => await Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (_) => CartScreen(
                                              items: _cart,
                                              onChanged: () => setState(() {}),
                                            ),
                                          ))
                                      : null,
                                  child: Container(
                                    height: 56,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: AppPalette.headerGradient,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      subtotal > 0
                                          ? 'Pay  Rp ${formatInt(subtotal)}'
                                          : 'Pay',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 20),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------- Header ---------------------------------- */
class _Header extends StatelessWidget {
  const _Header({required this.amountText, required this.onOpenCart});

  final String amountText;
  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppPalette.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        children: [
          Row(
            children: [
              // Mode pill
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
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
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
              // Cart pill
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onOpenCart,
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Amount card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppPalette.shadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter Amount',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppPalette.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amountText,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------- Matched product widget -------------------------- */

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  });

  final String title;
  final int price;
  final String imageUrl;
  final VoidCallback onTap;

  static String _f(int v) => QuickSaleScreenState.formatInt(v);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[300],
              width: 48,
              height: 48,
              child: const Icon(Icons.fastfood),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Rp ${_f(price)}',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

/* -------------------------------- Keypad ---------------------------------- */

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});
  final void Function(String) onKey;

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    final fn = const Color(0xFFEFF3F6); // function keys
    final op = const Color(0xFFDDE6EF); // operator column
    const red = AppPalette.danger;
    const gap = 8.0;
    const keyH = 58.0;

    Widget leftRow(List<_KeyDef> keys) => SizedBox(
          height: keyH,
          child: Row(
            children: [
              for (int i = 0; i < keys.length; i++) ...[
                Expanded(
                  child: _CalcKey(
                    label: keys[i].label,
                    bg: keys[i].bg,
                    fg: keys[i].fg,
                    onTap: () => onKey(keys[i].label),
                  ),
                ),
                if (i != keys.length - 1) const SizedBox(width: gap),
              ],
            ],
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left grid (3 columns)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              leftRow([
                _KeyDef('CLEAR', red, Colors.white),
                _KeyDef('%', fn),
                _KeyDef('/', fn),
              ]),
              const SizedBox(height: gap),
              leftRow([
                _KeyDef('7', white),
                _KeyDef('8', white),
                _KeyDef('9', white),
              ]),
              const SizedBox(height: gap),
              leftRow([
                _KeyDef('4', white),
                _KeyDef('5', white),
                _KeyDef('6', white),
              ]),
              const SizedBox(height: gap),
              leftRow([
                _KeyDef('1', white),
                _KeyDef('2', white),
                _KeyDef('3', white),
              ]),
              const SizedBox(height: gap),
              leftRow([
                _KeyDef(',', white),
                _KeyDef('000', white),
                _KeyDef('0', white),
              ]),
            ],
          ),
        ),
        const SizedBox(width: gap),
        // Operator column (5 uniform keys)
        Column(
          children: [
            SizedBox(
              height: keyH,
              width: 64,
              child: _CalcKey(
                label: '⌫',
                bg: op,
                fg: Colors.black87,
                onTap: () => onKey('⌫'),
              ),
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: keyH,
              width: 64,
              child: _CalcKey(
                label: 'X',
                bg: op,
                fg: Colors.black87,
                onTap: () => onKey('X'), // <-- penting
              ),
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: keyH,
              width: 64,
              child: _CalcKey(
                label: '-',
                bg: op,
                fg: Colors.black87,
                onTap: () => onKey('-'),
              ),
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: keyH,
              width: 64,
              child: _CalcKey(
                label: '+',
                bg: op,
                fg: Colors.black87,
                onTap: () => onKey('+'),
              ),
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: keyH,
              width: 64,
              child: _CalcKey(
                label: '=',
                bg: op,
                fg: Colors.black87,
                onTap: () => onKey('='), // <-- pastikan panggil onKey
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyDef {
  final String label;
  final Color bg;
  final Color fg;
  _KeyDef(this.label, this.bg, [this.fg = Colors.black87]);
}

class _CalcKey extends StatelessWidget {
  const _CalcKey({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
