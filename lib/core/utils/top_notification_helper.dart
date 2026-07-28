import 'dart:async';

import 'package:flutter/material.dart';

/// Lưu trữ thông báo hiện tại để tránh việc hiển thị chồng chéo
OverlayEntry? _currentEntry;

class TopNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color? color;
  final VoidCallback onDismiss;

  const TopNotification({
    super.key,
    required this.message,
    required this.icon,
    this.color,
    required this.onDismiss,
  });

  @override
  State<TopNotification> createState() => _TopNotificationState();
}

class _TopNotificationState extends State<TopNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _offsetAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutQuart,
          ),
        );

    _controller.forward();

    // Tự động đóng sau 3 giây
    _dismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).colorScheme;
    final padding = MediaQuery.of(context).padding;
    final primaryColor = widget.color ?? themeColors.primary;

    return Positioned(
      top: padding.top + 10,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: themeColors.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 18, color: primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: themeColors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hiển thị thông báo trượt từ trên xuống phong cách Samsung
/// Cơ chế Singleton: Chỉ một thông báo xuất hiện tại một thời điểm
void showTopNotification(
  BuildContext context,
  String message, {
  IconData icon = Icons.notifications_active_outlined,
  Color? color,
}) {
  final overlay = Overlay.of(context);

  // 1. Dọn dẹp thông báo cũ nếu đang hiển thị
  if (_currentEntry != null) {
    _currentEntry!.remove();
    _currentEntry = null;
  }

  // 2. Tạo thông báo mới
  _currentEntry = OverlayEntry(
    builder: (context) => TopNotification(
      message: message,
      icon: icon,
      color: color,
      onDismiss: () {
        // Đảm bảo chỉ remove nếu chính nó đang được gán cho _currentEntry
        if (_currentEntry != null) {
          _currentEntry!.remove();
          _currentEntry = null;
        }
      },
    ),
  );

  // 3. Hiển thị lên màn hình
  overlay.insert(_currentEntry!);
}
