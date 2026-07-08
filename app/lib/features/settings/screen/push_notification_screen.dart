import 'package:flutter/material.dart';

class PushNotificationsScreen extends StatefulWidget {
  const PushNotificationsScreen({super.key});

  @override
  State<PushNotificationsScreen> createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  bool master = true;
  bool likes = true;
  bool comments = true;
  bool newFollowers = true;
  bool mentions = true;
  bool reminders = false;

  TimeOfDay quietFrom = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay quietTo = const TimeOfDay(hour: 7, minute: 0);
  bool quietHours = false;

  Future<void> _pickTime({required bool from}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: from ? quietFrom : quietTo,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          timePickerTheme: TimePickerThemeData(
            dialHandColor: Theme.of(ctx).colorScheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (from) quietFrom = picked;
        else quietTo = picked;
      });
    }
  }

  Widget _sectionTitle(String t, Color textColor) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
    child: Text(t,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
  );

  Widget _tile({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required Color textColor,
    Color? subTextColor,
  }) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          title: Text(title,
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500, color: textColor)),
          subtitle: subtitle == null
              ? null
              : Text(subtitle,
              style: TextStyle(color: subTextColor ?? textColor.withOpacity(0.6), fontSize: 12.5)),
          trailing: trailing,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          visualDensity: const VisualDensity(vertical: -1),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final subTextColor = theme.textTheme.bodyMedium?.color ?? textColor.withOpacity(0.6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Push notifications',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _card([
            _tile(
              title: 'Enable notifications',
              subtitle: 'Turn all notifications on or off',
              trailing: Switch(
                value: master,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF22C55E),
                onChanged: (v) => setState(() => master = v),
              ),
              textColor: textColor,
            ),
          ]),
          const SizedBox(height: 16),
          _sectionTitle('What you receive', textColor),
          _card([
            _tile(
              title: 'Likes',
              trailing: Switch(
                value: likes && master,
                onChanged: master ? (v) => setState(() => likes = v) : null,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF22C55E),
              ),
              textColor: textColor,
            ),
            _tile(
              title: 'Comments',
              trailing: Switch(
                value: comments && master,
                onChanged: master ? (v) => setState(() => comments = v) : null,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF22C55E),
              ),
              textColor: textColor,
            ),
            _tile(
              title: 'New followers',
              trailing: Switch(
                value: newFollowers && master,
                onChanged: master ? (v) => setState(() => newFollowers = v) : null,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF22C55E),
              ),
              textColor: textColor,
            ),
            _tile(
              title: 'Mentions',
              trailing: Switch(
                value: mentions && master,
                onChanged: master ? (v) => setState(() => mentions = v) : null,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF22C55E),
              ),
              textColor: textColor,
            ),
            _tile(
              title: 'Reminders',
              trailing: Switch(
                value: reminders && master,
                onChanged: master ? (v) => setState(() => reminders = v) : null,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF22C55E),
              ),
              textColor: textColor,
            ),
          ]),
          const SizedBox(height: 16),
          _sectionTitle('Quiet hours', textColor),
          _card([
            _tile(
              title: 'Enable quiet hours',
              subtitle: 'Mute notifications during selected hours',
              trailing: Switch(
                value: quietHours && master,
                onChanged: master ? (v) => setState(() => quietHours = v) : null,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF22C55E),
              ),
              textColor: textColor,
              subTextColor: subTextColor,
            ),
            _tile(
              title: 'From',
              subtitle: _fmt(quietFrom),
              trailing: Icon(Icons.schedule, color: subTextColor),
              onTap: master && quietHours ? () => _pickTime(from: true) : null,
              textColor: textColor,
            ),
            _tile(
              title: 'To',
              subtitle: _fmt(quietTo),
              trailing: Icon(Icons.schedule, color: subTextColor),
              onTap: master && quietHours ? () => _pickTime(from: false) : null,
              textColor: textColor,
            ),
          ]),
          const SizedBox(height: 22),

          // ===== Gradient Save Button =====
          SizedBox(
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _save,
                child: const Text('Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
