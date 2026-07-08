import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popbom/features/profile/controller/edit_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialUsername,
    required this.initialBio,
    required this.initialInstagram,
    required this.initialYoutube,
    this.initialAvatarPath,
  });

  final String initialName;
  final String initialUsername;
  final String initialBio;
  final String initialInstagram;
  final String initialYoutube;
  final String? initialAvatarPath;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final EditProfileController _controller = Get.put(EditProfileController());

  File? _photo;
  late String name;
  late String username;
  late String bio;
  late String instagram;
  late String youtube;

  static const double _labelWidth = 120;
  String get publicLink => 'popbom.app/@$username';

  @override
  void initState() {
    super.initState();
    name = widget.initialName;
    username = widget.initialUsername;
    bio = widget.initialBio;
    instagram = widget.initialInstagram;
    youtube = widget.initialYoutube;

    if ((widget.initialAvatarPath ?? '').isNotEmpty) {
      _photo = File(widget.initialAvatarPath!);
    }
  }

  Future<void> _changePhoto() async {
    final picked =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _photo = File(picked.path));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Photo selected')));
    }
  }

  Future<void> _editText({
    required String title,
    required String initial,
    required ValueChanged<String> onSave,
    String? hint,
    TextInputType? keyboard,
    int maxLines = 1,
  }) async {
    final ctrl = TextEditingController(text: initial);
    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              keyboardType: keyboard,
              maxLines: maxLines,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.55)),
                filled: true,
                fillColor: cs.surfaceVariant,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: cs.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  onSave(ctrl.text.trim());
                  Navigator.pop(ctx);
                  setState(() {});
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              SizedBox(
                width: _labelWidth,
                child: Text(
                  label,
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.6),
                    fontSize: 13.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(children: [
                  Expanded(
                    child: Text(
                      value.isEmpty ? 'Add $label to your profile' : value,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: value.isEmpty
                            ? cs.onSurface.withOpacity(0.45)
                            : cs.onSurface,
                        fontSize: 14.5,
                        fontWeight:
                        value.isEmpty ? FontWeight.w400 : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right,
                      size: 18, color: cs.onSurface.withOpacity(0.4)),
                ]),
              ),
            ]),
            if (subtitle != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.6),
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.copy,
                        size: 16, color: cs.onSurface.withOpacity(0.6)),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: subtitle));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied')),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _sep() => Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 1);

  Widget _buildAvatar() {
    final cs = Theme.of(context).colorScheme;
    ImageProvider? avatarImage;

    if (_photo != null) {
      avatarImage = FileImage(_photo!);
    } else if (_controller.avatarUrl != null &&
        _controller.avatarUrl!.isNotEmpty) {
      avatarImage = CachedNetworkImageProvider(_controller.avatarUrl!,
          maxHeight: 180, maxWidth: 180);
    }

    return CircleAvatar(
      radius: 36,
      backgroundColor: cs.surfaceVariant,
      backgroundImage: avatarImage,
      child: avatarImage == null
          ? Icon(Icons.photo_camera_outlined,
          color: cs.onSurface.withOpacity(0.55), size: 26)
          : null,
    );
  }

  // In EditProfileScreen - Update the _saveChanges method
  Future<void> _saveChanges() async {
    final success = await _controller.updateProfile(
      originalName: widget.initialName,
      originalUsername: widget.initialUsername,
      originalBio: widget.initialBio,
      originalInstagram: widget.initialInstagram,
      originalYoutube: widget.initialYoutube,

      newName: name,
      newUsername: username,
      newBio: bio,
      newInstagram: instagram,
      newYoutube: youtube,

      avatarFile: _photo,
    );


    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context, {
        'name': name,
        'username': username,
        'bio': bio,
        'instagram': instagram,
        'youtube': youtube,
        'avatarPath': _photo?.path,
        'avatarUrl': _controller.avatarUrl,   // ⭐ NEW
      });


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? 'Update failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: cs.onBackground,size: 18,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: cs.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: 16
          ),
        ),
      ),
      body: GetBuilder<EditProfileController>(
        builder: (_) => ListView(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MediaAction(
                  label: 'Change photo',
                  onTap: _changePhoto,
                  child: _buildAvatar(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sep(),
            _infoRow(
              label: 'Name',
              value: name,
              onTap: () => _editText(
                title: 'Name',
                initial: name,
                onSave: (v) => name = v,
                hint: 'Your full name',
              ),
            ),
            _sep(),
            _infoRow(
              label: 'Username',
              value: username,
              subtitle: publicLink,
              onTap: () => _editText(
                title: 'Username',
                initial: username,
                onSave: (v) => username = v.replaceAll(' ', '_'),
                hint: 'username (a–z, 0–9, _)',
              ),
            ),
            _sep(),
            _infoRow(
              label: 'Bio',
              value: bio,
              onTap: () => _editText(
                title: 'Bio',
                initial: bio,
                onSave: (v) => bio = v,
                hint: 'Write something about you',
                maxLines: 5,
              ),
            ),
            _sep(),
            _infoRow(
              label: 'Instagram',
              value: instagram,
              onTap: () => _editText(
                title: 'Instagram',
                initial: instagram,
                onSave: (v) => instagram = v,
                hint: 'Add Instagram to your profile',
              ),
            ),
            _sep(),
            _infoRow(
              label: 'YouTube',
              value: youtube,
              onTap: () => _editText(
                title: 'YouTube',
                initial: youtube,
                onSave: (v) => youtube = v,
                hint: 'Add YouTube to your profile',
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                height: 50,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _controller.inProgress ? null : _saveChanges,
                    child: _controller.inProgress
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                      'Save changes',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaAction extends StatelessWidget {
  final Widget child;
  final String label;
  final VoidCallback onTap;

  const _MediaAction({
    required this.child,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(44),
      child: Column(
        children: [
          child,
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
