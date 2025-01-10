import 'package:aud_vid_call/models/meeting_details.dart';
import 'package:aud_vid_call/pages/meeting_page.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

class JoinScreen extends StatefulWidget {
  final MeetingDetail? meetingDetail;
  JoinScreen({super.key, this.meetingDetail});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String userName = "";
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Meeting"),
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
            FormHelper.inputFieldWidget(
              context,
              "userId",
              "Enter your name",
              (val) {
                if (val.isEmpty) {
                  return "Name can't be empty";
                }
                return null;
              },
              (onSaved) {
                userName = onSaved;
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
                    child: FormHelper.submitButton("Join", () {
                  if (validateAndSave()) {
                    //MeetingPage
                    print('meetingDetail passed to meeting page: ${widget.meetingDetail!.id}');
                    Navigator.pushReplacement(context, 
                    MaterialPageRoute(builder: (context) => MeetingPage(
                      meetingId: widget.meetingDetail!.id,
                      name: userName,
                      meetingDetail: widget.meetingDetail!,
                      ))
                    );
                  }
                })),
               
              ],
            )
          ],
        ),
      ),
    );
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