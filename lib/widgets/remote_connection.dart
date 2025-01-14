// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';

class RemoteConnection extends StatefulWidget {
  final RTCVideoRenderer renderer;
  final Connection connection;
  RemoteConnection({
    Key? key,
    required this.renderer,
    required this.connection,
  }) : super(key: key);

  @override
  State<RemoteConnection> createState() => _RemoteConnectionState();
}

class _RemoteConnectionState extends State<RemoteConnection> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          child: RTCVideoView(
            widget.renderer,
            mirror: false,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
        ),
        Container(
          color: widget.connection.videoEnabled!
              ? Colors.transparent
              : Colors.blueGrey[900],
          child: Center(
            child: Text(
              widget.connection.videoEnabled! ? '' : widget.connection.name!,
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
        ),
        Positioned(
          child: Container(
            padding: const EdgeInsets.all(5),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.connection.name!,
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                Icon(
                  widget.connection.audioEnabled! ? Icons.mic : Icons.mic_off,
                  color: Colors.white,
                  size: 15,
                )
              ],
            ),
          ),
          bottom: 10,
          left: 10,
        ),
      ],
    );
  }
}
