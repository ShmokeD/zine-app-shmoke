import 'package:flutter/material.dart';
import 'package:zineapp2023/models/message.dart';
import 'package:zineapp2023/screens/chat/chat_screen/components/file_tile.dart';
import 'package:zineapp2023/theme/color.dart';

class ReplyIndicator extends StatelessWidget {
  final bool isUser;
  final MessageModel message;
  final MessageModel repliedMessage;

  const ReplyIndicator({
    Key? key,
    required this.isUser,
    required this.message,
    required this.repliedMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
      child: Text(
        "${isUser ? "You" : message.sender?.name} replied to ${repliedMessage.sender?.name}",
        textAlign: isUser ? TextAlign.right : TextAlign.left,
        style: const TextStyle(color: greyText, fontSize: 11),
      ),
    );
  }
}

class ReplyMessageWidget extends StatelessWidget {
  final bool isUser;
  final MessageModel repliedMessage;
  final dynamic chatRoomViewModel;

  const ReplyMessageWidget({
    Key? key,
    required this.isUser,
    required this.repliedMessage,
    required this.chatRoomViewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (isUser) _buildReplyBubble() else _buildReplyIndicatorLine(),
          const SizedBox(width: 4),
          if (isUser) _buildReplyIndicatorLine() else _buildReplyBubble(),
        ],
      ),
    );
  }

  Widget _buildReplyBubble() {
    return Flexible(
      child: InkWell(
        onTap: () => _scrollToRepliedMessage(),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            color: backgroundGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _getReplyText(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyIndicatorLine() {
    return Container(
      width: 3,
      height: 30,
      decoration: BoxDecoration(
        color: isUser ? otherColor : userColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  String _getReplyText() {
    if (repliedMessage.type == MessageType.text && repliedMessage.text != null) {
      final content = repliedMessage.text!.content.toString();
      return content.length > 50 ? '${content.substring(0, 50)}...' : content;
    }
    return "Message";
  }

  void _scrollToRepliedMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatRoomViewModel.scrollToFocusedMessage(repliedMessage.id);
    });
  }
}
