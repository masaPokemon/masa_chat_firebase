import 'dart:async';
import 'package:agora_token_service/agora_token_service.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:masa_chat_firebase/pages/chat_page.dart';

const appId = "bf70cd8ee96740ff941f3764c5f880a8";
const appCertificate = 'c70b32b75301494ebc30e105738af82d';
final channel = channelName;
const uid = '';
const role = RtcRole.publisher;

const expirationInSeconds = 3600;
final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
final expireTimestamp = currentTimestamp + expirationInSeconds;

final token = RtcTokenBuilder.build(
  appId: appId,
  appCertificate: appCertificate,
  channelName: channel,
  uid: uid,
  role: role,
  expireTimestamp: expireTimestamp,
);
//const token = "007eJxTYEiUdDUtWPNyserME/xBD3ao1+fUshdp+qmrGzr67rx55IgCQ1KauUFyikVqqqWZuYlBWpqliWGasbmZSbJpmoWFQaLFzMuX0xoCGRmKpz9gYmSAQBCfgyE3sTgxOSOxhIEBAFgAIGI=";

//const channel = "masachat";
void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState(){
    super.initState();
    initAgora();

  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();
    //create the engine
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.joinChannel(token, channel, null, 0);
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              color: Colors.grey[700],
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                  ? RtcLocalView.SurfaceView()
                  : CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid!,
        channelId: channel,
      );
    } else {
      return Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
