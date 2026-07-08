import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileSettingsPage extends StatefulWidget {
  final String userId;
  final String name;
  final String image;

  const ProfileSettingsPage({
    super.key,
    required this.userId,
    required this.name,
    required this.image,
  });

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool notificationsOn = false;
  bool copied = false;

  final String liveLink = 'https://example.com/live/abcd1234';

  void _copyLink() async {
    await Clipboard.setData(ClipboardData(text: liveLink));
    setState(() => copied = true);
    // short feedback then reset
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? Colors.white : Colors.black87;
    final iconColor = dark ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,size: 18,),
          onPressed: () => Navigator.maybePop(context),
          tooltip: 'Back',
          splashRadius: 20,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: const SizedBox.shrink(),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: widget.image.isNotEmpty
                        ? NetworkImage(widget.image)
                        : null,
                    child: widget.image.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 28),

              // Settings list
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingRow(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      trailing: Switch.adaptive(
                        value: notificationsOn,
                        onChanged: (v) => setState(() => notificationsOn = v),
                      ),
                      textColor: textColor,
                      iconColor: iconColor,
                    ),
                    const SizedBox(height: 18),

                    _buildSettingRow(
                      icon: Icons.link_outlined,
                      title: 'Invite live link',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            copied ? 'copied' : 'copy',
                            style: TextStyle(
                              color: copied
                                  ? Theme.of(context).colorScheme.primary
                                  : (dark ? Colors.white70 : Colors.black54),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: Icon(Icons.copy, size: 20, color: iconColor),
                            onPressed: _copyLink,
                            tooltip: 'Copy invite link',
                          )
                        ],
                      ),
                      textColor: textColor,
                      iconColor: iconColor,
                    ),

                    const SizedBox(height: 8),

                    const SizedBox(height: 8),
                    Text(
                      'Manage who can join your live sessions and control notifications.',
                      style: TextStyle(
                        color: dark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required Widget trailing,
    required Color textColor,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: () {}, // optional: open detailed setting
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
      Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Invite link', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              SelectableText(liveLink),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: liveLink));
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy link'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
