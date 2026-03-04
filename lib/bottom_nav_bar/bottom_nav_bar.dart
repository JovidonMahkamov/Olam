import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:olam/bottom_nav_bar/gold_nav_item_wg.dart';
import 'package:olam/bottom_nav_bar/olam_drawer.dart';
import 'package:olam/features/home/presentation/pages/sales_page.dart';
import 'package:olam/features/kassa/presentation/pages/kassa_page.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_store.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/search/presentation/pages/search_page.dart';

class BottomNavBarPage extends StatefulWidget {
  const BottomNavBarPage({super.key});

  @override
  State<BottomNavBarPage> createState() => _BottomNavBarPageState();
}

class _BottomNavBarPageState extends State<BottomNavBarPage> {
  void _openSalesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalesPage(
          kassaStore: kassaStore, // ✅ bitta store
          onGoToKassa: () {
            if (!mounted) return;

            // ✅ 1) Sales flow'ni to'liq yopamiz (SaleDetail + SalesPage)
            Navigator.of(context).popUntil((route) => route.isFirst);

            // ✅ 2) Keyin Kassa tabga o'tamiz
            setState(() => currentIndex = 2);
          },
        ),
      ),
    );
  }
  void goToKassaAndCloseFlows() {
    if (!mounted) return;
    setState(() => currentIndex = 2);

    // bu yerda popUntil bilan o'ynamaymiz
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentIndex = 0;
  final KassaStore kassaStore = KassaStore();
  late final List<Widget> _pages =  [
    HomePage( onOpenSales: _openSalesPage,),
    SearchPage(),
    KassaPage(store: kassaStore,),
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const OlamDrawer(),
      extendBody: true, // MUHIM: body bottom nav orqasidan ko‘rinadi
      appBar: AppBar(
        toolbarHeight: 88,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
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
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 2),
              const Text(
                "Olam",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text(
                  "1 200 000 UZS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // IndexedStack => tablar state saqlanadi
      body: IndexedStack(
        index: currentIndex,
        children: _pages.map((page) {
          // Pastda navbar joyini qoldirish (scroll page'larda bosilib ketmasin)
          return Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: page,
          );
        }).toList(),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    GoldBottomNavItem(
                      isSelected: currentIndex == 0,
                      icon: "assets/bottom_nav_bar/Home.svg",
                      label: 'Asosiy',
                      onTap: () {
                        if (currentIndex == 0) return;
                        setState(() => currentIndex = 0);
                      },
                    ),
                    GoldBottomNavItem(
                      isSelected: currentIndex == 1,
                      icon: "assets/bottom_nav_bar/Search.svg",
                      label: 'Qidiruv',
                      onTap: () {
                        if (currentIndex == 1) return;
                        setState(() => currentIndex = 1);
                      },
                    ),
                    GoldBottomNavItem(
                      isSelected: currentIndex == 2,
                      icon: "assets/bottom_nav_bar/Kassa.svg",
                      label: 'Kassa',
                      onTap: () {
                        if (currentIndex == 2) return;
                        setState(() => currentIndex = 2);
                      },
                    ),
                    GoldBottomNavItem(
                      isSelected: currentIndex == 3,
                      icon: "assets/bottom_nav_bar/History.svg",
                      label: 'Tarix',
                      onTap: () {
                        if (currentIndex == 3) return;
                        setState(() => currentIndex = 3);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}