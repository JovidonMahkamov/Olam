import 'package:flutter/material.dart';
import 'package:olam/features/home/presentation/pages/sale_detail_page.dart';
import 'package:olam/features/home/presentation/widgets/create_sale_dialog.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_store.dart';

import '../../../auth/presentation/widgets/elevated_wg.dart';

class SalesPage extends StatefulWidget {
  final VoidCallback onGoToKassa;
  final KassaStore kassaStore;
  const SalesPage({super.key, required this.onGoToKassa, required this.kassaStore});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  bool isSelectionMode = false;
  final Set<int> selectedIndexes = {};

  /// API ulanganidan keyin shu listga response keladi
  /// Hozircha demo ko‘rinish uchun map ishlatyapmiz.
  /// Keyin modelga almashtirish oson bo‘ladi.
  List<Map<String, dynamic>> _roomsCache = [
    {
      "id": 1,
      "name": "Savdo 1",
      "created_at": "2026-02-15 19:13:43",
    },
    {
      "id": 2,
      "name": "Savdo 2",
      "created_at": "2026-03-15 19:13:43",
    },
  ];

  void clearSelection() {
    setState(() {
      selectedIndexes.clear();
      isSelectionMode = false;
    });
  }

  Future<void> deleteSelected() async {
    if (_roomsCache.isEmpty || selectedIndexes.isEmpty) return;

    // index -> roomId
    final roomIds = selectedIndexes
        .where((i) => i >= 0 && i < _roomsCache.length)
        .map((i) => _roomsCache[i]["id"])
        .toList();

    if (roomIds.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Chatni o‘chirish",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        content: Text(
          "${roomIds.length} ta chatni o‘chirmoqchimisiz?",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                  text: 'O‘chirish',
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (ok != true) return;

    /// Hozircha local listdan o‘chirib turamiz (demo)
    setState(() {
      _roomsCache = _roomsCache.asMap().entries
          .where((e) => !selectedIndexes.contains(e.key))
          .map((e) => e.value)
          .toList();

      selectedIndexes.clear();
      isSelectionMode = false;
    });

    // Keyinchalik
    // context.read<ChatDeleteBloc>().add(DeleteChatsE(roomIds: roomIds));
  }

  /// API ga moslash uchun helperlar (keyin modelga oson almashtiriladi)
  String _roomTitle(Map<String, dynamic> room, int index) {
    final name = room["name"]?.toString();
    if (name != null && name.trim().isNotEmpty) return name;
    return "Savdo ${index + 1}";
  }

  String _roomCreatedAt(Map<String, dynamic> room) {
    final createdAt = room["created_at"]?.toString() ?? "";
    if (createdAt.isEmpty) return "Sana mavjud emas";
    return "$createdAt da yaratilgan";
  }

  void _onTapItem(int index) {
    if (isSelectionMode) {
      setState(() {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
          if (selectedIndexes.isEmpty) {
            isSelectionMode = false;
          }
        } else {
          selectedIndexes.add(index);
        }
      });
      return;
    }

    /// Oddiy holatda item ochiladi (detail page)
    final room = _roomsCache[index];
    debugPrint("Open sale room id: ${room["id"]}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaleDetailPage(
          saleName: room["name"]?.toString() ?? "Savdo",
          saleId: room["id"] as int?,
          kassaStore: widget.kassaStore,
          onGoToKassa: widget.onGoToKassa,
        ),
      ),
    );
  }

  void _onLongPressItem(int index) {
    setState(() {
      isSelectionMode = true;
      selectedIndexes.add(index);
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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                if (!isSelectionMode) {
                  setState(() => isSelectionMode = true);
                  return;
                }

                if (selectedIndexes.isEmpty) {
                  clearSelection(); // selectiondan chiqish
                } else {
                  deleteSelected(); // o‘chirish
                }
              },
              icon: Icon(
                isSelectionMode && selectedIndexes.isNotEmpty
                    ? Icons.delete
                    : Icons.delete_outline,
                color: Colors.white,
              ),
              tooltip: !isSelectionMode
                  ? "Tanlash"
                  : (selectedIndexes.isEmpty ? "Bekor qilish" : "O‘chirish"),
            ),
          ),
        ],
      ),
      body: _roomsCache.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
        itemCount: _roomsCache.length,
        itemBuilder: (context, index) {
          final room = _roomsCache[index];
          final isSelected = selectedIndexes.contains(index);

          return _SaleCard(
            title: _roomTitle(room, index),
            subtitle: _roomCreatedAt(room),
            isSelected: isSelected,
            isSelectionMode: isSelectionMode,
            onTap: () => _onTapItem(index),
            onLongPress: () => _onLongPressItem(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saleName = await CreateSaleDialog.show(context);

          if (saleName == null || saleName.trim().isEmpty) return;
          if (!mounted) return;

          /// Hozircha local listga qo'shish (demo)
          final nextId = _roomsCache.isEmpty
              ? 1
              : (_roomsCache.last["id"] as int) + 1;

          setState(() {
            _roomsCache.add({
              "id": nextId,
              "name": saleName.trim(),
              "created_at": DateTime.now().toString().split('.').first,
            });
          });

          /// Yangi pagega o'tish
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SaleDetailPage(
                saleName: saleName.trim(),
                saleId: nextId,
                kassaStore: widget.kassaStore,
                onGoToKassa: widget.onGoToKassa,
              ),
            ),
          );

          /// Keyinchalik API bo'lsa:
          /// 1) create request yuborasan
          /// 2) response dan id olasan
          /// 3) shu pagega response.id bilan o'tasan
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
          "Hozircha savdolar yo‘q.\nPastdagi + tugmasi orqali yangi savdo qo‘shing.",
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
    final borderColor = isSelected
        ? const Color(0xFFE0A52C)
        : const Color(0xFFE8D39B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
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
                  child: _CardTexts(title: title, subtitle: subtitle),
                ),
                if (isSelectionMode)
                  AnimatedScale(
                    scale: isSelectionMode ? 1 : 0.8,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? const Color(0xFFE0A52C)
                          : Colors.grey.shade400,
                      size: 22,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardTexts extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CardTexts({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}