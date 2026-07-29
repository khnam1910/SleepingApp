import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/top_notification_helper.dart';
import '../../../data/models/alarm_schedules_model.dart';
import '../../../domain/entities/alarm_schedules_entity.dart';
import '../../../domain/entities/sleep_conflict.dart';
import '../../../domain/entities/sleep_cycle.dart';
import '../../../domain/entities/wake_up_quality.dart';
import '../../../domain/utils/sleep_math_utils.dart';
import '../bloc/alarms_bloc.dart';
import '../bloc/alarms_event.dart';
import '../bloc/alarms_state.dart';
import '../extensions/duration_extension.dart';
import '../extensions/time_of_day_extension.dart';
import '../widgets/samsung_time_picker.dart';
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

  // New State for suggested calculations
  TimeOfDay? _baseTime;
  bool _showSuggestions = false;
  int _calculationMode = 0; // 0: Fix Wake, 1: Fix Bed

  void _saveWithConflictCheck() {
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
      smartWakeWindow: widget.existingAlarm?.smartWakeWindow ?? 30,
      isEnabled: widget.existingAlarm?.isEnabled ?? true,
      createdAt: widget.existingAlarm?.createdAt ?? DateTime.now(),
    );

    final alarmBloc = context.read<AlarmBloc>();
    final conflict = SleepMathUtils.analyzeConflict(
      alarmModel,
      alarmBloc.state.alarms,
    );

    if (conflict != null) {
      _showConflictDialog(conflict, () {
        alarmBloc.add(SaveAlarmRequested(alarmModel));
      });
    } else {
      alarmBloc.add(SaveAlarmRequested(alarmModel));
    }
  }

  void _showConflictDialog(SleepConflict conflict, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phát hiện xung đột'),
        content: Text('${conflict.message}\n\nBạn vẫn muốn lưu chứ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Vẫn lưu'),
          ),
        ],
      ),
    );
  }

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
      _baseTime = _wakeTime;
    } else {
      _bedTime = const TimeOfDay(hour: 23, minute: 0);
      _wakeTime = const TimeOfDay(hour: 6, minute: 30);
      _selectedDays = [true, true, true, true, true, false, false];
      _baseTime = null;
    }
  }

  Future<void> _selectBaseTime() async {
    final colors = Theme.of(context).colorScheme;
    final initialTime = _baseTime ?? const TimeOfDay(hour: 7, minute: 0);

    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return SamsungTimePickerDialog(
          initialTime: initialTime,
          colors: colors,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _baseTime = picked;
        _showSuggestions = false; // Reset suggestions when base time changes
      });
    }
  }

  Widget _buildTimePanel(
    String title,
    TimeOfDay time,
    IconData icon,
    ColorScheme colors, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
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
      ),
    );
  }

  void _applySuggestion(SleepCycle cycle) {
    if (_baseTime == null) return;
    setState(() {
      if (_calculationMode == 0) {
        _wakeTime = _baseTime!;
        _bedTime = TimeOfDay(hour: cycle.hour, minute: cycle.minute);
      } else {
        _bedTime = _baseTime!;
        _wakeTime = TimeOfDay(hour: cycle.hour, minute: cycle.minute);
      }
    });
  }

  Widget _buildSmartSuggestions(ColorScheme colors) {
    final bool isEnabled = _baseTime != null;

    List<SleepCycle> filtered = [];
    if (isEnabled) {
      final suggestions = SleepMathUtils.calculateSleepCycles(
        baseHour: _baseTime!.hour,
        baseMinute: _baseTime!.minute,
        isWakeUpTime: _calculationMode == 0,
      );
      filtered = suggestions
          .where((c) => c.cycles >= 4 && c.cycles <= 6)
          .toList();
    }

    return Column(
      children: [
        // 1. Hai nút lựa chọn ngữ cảnh - Đảo lên trên, đối xứng
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'TÔI SẼ NGỦ',
                _calculationMode == 1,
                isEnabled,
                () => setState(() {
                  _calculationMode = 1;
                  _showSuggestions = true;
                }),
                colors,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'TÔI SẼ THỨC',
                _calculationMode == 0,
                isEnabled,
                () => setState(() {
                  _calculationMode = 0;
                  _showSuggestions = true;
                }),
                colors,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 2. Mốc giờ gốc - Nằm dưới, thiết kế thanh mảnh
        InkWell(
          onTap: _selectBaseTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled
                    ? colors.primary.withValues(alpha: 0.3)
                    : colors.outline.withValues(alpha: 0.2),
                width: 1.0,
              ),
              color: colors.surfaceContainerHighest.withValues(alpha: 0.15),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: isEnabled
                      ? colors.primary.withValues(alpha: 0.8)
                      : colors.outline.withValues(alpha: 0.5),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _baseTime?.formatHHmm() ?? '--:--',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? colors.onSurface : colors.outline,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_note_rounded,
                  color: colors.outline.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        if (_showSuggestions) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: filtered.map((cycle) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildSuggestionChip(cycle, colors),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    bool isActive,
    bool isEnabled,
    VoidCallback onTap,
    ColorScheme colors,
  ) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: !isEnabled
              ? colors.surfaceContainerHighest.withValues(alpha: 0.1)
              : isActive
              ? colors.primary
              : colors.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isEnabled && isActive
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.3,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isActive && isEnabled
                  ? colors.onPrimary
                  : colors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(SleepCycle cycle, ColorScheme colors) {
    Color chipColor;
    String label;

    if (cycle.cycles == 6) {
      chipColor = Colors.green;
      label = 'TỐT NHẤT';
    } else if (cycle.cycles == 5) {
      chipColor = Colors.orange;
      label = 'KHÁ';
    } else {
      chipColor = Colors.red;
      label = 'TỐI THIỂU';
    }

    final currentTargetTime = _calculationMode == 0 ? _bedTime : _wakeTime;
    final bool isSelected =
        currentTargetTime.hour == cycle.hour &&
        currentTargetTime.minute == cycle.minute;
    final timeStr = TimeOfDay(
      hour: cycle.hour,
      minute: cycle.minute,
    ).formatHHmm();

    return InkWell(
      onTap: () => _applySuggestion(cycle),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? chipColor.withValues(alpha: 0.9)
                  : chipColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? chipColor
                    : chipColor.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cycle.cycles} Chu kỳ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : chipColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: chipColor.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final sleepMins = SleepMathUtils.getDifferenceMinutes(
      _bedTime.hour,
      _bedTime.minute,
      _wakeTime.hour,
      _wakeTime.minute,
    );
    final cycles = (sleepMins / 90).toStringAsFixed(1);
    final quality = SleepMathUtils.getWakeUpQuality(sleepMins);

    Color qualityColor;
    IconData qualityIcon;
    switch (quality) {
      case WakeUpQuality.optimal:
        qualityColor = Colors.green;
        qualityIcon = Icons.check_circle_rounded;
        break;
      case WakeUpQuality.deepSleepRisk:
        qualityColor = colors.error;
        qualityIcon = Icons.warning_rounded;
        break;
      case WakeUpQuality.remRisk:
        qualityColor = Colors.orange;
        qualityIcon = Icons.info_rounded;
        break;
    }

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
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
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: qualityColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  sleepMins.formatAsDuration(),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: colors.onSurface,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: qualityColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: qualityColor.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      qualityIcon,
                                      size: 14,
                                      color: qualityColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$cycles Chu kỳ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: qualityColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSmartSuggestions(colors),
                      ),
                      const SizedBox(height: 16),
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
                                isHighlight: true,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: colors.outlineVariant.withValues(
                                alpha: 0.4,
                              ),
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
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
                                      : colors.outlineVariant.withValues(
                                          alpha: 0.5,
                                        ),
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
                    colors.surface.withValues(alpha: 0.9),
                    colors.surface.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: BlocListener<AlarmBloc, AlarmState>(
                listener: (context, state) {
                  if (state.status == AlarmStatus.saveSuccess) {
                    context.read<AlarmBloc>().add(LoadAlarmsRequested());
                    showTopNotification(
                      context,
                      'Đã lưu lịch trình ngủ!',
                      icon: Icons.check_circle_outline_rounded,
                      color: Colors.green,
                    );
                    Navigator.pop(context);
                  } else if (state.status == AlarmStatus.failure) {
                    showTopNotification(
                      context,
                      'Lỗi: ${state.errorMessage}',
                      icon: Icons.error_outline_rounded,
                      color: Colors.red,
                    );
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveWithConflictCheck,
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
                        if (state.status == AlarmStatus.saving) {
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
