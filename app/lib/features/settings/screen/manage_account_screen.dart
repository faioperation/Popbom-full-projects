import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/settings/controller/manage_account_controller.dart';

class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _hideCurrent = true, _hideNew = true, _hideConfirm = true;

  final manageCtrl = Get.put(ManageAccountController());

  @override
  void initState() {
    super.initState();
    final u = manageCtrl.user;
    _nameCtrl.text = u?.name ?? "";
    _usernameCtrl.text = u?.username ?? "";
    _emailCtrl.text = u?.email ?? "";
    _phoneCtrl.text = u?.mobile ?? "";
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec({required String hint, String? helper, IconData? icon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: theme.iconTheme.color),
      hintText: hint,
      helperText: helper,
      helperStyle: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary),
      ),
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
    );
  }

  Widget _sectionTitle(String t, {IconData? icon}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: theme.iconTheme.color),
            const SizedBox(width: 6),
          ],
          Text(
            t,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard(Widget child) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final name = _nameCtrl.text.trim();
      final username = _usernameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final mobile = _phoneCtrl.text.trim();

      final currentPass = _currentPassCtrl.text.trim();
      final newPass = _newPassCtrl.text.trim();
      final confirmPass = _confirmPassCtrl.text.trim();

      if (newPass.isNotEmpty || currentPass.isNotEmpty) {
        if (newPass != confirmPass) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("New password & confirm password do not match"),
            ),
          );
          return;
        }
        if (newPass.length < 8) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("New password must be at least 8 characters"),
            ),
          );
          return;
        }
      }

      await manageCtrl.updateAccount(
        name: name,
        username: username,
        email: email,
        mobile: mobile,
        currentPassword: currentPass.isEmpty ? null : currentPass,
        newPassword: newPass.isEmpty ? null : newPass,
      );

      if (manageCtrl.error.value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );

        _currentPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(manageCtrl.error.value)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage my account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _sectionTitle('Profile', icon: Icons.person),

            // PROFILE INPUTS
            _glassCard(
              Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _dec(
                      hint: 'Full name',
                      icon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: _dec(
                      hint: 'Username',
                      helper: 'Only letters, numbers, underscores',
                      icon: Icons.alternate_email,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _dec(hint: 'Email', icon: Icons.email_outlined),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _dec(hint: 'Phone', icon: Icons.phone_outlined),
                  ),
                ],
              ),
            ),

            _sectionTitle('Password', icon: Icons.lock_outline),

            // PASSWORD INPUTS
            _glassCard(
              Column(
                children: [
                  TextFormField(
                    controller: _currentPassCtrl,
                    obscureText: _hideCurrent,
                    decoration:
                        _dec(
                          hint: 'Current password',
                          icon: Icons.vpn_key_outlined,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _hideCurrent
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _hideCurrent = !_hideCurrent),
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newPassCtrl,
                    obscureText: _hideNew,
                    decoration:
                        _dec(
                          hint: 'New password (min 8)',
                          icon: Icons.lock_reset_outlined,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _hideNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _hideNew = !_hideNew),
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPassCtrl,
                    obscureText: _hideConfirm,
                    decoration:
                        _dec(
                          hint: 'Confirm new password',
                          icon: Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _hideConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _hideConfirm = !_hideConfirm),
                          ),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // SAVE BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: _save,
                    child: const Text(
                      'Save changes',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // DELETE ACCOUNT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  label: const Text('Delete account'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
