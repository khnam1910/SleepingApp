import 'package:cloud_firestore/cloud_firestore.dart';

// Nhớ import đường dẫn file UserModel của bạn cho chính xác
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  // Constructor cho phép tiêm (inject) Firestore vào,
  // Rất tiện cho việc viết Unit Test sau này.
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy thông tin người dùng dựa trên UID
  Future<UserModel?> getUser(String uid) async {
    try {
      // Trỏ tới bảng 'users' và tìm bản ghi có id trùng với uid
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      // Kiểm tra xem dữ liệu có tồn tại không
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;

        // Trả về UserModel thông qua hàm fromJson
        // (Lưu ý: Nếu hàm fromJson của bạn cần thêm ID, bạn có thể truyền data['id'] = docSnapshot.id)
        return UserModel.fromJson(data, docSnapshot.id);
      }

      // Nếu không tìm thấy, trả về null
      return null;
    } on FirebaseException catch (e) {
      // Bắt các lỗi cụ thể từ Firebase
      throw Exception('Lỗi máy chủ Firebase: ${e.message}');
    } catch (e) {
      // Bắt các lỗi vặt khác (ví dụ rớt mạng, sai định dạng JSON)
      throw Exception('Không thể tải thông tin người dùng: $e');
    }
  }

  /// (Bonus) Hàm cập nhật thông tin người dùng (dùng cho tính năng Edit Profile sau này)
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thông tin: $e');
    }
  }
}
