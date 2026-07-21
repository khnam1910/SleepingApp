import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/utils/app_validator.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/custom_label_input.dart';
import '../widgets/custom_text_field.dart';
import 'forgot_password.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
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
        if (state is AuthFailure) {
          final errorMsg = state.message.toLowerCase();

          if (errorMsg.contains('network') || errorMsg.contains('timeout')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Lỗi kết nối mạng. Vui lòng kiểm tra lại!'),
                backgroundColor: colorScheme.error,
              ),
            );
          } else {
            setState(() {
              if (errorMsg.contains('invalid-credential') ||
                  errorMsg.contains('user-not-found')) {
                _errorMessage = 'Email hoặc mật khẩu không chính xác.';
              } else if (errorMsg.contains('too-many-requests')) {
                _errorMessage = 'Thử sai quá nhiều lần. Vui lòng đợi một lát.';
              } else {
                _errorMessage = state.message;
              }
            });
          }
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            // 1. LOGO & SLOGAN
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
                              'Bắt đầu hành trình \ntìm lại sự cân bằng',
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
                              'Đăng nhập để tiếp tục theo dõi nhịp sinh học của bạn.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 12),

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
                                    const CustomLabelInput(text: 'Email'),
                                    const SizedBox(height: 8),
                                    CustomTextField(
                                      controller: _emailController,
                                      validator: AppValidator.validateEmail,
                                      hintText: 'nhap@email.com',
                                      prefixIcon: Icons.mail_outline,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    // Giảm vì CustomTextField đã có helperText giữ chỗ
                                    const CustomLabelInput(text: 'Mật khẩu'),
                                    const SizedBox(height: 8),
                                    CustomTextField(
                                      controller: _passwordController,
                                      validator: AppValidator.validatePassword,
                                      hintText: '••••••••',
                                      prefixIcon: Icons.lock_outline,
                                      isPassword: true,
                                    ),
                                    const SizedBox(height: 2),
                                    // Giảm tối đa
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildRememberMe(context),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ForgotPasswordPage(),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            'Quên mật khẩu?',
                                            style: textTheme.labelMedium
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (_errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16.0,
                                        ),
                                        child: Text(
                                          _errorMessage!,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.error,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        final isLoading = state is AuthLoading;

                                        return SizedBox(
                                          width: double.infinity,
                                          height: 52,
                                          child: ElevatedButton(
                                            // Khóa nút khi đang loading
                                            onPressed: isLoading
                                                ? null
                                                : _onLogin,
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
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Đăng nhập',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                    ],
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),

                            // 3. DIVIDER
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: colorScheme.outlineVariant
                                        .withValues(
                                          alpha: 0.3,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'HOẶC',
                                    style: textTheme.labelSmall?.copyWith(
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: colorScheme.outlineVariant
                                        .withValues(
                                          alpha: 0.3,
                                        ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 4. SOCIAL BUTTONS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialIcon(
                                  context,
                                  svgPath:
                                      'assets/icons/material-icon-theme--google.svg',
                                  iconSize: 24,
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                      AuthGoogleSignInRequested(),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildSocialIcon(
                                  context,
                                  icon: Icons.facebook,
                                  iconColor: const Color(0xFF1877F2),
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                      AuthFacebookSignInRequested(),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildSocialIcon(
                                  context,
                                  icon: Icons.apple,
                                  iconColor: colorScheme.onSurface,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Chưa có tài khoản? ',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterPage(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                    ),
                                    child: Text(
                                      'Tạo tài khoản mới',
                                      style: textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                      ),
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

  Widget _buildRememberMe(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _rememberMe = !_rememberMe),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colorScheme.outlineVariant),
              color: _rememberMe ? colorScheme.primary : Colors.transparent,
            ),
            child: _rememberMe
                ? Icon(Icons.check, size: 14, color: colorScheme.onPrimary)
                : null,
          ),
          const SizedBox(width: 8),
          Text('Ghi nhớ', style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(
    BuildContext context, {
    IconData? icon,
    String? svgPath,
    Color? iconColor,
    double iconSize = 28,
    VoidCallback? onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          color: colorScheme.surface,
        ),
        child: Center(
          child: svgPath != null
              ? SvgPicture.asset(
                  svgPath,
                  width: iconSize,
                  height: iconSize,
                )
              : Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}
