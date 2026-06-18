import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final Widget? suffix;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.suffix,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // Biến quản lý trạng thái ẩn/hiện mật khẩu (Chỉ tác động bên trong Widget này)
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Gán trạng thái ban đầu dựa vào việc nó có phải ô mật khẩu hay không
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
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
        color: colorScheme.onSurface,
      ),
      // Thuộc tính decoration quản lý toàn bộ giao diện của ô nhập liệu
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: colorScheme.outlineVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        // 1. Icon bên trái (Cố định)
        prefixIcon: Icon(
          widget.prefixIcon,
          color: colorScheme.outline,
          size: 20,
        ),


        suffixIcon: widget.suffix ?? (widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: colorScheme.outline,
            size: 20,
          ),
          onPressed: () {
            // Cập nhật giao diện: Chỉ vẽ lại ô mật khẩu này, không vẽ lại cả trang
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null),

        // 3. Viền lúc bình thường (Không có viền, chỉ bo góc)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        // 4. Viền lúc người dùng bấm vào (Tự động đổi màu Primary và dày lên 2px)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}