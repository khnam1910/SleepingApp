import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/sleep_cycle.dart';
import '../../global_widgets/shared_sleep_widgets.dart';
import '../../home/widgets/shared_app_bar.dart';
import '../bloc/alarms_bloc.dart';
import '../bloc/alarms_event.dart';
import '../bloc/alarms_state.dart';
import '../extensions/alarm_schedule_ui_extension.dart';
import '../extensions/sleep_cycle_ui_extension.dart';
import '../extensions/time_of_day_extension.dart';
import '../widgets/samsung_time_picker.dart';
import 'set_alarm_page.dart';

class AlarmsPage extends StatefulWidget {
  const AlarmsPage({super.key});

  @override
  State<AlarmsPage> createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  int _selectedToggleIndex = 0;
  TimeOfDay _targetTime = const TimeOfDay(hour: 7, minute: 0);

  Future<void> _selectTime(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;

    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return SamsungTimePickerDialog(
          initialTime: _targetTime,
          colors: colors,
        );
      },
    );

    if (picked != null && picked != _targetTime) {
      setState(() {
        _targetTime = picked;
      });
      if (mounted) {
        context.read<AlarmBloc>().add(
          CalculateCyclesRequested(
            time: picked,
            toggleIndex: _selectedToggleIndex,
          ),
        );
      }
    }
  }

  void _show90MinRuleDialog(BuildContext context, ColorScheme colors) {
    showDialog(
      context: context,
      barrierColor: colors.scrim.withOpacity(0.4),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Dialog(
            backgroundColor: colors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: colors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Quy tắc 90 Phút',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cơ thể người ngủ theo các chu kỳ dài khoảng 90 phút. Việc thức giấc giữa chừng thường khiến bạn lờ đờ, trong khi thức dậy vào cuối chu kỳ sẽ giúp cơ thể tỉnh táo và sảng khoái.',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: colors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Mục tiêu lý tưởng là 5–6 chu kỳ để phục hồi tốt nhất.',
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Đã hiểu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: colors.surface,
      appBar: const SharedAppBar(),
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
                BlocBuilder<AlarmBloc, AlarmState>(
                  builder: (context, state) {
                    if (state is AlarmsLoaded) {
                      final alarms = state.alarms;

                      if (alarms.isEmpty) {
                        return const Center(
                          child: Text("Chưa có lịch trình nào"),
                        );
                      }

                      return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: alarms.map((alarm) {
                          return SavedAlarmCard(
                            title: 'Lịch trình',
                            wakeTime: alarm.wakeUpTime,
                            bedTime: alarm.bedTime,
                            duration: alarm.sleepDurationText,
                            days: alarm.repeatDaysText,
                            isActive: alarm.isEnabled,
                            onToggle: (val) {
                              context.read<AlarmBloc>().add(
                                ToggleAlarmRequested(
                                  alarm: alarm,
                                  isEnabled: val,
                                ),
                              );
                            },
                            colors: colors,
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                GestureDetector(
                  onTap: () {
                    // Lấy bloc từ context hiện tại (trước khi push sang Route mới)
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
                        color: colors.outlineVariant.withOpacity(0.5),
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
            const SizedBox(height: 32),
            CustomSegmentedToggle(
              leftText: 'Tôi muốn thức\ndậy lúc...',
              rightText: 'Tôi sẽ đi\nngủ lúc...',
              selectedIndex: _selectedToggleIndex,
              onChanged: (index) {
                setState(() => _selectedToggleIndex = index);
                final state = context.read<AlarmBloc>().state;
                if (state is AlarmCalculated) {
                  context.read<AlarmBloc>().add(
                    CalculateCyclesRequested(
                      time: state.targetTime,
                      toggleIndex: index,
                    ),
                  );
                }
              },
              colors: colors,
            ),
            const SizedBox(height: 16),
            BlocBuilder<AlarmBloc, AlarmState>(
              builder: (context, state) {
                bool hasCalculated = false;
                List<SleepCycle> cycles = [];

                if (state is AlarmCalculated) {
                  hasCalculated = true;
                  cycles = state.cycles;
                }

                String cardTimeLabel = _selectedToggleIndex == 0
                    ? 'Giờ đi ngủ'
                    : 'Giờ thức dậy';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colors.outlineVariant.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: colors.onSurfaceVariant,
                                size: 22,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _targetTime.formatHHmm(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.edit,
                                color: colors.outline,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (hasCalculated) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Tính toán chu kỳ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  _show90MinRuleDialog(context, colors),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer.withOpacity(
                                    0.4,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: colors.primary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'GỢI Ý',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...cycles.map((cycle) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: SleepCycleCard(
                            timeLabel: cardTimeLabel,
                            wakeTime: cycle.time.formatHHmm(),
                            duration: cycle.durationStr,
                            cycles: cycle.cycles,
                            batteryBars: cycle.batteryBars,
                            isHighlighted: cycle.isOptimal,
                            colors: colors,
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print(
                              "Sẽ lưu mốc giờ: ${_targetTime.formatHHmm()}",
                            );
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 20,
                          ),
                          label: const Text(
                            'Áp dụng lịch ngủ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Các chu kỳ này đã bao gồm trung bình\n15 phút để chìm vào giấc ngủ.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.outline,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
