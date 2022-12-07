import 'package:flutter/material.dart';
import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/Chat/AllChats.dart';
import 'package:hirectt/widgets/ProfileListItem.dart';
import 'package:http/http.dart' as http;
import 'package:hirectt/Contants/Constants.dart';
import 'dart:convert';
import 'package:hirectt/data/Handler.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class SeekerProfile extends StatefulWidget {
  final JobSeekerDetails jobSeekerDetails;
  final JobProviderDetails jobProviderDetails;
  final jobSeekerStatus;
  final applicantEmail;
  final jobID;

  const SeekerProfile(
      {Key? key,
      required this.jobProviderDetails,
      required this.jobSeekerDetails,
      this.jobSeekerStatus,
      this.applicantEmail,
      this.jobID})
      : super(key: key);

  @override
  State<SeekerProfile> createState() => _SeekerProfileState();
}

class _SeekerProfileState extends State<SeekerProfile> {
  var dropdownValue = "0";

  @override
  void initState() {
    dropdownValue = widget.jobSeekerStatus ?? "0";
    getUserStatus(widget.jobSeekerDetails.email, widget.jobID);
    super.initState();
  }

  getUserStatus(_email, _jobID) async {
    final response =
        await http.get(Uri.parse('$backend_api/profile/job/$_email/$_jobID'));
    if (response.statusCode == 200) {
      setState(() {
        dropdownValue = json.decode(response.body)["status"].toString();
      });
    } else {
      throw Exception('Failed to load Jobs');
    }
  }

// "Applied", "In Process", "Job Offered"
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(child: Text("Applied"), value: "0"),
      const DropdownMenuItem(child: Text("In Process"), value: "1"),
      const DropdownMenuItem(child: Text("Job Offered"), value: "2"),
    ];
    return menuItems;
  }

  void handleStatusUpdate(_email, _status, _jobID) async {
    final response = await http.post(
        Uri.parse('$backend_api/profile/application/status/update'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'email': _email,
          'status': _status.toString(),
          'jobID': _jobID,
        }));
    if (response.statusCode == 200) {
      setState(() {
        dropdownValue = json.decode(response.body)['status'];
      });
      updateLocalAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                ),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.jobSeekerDetails.fullName,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ))),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Applicant Name"),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(widget.jobSeekerDetails.fullName),
                    ),
                    const Text("Applicant Email"),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(widget.jobSeekerDetails.email),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Education"),
                            ],
                          ),
                          for (var item in widget.jobSeekerDetails.education)
                            ProfileListItem(data: item)
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Experience"),
                            ],
                          ),
                          for (var item in widget.jobSeekerDetails.experience)
                            ProfileListItem(
                              data: item,
                            )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Applicant Status"),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton(
                            value: dropdownValue,
                            items: dropdownItems,
                            onChanged: (val) {
                              handleStatusUpdate(
                                  widget.applicantEmail, val, widget.jobID);
                            },
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Certifications"),
                            ],
                          ),
                          for (var item
                              in widget.jobSeekerDetails.certifications)
                            ProfileListItem(data: item)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () async {
                    StreamChatClient client = StreamChatClient(
                      'try43se9tyqm',
                      logLevel: Level.INFO,
                    );

                    await client.connectUser(
                      User(id: widget.jobProviderDetails.fullName),
                      widget.jobProviderDetails.chatToken,
                    );
                    final response = await http.get(Uri.parse(
                        '$backend_api/chat/channel/new?user1=${widget.jobSeekerDetails.fullName}&user2=${widget.jobProviderDetails.fullName}'));

                    if (response.statusCode == 200) {
                      Route route = MaterialPageRoute(
                          builder: (context) => Scaffold(
                                body: AllChats(
                                  jobSeekerDetails: widget.jobSeekerDetails,
                                  client: client,
                                ),
                              ));

                      Navigator.push(context, route);
                    }
                  },
                  child: Text("Chat with ${widget.jobSeekerDetails.fullName}")),
            )
          ],
        ),
      ),
    );
  }
}
