// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:aud_vid_call/pages/home_screen.dart';
import 'package:aud_vid_call/utils/user.utils.dart';
import 'package:aud_vid_call/widgets/control_panel.dart';
import 'package:aud_vid_call/widgets/remote_connection.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:aud_vid_call/models/meeting_details.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';

class MeetingPage extends StatefulWidget {
  final String? meetingId;
  final String? name;
  final MeetingDetail meetingDetail;
  const MeetingPage({
    Key? key,
    this.meetingId,
    this.name,
    required this.meetingDetail,
  }) : super(key: key);

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _localRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = {"audio": true, "video": true};
  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  void startMeeting() async {
    print('meeting id passed to webrtc helper: ${widget.meetingDetail.id}');
    final String userId = await loadUserId();
    meetingHelper = WebRTCMeetingHelper(
      url: "http://34.93.141.164:4000",
      meetingId: widget.meetingDetail.id,
      userId: userId,
      name: widget.name,
    );

    MediaStream _localStream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;
    meetingHelper!.stream = _localStream;

    meetingHelper!.on("open", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("connection", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("user-left", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("video_toggle", context, (ev, context) {
      setState(() {});
    });

    meetingHelper!.on("audio_toggle", context, (ev, context) {
      setState(() {});
    });

    meetingHelper!.on("meeting_ended", context, (ev, context) {
      onMeetingEnd();
    });

    meetingHelper!.on("connection-setting-changed", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("stream-changed", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    setState(() {});
  }

  initRenderer() async {
    await _localRenderer.initialize();
  }

  @override
  void initState() {
    super.initState();
    initRenderer();
    startMeeting();
  }

  @override
  void deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHomePage();
    }
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }

  bool isVideoEnabled() {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  bool isAudioEnabled() {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  void handleReconnect() {
    if (meetingHelper != null) {
      meetingHelper!.reconnect();
    }
  }

  void goToHomePage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  _buildMeetingRoom() {
    if(meetingHelper != null && meetingHelper!.connections.isNotEmpty){
      print('INSIDE BUILD MEETING ROOM');
      log('MEETING HELPER CONNECTIONS LIST: ${meetingHelper!.connections[0].renderer}');
      log('RENDERER: ${meetingHelper!.connections[0].renderer}');
    }
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty
            ? GridView.count(
                crossAxisCount: meetingHelper!.connections.length < 3 ? 1 : 2,
                children:
                    List.generate(meetingHelper!.connections.length, (index) {
                  return Padding(
                    padding: EdgeInsets.all(1),
                    child: RemoteConnection(
                        renderer: meetingHelper!.connections[index].renderer,
                        connection: meetingHelper!.connections[index]),
                  );
                }),
              )
            :  Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Waiting for participants to join...',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 24),
                      ),
                      Text(
                        'SHARE MEETING ID:',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 24),
                      ),
                      Text(
                        widget.meetingDetail.id!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
        Positioned(
          bottom: 10,
          right: 0,
          child: SizedBox(
            width: 150,
            height: 200,
            child: RTCVideoView(_localRenderer),
          ),
        )
      ],
    );
  }
}
