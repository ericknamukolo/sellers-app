import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  bool? isLoading;
  final Function() click;
  CustomButton({
    Key? key,
    required this.text,
    required this.click,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: click,
      child: Container(
        height: 40,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 7, 205, 219),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.6),
              blurRadius: 6,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: isLoading!
            ? const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}
