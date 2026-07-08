import 'package:flutter/material.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<_Faq> _allFaqs = const [
    _Faq(
      q: 'How can I reset my password?',
      a:
      'Go to the account settings and tap on “Change password”. Specific instructions will be listed there.',
    ),
    _Faq(
      q: 'How do I delete my account?',
      a:
      'Open Settings → Manage my account → Delete account and follow the confirmation steps.',
    ),
    _Faq(
      q: 'Where can I change my email address?',
      a: 'Settings → Manage my account → Email → Update and verify.',
    ),
    _Faq(
      q: 'How to disable notifications?',
      a: 'Settings → Push notifications → toggle off the switches you don’t need.',
    ),
  ];

  String _query = '';

  List<_Faq> get _filtered =>
      _allFaqs.where((f) => f.q.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final hintColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor,size: 18,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Help Center',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600,fontSize: 16,),),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Search bar
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'search your problem',
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Icons.search, color: hintColor),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('FAQ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
          const SizedBox(height: 10),

          // FAQ cards
          for (final f in _filtered) ...[
            _FaqTile(faq: f),
            const SizedBox(height: 10),
          ],

          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'No results found.',
                style: TextStyle(color: hintColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _Faq faq;
  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final subTextColor = theme.textTheme.bodyMedium?.color ?? textColor;
    final borderColor = theme.dividerColor;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: borderColor),
    );

    return Material(
      color: theme.scaffoldBackgroundColor,
      shape: shape,
      child: ExpansionTile(
        key: PageStorageKey(widget.faq.q),
        initiallyExpanded: _open,
        onExpansionChanged: (v) => setState(() => _open = v),
        shape: shape,
        collapsedShape: shape,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        trailing: Icon(Icons.keyboard_arrow_down, color: subTextColor),
        title: Text(
          widget.faq.q,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: textColor),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.faq.a,
              style: TextStyle(color: subTextColor, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _Faq {
  final String q;
  final String a;
  const _Faq({required this.q, required this.a});
}
