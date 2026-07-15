import 'package:flutter/material.dart';

import '../widgets/sleep_schedule_tracker.dart';

class SetAlarmPage extends StatefulWidget {
  const SetAlarmPage({super.key});

  @override
  State<SetAlarmPage> createState() => _SetAlarmPageState();
}

class _SetAlarmPageState extends State<SetAlarmPage> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);

  bool _isVibrationActive = true;
  final List<bool> _selectedDays = [true, true, true, true, true, false, false];
  final List<String> _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  bool _isDialDragging = false;

  String formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Lấy tổng số phút ngủ
  int get sleepMinutes {
    int bedMins = _bedTime.hour * 60 + _bedTime.minute;
    int wakeMins = _wakeTime.hour * 60 + _wakeTime.minute;
    return (wakeMins - bedMins + 1440) % 1440;
  }

  // Định dạng thời gian ngủ (VD: 7h 30p)
  String get sleepDuration {
    int diff = sleepMinutes;
    int h = diff ~/ 60;
    int m = diff % 60;
    return '${h}h ${m}p';
  }

  // Tính số chu kỳ ngủ (Mỗi chu kỳ = 90 phút)
  String get sleepCycles {
    double cycles = sleepMinutes / 90;
    // Làm tròn 1 chữ số thập phân nếu bị lẻ, hoặc hiển thị số chẵn
    String cycleText = cycles == cycles.truncateToDouble()
        ? cycles.toInt().toString()
        : cycles.toStringAsFixed(1);
    return '$cycleText Chu kỳ';
  }

  // Widget hỗ trợ vẽ ô Thời gian (Đi ngủ / Thức dậy)
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
          formatTime(time),
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
                // ==========================================
                // 1. TRUNG TÂM ĐIỀU KHIỂN (CONTROL CENTER CARD)
                // ==========================================
                Container(
                  padding: const EdgeInsets.only(top: 32, bottom: 24),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(36), // Bo góc tròn trịa
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // --- VÒNG XOAY ĐỒNG HỒ (TÍCH HỢP CHỮ Ở GIỮA TÂM) ---
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Widget vòng xoay
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

                          // Nội dung nằm ngay giữa tâm vòng tròn
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
                                sleepDuration,
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
                                  sleepCycles,
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

                      // --- BẢNG ĐIỀU KHIỂN THỜI GIAN BÊN DƯỚI ---
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

                            // Vạch ngăn cách mỏng manh, tinh tế
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

                // ==========================================
                // 2. THẺ CÀI ĐẶT
                // ==========================================
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

          // --- NÚT LƯU ---
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
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lưu báo thức',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

// =========================================================================
// WIDGET VÒNG XOAY CHU KỲ NGỦ (SLEEP TRACKER DIAL)
// =========================================================================
