import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:olam/core/route/route_names.dart';

import '../features/home/presentation/pages/qr_scanner_page.dart';

class OlamDrawer extends StatefulWidget {
  const OlamDrawer({super.key});

  @override
  State<OlamDrawer> createState() => _OlamDrawerState();
}

class _OlamDrawerState extends State<OlamDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.74, // rasmga yaqin
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header (logo qismi)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E5E5)),
                ),
              ),
              child: Column(
                children: [
                  SvgPicture.asset("assets/home/logo1.svg")
                ],
              ),
            ),

            // Menyu itemlar
            _DrawerItem(
              icon: Icons.qr_code_scanner_rounded,
              title: "Scanner",
              onTap: () async {
                Navigator.pop(context);
                final code = await QrScannerPage.open(context);

                if (code == null || code.isEmpty) return;
                if (!mounted) return;

                debugPrint("QR code: $code");

                // Hozircha API yo'q -> vaqtincha snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Skanerlandi: $code")),
                );

                // Keyinchalik:
                // context.read<SaleDetailBloc>().add(ScanQrSubmitted(code));
              },
            ),
            _DrawerItem(
              icon: Icons.groups_2_outlined,
              title: "Mijozlar",
              onTap: () {
                Navigator.pushNamed(context, RouteNames.customerPage);
              },
            ),
            _DrawerItem(
              icon: Icons.person_outline_rounded,
              title: "Profil",
              onTap: () {
                Navigator.pop(context);
                // TODO: profil page
              },
            ),
            _DrawerItem(
              icon: Icons.logout_rounded,
              title: "Dasturdan chiqish",
              onTap: () {
                Navigator.pop(context);
                // TODO: logout logic
              },
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.black12,
        highlightColor: Colors.black.withOpacity(0.03),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E5E5)),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: Colors.black54),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}