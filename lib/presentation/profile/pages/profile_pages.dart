import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme_cubit.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/pages/login_page.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({super.key});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  bool _isReminderEnabled = true;

  // Biến lưu trạng thái Theme hiện tại
  String _currentTheme = 'Theo hệ thống';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final sleepIconColor = const Color(0xFFA07C70);
    final sleepBgColor = sleepIconColor.withOpacity(0.2);
    final systemIconColor = const Color(0xFF5B718F);
    final systemBgColor = systemIconColor.withOpacity(0.2);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            'Cài đặt',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colors.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // 💡 ĐÃ BỎ SINGLE CHILD SCROLL VIEW, CHỈ SỬ DỤNG PADDING & COLUMN
        body: Padding(
          // Thêm SafeArea bọc Padding để đảm bảo không bị lẹm vào phần vuốt (Home Indicator) của iOS/Android mới
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- THẺ PROFILE ---
              // --- THẺ PROFILE ---
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    print("Chuyển hướng sang trang Sửa thông tin cá nhân");
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    // 💡 BẮT ĐẦU SỬA TỪ ĐÂY: Bọc Row bằng BlocBuilder
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        String? avatarUrl;
                        String displayName = 'Đang tải...';
                        String email = 'Đang tải...';

                        // Rút trích dữ liệu khi tải xong
                        if (state is ProfileLoaded) {
                          avatarUrl = state.user.avatarUrl;
                          displayName =
                              state.user.displayName ?? 'Người dùng mới';
                          email = state.user.email ?? 'Chưa có email';

                          // Áp dụng mẹo làm nét ảnh nếu là link Facebook
                          if (avatarUrl != null &&
                              avatarUrl.contains('graph.facebook.com')) {
                            avatarUrl = '$avatarUrl?width=200&height=200';
                          }
                        }

                        return Row(
                          children: [
                            Stack(
                              children: [
                                // 💡 AVATAR ĐỘNG TỪ FIREBASE
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: colors.outlineVariant,
                                  backgroundImage:
                                      avatarUrl != null && avatarUrl.isNotEmpty
                                      ? NetworkImage(avatarUrl)
                                      : null,
                                  child: avatarUrl == null || avatarUrl.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: colors.onSurfaceVariant,
                                          size: 32,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF676E46),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.surface,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 💡 TÊN ĐỘNG
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // 💡 EMAIL ĐỘNG
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colors.outline,
                              size: 28,
                            ),
                          ],
                        );
                      },
                    ),
                    // 💡 KẾT THÚC SỬA BLOCBUILDER
                  ),
                ),
              ),

              // 💡 SỬ DỤNG SPACER THAY VÌ SIZEDBOX ĐỂ CO GIÃN LINH HOẠT
              const Spacer(flex: 2),

              // --- KHỐI ƯU TIÊN GIẤC NGỦ ---
              _buildSectionTitle('ƯU TIÊN GIẤC NGỦ', colors),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      colors: colors,
                      icon: Icons.nightlight_round_sharp,
                      iconColor: sleepIconColor,
                      iconBgColor: sleepBgColor,
                      title: 'Mục tiêu giấc ngủ',
                      trailing: _buildTrailingText('8 giờ 30 phút', colors),
                      onTap: () {},
                    ),
                    _buildDivider(colors),
                    _buildSettingsTile(
                      colors: colors,
                      icon: Icons.notifications_active_outlined,
                      iconColor: sleepIconColor,
                      iconBgColor: sleepBgColor,
                      title: 'Nhắc nhở đi ngủ',
                      trailing: Switch(
                        value: _isReminderEnabled,
                        activeColor: const Color(0xFF676E46),
                        onChanged: (val) =>
                            setState(() => _isReminderEnabled = val),
                      ),
                      onTap: () => setState(
                        () => _isReminderEnabled = !_isReminderEnabled,
                      ),
                    ),
                    _buildDivider(colors),
                    _buildSettingsTile(
                      colors: colors,
                      icon: Icons.spa_outlined,
                      iconColor: sleepIconColor,
                      iconBgColor: sleepBgColor,
                      title: 'Âm thanh thư giãn',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: colors.outline,
                        size: 20,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // 💡 SPACER SẼ TỰ ĐỘNG CĂN CHỈNH KHOẢNG CÁCH
              const Spacer(flex: 2),

              // --- KHỐI HỆ THỐNG ---
              _buildSectionTitle('HỆ THỐNG', colors),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      colors: colors,
                      icon: Icons.brightness_medium_outlined,
                      iconColor: systemIconColor,
                      iconBgColor: systemBgColor,
                      title: 'Giao diện',
                      trailing: _buildTrailingText(_currentTheme, colors),
                      onTap: () => _showThemePicker(context, colors),
                    ),
                    _buildDivider(colors),
                    _buildSettingsTile(
                      colors: colors,
                      icon: Icons.info_outline_rounded,
                      iconColor: systemIconColor,
                      iconBgColor: systemBgColor,
                      title: 'Về ứng dụng',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: colors.outline,
                        size: 20,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // 💡 SPACER(FLEX: 3) SẼ CHIẾM PHẦN LỚN KHÔNG GIAN CÒN DƯ, ĐẨY NÚT ĐĂNG XUẤT XUỐNG ĐÁY MÀN HÌNH
              const Spacer(flex: 3),

              // --- NÚT ĐĂNG XUẤT ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                  icon: Icon(
                    Icons.logout_rounded,
                    size: 22,
                    color: colors.error,
                  ),
                  label: Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.error,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: colors.errorContainer.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, ColorScheme colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'CHỌN GIAO DIỆN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.outline,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              _buildThemeOptionItem('Sáng', Icons.light_mode_outlined, colors),
              _buildThemeOptionItem('Tối', Icons.dark_mode_outlined, colors),
              _buildThemeOptionItem(
                'Theo hệ thống',
                Icons.brightness_auto_outlined,
                colors,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionItem(
    String title,
    IconData icon,
    ColorScheme colors,
  ) {
    final isSelected = _currentTheme == title;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(
        icon,
        color: isSelected ? colors.primary : colors.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? colors.primary : colors.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: colors.primary, size: 22)
          : null,
      onTap: () {
        setState(() {
          _currentTheme = title;
        });

        ThemeMode selectedMode;
        if (title == 'Sáng') {
          selectedMode = ThemeMode.light;
        } else if (title == 'Tối') {
          selectedMode = ThemeMode.dark;
        } else {
          selectedMode = ThemeMode.system;
        }

        context.read<ThemeCubit>().changeTheme(selectedMode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: colors.outline,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required ColorScheme colors,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingText(String text, ColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded, color: colors.outline, size: 20),
      ],
    );
  }

  Widget _buildDivider(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colors.outlineVariant.withOpacity(0.2),
      ),
    );
  }
}
