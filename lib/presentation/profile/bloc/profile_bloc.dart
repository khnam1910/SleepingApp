import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeping_app_flutter/presentation/profile/bloc/profile_event.dart';
import 'package:sleeping_app_flutter/presentation/profile/bloc/profile_state.dart';

import '../../../domain/usecases/user/get_user_profile_usecase.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;

  ProfileBloc({required GetUserProfileUseCase getUserProfileUseCase})
    : _getUserProfileUseCase = getUserProfileUseCase,
      super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await _getUserProfileUseCase.execute(event.userId);

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
