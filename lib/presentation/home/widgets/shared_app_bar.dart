import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeping_app_flutter/presentation/profile/bloc/profile_bloc.dart';
import 'package:sleeping_app_flutter/presentation/profile/bloc/profile_state.dart';
import 'package:sleeping_app_flutter/presentation/profile/pages/profile_pages.dart';

// Nhớ import file SettingsPage của bạn vào đây nhé

// ==========================================
// APPBAR DÙNG CHUNG CHO TOÀN BỘ APP
// ==========================================
class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SharedAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colors.surface.withOpacity(0.7),
      elevation: 0,
      scrolledUnderElevation: 0,
      // Hiệu ứng kính mờ (Glassmorphism)
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(color: Colors.transparent),
        ),
      ),
      centerTitle: true,
      // Logo ở giữa
      title: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.primaryContainer.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.eco, size: 24, color: colors.onPrimaryContainer),
      ),
      // Avatar bên trái kèm hiệu ứng chuyển trang mượt mà
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProfilesPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOutQuart;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
              ),
            );
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              String? avatarUrl;
              if (state is ProfileLoaded) {
                avatarUrl = state.user.avatarUrl;
                debugPrint(avatarUrl);

                if (avatarUrl != null &&
                    avatarUrl.contains('graph.facebook.com')) {
                  avatarUrl = '$avatarUrl?width=200&height=200';
                }
              }

              return CircleAvatar(
                backgroundColor: colors.outlineVariant,
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Icon(Icons.person, color: colors.onSurfaceVariant)
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
