import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olam/core/currency/exchange_rate_local_ds.dart';
import 'package:olam/core/currency/exchange_rate_remote_ds.dart';
import 'package:olam/core/currency/exchange_rate_repo.dart';
import 'package:olam/core/utils/money_fmt.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _usdCtrl = TextEditingController();
  final _uzsCtrl = TextEditingController();

  double _rate = MoneyFmt.usdToUzs; // core'dagi hozirgi kurs (main set qilgan)
  DateTime? _updatedAt;

  bool _loading = false;
  _LastEdited _lastEdited = _LastEdited.usd;

  @override
  void initState() {
    super.initState();
    _loadRate(); // page ochilganda yangisini olib ko‘ramiz
    _usdCtrl.addListener(_onUsdChanged);
    _uzsCtrl.addListener(_onUzsChanged);
  }

  @override
  void dispose() {
    _usdCtrl.removeListener(_onUsdChanged);
    _uzsCtrl.removeListener(_onUzsChanged);
    _usdCtrl.dispose();
    _uzsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRate() async {
    setState(() => _loading = true);

    try {
      final repo = ExchangeRateRepo(
        remote: ExchangeRateRemoteDs(),
        local: ExchangeRateLocalDs(),
      );

      final r = await repo.getUsdToUzs();

      // ✅ global ham update bo‘lsin (app bo‘ylab)
      MoneyFmt.usdToUzs = r.usdToUzs;

      setState(() {
        _rate = r.usdToUzs;
        _updatedAt = r.updatedAt;
      });

      // kiritilgan qiymatlar bo‘lsa qayta hisoblab qo‘yamiz
      _recalc();
    } catch (_) {
      // xatoda ham fallback bor, shunchaki UI qoladi
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onUsdChanged() {
    if (_lastEdited != _LastEdited.usd) return;
    final usd = _parseUsd(_usdCtrl.text);
    final uzs = (usd * _rate).round();
    _setUzs(uzs);
  }

  void _onUzsChanged() {
    if (_lastEdited != _LastEdited.uzs) return;
    final uzs = _parseUzs(_uzsCtrl.text);
    final usd = uzs / _rate;
    _setUsd(usd);
  }

  void _recalc() {
    if (_lastEdited == _LastEdited.usd) {
      _onUsdChanged();
    } else {
      _onUzsChanged();
    }
  }

  void _setUsd(double usd) {
    final text = usd.isNaN || usd.isInfinite ? "" : usd.toStringAsFixed(2);
    if (_usdCtrl.text == text) return;

    _usdCtrl.removeListener(_onUsdChanged);
    _usdCtrl.text = text;
    _usdCtrl.selection = TextSelection.collapsed(offset: _usdCtrl.text.length);
    _usdCtrl.addListener(_onUsdChanged);
  }

  void _setUzs(int uzs) {
    final text = uzs <= 0 ? "" : _formatUzs(uzs);
    if (_uzsCtrl.text == text) return;

    _uzsCtrl.removeListener(_onUzsChanged);
    _uzsCtrl.text = text;
    _uzsCtrl.selection = TextSelection.collapsed(offset: _uzsCtrl.text.length);
    _uzsCtrl.addListener(_onUzsChanged);
  }

  double _parseUsd(String s) {
    final t = s.trim().replaceAll(',', '.');
    return double.tryParse(t) ?? 0.0;
  }

  int _parseUzs(String s) {
    final t = s.replaceAll(' ', '').trim();
    return int.tryParse(t) ?? 0;
  }

  String _formatUzs(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      b.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) b.write(' ');
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final rateText = "1\$ = ${_rate.toStringAsFixed(2)} UZS";
    final updatedText = _updatedAt == null
        ? ""
        : "Yangilandi: ${_updatedAt!.toLocal().toString().substring(0, 16)}";

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Kurs kalkulyatori",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: "Kursni yangilash",
            onPressed: _loading ? null : _loadRate,
            icon: _loading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            children: [
              _InfoCard(
                title: rateText,
                subtitle: updatedText.isEmpty ? null : updatedText,
              ),
              const SizedBox(height: 12),

              _InputCard(
                title: "USD (\$)",
                controller: _usdCtrl,
                hint: "Dollar kiriting",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onTap: () => setState(() => _lastEdited = _LastEdited.usd),
              ),
              const SizedBox(height: 12),

              Center(
                child: IconButton(
                  iconSize: 34,
                  onPressed: () {
                    setState(() {
                      _lastEdited = _lastEdited == _LastEdited.usd
                          ? _LastEdited.uzs
                          : _LastEdited.usd;
                    });
                    _recalc();
                  },
                  icon: const Icon(Icons.swap_vert),
                ),
              ),

              const SizedBox(height: 12),
              _InputCard(
                title: "UZS (so‘m)",
                controller: _uzsCtrl,
                hint: "So'm kiriting",
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onTap: () => setState(() => _lastEdited = _LastEdited.uzs),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

enum _LastEdited { usd, uzs }

class _InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _InfoCard({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: const TextStyle(color: Color(0xFF6A6A6A), fontWeight: FontWeight.w600)),
          ]
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final VoidCallback onTap;

  const _InputCard({
    required this.title,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onTap: onTap,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF3F3F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
