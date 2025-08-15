import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zineapp2023/models/message.dart';
import 'reply_message_widget.dart';
import 'message_bubble.dart';

const Color userColor = Color.fromARGB(255, 104, 181, 228);
const Color userSelectedTextColor = Color.fromARGB(255, 255, 255, 255);
const Color otherColor = Color(0xff0c72b0);
const Color otherSelectedTextColor = Color(0xffE8F2FC);

class TextMessageWidget extends StatelessWidget {
  final MessageModel message;
  final bool isUser;
  final MessageModel? repliedMessage;
  final dynamic chatRoomViewModel;
  final dynamic userVm;

  const TextMessageWidget({
    super.key,
    required this.message,
    required this.isUser,
    this.repliedMessage,
    required this.chatRoomViewModel,
    required this.userVm,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reply Message Section
          if (repliedMessage != null) ...[
            ReplyIndicator(
              isUser: isUser,
              message: message,
              repliedMessage: repliedMessage!,
            ),
            ReplyMessageWidget(
              isUser: isUser,
              repliedMessage: repliedMessage!,
              chatRoomViewModel: chatRoomViewModel,
            ),
          ],

          // Main Message Bubble
          SwipeTo(
            onRightSwipe: (details) {
              chatRoomViewModel.userReplyText(message);
              chatRoomViewModel.replyfocus.requestFocus();
            },
            child: MessageBubble(
              isUser: isUser,
              child: SelectableLinkify(
                text: message.text!.content.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18.0,
                  color: isUser ? userSelectedTextColor : otherSelectedTextColor,
                ),
                onOpen: (link) => launchUrlString(link.url),
                linkStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18.0,
                  color: isUser ? userSelectedTextColor : otherSelectedTextColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
