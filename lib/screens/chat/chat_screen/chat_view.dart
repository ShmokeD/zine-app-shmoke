import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zineapp2023/components/profile_picture.dart';
import 'package:zineapp2023/models/message.dart';
import 'package:zineapp2023/providers/user_info.dart';
import 'package:zineapp2023/screens/chat/chat_screen/components/empty_chat_widget.dart';
import 'package:zineapp2023/screens/chat/chat_screen/components/file_tile.dart';
import 'package:zineapp2023/screens/chat/chat_screen/components/poll_tile.dart';
import 'package:zineapp2023/screens/chat/chat_screen/view_model/chat_room_view_model.dart';
import 'package:zineapp2023/theme/color.dart';
import 'package:zineapp2023/utilities/date_time.dart';
import 'components/text_message_widget.dart';

class ChatsScreen extends StatelessWidget {
  final dynamic reply;

  const ChatsScreen({
    super.key,
    this.reply,
  });

  @override
  Widget build(BuildContext context) {
    ChatRoomViewModel chatRoomViewModel =
        Provider.of<ChatRoomViewModel>(context, listen: true);
    List<MessageModel> chats = chatRoomViewModel.messages;
    UserProv userVm = Provider.of<UserProv>(context, listen: true);

    if (chatRoomViewModel.loadingAPIMessages) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      );
    }

    if (chats.isEmpty) {
      return const EmptyChatWidget();
    }

    return Flexible(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: ListView.builder(
          controller: chatRoomViewModel.scrollController,
          padding: const EdgeInsets.all(8.0),
          reverse: true,
          dragStartBehavior: DragStartBehavior.down,
          shrinkWrap: true,
          itemCount: chats.length,
          itemBuilder: (BuildContext context, int index) {
            chats[index].timestamp = chats[index].timestamp!.toLocal();
            var currIndx = chats.length - index - 1;

            chatRoomViewModel.messageKeys[chats[currIndx].id] = GlobalKey();

            bool isUser = (userVm.getUserInfo.id == chats[currIndx].sender!.id);
            bool showDate = _shouldShowDate(index, currIndx, chats);
            bool group = _isGroupedMessage(index, currIndx, chats);
            MessageModel? repliedMessage =
                _getRepliedMessage(currIndx, chats, chatRoomViewModel);
            Sender sender = chats[currIndx].sender!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showDate) _buildDateSeparator(chats[currIndx].timestamp!),
                Container(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _buildProfilePicture(
                              isUser, group, sender.name, sender.dp),
                        ),
                      Flexible(
                        child: _buildMessageWidget(
                          chats[currIndx],
                          isUser,
                          group,
                          repliedMessage,
                          chatRoomViewModel,
                          userVm,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!group) _buildMessageMetadata(chats[currIndx], isUser),
              ],
            );
          },
        ),
      ),
    );
  }
}

bool _shouldShowDate(int index, int currIndx, List<MessageModel> chats) {
  return index == chats.length - 1 ||
      (chats.length - index >= 2 &&
          validShowDate(chats[currIndx].timestamp!) !=
              validShowDate(chats[chats.length - index - 2].timestamp!));
}

bool _isGroupedMessage(int index, int currIndx, List<MessageModel> chats) {
  return index > 0 &&
      chats[currIndx].sender!.id == chats[chats.length - index].sender?.id &&
      getChatDate(chats[currIndx].timestamp!) ==
          getChatDate(chats[chats.length - index].timestamp!);
}

MessageModel? _getRepliedMessage(int currIndx, List<MessageModel> chats,
    ChatRoomViewModel chatRoomViewModel) {
  if (chats[currIndx].replyToId != null) {
    return chatRoomViewModel.userGetMessageById(
        chats, chats[currIndx].replyToId.toString());
  }
  return null;
}

Widget _buildProfilePicture(bool isUser, bool group, String name, String? dp) {
  if (group) {
    return const SizedBox(
      height: 40,
      width: 40,
    );
  }

  return ProfilePicture(
    name: name,
    dp: dp,
  );
}

Widget _buildDateSeparator(DateTime date) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      DateFormat.yMMMMd().format(date).toString(),
      textAlign: TextAlign.center,
      style: const TextStyle(color: greyText),
    ),
  );
}

Widget _buildMessageMetadata(MessageModel message, bool isUser) {
  return Padding(
    padding: EdgeInsets.only(
      left: isUser ? 0 : 58, // Account for avatar space
      right: isUser ? 8 : 0,
      top: 4,
      bottom: 8,
    ),
    child: Text(
      "${message.sender!.name}  •  ${getChatTime(message.timestamp!)}",
      textAlign: isUser ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 11.0,
        color: Color.fromARGB(255, 92, 92, 92),
      ),
    ),
  );
}

Widget _buildMessageWidget(
  MessageModel message,
  bool isUser,
  bool group,
  MessageModel? repliedMessage,
  ChatRoomViewModel chatRoomViewModel,
  UserProv userVm,
) {
  if (message.type == MessageType.text && message.text != null) {
    return TextMessageWidget(
      key: chatRoomViewModel.messageKeys[message.id],
      message: message,
      isUser: isUser,
      repliedMessage: repliedMessage,
      chatRoomViewModel: chatRoomViewModel,
      userVm: userVm,
    );
  } else if (message.type == MessageType.poll && message.poll != null) {
    return KeyedSubtree(
      key: chatRoomViewModel.messageKeys[message.id],
      child: PollTile(
        group: group,
        chatVm: chatRoomViewModel,
        message: message,
        isUser: message.sender!.id == userVm.getUserInfo.id,
        onVote: (optionId) =>
            chatRoomViewModel.sendPollResponse(message.id, optionId),
      ),
    );
  } else if (message.type == MessageType.file && message.file != null) {
    return KeyedSubtree(
      key: chatRoomViewModel.messageKeys[message.id],
      child: FileTile(
        chatRoomViewModel: chatRoomViewModel,
        group: group,
        message: message,
        isUser: isUser,
      ),
    );
  }

  return Container();
}
