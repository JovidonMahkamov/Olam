import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/features/home/domain/entity/sotuv_entity.dart';
import 'package:olam/features/home/presentation/bloc/home_bloc.dart';
import 'package:olam/features/home/presentation/bloc/home_event.dart';
import 'package:olam/features/home/presentation/bloc/home_state.dart';
import 'package:olam/features/home/presentation/pages/sale_detail_page.dart';
import 'package:olam/features/home/presentation/widgets/create_sale_dialog.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_store.dart';
import 'package:olam/features/auth/presentation/widgets/elevated_wg.dart';

class SalesPage extends StatefulWidget {
  final VoidCallback onGoToKassa;
  final KassaStore kassaStore;

  const SalesPage({
    super.key,
    required this.onGoToKassa,
    required this.kassaStore,
  });

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  bool isSelectionMode = false;
  final Set<int> selectedIds = {};

  @override
  void initState() {
    super.initState();
    context.read<SotuvlarBloc>().add(const GetSotuvlarE());
  }

  void clearSelection() {
    setState(() {
      selectedIds.clear();
      isSelectionMode = false;
    });
  }

  Future<void> deleteSelected(List<SotuvEntity> sotuvlar) async {
    if (selectedIds.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("O'chirish", style: TextStyle(fontWeight: FontWeight.w500)),
        content: Text(
          "${selectedIds.length} ta savdoni o'chirmoqchimisiz?",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedWidget(
                  onPressed: () => Navigator.pop(context, false),
                  text: 'Bekor qilish',
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedWidget(
                  onPressed: () => Navigator.pop(context, true),
                  text: "O'chirish",
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    for (final id in selectedIds) {
      context.read<DeleteSotuvBloc>().add(DeleteSotuvE(id: id));
    }

    setState(() {
      selectedIds.clear();
      isSelectionMode = false;
    });

    // Ro'yxatni yangilaymiz
    context.read<SotuvlarBloc>().add(const GetSotuvlarE());
  }

  void _onTapItem(SotuvEntity sotuv) {
    if (isSelectionMode) {
      setState(() {
        if (selectedIds.contains(sotuv.id)) {
          selectedIds.remove(sotuv.id);
          if (selectedIds.isEmpty) isSelectionMode = false;
        } else {
          selectedIds.add(sotuv.id);
        }
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaleDetailPage(
          saleName: sotuv.nomi,
          saleId: sotuv.id,
          mijozId: sotuv.mijozId,
          kassaStore: widget.kassaStore,
          onGoToKassa: widget.onGoToKassa,
        ),
      ),
    );
  }

  void _onLongPressItem(SotuvEntity sotuv) {
    setState(() {
      isSelectionMode = true;
      selectedIds.add(sotuv.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          "Savdolar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: BlocBuilder<SotuvlarBloc, SotuvlarState>(
              builder: (context, state) {
                final sotuvlar = state is SotuvlarSuccess ? state.sotuvlar : <SotuvEntity>[];
                return IconButton(
                  onPressed: () {
                    if (!isSelectionMode) {
                      setState(() => isSelectionMode = true);
                      return;
                    }
                    if (selectedIds.isEmpty) {
                      clearSelection();
                    } else {
                      deleteSelected(sotuvlar);
                    }
                  },
                  icon: Icon(
                    isSelectionMode && selectedIds.isNotEmpty
                        ? Icons.delete
                        : Icons.delete_outline,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<SotuvlarBloc, SotuvlarState>(
        builder: (context, state) {
          if (state is SotuvlarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SotuvlarError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<SotuvlarBloc>().add(const GetSotuvlarE()),
                    child: const Text("Qayta urinish"),
                  ),
                ],
              ),
            );
          }

          final sotuvlar = state is SotuvlarSuccess
              ? state.sotuvlar.where((s) => s.holat == 'aktiv').toList()
              : <SotuvEntity>[];

          if (sotuvlar.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<SotuvlarBloc>().add(const GetSotuvlarE()),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
              itemCount: sotuvlar.length,
              itemBuilder: (context, index) {
                final sotuv = sotuvlar[index];
                final isSelected = selectedIds.contains(sotuv.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SaleCard(
                    title: sotuv.nomi,
                    subtitle: "${sotuv.sana.substring(0, 16)} da yaratilgan",
                    isSelected: isSelected,
                    isSelectionMode: isSelectionMode,
                    onTap: () => _onTapItem(sotuv),
                    onLongPress: () => _onLongPressItem(sotuv),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saleName = await CreateSaleDialog.show(context);
          if (saleName == null || saleName.trim().isEmpty) return;
          if (!mounted) return;

          // Mijoz tanlash dialogini ko'rsatamiz
          // Avval savdo nomi bilan keyingi sahifaga o'tamiz
          // mijoz_id ni SaleDetailPage ichida tanlatamiz
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SaleDetailPage(
                saleName: saleName.trim(),
                saleId: null, // yangi — hali API ga yuborilmagan
                mijozId: null,
                kassaStore: widget.kassaStore,
                onGoToKassa: widget.onGoToKassa,
              ),
            ),
          ).then((_) {
            // Orqaga qaytganda ro'yxatni yangilaymiz
            if (mounted) {
              context.read<SotuvlarBloc>().add(const GetSotuvlarE());
            }
          });
        },
        backgroundColor: const Color(0xFFF2C23A),
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          "Hozircha savdolar yo'q.\nPastdagi + tugmasi orqali yangi savdo qo'shing.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _SaleCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
    isSelected ? const Color(0xFFE0A52C) : const Color(0xFFE8D39B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFAEE) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3A3A3A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelectionMode)
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? const Color(0xFFE0A52C)
                      : Colors.grey.shade400,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}