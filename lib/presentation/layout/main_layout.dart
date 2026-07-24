import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/alarm_repository.dart';
import '../../domain/usecases/alarm/get_alarms_usecase.dart';
import '../../domain/usecases/alarm/save_alarm_usecase.dart';
import '../alarms/bloc/alarms_bloc.dart';
import '../alarms/bloc/alarms_event.dart';
import '../alarms/pages/alarms_page.dart';
import '../home/pages/home_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Di chuyển _pages vào build để có thể truy cập context và inject UseCases
    final List<Widget> pages = [
      const HomePage(),
      BlocProvider(
        create: (context) {
          final repo = context.read<IAlarmRepository>();
          return AlarmBloc(
            saveAlarmUseCase: SaveAlarmUseCase(repo),
            getAlarmsUseCase: GetAlarmsUseCase(repo),
          )..add(LoadAlarmsRequested());
        },
        child: const AlarmsPage(),
      ),
      const Center(child: Text('Sounds Page (Coming Soon)')),
      const Center(child: Text('Stats Page (Coming Soon)')),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.surface,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildCustomBottomNav(colors),
    );
  }

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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.transparent
                      : Colors.white.withOpacity(
                          0.2,
                        ),
                  width: 1.0,
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
