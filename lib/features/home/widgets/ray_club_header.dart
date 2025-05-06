// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';

class RayClubHeader extends StatelessWidget {
  final String username;
  final VoidCallback onMenuPressed;

  const RayClubHeader({
    Key? key,
    required this.username,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent to allow our header to extend behind it
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Calculate status bar height
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(24, statusBarHeight + 10, 24, 35),
        height: statusBarHeight + 180, // Increased height further
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/logos/app/header.png'),
            fit: BoxFit.cover,
            alignment: Alignment(0, -0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botão de menu simplicado - versão direta
            GestureDetector(
              onTap: () {
                print('DEBUG: Menu button tapped directly in GestureDetector');
                onMenuPressed();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(4), // Margem adicional para área de toque
                width: 60, // Aumentado para melhor área de toque
                height: 60, // Aumentado para melhor área de toque
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 28, // Ícone um pouco maior
                ),
              ),
            ),
            
            // Notification Button
            GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(8),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 