import 'package:flutter/material.dart';

void main() => runApp(const PosWarmindoApp());

class PosWarmindoApp extends StatelessWidget {
  const PosWarmindoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appBlue = Color(0xFF3B6EA5);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS Warmindo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appBlue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: appBlue,
          foregroundColor: Colors.white,
        ),
        fontFamily: 'Montserrat',
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool byItem = true;
  String _display = '0';
  int _total = 0;

  final List<String> itemChips = ['Indomie Telor', 'Jumbo', 'Nasi Bakar'];

  void _tap(String key) {
    setState(() {
      switch (key) {
        case 'CLEAR':
          _display = '0';
          _total = 0;
          return;
        case '+':
          _total += int.tryParse(_display.replaceAll('.', '')) ?? 0;
          _display = '0';
          return;
        case '-':
          _total -= int.tryParse(_display.replaceAll('.', '')) ?? 0;
          if (_total < 0) _total = 0;
          _display = '0';
          return;
        case '%':
          final v = int.tryParse(_display.replaceAll('.', '')) ?? 0;
          _display = _format(v ~/ 100);
          return;
        case '/':
        case 'X':
          // Placeholder for MVP
          return;
        case ',':
          // Thousands separator shortcut (visual only for MVP)
          return;
        case '.000':
          final v = int.tryParse(_display.replaceAll('.', '')) ?? 0;
          _display = _format(v * 1000);
          return;
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
          if (_display == '0') {
            _display = key;
          } else {
            _display += key;
          }
          _display = _format(int.tryParse(_display.replaceAll('.', '')) ?? 0);
          return;
      }
    });
  }

  void _addItem() {
    setState(() {
      final v = int.tryParse(_display.replaceAll('.', '')) ?? 0;
      if (v > 0) {
        _total += v;
        if (byItem) itemChips.add('Item ${itemChips.length + 1}');
        _display = '0';
      }
    });
  }

  void _clearBill() => setState(() {
    _display = '0';
    _total = 0;
    itemChips
      ..clear()
      ..addAll(['Indomie Telor', 'Jumbo', 'Nasi Bakar']);
  });

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

  @override
  Widget build(BuildContext context) {
    const softBlue = Color(0xFF9DB6D5);
    const fnBlue = Color(0xFF7FA6D6);
    final payEnabled = _total > 0 || _display != '0';
    final payAmount =
        _total + (int.tryParse(_display.replaceAll('.', '')) ?? 0);

    return Scaffold(
      drawer: const _SideDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('POS Warmindo'),
        centerTitle: false,
        actions: [
          Row(
            children: [
              const Text(
                'By item',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: byItem,
                activeColor: Colors.white,
                onChanged: (v) => setState(() => byItem = v),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Clear Bill',
                onPressed: _clearBill,
                icon: const Icon(Icons.delete_outline),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top totals & main display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_format(_total)} | ${_display}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    _format(int.tryParse(_display.replaceAll('.', '')) ?? 0),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Item:'),
              const SizedBox(height: 8),
              if (byItem)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final it in itemChips)
                      InputChip(
                        label: Text(it),
                        onPressed: () {},
                        onDeleted: () => setState(() => itemChips.remove(it)),
                        deleteIcon: const Icon(Icons.add, size: 18),
                      ),
                  ],
                )
              else
                const SizedBox(height: 8),
              const SizedBox(height: 8),

              // Keypad
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final btnH =
                        (c.maxHeight - 24) / 5; // ~5 rows (spacing included)
                    return Column(
                      children: [
                        _keyRow([
                          _K(
                            'CLEAR',
                            background: const Color(0xFFF1CACA),
                            onTap: () => _tap('CLEAR'),
                          ),
                          _K('%', background: softBlue, onTap: () => _tap('%')),
                          _K('-', background: softBlue, onTap: () => _tap('-')),
                          _K('+', background: softBlue, onTap: () => _tap('+')),
                        ], height: btnH),
                        const SizedBox(height: 6),
                        _keyRow([
                          _K('7', onTap: () => _tap('7')),
                          _K('8', onTap: () => _tap('8')),
                          _K('9', onTap: () => _tap('9')),
                          _K('/', background: fnBlue, onTap: () => _tap('/')),
                        ], height: btnH),
                        const SizedBox(height: 6),
                        _keyRow([
                          _K('4', onTap: () => _tap('4')),
                          _K('5', onTap: () => _tap('5')),
                          _K('6', onTap: () => _tap('6')),
                          _K('X', background: fnBlue, onTap: () => _tap('X')),
                        ], height: btnH),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _keyRow([
                                      _K('1', onTap: () => _tap('1')),
                                      _K('2', onTap: () => _tap('2')),
                                      _K('3', onTap: () => _tap('3')),
                                    ], height: (btnH - 3)),
                                    const SizedBox(height: 6),
                                    _keyRow([
                                      _K(',', onTap: () => _tap(',')),
                                      _K('0', onTap: () => _tap('0')),
                                      _K('.000', onTap: () => _tap('.000')),
                                    ], height: (btnH - 3)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 90,
                                child: _KeyButton(
                                  label: 'Add\nItem',
                                  onTap: _addItem,
                                  background: fnBlue,
                                  height: (btnH * 2 + 6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF7E4FB4),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long),
                          SizedBox(width: 8),
                          Text('Bill'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                      onPressed: payEnabled ? () {} : null,
                      child: Text(
                        'PAY Rp. ${_format(payAmount)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keyRow(List<_K> ks, {required double height}) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (int i = 0; i < ks.length; i++) ...[
            Expanded(
              child: _KeyButton(
                label: ks[i].label,
                onTap: ks[i].onTap,
                background: ks[i].background,
              ),
            ),
            if (i != ks.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _K {
  final String label;
  final VoidCallback onTap;
  final Color? background;
  _K(this.label, {required this.onTap, this.background});
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? background;
  final double? height;
  const _KeyButton({
    required this.label,
    this.onTap,
    this.background,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? Colors.white;
    return SizedBox(
      height: height,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideDrawer extends StatelessWidget {
  const _SideDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: CircleAvatar(child: Text('W')),
              title: Text('POS Warmindo'),
              subtitle: Text('pos@wolkk.com'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.calculate_outlined),
              title: Text('Calculator'),
            ),
            const ListTile(
              leading: Icon(Icons.history),
              title: Text('History Transaction'),
            ),
            const ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Setting'),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () => Navigator.pop(context),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Calculator POS 2025',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
