import 'dart:convert';
import 'dart:developer';

import 'package:aud_vid_call/api/meeting_api.dart';
import 'package:aud_vid_call/models/meeting_details.dart';
import 'package:aud_vid_call/pages/join_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:http/http.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String meetingId = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting App"),
        backgroundColor: Colors.redAccent,
      ),
      body: Form(
        key: globalKey,
        child: formUI(),
      ),
    );
  }

  formUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to WebRTC Meeting App",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            SizedBox(
              height: 20,
            ),
            FormHelper.inputFieldWidget(
              context,
              "meetingId",
              "Enter your Meeting ID",
              (val) {
                if (val.isEmpty) {
                  return "Meeting ID can't be empty";
                }
                return null;
              },
              (onSaved) {
                meetingId = onSaved;
              },
              borderRadius: 10,
              borderFocusColor: Colors.redAccent,
              borderColor: Colors.redAccent,
              hintColor: Colors.grey,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                    child: FormHelper.submitButton("Join Meeting", () {
                  if (validateAndSave()) {
                    validateMeeting(meetingId);
                  }
                })),
                Flexible(
                    child: FormHelper.submitButton("Start Meeting", () async {
                  var response = await startMeeting();
                  final body = json.decode(response!.body);

                  final meetId = body['data'];
                  validateMeeting(meetId);
                }))
              ],
            )
          ],
        ),
      ),
    );
  }

  void validateMeeting(String meetingId) async {
    try {
      Response? response = await joinMeeting(meetingId);
      var data = json.decode(response!.body);
      print('data: $data');
      final meetingDetails = MeetingDetail.fromJson(data["data"]);
      print('meeting detail: ${meetingDetails.id}');
      goToJoinScreen(meetingDetails);
    } catch (err) {
      log('THIS IS ERROR: $err');
      FormHelper.showSimpleAlertDialog(
          context, "Meeting App", "Invalid meeting ID", "OK", () {
        Navigator.of(context).pop();
      });
    }
  }

  goToJoinScreen(MeetingDetail meetingDetail) {
    print('${(meetingDetail.id)}');
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => JoinScreen(meetingDetail: meetingDetail)));
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
