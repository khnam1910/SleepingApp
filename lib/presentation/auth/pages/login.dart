import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // ResizeToAvoidBottomInset true helps prevent the keyboard from overlapping fields
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // BouncingScrollPhysics makes it feel more "premium" on iOS/Android
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Minimum height is the height of the screen
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // 1. LOGO & SLOGAN
                        const SizedBox(height: 24),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.4),
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

                        const SizedBox(height: 24),

                        // 2. FORM CARD
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(context, 'Email'),
                              const SizedBox(height: 10),
                              const CustomTextField(
                                hintText: 'nhap@email.com',
                                prefixIcon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              _buildLabel(context, 'Mật khẩu'),
                              const SizedBox(height: 10),
                              const CustomTextField(
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildRememberMe(context),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Quên mật khẩu?',
                                      style: textTheme.labelMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 3. DIVIDER
                        Row(
                          children: [
                            Expanded(child: Divider(color: colorScheme.outlineVariant.withOpacity(0.3))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('HOẶC', style: textTheme.labelSmall?.copyWith(letterSpacing: 1.1)),
                            ),
                            Expanded(child: Divider(color: colorScheme.outlineVariant.withOpacity(0.3))),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 4. SOCIAL BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialIcon(
                              context,
                              svgPath: 'assets/icons/material-icon-theme--google.svg',
                              iconSize: 24,
                            ),
                            const SizedBox(width: 16),
                            _buildSocialIcon(
                              context,
                              icon: Icons.facebook,
                              iconColor: const Color(0xFF1877F2),
                            ),
                            const SizedBox(width: 16),
                            _buildSocialIcon(
                              context,
                              icon: Icons.apple,
                              iconColor: Theme.of(context).colorScheme.onSurface,
                            ),
                          ],
                        ),

                        // 5. FOOTER
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Chưa có tài khoản? ', style: textTheme.bodyMedium?.copyWith(fontSize: 13)),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                ),
                                child: Text('Tạo tài khoản mới',
                                    style: textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                      fontSize: 13,
                                    )),
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
    );
  }


  // CÁC WIDGET BỔ SUNG
  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
          fontSize: 14,
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
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
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