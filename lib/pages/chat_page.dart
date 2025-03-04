import 'package:chatapp_firebase/pages/group_info.dart';
import 'package:chatapp_firebase/service/database_service.dart';
import 'package:chatapp_firebase/widgets/message_tile.dart';
import 'package:chatapp_firebase/widgets/widgetsa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

var channelName;

class ChatPage extends StatefulWidget {
  final String userName;
  final String groupName;
  final String groupId;
  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messagesController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupName).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Colors.green,
        
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                        groupId: widget.groupId,
                        groupName: widget.groupName,
                        adminName: admin));
              },
              icon: const Icon(Icons.info)),
        ],
      ),
      body: Stack(children: <Widget>[
        chatMessages(),
        Container(
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            width: MediaQuery.of(context).size.width,
            color: Colors.grey[700],
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: messagesController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Send a message.....",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      sender: snapshot.data.docs[index]['sender'],
                      message: snapshot.data.docs[index]['message'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender']);
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messagesController.text.isNotEmpty) {
      Map<String, dynamic> chatMessagesMap = {
        "message": messagesController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessagesMap);
      setState(() {
        messagesController.clear();
      });
    }
  }
}
