import 'package:flutter/material.dart';

class CreateSaleDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String buttonText;
  final String? initialValue;

  const CreateSaleDialog({
    super.key,
    this.title = "Yangi savdo yaratish",
    this.hintText = "Savdo nomi",
    this.buttonText = "Yaratish",
    this.initialValue,
  });

  /// Tashqaridan chaqirish uchun qulay static method
  static Future<String?> show(
      BuildContext context, {
        String title = "Yangi savdo yaratish",
        String hintText = "Savdo nomi",
        String buttonText = "Yaratish",
        String? initialValue,
      }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => CreateSaleDialog(
        title: title,
        hintText: hintText,
        buttonText: buttonText,
        initialValue: initialValue,
      ),
    );
  }

  @override
  State<CreateSaleDialog> createState() => _CreateSaleDialogState();
}

class _CreateSaleDialogState extends State<CreateSaleDialog> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final value = _nameController.text.trim();

    setState(() => _isSubmitting = true);

    /// Dialog faqat qiymat qaytaradi (Clean Architecture uchun yaxshi)
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Savdo nomini kiriting",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// TextField
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0A52C)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return "Savdo nomini kiriting";
                  if (text.length < 2) return "Kamida 2 ta harf kiriting";
                  if (text.length > 50) return "Nom juda uzun";
                  return null;
                },
              ),

              const SizedBox(height: 18),

              /// Button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFF2C23A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFF2C23A).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    widget.buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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