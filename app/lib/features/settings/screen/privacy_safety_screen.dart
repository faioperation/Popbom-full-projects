import 'package:flutter/material.dart';

class PrivacySafetyScreen extends StatelessWidget {
  const PrivacySafetyScreen({super.key});

  Widget _bullet(String text, Color textColor) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Icon(Icons.circle, size: 6, color: textColor),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 14, height: 1.35, color: textColor),
        ),
      ),
    ],
  );

  Widget _h(String t, Color color) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 6),
    child: Text(
      t,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final subTextColor = theme.textTheme.bodyMedium?.color ?? textColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy & Safety',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DoneBox is a task and reminder app. We respect your privacy and only collect what's needed to provide our services.",
              style: TextStyle(fontSize: 14, height: 1.45, color: subTextColor),
            ),
            _h('Information We Collect', textColor),
            _bullet(
              'Account info: email, name, password (hashed).',
              subTextColor,
            ),
            _bullet(
              'Task data: tasks, notes, reminders, attachments.',
              subTextColor,
            ),
            _bullet(
              'Device data: app usage, crash logs, timezone.',
              subTextColor,
            ),
            _bullet(
              'Optional: calendar, contacts, notifications, analytics (only if you enable).',
              subTextColor,
            ),
            _h('How We Use Data', textColor),
            _bullet('Provide and sync reminders and tasks.', subTextColor),
            _bullet('Send notifications and alerts.', subTextColor),
            _bullet('Improve app performance and fix bugs.', subTextColor),
            _bullet('Comply with law and prevent abuse.', subTextColor),
            _h('Sharing', textColor),
            _bullet('We do not sell your data.', subTextColor),
            _bullet(
              'Shared only with service providers (hosting, crash reports, payments) or if required by law.',
              subTextColor,
            ),
            _h('Security & Retention', textColor),
            _bullet('We use encryption and safeguards.', subTextColor),
            _bullet(
              'Data is deleted when you close your account, except where law requires longer retention.',
              subTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
