import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final IconData icon;
  final TextInputType keyboardType;
  final bool showVisibilityToggle;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.showVisibilityToggle = false,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.obscureText && _isObscured,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(widget.icon, color: const Color(0xFF626FFF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.showVisibilityToggle
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF626FFF),
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
      ),
    );
  }
}
