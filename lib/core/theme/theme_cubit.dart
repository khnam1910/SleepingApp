import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Quản lý trạng thái ThemeMode (Light / Dark)
class ThemeCubit extends Cubit<ThemeMode> {
  // Mặc định khởi tạo ứng dụng với Theme sáng (Light)
  ThemeCubit() : super(ThemeMode.light);

  // Hàm chuyển đổi qua lại giữa 2 chế độ
  void toggleTheme() {
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }
}
