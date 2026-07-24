extension DurationUX on Duration {
  /// Định dạng sang chuỗi "7h 30p"
  String formatDuration() {
    int h = inHours;
    int m = inMinutes % 60;
    return '${h}h ${m.toString().padLeft(2, '0')}p';
  }
}

extension MinutesUX on int {
  /// Giả định int là số phút, chuyển sang chuỗi "7h 30p"
  String formatAsDuration() {
    int h = this ~/ 60;
    int m = this % 60;
    return '${h}h ${m.toString().padLeft(2, '0')}p';
  }
}
