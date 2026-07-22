import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeping_app_flutter/presentation/profile/bloc/profile_event.dart';
import 'package:sleeping_app_flutter/presentation/profile/bloc/profile_state.dart';

import '../../../data/repositories/users_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;

  ProfileBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // Gọi xuống UserRepository để lấy dữ liệu
      final user = await _userRepository.getUser(event.userId);

      if (user != null) {
        emit(ProfileLoaded(user: user));
      } else {
        emit(
          const ProfileError(message: 'Không tìm thấy thông tin người dùng'),
        );
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
