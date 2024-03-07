import 'package:flutter/material.dart';

class BurbleChat extends StatelessWidget {
  final String message;
  const BurbleChat({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xffB81736),
            Color(0xff281537),
          ],
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
