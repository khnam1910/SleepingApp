import 'package:flutter/material.dart';

class SamsungTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final ColorScheme colors;

  const SamsungTimePickerDialog({
    super.key,
    required this.initialTime,
    required this.colors,
  });

  @override
  State<SamsungTimePickerDialog> createState() =>
      _SamsungTimePickerDialogState();
}

class _SamsungTimePickerDialogState extends State<SamsungTimePickerDialog> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CHỌN GIỜ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.colors.onSurfaceVariant,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 32),

            // --- KHU VỰC VÒNG CUỘN ---
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dải màu Highlight ở giữa (chỉ thị vị trí đang chọn)
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.colors.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- CUỘN GIỜ ---
                      SizedBox(
                        width: 80,
                        child: ListWheelScrollView.useDelegate(
                          controller: _hourController,
                          itemExtent: 52, // Chiều cao mỗi item
                          physics: const FixedExtentScrollPhysics(),
                          diameterRatio: 1.2, // Tạo độ cong 3D nhẹ
                          squeeze: 1.1, // Ép các số gần lại nhau một chút
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedHour = index);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 24,
                            builder: (context, index) {
                              final isSelected = _selectedHour == index;
                              return Center(
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: isSelected
                                        ? 36
                                        : 28, // Số được chọn sẽ phóng to
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? widget.colors.primary
                                        : widget.colors.outline.withOpacity(
                                            0.5,
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Dấu hai chấm tĩnh ở giữa
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: widget.colors.primary,
                          ),
                        ),
                      ),

                      // --- CUỘN PHÚT ---
                      SizedBox(
                        width: 80,
                        child: ListWheelScrollView.useDelegate(
                          controller: _minuteController,
                          itemExtent: 52,
                          physics: const FixedExtentScrollPhysics(),
                          diameterRatio: 1.2,
                          squeeze: 1.1,
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedMinute = index);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 60,
                            builder: (context, index) {
                              final isSelected = _selectedMinute == index;
                              return Center(
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: isSelected ? 36 : 28,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? widget.colors.primary
                                        : widget.colors.outline.withOpacity(
                                            0.5,
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- NÚT HỦY / LƯU ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context), // Trả về null khi bấm Hủy
                  child: Text(
                    'HỦY',
                    style: TextStyle(
                      color: widget.colors.outline,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                    TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                  ), // Trả về giờ khi Lưu
                  style: TextButton.styleFrom(
                    backgroundColor: widget.colors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'LƯU',
                    style: TextStyle(
                      color: widget.colors.onPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
