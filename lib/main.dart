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
    _Product(
      'Indomie Goreng',
      3000,
      'https://pasarsegar.co.id/wp-content/uploads/2022/12/3bf90ea6-651c-4bb1-b0eb-97c1df7a11aa_Indomie-Rasa-Mie-Goreng-1-Pcs-10-1.jpg',
    ),
    _Product('Nasi Putih', 5000, 'https://picsum.photos/seed/nasi/200'),
    _Product('Teh Manis', 5000, 'https://picsum.photos/seed/teh/200'),
    _Product('Indomie Telor', 12000, 'https://picsum.photos/seed/telor/200'),
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

  void _onKey(String k) {
    switch (k) {
      case 'CLEAR':
        setState(() => _display = '0');
        return;
      case '%':
      case '/':
      case 'X':
      case '+':
      case '-':
        return;
      case ',':
        return;
      case '000':
        setState(() {
          final v = _parse(_display);
          _display = _format(v * 1000);
        });
        return;
      default:
        if (RegExp(r'^\d+$').hasMatch(k)) {
          setState(() {
            if (_display == '0') {
              _display = k;
            } else {
              _display += k;
            }
            final v = _parse(_display);
            _display = _format(v);
          });
        }
    }
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
                              vertical: 6,
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
    const keyWhite = Colors.white;
    final fnBg = const Color(0xFFE8ECEF);
    final opBg = const Color(0xFFD7E0EA);
    const clearBg = Color(0xFFF36A6A);

    final rows = <List<_Cell?>>[
      [
        _Cell('CLEAR', clearBg, Colors.white),
        _Cell('%', fnBg),
        _Cell('/', fnBg),
        _Cell('X', opBg),
      ],
      [
        _Cell('7', keyWhite),
        _Cell('8', keyWhite),
        _Cell('9', keyWhite),
        _Cell('-', opBg),
      ],
      [
        _Cell('4', keyWhite),
        _Cell('5', keyWhite),
        _Cell('6', keyWhite),
        _Cell('+', opBg),
      ],
      [_Cell('1', keyWhite), _Cell('2', keyWhite), _Cell('3', keyWhite), null],
      [
        _Cell(',', keyWhite),
        _Cell('000', keyWhite),
        _Cell('0', keyWhite),
        null,
      ],
    ];

    return Column(
      children: [
        for (final r in rows) ...[
          SizedBox(
            height: 64,
            child: Row(
              children: [
                for (int i = 0; i < 4; i++) ...[
                  Expanded(
                    child: r[i] == null
                        ? const SizedBox.shrink()
                        : _CalcKey(
                            label: r[i]!.label,
                            bg: r[i]!.bg,
                            fg: r[i]!.fg,
                            onTap: () => _onKey(r[i]!.label),
                          ),
                  ),
                  if (i != 3) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Cell {
  final String label;
  final Color bg;
  final Color fg;
  _Cell(this.label, this.bg, [this.fg = Colors.black87]);
}

class _CalcKey extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  const _CalcKey({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isClear = label == 'CLEAR';
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
              color: isClear ? Colors.white : fg,
            ),
          ),
        ),
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
