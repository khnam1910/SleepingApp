import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Quản lý trạng thái ThemeMode (Light / Dark / System)
class ThemeCubit extends Cubit<ThemeMode> {
  // 💡 Đổi mặc định thành ThemeMode.system để khớp với chữ "Theo hệ thống" ở UI
  ThemeCubit() : super(ThemeMode.system);

  // 💡 Hàm MỚI: Nhận trực tiếp lựa chọn từ BottomSheet bên giao diện
  void changeTheme(ThemeMode mode) {
    emit(mode);
  }

  // (Tùy chọn) Bạn vẫn có thể giữ lại hàm cũ nếu có nút nào đó trong app cần bật/tắt nhanh
  void toggleTheme() {
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }
}
