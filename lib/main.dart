import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/data/constants/constants.dart';
import 'package:flutter_chatgpt/data/models/chat_message.dart';
import 'package:flutter_chatgpt/widgets/chat_message_widget.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatPage(title: 'Flutter + ChatGPT'),
    );
  }
}

const backgroundColor = Color(0xff343551);
const botBackgroundColor = Color(0xff444654);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});
  final String title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  late bool isLoading;
  TextEditingController _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  Future<String> generateResponse(String prompt) async {
    const apiKey = apiSecretKey;
    var url = Uri.https("api.openai.com", "/v1/completions");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': prompt,
        'temperature': 0,
        'max_tokens': 2000,
        'top_p': 1,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0
      })
    );

    Map<String, dynamic> newresponse = jsonDecode(response.body);
    return newresponse['choices'][0]['text'];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(widget.title),
        backgroundColor: botBackgroundColor,  
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(child: _buildList()),
          Visibility(
            visible: isLoading,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildInput(),
                  _buildSubmit(),
                ],
              ),
            )
        ],
      ),
    ));
  }

  Expanded _buildInput(){
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
          fillColor: botBackgroundColor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmit(){
    return Visibility(
      visible: !isLoading,
      child: Container(
        color: botBackgroundColor,
        child: IconButton(
          icon: const Icon(Icons.send_rounded, color: Color.fromRGBO(142, 142, 160, 1)),
          onPressed: (){
            setState(() {
              _messages.add(ChatMessage(text: _textController.text, chatMessageType: ChatMessageType.user));
              isLoading = true;
            });

            var input = _textController.text;
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50)).then((value) => _scrollDown());
            generateResponse(input).then((value) {
              setState(() {
                isLoading = false;
                _messages.add(ChatMessage(text: value, chatMessageType: ChatMessageType.bot));
              });
            });

            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50)).then((value) => _scrollDown());
          },
        ),
      ),
    );
  }

  void _scrollDown(){
    _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  ListView _buildList(){
    return ListView.builder(
      itemCount: _messages.length,
      controller: _scrollController,
      itemBuilder: ((context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      }),
    );
  }
}
