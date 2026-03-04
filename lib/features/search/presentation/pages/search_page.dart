import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchCtrl = TextEditingController();

  // Hozircha demo data (keyin API / bloc'dan berasan)
  final List<_SearchProductUiModel> _all = const [
    _SearchProductUiModel(
      name: "011M turkiya",
      imageAsset: "assets/home/parda.jpg",
      rightMain: "17 Dona",
      leftExtra1: "",
      leftExtra2: "",
    ),
    _SearchProductUiModel(
      name: "0422 sinyor",
      imageAsset: "assets/home/parda.jpg",
      rightMain: "397 Dona",
      leftExtra1: "197 Pachka",
      leftExtra2: "",
    ),
    _SearchProductUiModel(
      name: "0422 sinyor",
      imageAsset: "assets/home/parda.jpg",
      rightMain: "397 Dona",
      leftExtra1: "197 Pachka",
      leftExtra2: "",
    ),
    _SearchProductUiModel(
      name: "011M turkiya",
      imageAsset: "assets/home/parda.jpg",
      rightMain: "50 Metr",
      leftExtra1: "2 Pachka",
      leftExtra2: "",
    ),
    _SearchProductUiModel(
      name: "011M turkiya",
      imageAsset: null, // rasm yo'q holat (skrinshotdagidek)
      rightMain: "17 Dona",
      leftExtra1: "",
      leftExtra2: "",
    ),
    _SearchProductUiModel(
      name: "011M turkiya",
      imageAsset: "assets/home/parda.jpg",
      rightMain: "17 Dona",
      leftExtra1: "",
      leftExtra2: "",
    ),
    _SearchProductUiModel(
      name: "011M turkiya",
      imageAsset: "assets/home/parda.jpg",
      rightMain: "50 Metr",
      leftExtra1: "2 Pachka",
      leftExtra2: "",
    ),
  ];

  String _query = "";

  List<_SearchProductUiModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          // TOP GRADIENT HEADER + SEARCH
          Container(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 14,
            ),
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
            child: _SearchBar(
              controller: _searchCtrl,
              hint: "Qidiruv",
              onChanged: (v) => setState(() => _query = v),
              onClear: () {
                _searchCtrl.clear();
                setState(() => _query = "");
              },
            ),
          ),

          // LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final item = _filtered[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProductSearchCard(
                    item: item,
                    onTap: () {
                      // TODO: product detail / select
                      // Navigator.pushNamed(...);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- UI WIDGETS ----------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, size: 20, color: Color(0xFF9E9E9E)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) {
              final hasText = v.text.trim().isNotEmpty;
              return AnimatedOpacity(
                opacity: hasText ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: IconButton(
                  onPressed: hasText ? onClear : null,
                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF9E9E9E)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductSearchCard extends StatelessWidget {
  final _SearchProductUiModel item;
  final VoidCallback onTap;

  const _ProductSearchCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE7C66A), width: 0.9),
          ),
          child: Row(
            children: [
              _Thumb(imageAsset: item.imageAsset),
              const SizedBox(width: 10),

              // LEFT: name + extras
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3F3F3F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (item.leftExtra1.trim().isNotEmpty)
                      Text(
                        item.leftExtra1,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF8A8A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (item.leftExtra2.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.leftExtra2,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF8A8A8A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // RIGHT: main stock
              Text(
                item.rightMain,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A5A5A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageAsset;
  const _Thumb({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFE0E0E0),
        image: imageAsset == null
            ? null
            : DecorationImage(
          image: AssetImage(imageAsset!),
          fit: BoxFit.cover,
        ),
      ),
      child: imageAsset == null
          ? const Icon(Icons.image, color: Colors.white70, size: 20)
          : null,
    );
  }
}

/// ---------- UI MODEL (API/modelga bog‘lanmay turib UI qilish uchun) ----------
@immutable
class _SearchProductUiModel {
  final String name;
  final String? imageAsset;
  final String rightMain; // masalan: "17 Dona" yoki "50 Metr"
  final String leftExtra1; // masalan: "197 Pachka"
  final String leftExtra2; // masalan: "2 Pachka"

  const _SearchProductUiModel({
    required this.name,
    required this.imageAsset,
    required this.rightMain,
    required this.leftExtra1,
    required this.leftExtra2,
  });
}