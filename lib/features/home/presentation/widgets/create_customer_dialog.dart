import 'package:flutter/material.dart';
import 'package:olam/features/home/presentation/widgets/create_customer_form_result.dart';
import 'package:olam/features/home/presentation/widgets/sale_customer_model.dart';

class CreateCustomerDialog extends StatefulWidget {
  const CreateCustomerDialog({super.key});

  static Future<CreateCustomerFormResult?> show(BuildContext context) {
    return showDialog<CreateCustomerFormResult>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => const CreateCustomerDialog(),
    );
  }

  @override
  State<CreateCustomerDialog> createState() => _CreateCustomerDialogState();
}

class _CreateCustomerDialogState extends State<CreateCustomerDialog> {
  final _formKey = GlobalKey<FormState>();

  SaleCustomerType _selectedType = SaleCustomerType.mijoz;

  final _socialTypeCtrl = TextEditingController(text: "Eski");
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _socialTypeCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _isSubmitting = true);

    final result = CreateCustomerFormResult(
      customerType: _selectedType,
      socialType: _socialTypeCtrl.text.trim(),
      fullName: _fullNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Yangi mijoz qo‘shish",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: Colors.redAccent, size: 22),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 18),

              _FieldLabel("Mijoz turi"),
              const SizedBox(height: 6),
              _TypeDropdownField(
                value: _selectedType,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedType = value);
                },
              ),

              const SizedBox(height: 10),

              _FieldLabel("Ijtimoiy tarmoq turi"),
              const SizedBox(height: 6),
              _CommonTextField(
                controller: _socialTypeCtrl,
                hintText: "Ijtimoiy tarmoq turini kiriting",
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return "Ijtimoiy tarmoq turini kiriting";
                  return null;
                },
              ),

              const SizedBox(height: 10),

              _FieldLabel("F.I.SH"),
              const SizedBox(height: 6),
              _CommonTextField(
                controller: _fullNameCtrl,
                hintText: "F.I.SH kiriting",
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return "F.I.SH kiriting";
                  if (t.length < 2) return "Kamida 2 ta harf kiriting";
                  return null;
                },
              ),

              const SizedBox(height: 10),

              _FieldLabel("Telefon raqami"),
              const SizedBox(height: 6),
              _CommonTextField(
                controller: _phoneCtrl,
                hintText: "Telefon raqamini kiriting",
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),

              _FieldLabel("Manzil"),
              const SizedBox(height: 6),
              _CommonTextField(
                controller: _addressCtrl,
                hintText: "Manzilni kiriting",
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFF2C23A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Yaratish",
                    style: TextStyle(
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF666666),
        ),
      ),
    );
  }
}

class _TypeDropdownField extends StatelessWidget {
  final SaleCustomerType value;
  final ValueChanged<SaleCustomerType?> onChanged;

  const _TypeDropdownField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SaleCustomerType>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          hint: Text(
            "Mijoz turini tanlang",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: SaleCustomerType.mijoz,
              child: Text("Mijoz"),
            ),
            DropdownMenuItem(
              value: SaleCustomerType.optom,
              child: Text("Optom"),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const _CommonTextField({
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
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
      validator: validator,
    );
  }
}