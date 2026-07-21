import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pinput/pinput.dart';
import 'package:sleeping_app_flutter/core/utils/app_validator.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/custom_label_input.dart';
import '../widgets/custom_text_field.dart';
import 'createpassword.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpLoading = false;
  String? _emailError;
  bool _isOtpSent = false;
  int _countdown = 0;
  Timer? _timer;

  String get _formattedTime {
    int minutes = _countdown ~/ 60;
    int seconds = _countdown % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _countdown = 180;
      _isOtpSent = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  void _onSendOtp() {
    setState(() {
      _emailError = null; // Xóa data lỗi cũ
      _isOtpLoading = true; // 1. BẬT VÒNG XOAY LOADING
    });

    // 2. ÉP FORM KIỂM TRA LẠI ĐỂ XÓA NGAY DÒNG CHỮ ĐỎ
    _formKey.currentState?.validate();

    if (AppValidator.validateEmail(_emailController.text) == null) {
      context.read<AuthBloc>().add(
        AuthSendOtpRequested(email: _emailController.text),
      );
    } else {
      // Nếu email nhập sai định dạng thì tắt loading đi
      setState(() {
        _isOtpLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email hợp lệ')),
      );
    }
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthVerifyOtpRequested(
          email: _emailController.text,
          otp: _otpController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpVerifiedSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreatePasswordPage(email: _emailController.text),
            ),
          );
        } else if (state is AuthOtpVerifiedFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthOtpSentSuccess) {
          _startTimer();
          setState(() {
            _isOtpLoading = false;
            _isOtpSent = true; // Thêm dòng này để dấu tích hiện ra
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi mã OTP! Vui lòng kiểm tra email.'),
            ),
          );
        } else if (state is AuthOtpSentFailure) {
          setState(() {
            _isOtpLoading = false;
            _emailError = state.message; // Gán lỗi
          });
          // THÊM DÒNG NÀY: Ép Form kiểm tra lại để hiện dòng chữ đỏ dưới ô text
          _formKey.currentState?.validate();
        }
      },
      child: GestureDetector(
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
                            // 1. TOP BAR
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(
                                  alpha: 0.4,
                                ),
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
                              'Đăng ký mới',
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
                              'Bắt đầu hành trình cân bằng nhịp sinh học\ncủa bạn.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 20),

                            // 2. FORM CARD
                            Container(
                              padding: const EdgeInsets.all(20),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CustomLabelInput(
                                      text: 'Email của bạn',
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      controller: _emailController,
                                      validator: (val) =>
                                          _emailError ??
                                          AppValidator.validateEmail(val),
                                      hintText: 'Nhập địa chỉ email',
                                      prefixIcon: Icons.mail_outline,
                                      keyboardType: TextInputType.emailAddress,
                                      // Thêm dòng này để khóa input khi đang loading
                                      enabled: !_isOtpSent,
                                      suffix: BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          if (_isOtpLoading) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 16.0,
                                              ),
                                              child: SizedBox(
                                                width:
                                                    24, // Cho rộng một chút để chứa vừa 3 dấu chấm
                                                height: 20,
                                                child: SpinKitFadingCircle(
                                                  color: colorScheme
                                                      .primary, // Lấy tự động màu chủ đạo của App
                                                  size:
                                                      20.0, // Kích thước của các dấu chấm
                                                ),
                                              ),
                                            );
                                          }
                                          // Nếu đã gửi thành công thì hiện dấu tích xanh
                                          if (_isOtpSent) {
                                            return const Padding(
                                              padding: EdgeInsets.only(
                                                right: 12.0,
                                              ),
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              ),
                                            );
                                          }
                                          // Nếu chưa gửi thì hiện nút Gửi mã
                                          return TextButton(
                                            // Chỗ này chỉ cần gọi _onSendOtp vì mình đã đưa setState vào trong hàm đó rồi
                                            onPressed: _onSendOtp,
                                            child: const Text(
                                              'Gửi mã',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Center(
                                      child: CustomLabelInput(
                                        text: 'Mã xác nhận (OTP)',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: Pinput(
                                        controller: _otpController,
                                        length: 6,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        defaultPinTheme: PinTheme(
                                          width: 44,
                                          height: 52,
                                          textStyle: textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                              ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.surface,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: colorScheme.outlineVariant
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                        focusedPinTheme: PinTheme(
                                          width: 44,
                                          height: 52,
                                          textStyle: textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.surface,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: colorScheme.primary,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        submittedPinTheme: PinTheme(
                                          width: 44,
                                          height: 52,
                                          textStyle: textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                              ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.surface,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: colorScheme.outlineVariant,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Bạn chưa nhận được mã?',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          if (_countdown > 0)
                                            Text(
                                              // Dùng hàm _formattedTime để hiển thị 2:59 thay vì số giây
                                              'Gửi lại sau ${_formattedTime}',
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            )
                                          else
                                            TextButton(
                                              onPressed: _onSendOtp,
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                              child: Text(
                                                'Gửi lại ngay',
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // const SizedBox(height: 24),
                                    // SizedBox(
                                    //   width: double.infinity,
                                    //   height: 52,
                                    //   child: ElevatedButton(
                                    //     onPressed: _onContinue,
                                    //     style: ElevatedButton.styleFrom(
                                    //       backgroundColor: colorScheme.primary,
                                    //       foregroundColor:
                                    //           colorScheme.onPrimary,
                                    //       shape: RoundedRectangleBorder(
                                    //         borderRadius: BorderRadius.circular(
                                    //           16,
                                    //         ),
                                    //       ),
                                    //       elevation: 0,
                                    //     ),
                                    //     child: const Row(
                                    //       mainAxisAlignment:
                                    //           MainAxisAlignment.center,
                                    //       children: [
                                    //         Text(
                                    //           'Tiếp tục',
                                    //           style: TextStyle(
                                    //             fontWeight: FontWeight.bold,
                                    //             fontSize: 16,
                                    //           ),
                                    //         ),
                                    //         SizedBox(width: 8),
                                    //         Icon(Icons.arrow_forward, size: 18),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _onContinue,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.primary,
                                          foregroundColor:
                                              colorScheme.onPrimary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          'Tiếp tục',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Đã có tài khoản? ',
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontSize: 13,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                        ),
                                        child: Text(
                                          'Đăng nhập ngay',
                                          style: textTheme.labelMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                                fontSize: 13,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Bằng việc tiếp tục, bạn đồng ý với Điều khoản \n & Chính sách bảo mật',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
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
      ),
    );
  }
}
