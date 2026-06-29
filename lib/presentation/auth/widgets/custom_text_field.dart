import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final Widget? suffix;
  final String? Function(String?)? validator;

  // 1. THÊM BIẾN ENABLED
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.suffix,
    // 2. GÁN MẶC ĐỊNH LÀ TRUE (để không làm lỗi các trang cũ chưa truyền thuộc tính này)
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      // 3. TRUYỀN XUỐNG TEXTFORMFIELD
      enabled: widget.enabled,
      validator: widget.validator,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: !widget.isPassword,
      autofillHints: widget.keyboardType == TextInputType.emailAddress
          ? [AutofillHints.email]
          : (widget.isPassword ? [AutofillHints.password] : null),
      style: textTheme.bodyLarge?.copyWith(
        fontSize: 15,
        // Làm mờ chữ nếu bị disable
        color: widget.enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: widget.enabled
              ? colorScheme.outlineVariant
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        filled: true,
        // Làm mờ nền đi một chút nếu bị disable
        fillColor: widget.enabled
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        // Icon bên trái
        prefixIcon: Icon(
          widget.prefixIcon,
          // Làm mờ icon nếu disable
          color: widget.enabled
              ? colorScheme.outline
              : colorScheme.outline.withValues(alpha: 0.3),
          size: 20,
        ),

        suffixIcon:
            widget.suffix ??
            (widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: widget.enabled
                          ? colorScheme.outline
                          : colorScheme.outline.withValues(alpha: 0.3),
                      size: 20,
                    ),
                    // Khóa luôn nút bấm ẩn/hiện mật khẩu nếu form bị disable
                    onPressed: widget.enabled
                        ? () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          }
                        : null,
                  )
                : null),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        helperText: ' ',
        helperStyle: const TextStyle(fontSize: 12, height: 1.5),
        errorStyle: const TextStyle(
          fontSize: 12,
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
        errorMaxLines: 1,
      ),
    );
  }
}
