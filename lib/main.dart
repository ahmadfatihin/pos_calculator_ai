import 'package:flutter/material.dart';

void main() => runApp(const PosGreenApp());

class PosGreenApp extends StatelessWidget {
  const PosGreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Quick Sale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const QuickSaleScreen(),
    );
  }
}

class QuickSaleScreen extends StatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  State<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends State<QuickSaleScreen> {
  String _display = '0';

  final List<_Product> _products = const [
    _Product('Indomie Goreng', 3000, 'https://picsum.photos/seed/indomie/200'),
    _Product('Mie Rebus', 4000, 'https://picsum.photos/seed/mie/200'),
    _Product('Teh Manis', 5000, 'https://picsum.photos/seed/teh/200'),
  ];

  int _parse(String s) => int.tryParse(s.replaceAll('.', '')) ?? 0;

  static String _format(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write('.');
    }
    return buf.toString();
  }

  void _tap(String key) {
    setState(() {
      switch (key) {
        case 'CLEAR':
          _display = '0';
          return;
        default:
          if (_display == '0') {
            _display = key;
          } else {
            _display += key;
          }
          _display = _format(_parse(_display));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _parse(_display);
    final matched = _products.where((p) => p.price == total).toList();

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            label: 'Calculator',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        selectedIndex: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Header
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Mode',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          Icon(Icons.shopping_cart, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Quick Sale',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter Amount',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${_format(total)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Product list
                if (matched.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 150),
                      itemCount: matched.length,
                      itemBuilder: (context, i) {
                        final p = matched[i];
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                p.image,
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
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              'Rp ${_format(p.price)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),

            // Draggable calculator sheet
            DraggableScrollableSheet(
              initialChildSize: 0.37,
              minChildSize: 0.25,
              maxChildSize: 0.95,
              builder: (context, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
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
                    _keypad(),
                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: total > 0 ? () {} : null,
                      child: const Text(
                        'Pay',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keypad() {
    const fnColor = Color(0xFFE8ECEF);
    const red = Color(0xFFF36A6A);
    return Column(
      children: [
        _row(['CLEAR', '%', '/', 'X'], [red, fnColor, fnColor, fnColor]),
        _row(['7', '8', '9', '-']),
        _row(['4', '5', '6', '+']),
        _row(['1', '2', '3']),
        _row([',', '000', '0']),
      ],
    );
  }

  Widget _row(List<String> keys, [List<Color?>? colors]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          for (int i = 0; i < keys.length; i++) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => _tap(keys[i]),
                child: Container(
                  height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: colors != null && i < colors.length
                        ? colors[i] ?? Colors.white
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      keys[i],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: keys[i] == 'CLEAR'
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Product {
  final String name;
  final int price;
  final String image;
  const _Product(this.name, this.price, this.image);
}
