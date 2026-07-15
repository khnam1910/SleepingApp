import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Nhớ import file state vừa tạo ở trên vào
import 'alarms_state.dart';

class AlarmsBloc extends Cubit<AlarmsState> {
  AlarmsBloc() : super(AlarmsInitial());

  void calculateCycles(TimeOfDay time, int toggleIndex) {
    List<SleepCycleModel> results = [];
    final int baseMinutes = time.hour * 60 + time.minute;

    for (int i = 6; i >= 3; i--) {
      int totalSleepMinutes = i * 90;
      int targetMinutes;

      if (toggleIndex == 0) {
        // Option 0: "Tôi muốn THỨC DẬY lúc..." -> Tính giờ ĐI NGỦ
        targetMinutes = baseMinutes - totalSleepMinutes - 15;
      } else {
        // Option 1: "Tôi sẽ ĐI NGỦ lúc..." -> Tính giờ THỨC DẬY
        targetMinutes = baseMinutes + totalSleepMinutes + 15;
      }

      // Xử lý logic qua ngày (VD: Ngủ 23h, dậy 6h)
      targetMinutes = (targetMinutes % 1440 + 1440) % 1440;

      final resultTime = TimeOfDay(
        hour: targetMinutes ~/ 60,
        minute: targetMinutes % 60,
      );
      final hours = totalSleepMinutes ~/ 60;
      final mins = totalSleepMinutes % 60;
      final durationStr = '${hours}h ${mins.toString().padLeft(2, '0')}p';

      int batteryBars = i >= 5 ? (i == 6 ? 4 : 3) : (i == 4 ? 2 : 1);
      bool isOptimal = i == 6;

      results.add(
        SleepCycleModel(
          time: resultTime,
          cycles: i,
          durationStr: durationStr,
          batteryBars: batteryBars,
          isOptimal: isOptimal,
        ),
      );
    }

    // Sau khi tính xong, phát ra trạng thái AlarmsCalculated
    emit(AlarmsCalculated(results, time, toggleIndex));
  }
}
