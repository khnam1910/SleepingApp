import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/alarm_schedules_model.dart';
import '../../../domain/entities/alarm_schedules_entity.dart';
import '../../../domain/utils/sleep_math_utils.dart';
import '../bloc/alarms_bloc.dart';
import '../bloc/alarms_event.dart';
import '../bloc/alarms_state.dart';
import '../extensions/duration_extension.dart';
import '../extensions/time_of_day_extension.dart';
import '../widgets/sleep_schedule_tracker.dart';

class SetAlarmPage extends StatefulWidget {
  final AlarmSchedule? existingAlarm;

  const SetAlarmPage({super.key, this.existingAlarm});
  @override
  State<SetAlarmPage> createState() => _SetAlarmPageState();
}

class _SetAlarmPageState extends State<SetAlarmPage> {
  late TimeOfDay _bedTime;
  late TimeOfDay _wakeTime;
  late List<bool> _selectedDays;
  bool _isVibrationActive = true;
  final List<String> _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  bool _isDialDragging = false;
  @override
  void initState() {
    super.initState();
    if (widget.existingAlarm != null) {
      final alarm = widget.existingAlarm!;

      final wakeParts = alarm.wakeUpTime.split(':');
      _wakeTime = TimeOfDay(
        hour: int.parse(wakeParts[0]),
        minute: int.parse(wakeParts[1]),
      );

      final bedParts = alarm.bedTime.split(':');
      _bedTime = TimeOfDay(
        hour: int.parse(bedParts[0]),
        minute: int.parse(bedParts[1]),
      );

      _selectedDays = List.generate(7, (index) {
        int weekday = index + 2;
        return alarm.repeatDays.contains(weekday);
      });
    } else {
      _bedTime = const TimeOfDay(hour: 23, minute: 0);
      _wakeTime = const TimeOfDay(hour: 6, minute: 30);
      _selectedDays = [true, true, true, true, true, false, false];
    }
  }

  Widget _buildTimePanel(
    String title,
    TimeOfDay time,
    IconData icon,
    ColorScheme colors, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isHighlight ? colors.primary : colors.outline,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          time.formatHHmm(),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isHighlight ? colors.primary : colors.onSurface,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Tính toán thời gian ngủ và chu kỳ
    final sleepMins = SleepMathUtils.getDifferenceMinutes(
      _bedTime.hour,
      _bedTime.minute,
      _wakeTime.hour,
      _wakeTime.minute,
    );
    final cycles = (sleepMins / 90).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch trình ngủ',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: _isDialDragging
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 32, bottom: 24),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SleepScheduleTracker(
                            bedTime: _bedTime,
                            wakeTime: _wakeTime,
                            colors: colors,
                            onTimeChanged: (newBedTime, newWakeTime) {
                              setState(() {
                                _bedTime = newBedTime;
                                _wakeTime = newWakeTime;
                              });
                            },
                            onDragStart: () =>
                                setState(() => _isDialDragging = true),
                            onDragEnd: () =>
                                setState(() => _isDialDragging = false),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'THỜI GIAN NGỦ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colors.outline,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sleepMins.formatAsDuration(),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer.withOpacity(
                                    0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$cycles Chu kỳ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildTimePanel(
                                'Đi ngủ',
                                _bedTime,
                                Icons.bedtime_rounded,
                                colors,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: colors.outlineVariant.withOpacity(0.4),
                            ),
                            Expanded(
                              child: _buildTimePanel(
                                'Thức dậy',
                                _wakeTime,
                                Icons.alarm,
                                colors,
                                isHighlight: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lặp lại',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          bool isSelected = _selectedDays[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDays[index] = !_selectedDays[index];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.outlineVariant.withOpacity(0.5),
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _dayLabels[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? colors.onPrimary
                                      : colors.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, thickness: 1),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.music_note_rounded,
                                  color: colors.onSurfaceVariant,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Âm thanh',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Tiếng chim hót',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right,
                                  color: colors.outline,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, thickness: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.vibration_rounded,
                                color: colors.onSurfaceVariant,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Độ rung',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isVibrationActive,
                            onChanged: (val) =>
                                setState(() => _isVibrationActive = val),
                            activeColor: colors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 32,
                top: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colors.surface,
                    colors.surface.withOpacity(0.9),
                    colors.surface.withOpacity(0.0),
                  ],
                ),
              ),
              child: BlocListener<AlarmBloc, AlarmState>(
                listener: (context, state) {
                  if (state is AlarmSaveSuccess) {
                    context.read<AlarmBloc>().add(LoadAlarmsRequested());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã lưu lịch trình ngủ!')),
                    );
                    Navigator.pop(context);
                  } else if (state is AlarmSaveFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${state.error}')),
                    );
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      List<int> repeatDays = [];
                      for (int i = 0; i < _selectedDays.length; i++) {
                        if (_selectedDays[i]) repeatDays.add(i + 2);
                      }

                      final alarmModel = AlarmScheduleModel(
                        id:
                            widget.existingAlarm?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: widget.existingAlarm?.userId ?? '',
                        wakeUpTime: _wakeTime.formatHHmm(),
                        bedTime: _bedTime.formatHHmm(),
                        repeatDays: repeatDays,
                        isSmartWake: widget.existingAlarm?.isSmartWake ?? false,
                        smartWakeWindow:
                            widget.existingAlarm?.smartWakeWindow ?? 30,
                        isEnabled: widget.existingAlarm?.isEnabled ?? true,
                      );

                      context.read<AlarmBloc>().add(
                        SaveAlarmRequested(alarmModel),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: BlocBuilder<AlarmBloc, AlarmState>(
                      builder: (context, state) {
                        if (state is AlarmSaving) {
                          return CircularProgressIndicator(
                            color: colors.onPrimary,
                          );
                        }
                        return const Text(
                          'Lưu báo thức',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
