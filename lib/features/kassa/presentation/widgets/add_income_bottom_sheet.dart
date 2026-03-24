import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/core/di/services_locator.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';
import 'package:olam/features/kassa/data/datasource/kassa_data_source.dart';
import 'package:olam/features/kassa/domain/entity/kassa_entity.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_bloc.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_event.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_state.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_store.dart';

class AddIncomeBottomSheet extends StatefulWidget {
  final KassaStore store;
  final PayType payType;
  final int kassaId;
  final VoidCallback? onSuccess;

  const AddIncomeBottomSheet({
    super.key,
    required this.store,
    required this.payType,
    required this.kassaId,
    this.onSuccess,
  });

  static Future<void> show(
      BuildContext context, {
        required KassaStore store,
        required PayType payType,
        required int kassaId,
        VoidCallback? onSuccess,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<KassaBloc>()),
          BlocProvider.value(value: context.read<BugungiSotuvBloc>()),
          BlocProvider.value(value: context.read<QarzdorBloc>()),
          BlocProvider.value(value: context.read<KirimBloc>()),
        ],
        child: AddIncomeBottomSheet(
          store:     store,
          payType:   payType,
          kassaId:   kassaId,
          onSuccess: onSuccess,
        ),
      ),
    );
  }

  @override
  State<AddIncomeBottomSheet> createState() => _AddIncomeBottomSheetState();
}

class _AddIncomeBottomSheetState extends State<AddIncomeBottomSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  bool _sendSms     = false;
  bool _isLoading   = false;
  QarzdorMijozEntity? _selected;

  @override
  void initState() {
    super.initState();
    context.read<QarzdorBloc>().add(const GetQarzdorMijozlarE());
  }

  double get _enteredUsd {
    final t = _amountCtrl.text.trim().replaceAll(',', '.');
    return double.tryParse(t) ?? 0.0;
  }

  double get _remainingDebt {
    if (_selected == null) return 0;
    final left = _selected!.qarzdorlik - _enteredUsd;
    return left > 0 ? left : 0;
  }

  void _pickDebtor(List<QarzdorMijozEntity> debtors) async {
    if (debtors.isEmpty) {
      _toast("Qarzdor mijozlar yo'q");
      return;
    }
    final selected = await showModalBottomSheet<QarzdorMijozEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DebtorPickerSheet(items: debtors, initial: _selected),
    );
    if (!mounted) return;
    if (selected != null) {
      setState(() {
        _selected = selected;
        _amountCtrl.clear();
      });
    }
  }

  void _submit() async {
    final debtor = _selected;
    if (debtor == null) { _toast("Mijozni tanlang"); return; }
    if (_enteredUsd <= 0) { _toast("Summani kiriting"); return; }
    if (_enteredUsd > debtor.qarzdorlik + 0.01) {
      _toast("Kiritilgan summa qarzdan katta bo'lmasin");
      return;
    }

    final payUsd = _enteredUsd > debtor.qarzdorlik
        ? debtor.qarzdorlik
        : _enteredUsd;
    final yangiQarz = debtor.qarzdorlik - payUsd;

    setState(() => _isLoading = true);

    try {
      // ✅ Kassaga kirim qo'shamiz
      await sl<KassaDataSource>().addKirim(
        kassaId:      widget.kassaId,
        mijozId:      debtor.id,
        summaUsd:     payUsd,
        smsYuborildi: _sendSms,
        izoh:         _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );

      // ✅ Mijoz qarzini API da yangilaymiz
      await sl<KassaDataSource>().updateMijozQarz(
        mijozId:   debtor.id,
        yangiQarz: yangiQarz,
      );

      if (!mounted) return;

      // ✅ Avval refresh, keyin yopamiz
      widget.onSuccess?.call();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(yangiQarz < 0.01
            ? "${debtor.fish} qarzi to'liq yopildi ✅"
            : "${debtor.fish} \$${payUsd.toStringAsFixed(2)} qabul qilindi. Qoldi: \$${yangiQarz.toStringAsFixed(2)}"),
        backgroundColor: Colors.green,
      ));

      widget.onSuccess?.call();
    } catch (e) {
      if (mounted) _toast("Xatolik yuz berdi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: BlocListener<KirimBloc, KirimState>(
          listener: (context, state) {
            if (state is KirimError) _toast(state.message);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      "Kirim qo'shish · ${widget.payType.label}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Mijoz tanlash
              BlocBuilder<QarzdorBloc, QarzdorState>(
                builder: (context, state) {
                  final debtors = state is QarzdorSuccess ? state.mijozlar : <QarzdorMijozEntity>[];
                  final isLoading = state is QarzdorLoading;

                  return InkWell(
                    onTap: isLoading ? null : () => _pickDebtor(debtors),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: isLoading
                                ? const Text("Yuklanmoqda...",
                                style: TextStyle(color: Colors.grey))
                                : Text(
                              _selected?.fish ?? "Qarzdor mijozni tanlang",
                              style: TextStyle(
                                color: _selected == null
                                    ? Colors.grey
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Tanlangan mijoz qarzi
              if (_selected != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selected!.fish,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            if (_selected!.telefon != null)
                              Text(_selected!.telefon!,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            Text(
                              "Umumiy qarz: \$${_selected!.qarzdorlik.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Summa
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      onChanged: (_) => setState(() {}),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        hintText: "Summa kiriting (\$)",
                        filled: true,
                        fillColor: const Color(0xFFF3F3F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text("\$",
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),

              // Qolgan qarz
              if (_selected != null && _enteredUsd > 0) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _remainingDebt < 0.01
                        ? "Qarz to'liq yopiladi ✅"
                        : "Qoladi: \$${_remainingDebt.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _remainingDebt < 0.01
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // SMS
              InkWell(
                onTap: () => setState(() => _sendSms = !_sendSms),
                child: Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: _sendSms
                            ? const Color(0xFFE7C66A)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: _sendSms
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text("SMS yuborish",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Izoh
              TextField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  hintText: "Izoh...",
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                minLines: 1,
                maxLines: 2,
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: BlocBuilder<KirimBloc, KirimState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is KirimLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE7C66A),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26)),
                      ),
                      child: state is KirimLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Qo'shish",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Debtor picker
class _DebtorPickerSheet extends StatelessWidget {
  final List<QarzdorMijozEntity> items;
  final QarzdorMijozEntity? initial;

  const _DebtorPickerSheet({required this.items, required this.initial});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 80),
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Qarzdor mijozlar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final it = items[i];
                  return InkWell(
                    onTap: () => Navigator.pop(context, it),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3F3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline,
                              color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it.fish,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                if (it.telefon != null)
                                  Text(it.telefon!,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            "\$${it.qarzdorlik.toStringAsFixed(2)}",
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}