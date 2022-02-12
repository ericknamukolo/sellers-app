import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final IconData icon;
  IconData? trailingIcon;
  bool? enabled;
  Function()? trailingFunc;
  CustomInputField({
    Key? key,
    this.controller,
    required this.hint,
    required this.icon,
    this.trailingIcon,
    this.trailingFunc,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: Colors.teal,
          ),
          enabled: enabled!,
          suffixIcon: IconButton(
              onPressed: trailingFunc,
              icon: Icon(trailingIcon, color: Colors.teal)),
        ),
      ),
    );
  }
}
