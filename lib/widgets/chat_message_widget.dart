import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/data/models/chat_message.dart';

const backgroundColor = Color(0xff343551);
const botBackgroundColor = Color(0xff444654);


class ChatMessageWidget extends StatelessWidget {
  final String text;
  final ChatMessageType chatMessageType;

  const ChatMessageWidget({ Key? key, required this.text, required this.chatMessageType }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot ? botBackgroundColor : backgroundColor,
      child: Row(
        children: [
          chatMessageType == ChatMessageType.bot ? Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
              child: Image.asset('assets/images/chatgpt-logo.png', scale: 1.5,),
            ),
          ) : Container(
            margin: const EdgeInsets.only(right: 16),
            child: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),),
                )
              ],
          ),)
        ],
      ),
    );
  }
}