import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:popbom/features/challenge/controller/challenge_create_controller.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({Key? key}) : super(key: key);

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  static const gradientColors = [Color(0xff21E6A0), Color(0xFF6DF844)];

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<TextEditingController> _ruleCtrls = [TextEditingController()];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // NEW: DATE VARIABLES
  DateTime? _startDate;
  DateTime? _endDate;

  final ChallengeCreateController cCtrl =
  Get.put(ChallengeCreateController());

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _ruleCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // PICK IMAGE
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // PICK DATE
  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // ADD RULE
  void _addRuleField() {
    if (_ruleCtrls.length >= 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot add more — maximum of 7 rules allowed."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() {
      _ruleCtrls.add(TextEditingController());
    });
  }

  // REMOVE RULE
  void _removeRuleField(int index) {
    setState(() {
      if (_ruleCtrls.length > 1) {
        _ruleCtrls[index].dispose();
        _ruleCtrls.removeAt(index);
      }
    });
  }

  // SUBMIT
  Future<void> _submit(bool isDark) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please upload an image")));
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please select dates")));
      return;
    }

    final rules = _ruleCtrls
        .map((e) => e.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final ok = await cCtrl.createChallenge(
      challengeName: _nameCtrl.text.trim(),
      challengeDesc: _descCtrl.text.trim(),
      rules: rules,
      startDate: _startDate!.toIso8601String(),
      endDate: _endDate!.toIso8601String(),
      poster: _selectedImage!,
    );

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Challenge created successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cCtrl.errorMessage ?? "Failed to create challenge"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,size: 18,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Challenges',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    // NAME
                    _FieldLabel('Challenges Name', isDark: isDark),
                    const SizedBox(height: 6),
                    _RoundedField(
                      controller: _nameCtrl,
                      hintText: 'type here',
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 18),

                    // DESCRIPTION
                    _FieldLabel('Challenges Description', isDark: isDark),
                    const SizedBox(height: 6),
                    _RoundedField(
                      controller: _descCtrl,
                      hintText: 'type here',
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 20),

                    // ============ NEW DATE ROW ============
                    _FieldLabel('Challenge Dates', isDark: isDark),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // START DATE
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[900]
                                    : const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                _startDate == null
                                    ? 'Start date'
                                    : "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // END DATE
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[900]
                                    : const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                _endDate == null
                                    ? 'End date'
                                    : "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // RULES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FieldLabel('Challenge Rules', isDark: isDark),
                        Text(
                          '${_ruleCtrls.length}/7',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Column(
                      children: List.generate(_ruleCtrls.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: _RoundedField(
                                  controller: _ruleCtrls[i],
                                  hintText: 'type rule ${i + 1}',
                                  isDark: isDark,
                                  validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_ruleCtrls.length > 1)
                                IconButton(
                                  onPressed: () => _removeRuleField(i),
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.redAccent),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _ruleCtrls.length >= 7 ? null : _addRuleField,
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: _ruleCtrls.length >= 7
                              ? Colors.grey
                              : const Color(0xff21E6A0),
                        ),
                        label: Text(
                          'Add another rule',
                          style: TextStyle(
                            color: _ruleCtrls.length >= 7
                                ? Colors.grey
                                : const Color(0xff21E6A0),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // IMAGE
                    _FieldLabel('Upload Image', isDark: isDark),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey[900]
                              : const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xff21E6A0).withOpacity(.4),
                            width: 1.2,
                          ),
                        ),
                        child: _selectedImage == null
                            ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                  size: 40,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // SUBMIT BUTTON
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: SafeArea(
                top: false,
                child: GetBuilder<ChallengeCreateController>(
                  builder: (c) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: c.inProgress ? null : () => _submit(isDark),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: c.inProgress
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                              : const Text(
                            'Create',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Reusable Widgets ---------- */

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FieldLabel(this.text, {this.isDark = false, Key? key})
      : super(key: key);

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
  final String? Function(String?)? validator;
  final bool isDark;

  const _RoundedField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
        TextStyle(color: isDark ? Colors.white54 : Colors.black45),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : const Color(0xFFF3F3F3),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xff21E6A0)),
        ),
      ),
    );
  }
}
