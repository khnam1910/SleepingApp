import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../global_widgets/shared_sleep_widgets.dart';
import '../../home/widgets/shared_app_bar.dart';
import '../bloc/alarms_bloc.dart';
import '../bloc/alarms_event.dart';
import '../bloc/alarms_state.dart';
import '../extensions/alarm_schedule_ui_extension.dart';
import 'set_alarm_page.dart';

class AlarmsPage extends StatefulWidget {
  const AlarmsPage({super.key});

  @override
  State<AlarmsPage> createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Tự động tải lại danh sách khi quay lại app từ đa nhiệm
    if (state == AppLifecycleState.resumed) {
      context.read<AlarmBloc>().add(LoadAlarmsRequested());
    }
  }

  bool _isSameDay(DateTime? d1, DateTime d2) {
    if (d1 == null) return false;
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  PreferredSizeWidget _buildAppBar(AlarmState state, ColorScheme colors) {
    if (state.isSelectionMode) {
      return AppBar(
        backgroundColor: colors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.read<AlarmBloc>().add(ClearSelectionRequested()),
        ),
        title: Text('${state.selectedAlarmIds.length} đã chọn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      );
    }
    return const SharedAppBar();
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa lịch trình?'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa các lịch trình đã chọn không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AlarmBloc>().add(DeleteSelectedAlarmsRequested());
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: colors.surface,
          appBar: _buildAppBar(state, colors),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lịch trình của bạn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    if (!state.isSelectionMode)
                      Text(
                        'Xem tất cả',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    if (state.status == AlarmStatus.loading &&
                        state.alarms.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (state.alarms.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('Chưa có lịch trình nào'),
                        ),
                      )
                    else
                      ...state.alarms.map((alarm) {
                        final isSelected = state.selectedAlarmIds.contains(
                          alarm.id,
                        );

                        // 💡 Logic: Kiểm tra xem hôm nay có bị bỏ qua không
                        final bool isSkippedToday =
                            _isSameDay(alarm.skippedAt, DateTime.now());

                        return Dismissible(
                          key: Key(alarm.id),
                          direction: state.isSelectionMode
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            context.read<AlarmBloc>().add(
                              DeleteSingleAlarmRequested(alarm.id),
                            );
                          },
                          child: SavedAlarmCard(
                            title: 'Lịch trình',
                            wakeTime: alarm.wakeUpTime,
                            bedTime: alarm.bedTime,
                            duration: alarm.sleepDurationText,
                            days: alarm.repeatDaysText,
                            isActive: alarm.isEnabled,
                            isSkipped: isSkippedToday,
                            isSelectionMode: state.isSelectionMode,
                            isSelected: isSelected,
                            onToggle: (val) {
                              context.read<AlarmBloc>().add(
                                ToggleAlarmRequested(
                                  alarm: alarm,
                                  isEnabled: val,
                                ),
                              );
                            },
                            onTap: () {
                              if (state.isSelectionMode) {
                                context.read<AlarmBloc>().add(
                                  ToggleAlarmSelection(alarm.id),
                                );
                              } else {
                                final alarmBloc = context.read<AlarmBloc>();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: alarmBloc,
                                      child: SetAlarmPage(existingAlarm: alarm),
                                    ),
                                  ),
                                );
                              }
                            },
                            onLongPress: () {
                              context.read<AlarmBloc>().add(
                                ToggleSelectionModeRequested(
                                  initialAlarmId: alarm.id,
                                ),
                              );
                            },
                            colors: colors,
                          ),
                        );
                      }),
                    if (!state.isSelectionMode)
                      GestureDetector(
                        onTap: () {
                          final alarmBloc = context.read<AlarmBloc>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: alarmBloc,
                                child: const SetAlarmPage(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 20,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Thêm lịch trình mới',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }
}
