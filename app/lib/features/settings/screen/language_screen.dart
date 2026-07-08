import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<_Lang> _all = const [
    _Lang('English', 'EN'),
    _Lang('বাংলা', 'BN'),
    _Lang('हिंदी', 'HI'),
    _Lang('Español', 'ES'),
    _Lang('Français', 'FR'),
    _Lang('Deutsch', 'DE'),
    _Lang('Italiano', 'IT'),
    _Lang('Português', 'PT'),
    _Lang('Türkçe', 'TR'),
    _Lang('العربية', 'AR'),
    _Lang('中文 (简体)', 'ZH'),
    _Lang('日本語', 'JA'),
  ];

  String _query = '';
  String _selectedCode = 'EN';

  List<_Lang> get _filtered => _all
      .where((l) =>
  l.name.toLowerCase().contains(_query.toLowerCase()) ||
      l.code.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  void _apply() {
    final selected =
    _all.firstWhere((e) => e.code == _selectedCode, orElse: () => _all[0]);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Language set to ${selected.name}')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _row(_Lang l, Color textColor, Color subTextColor) {
    return Material(
      color: Colors.transparent, // <-- এখানে changed
      child: InkWell(
        onTap: () => setState(() => _selectedCode = l.code),
        child: ListTile(
          title: Text(l.name,
              style: TextStyle(
                  fontSize: 15.5, fontWeight: FontWeight.w500, color: textColor)),
          subtitle: Text(l.code, style: TextStyle(color: subTextColor)),
          trailing: Radio<String>(
            value: l.code,
            groupValue: _selectedCode,
            activeColor: const Color(0xFF22C55E),
            onChanged: (v) => setState(() => _selectedCode = v!),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          visualDensity: const VisualDensity(vertical: -1),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final inputBg = theme.inputDecorationTheme.fillColor;
    final textColor = theme.textTheme.bodyLarge!.color!;
    final hintColor = theme.textTheme.bodyMedium!.color!;
    final subTextColor = hintColor.withOpacity(0.7);

    final items = _filtered;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Language',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search language',
                hintStyle: TextStyle(color: hintColor),
                prefixIcon: Icon(Icons.search, color: hintColor),
                filled: true,
                fillColor: inputBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
              child: Text('No languages found',
                  style: TextStyle(color: subTextColor)),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemBuilder: (_, i) => _row(items[i], textColor, subTextColor),
              itemCount: items.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _apply,
                  child: const Text('Apply',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Lang {
  final String name;
  final String code;
  const _Lang(this.name, this.code);
}
