import 'package:flutter/material.dart';
import 'package:olam/features/home/presentation/widgets/customer_model.dart';

class CustomerSelectPage extends StatefulWidget {
  const CustomerSelectPage({
    super.key,
    required this.customers,
  });

  final List<CustomerModel> customers;

  @override
  State<CustomerSelectPage> createState() => _CustomerSelectPageState();
}

class _CustomerSelectPageState extends State<CustomerSelectPage> {
  final _qController = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    _qController.addListener(() {
      setState(() => _query = _qController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _qController.dispose();
    super.dispose();
  }

  List<CustomerModel> get _filtered {
    if (_query.isEmpty) return widget.customers;
    return widget.customers.where((c) {
      final n = c.name.toLowerCase();
      final p = (c.phone ?? "").toLowerCase();
      final a = (c.address ?? "").toLowerCase();
      return n.contains(_query) || p.contains(_query) || a.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFB96D00),
                Color(0xFFD8921A),
                Color(0xFFE0A52C),
                Color(0xFFC97D08),
              ],
            ),
          ),
        ),
        title: const Text(
          "Mijoz tanlash",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SearchField(controller: _qController),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
              child: Text(
                "Mijoz topilmadi",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = _filtered[index];
                return _CustomerCard(
                  customer: c,
                  onTap: () => Navigator.pop(context, c), // ✅ qaytarib beradi
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            spreadRadius: 0,
            offset: Offset(0, 6),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: "Qidiruv",
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.black45),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.onTap,
  });

  final CustomerModel customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFD58A), width: 1),
          boxShadow: const [
            BoxShadow(
              blurRadius: 14,
              offset: Offset(0, 6),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  customer.roleText,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if ((customer.phone ?? "").isNotEmpty) ...[
              _InfoRow(icon: Icons.phone, text: customer.phone!),
              const SizedBox(height: 8),
            ],

            if ((customer.address ?? "").isNotEmpty)
              _InfoRow(icon: Icons.location_on, text: customer.address!),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE0A52C)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}