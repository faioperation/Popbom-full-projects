import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _categoryController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  final NetworkClient _nc = Get.find<NetworkClient>();

  @override
  void dispose() {
    _categoryController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final body = {
      "category": _categoryController.text.trim(),
      "shortTitle": _titleController.text.trim(),
      "description": _descController.text.trim(),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Submitting report...")),
    );

    final res = await _nc.postRequest(
      Urls.createReport,
      body: body,
    );

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully!")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.errorMassage ?? "Something went wrong")),
      );
    }
  }

  InputDecoration _inputDecoration(String hint, Color fillColor, Color hintColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final fillColor = theme.brightness == Brightness.light
        ? const Color(0xFFF7F8FA)
        : const Color(0xFF2A2A2A);
    final hintColor = theme.brightness == Brightness.light
        ? Colors.black45
        : Colors.white54;
    final textColor = theme.colorScheme.onBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor,size: 18,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Report a problem",
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600,fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Category", style: TextStyle(color: textColor, fontSize: 14)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _categoryController,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration("Enter an issue type", fillColor, hintColor),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Category is required' : null,
              ),
              const SizedBox(height: 20),

              Text("Short Title", style: TextStyle(color: textColor, fontSize: 14)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration("Enter a short title of your problem", fillColor, hintColor),
                validator: (v) =>
                (v == null || v.trim().length < 4) ? 'At least 4 characters' : null,
              ),
              const SizedBox(height: 20),

              Text("Detailed description", style: TextStyle(color: textColor, fontSize: 14)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                textInputAction: TextInputAction.done,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration("Please describe your problem in details...", fillColor, hintColor),
                validator: (v) =>
                (v == null || v.trim().length < 10) ? 'At least 10 characters' : null,
              ),
              const SizedBox(height: 30),

              // Gradient Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
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
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      "Submit report",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
