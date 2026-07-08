import 'package:flutter/material.dart';

class CashOutScreen extends StatefulWidget {
  final double estimatedBalance;
  const CashOutScreen({Key? key, required this.estimatedBalance}) : super(key: key);

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  static const gradientColors = [Color(0xff21E6A0), Color(0xFF6DF844)];

  final _formKey = GlobalKey<FormState>();
  final _agentCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _agentCtrl.dispose();
    _mobileCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit(bool isDark) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cash out $amount USD request submitted'),
        backgroundColor: isDark ? Colors.grey[850] : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // আগে Provider থেকে নিচ্ছিলে—এখন সরাসরি থিম থেকে নিচ্ছি যাতে উল্টো না হয়
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balance = widget.estimatedBalance;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: isDark ? Colors.white : Colors.black),
        ),
        title: Text(
          'Cash Out',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              _FieldLabel('Agent Name', isDark: isDark),
              const SizedBox(height: 6),
              _RoundedField(
                controller: _agentCtrl,
                hintText: 'type here',
                textInputAction: TextInputAction.next,
                isDark: isDark,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel('Bank Account', isDark: isDark),
              const SizedBox(height: 6),
              _RoundedField(
                controller: _mobileCtrl,
                hintText: 'type here',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                isDark: isDark,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Required';
                  if (t.length < 8) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _FieldLabel('Amount (USD) — Available: USD ${balance.toStringAsFixed(2)}', isDark: isDark),
              const SizedBox(height: 6),
              _RoundedField(
                controller: _amountCtrl,
                hintText: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                isDark: isDark,
                validator: (v) {
                  final raw = (v ?? '').trim();
                  if (raw.isEmpty) return 'Required';
                  final amount = double.tryParse(raw.replaceAll(',', ''));
                  if (amount == null) return 'Enter a valid amount';
                  if (amount <= 0) return 'Amount must be greater than 0';
                  if (amount > balance) return 'Exceeds available balance (USD ${balance.toStringAsFixed(2)})';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _submit(isDark),
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- Reusable pieces ---------- */

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FieldLabel(this.text, {this.isDark = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isDark;

  const _RoundedField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.textInputAction,
    this.keyboardType,
    this.validator,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : const Color(0xFFF3F3F3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Colors.green),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
