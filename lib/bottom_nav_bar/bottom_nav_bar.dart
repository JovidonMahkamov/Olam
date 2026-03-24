import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/bottom_nav_bar/gold_nav_item_wg.dart';
import 'package:olam/bottom_nav_bar/olam_drawer.dart';
import 'package:olam/core/navigation/app_navigation.dart';
import 'package:olam/core/route/route_names.dart';
import 'package:olam/features/home/presentation/pages/sales_page.dart';
import 'package:olam/features/home/presentation/pages/tovar_qaytarish_page.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_bloc.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_event.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_state.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentIndex = 0;
  final KassaStore kassaStore = KassaStore();

  @override
  void initState() {
    super.initState();
    context.read<BugungiSotuvBloc>().add(const GetBugungiSotuvlarE());
  }

  // ✅ Kassaga o'tish — global key orqali xavfsiz
  void _goToKassa() {
    // Barcha ustki sahifalarni yopamiz — bottomNavBar o'zi root sahifa
    // popUntil ishlatmaymiz, chunki u error routega tushishi mumkin
    final nav = Navigator.of(context);
    // Sotuv sahifalarini yopamiz
    nav.popUntil((route) {
      return route.isFirst || route.settings.name == RouteNames.bottomNavBar;
    });
    // Kassa tabga o'tamiz
    if (mounted) {
      setState(() => currentIndex = 2);
      context.read<BugungiSotuvBloc>().add(const GetBugungiSotuvlarE());
      context.read<KassaBloc>().add(const GetKassalarE());
    }
  }

  void _openQaytarishPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TovarQaytarishPage(
          onGoToKassa: () {
            // Sodda Navigator.pop — sotuv bilan bir xil yechim
            Navigator.of(context).pop();
            if (mounted) {
              setState(() => currentIndex = 2);
              context.read<BugungiSotuvBloc>().add(const GetBugungiSotuvlarE());
              context.read<KassaBloc>().add(const GetKassalarE());
            }
          },
        ),
      ),
    );
  }

  void _openSalesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: RouteNames.bottomNavBar),
        builder: (_) => SalesPage(
          kassaStore: kassaStore,
          onGoToKassa: _goToKassa,
        ),
      ),
    );
  }

  late final List<Widget> _pages = [
    HomePage(onOpenSales: _openSalesPage, onOpenQaytarish: _openQaytarishPage),
    const SearchPage(),
    KassaPage(store: kassaStore),
    const HistoryPage(),
  ];

  String _appBarSumma(BugungiSotuvState state) {
    if (state is BugungiSotuvSuccess) {
      return "\$${state.stat.jamiUsd.toStringAsFixed(2)}";
    }
    return "\$0.00";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const OlamDrawer(),
        extendBody: true,
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
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
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
                BlocBuilder<BugungiSotuvBloc, BugungiSotuvState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _appBarSumma(state),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            "bugungi savdo",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: IndexedStack(
          index: currentIndex,
          children: _pages,
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
                        onTap: () => setState(() => currentIndex = 0),
                      ),
                      GoldBottomNavItem(
                        isSelected: currentIndex == 1,
                        icon: "assets/bottom_nav_bar/Search.svg",
                        label: 'Qidiruv',
                        onTap: () => setState(() => currentIndex = 1),
                      ),
                      GoldBottomNavItem(
                        isSelected: currentIndex == 2,
                        icon: "assets/bottom_nav_bar/Kassa.svg",
                        label: 'Kassa',
                        onTap: () {
                          setState(() => currentIndex = 2);
                          context.read<BugungiSotuvBloc>().add(const GetBugungiSotuvlarE());
                          context.read<KassaBloc>().add(const GetKassalarE());
                        },
                      ),
                      GoldBottomNavItem(
                        isSelected: currentIndex == 3,
                        icon: "assets/bottom_nav_bar/History.svg",
                        label: 'Tarix',
                        onTap: () => setState(() => currentIndex = 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}