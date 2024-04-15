import 'package:flutter/material.dart';

class BurbleChat extends StatelessWidget {
  final String message;
  final bool isMe;

  const BurbleChat({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        margin: isMe
            ? const EdgeInsets.only(bottom: 8.0, left: 0.0, right: 0.0)
            : const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 0.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 30.0 : 4.0),
            topRight: Radius.circular(isMe ? 30.0 : 30.0),
            bottomLeft: const Radius.circular(30.0),
            bottomRight: Radius.circular(isMe ? 4.0 : 30.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: isMe
              ? const EdgeInsets.fromLTRB(14.0, 14.0, 16.0, 20.0)
              : const EdgeInsets.all(14.0),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
