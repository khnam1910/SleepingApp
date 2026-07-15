import 'dart:ui';

import 'package:flutter/material.dart';

import '../alarms/pages/alarms_page.dart';
// Nhớ import các màn hình của bạn vào đây nhé
import '../home/pages/home_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Danh sách 4 màn hình chính của App
  final List<Widget> _pages = [
    const HomePage(),
    const AlarmsPage(),
    const Center(
      child: Text('Sounds Page (Coming Soon)'),
    ), // Chỗ trống cho màn hình Sounds
    const Center(
      child: Text('Stats Page (Coming Soon)'),
    ), // Chỗ trống cho màn hình Stats
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true, // Ép body chìm xuống dưới thanh Navigation trong suốt
      backgroundColor: colors.surface,
      // IndexedStack giúp giữ nguyên trạng thái (không load lại) khi chuyển qua lại giữa các tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildCustomBottomNav(colors),
    );
  }

  // BÊ NGUYÊN HÀM VẼ BOTTOM NAV TỪ HOME_PAGE CŨ SANG ĐÂY
  Widget _buildCustomBottomNav(ColorScheme colors) {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {
        'icon': Icons.alarm_outlined,
        'activeIcon': Icons.alarm,
        'label': 'Alarms',
      },
      {
        'icon': Icons.nature_people_outlined,
        'activeIcon': Icons.nature_people,
        'label': 'Sounds',
      },
      {
        'icon': Icons.show_chart_outlined,
        'activeIcon': Icons.show_chart,
        'label': 'Stats',
      },
    ];

    return SafeArea(
      child: Container(
        height: 72,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: colors.onSurface.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.65),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (index) {
                  final isActive = _selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // CHỈ CẦN SET STATE Ở ĐÂY LÀ CHUYỂN TAB CỰC MƯỢT
                        setState(() => _selectedIndex = index);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: isActive ? 48 : 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? colors.primaryContainer.withOpacity(0.8)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Icon(
                                isActive
                                    ? navItems[index]['activeIcon']
                                    : navItems[index]['icon'],
                                color: isActive
                                    ? colors.onPrimaryContainer
                                    : colors.outline,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: isActive
                                  ? colors.onSurface
                                  : colors.outline,
                              fontSize: 10,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            child: Text(
                              navItems[index]['label'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
