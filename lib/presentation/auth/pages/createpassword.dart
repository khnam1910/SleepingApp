import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_validator.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/custom_label_input.dart';
import '../widgets/custom_text_field.dart';

class CreatePasswordPage extends StatefulWidget {
  // 1. THÊM BIẾN EMAIL: Nhận từ trang Register truyền sang
  final String email;

  const CreatePasswordPage({super.key, required this.email});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onFinish() {
    if (_formKey.currentState!.validate()) {
      // 2. GỌI BLOC: Bắn sự kiện tạo tài khoản
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: widget.email,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 3. THÊM BLOCCONSUMER: Lắng nghe trạng thái tạo tài khoản
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Khi tạo tài khoản thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng ký tài khoản thành công!')),
          );

          // TODO: Chuyển hướng người dùng về Trang chủ (Home) và xóa lịch sử trang
          // Ví dụ: Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else if (state is AuthFailure) {
          // Khi lỗi (ví dụ: email đã tồn tại, lỗi mạng...)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Lấy trạng thái loading để khóa form
        final isLoading = state is AuthLoading;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.eco,
                                  size: 28,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Thiết lập mật khẩu',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  fontSize: 22,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tạo một khẩu mạnh để bảo vệ hành \ntrình giấc ngủ của bạn.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.shadow.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CustomLabelInput(text: 'Mật khẩu'),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _passwordController,
                                        validator:
                                            AppValidator.validatePassword,
                                        hintText: 'Nhập mật khẩu mới',
                                        prefixIcon: Icons.lock_outline,
                                        isPassword: true,
                                        // Vô hiệu hóa input khi đang tải
                                        enabled: !isLoading,
                                      ),
                                      const SizedBox(height: 4),
                                      const CustomLabelInput(
                                        text: 'Xác nhận mật khẩu',
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _confirmPasswordController,
                                        validator: (value) =>
                                            AppValidator.validateConfirmPassword(
                                              _passwordController.text,
                                              value,
                                            ),
                                        hintText: 'Nhập lại mật khẩu',
                                        prefixIcon: Icons.lock_reset_outlined,
                                        isPassword: true,
                                        enabled: !isLoading,
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        // 4. CẬP NHẬT NÚT BẤM VỚI TRẠNG THÁI LOADING
                                        child: ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : _onFinish,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                colorScheme.primary,
                                            foregroundColor:
                                                colorScheme.onPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: isLoading
                                              ? SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: colorScheme
                                                            .onPrimary,
                                                        strokeWidth: 2.5,
                                                      ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Hoàn tất và bắt đầu',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons.arrow_forward,
                                                      size: 18,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Text(
                                  'Mật khẩu phải có ít nhất 8 ký tự, bao \ngồm chữ và số.',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
