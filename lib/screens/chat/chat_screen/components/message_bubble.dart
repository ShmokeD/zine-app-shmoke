import 'package:flutter/material.dart';
import 'package:zineapp2023/screens/chat/chat_screen/components/file_tile.dart';

class MessageBubble extends StatelessWidget {
  final bool isUser;
  final Widget child;

  const MessageBubble({
    super.key,
    required this.isUser,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: isUser
          ? EdgeInsets.only(left: 0.2 * screenWidth)
          : EdgeInsets.only(right: 0.2 * screenWidth),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 0.8 * screenWidth,
            minWidth: 40,
          ),
          decoration: BoxDecoration(
            color: isUser ? userColor : otherColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16.0),
              topRight: const Radius.circular(16.0),
              bottomRight: isUser
                  ? const Radius.circular(4.0)
                  : const Radius.circular(16.0),
              bottomLeft: isUser
                  ? const Radius.circular(16.0)
                  : const Radius.circular(4.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
