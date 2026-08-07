import 'dart:ui';

import 'package:flutter/material.dart';

// ==========================================
// 1. THẺ THÔNG TIN CHU KỲ (ĐÃ TÍCH HỢP PIN 4 NẤC)
// ==========================================
class SleepCycleCard extends StatelessWidget {
  final String timeLabel;
  final String wakeTime;
  final String duration;
  final int cycles;
  final int batteryBars; // Đổi từ badgeText sang số nấc pin
  final bool isHighlighted;
  final ColorScheme colors;

  const SleepCycleCard({
    super.key,
    required this.timeLabel,
    required this.wakeTime,
    required this.duration,
    required this.cycles,
    required this.batteryBars, // Nhận số nấc pin (1, 2, 3, 4)
    this.isHighlighted = false,
    required this.colors,
  });

  // Tái sử dụng hàm vẽ Pin 4 nấc
  Widget _buildBatteryIcon(int bars, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2.0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 5.5,
                height: 10,
                margin: EdgeInsets.only(right: index < 3 ? 1.5 : 0),
                decoration: BoxDecoration(
                  color: index < bars ? color : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
        ),
        Container(
          width: 2.5,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(3),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Xác định màu sắc dựa trên sự nổi bật (Màu nhấn hoặc màu của Pin)
    Color batteryColor;
    if (batteryBars >= 4) {
      batteryColor = const Color(0xFF3B82F6); // 6 Chu kỳ -> Xanh dương
    } else if (batteryBars == 3) {
      batteryColor = const Color(0xFF10B981); // 5 Chu kỳ -> Xanh lá
    } else if (batteryBars == 2) {
      batteryColor = const Color(0xFFF59E0B); // 4 Chu kỳ -> Cam
    } else {
      batteryColor = const Color(0xFFEF4444); // 3 Chu kỳ -> Đỏ
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted
            ? (isDark
                  ? colors.primary.withOpacity(0.15)
                  : colors.primaryContainer.withOpacity(0.7))
            : (isDark
                  ? colors.surfaceContainerHighest.withOpacity(0.2)
                  : colors.surface),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighlighted
              ? colors.primary.withOpacity(isDark ? 0.8 : 1.0)
              : colors.outlineVariant.withOpacity(0.2),
          width: isHighlighted ? 2.0 : 1.0,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: colors.primary.withOpacity(isDark ? 0.25 : 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeLabel,
                style: TextStyle(fontSize: 11, color: colors.outline),
              ),
              const SizedBox(height: 2),
              Text(
                wakeTime,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thời lượng',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBatteryIcon(batteryBars, batteryColor),
              const SizedBox(height: 24),
              Text(
                'Chu kỳ',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                '$cycles Chu kỳ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. THANH CHUYỂN ĐỔI 2 TAB (TOGGLE)
// ==========================================
class CustomSegmentedToggle extends StatelessWidget {
  final String leftText;
  final String rightText;
  final int selectedIndex;
  final Function(int) onChanged;
  final ColorScheme colors;

  const CustomSegmentedToggle({
    super.key,
    required this.leftText,
    required this.rightText,
    required this.selectedIndex,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(0),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? colors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: selectedIndex == 0
                      ? [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  leftText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedIndex == 0
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                    fontWeight: selectedIndex == 0
                        ? FontWeight.bold
                        : FontWeight.w600,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(1),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? colors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: selectedIndex == 1
                      ? [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  rightText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedIndex == 1
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                    fontWeight: selectedIndex == 1
                        ? FontWeight.bold
                        : FontWeight.w600,
                    fontSize: 13,
                    height: 1.2,
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

// ==========================================
// 3. NÚT BẤM VIỀN NÉT ĐỨT (DASHED BUTTON)
// ==========================================
class DashedOutlineButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ColorScheme colors;

  const DashedOutlineButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRectPainter(color: colors.outlineVariant),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          color: Colors.transparent, // Để nhận diện thao tác chạm
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.onPrimary, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    Path path = Path()..addRRect(rrect);
    Path dashPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// 4. THẺ THÔNG TIN / KIẾN THỨC (INFO BANNER)
// ==========================================
class InfoBannerCard extends StatelessWidget {
  final String title;
  final String description;
  final String highlightText;
  final IconData icon;
  final ColorScheme colors;

  const InfoBannerCard({
    super.key,
    required this.title,
    required this.description,
    required this.highlightText,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  highlightText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. CỤC PIN CHIA NẤC (DÙNG CHUNG TOÀN APP)
// ==========================================
class SegmentedBatteryIcon extends StatelessWidget {
  final int bars;
  final Color color;

  const SegmentedBatteryIcon({
    super.key,
    required this.bars,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2.0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 5.5,
                height: 10,
                margin: EdgeInsets.only(right: index < 3 ? 1.5 : 0),
                decoration: BoxDecoration(
                  color: index < bars ? color : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
        ),
        Container(
          width: 2.5,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(3),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 6. THẺ LỊCH TRÌNH ĐÃ LƯU (BALANCED LIST TILE)
// ==========================================
class SavedAlarmCard extends StatelessWidget {
  final String title;
  final String wakeTime;
  final String bedTime;
  final String duration;
  final String days;
  final bool isActive;
  final bool isSkipped;
  final ValueChanged<bool> onToggle;
  final ColorScheme colors;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SavedAlarmCard({
    super.key,
    required this.title,
    required this.wakeTime,
    required this.bedTime,
    required this.duration,
    required this.days,
    required this.isActive,
    this.isSkipped = false,
    required this.onToggle,
    required this.colors,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withOpacity(0.2)
              : isSkipped
              ? colors.surfaceContainerHighest.withOpacity(0.15)
              : isActive
              ? colors.primaryContainer.withOpacity(0.8)
              : colors.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSelectionMode) ...[
              Container(
                margin: const EdgeInsets.only(right: 16, top: 12),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.outline,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: colors.onPrimary)
                    : null,
              ),
            ],
            // --- CỘT TRÁI ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isActive ? colors.primary : colors.outline,
                        ),
                      ),
                      if (isSkipped) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BỎ QUA HÔM NAY',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: colors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    wakeTime,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      color: isSkipped
                          ? colors.onSurface.withOpacity(0.3)
                          : (isActive
                                ? colors.onPrimaryContainer
                                : colors.onSurface),
                      letterSpacing: -1.0,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    days,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSkipped
                          ? colors.outline.withOpacity(0.5)
                          : (isActive
                                ? colors.onPrimaryContainer.withOpacity(0.7)
                                : colors.outline),
                    ),
                  ),
                ],
              ),
            ),

            // --- CỘT PHẢI ---
            if (!isSelectionMode)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Transform.scale(
                    scale: 0.85,
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: isActive,
                      onChanged: onToggle,
                      activeThumbColor: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bedtime_rounded,
                        size: 14,
                        color: isSkipped
                            ? colors.outline.withOpacity(0.3)
                            : (isActive ? colors.primary : colors.outline),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$bedTime • $duration',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSkipped
                              ? colors.outline.withOpacity(0.3)
                              : (isActive ? colors.primary : colors.outline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
