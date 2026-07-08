import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(color: cs.onBackground),
        ),
        backgroundColor: cs.background,
        elevation: 0,
      ),
      backgroundColor: cs.background,
      body: Center(
        child: Text(
          '$title Page',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 22,
            color: cs.onBackground.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

/// Center post tab simulates opening a recorder/uploader.
class CenterPostPage extends StatelessWidget {
  const CenterPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: cs.background,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onBackground),
        titleTextStyle: theme.textTheme.titleMedium?.copyWith(
          color: cs.onBackground,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Center(
        child: FilledButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Open camera (demo)')),
          ),
          icon: Icon(Icons.videocam, color: cs.onPrimary),
          label: Text('Record / Upload', style: TextStyle(color: cs.onPrimary)),
        ),
      ),
    );
  }
}
