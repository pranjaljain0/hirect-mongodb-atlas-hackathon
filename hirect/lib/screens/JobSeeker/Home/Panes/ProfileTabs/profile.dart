import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hirectt/data/Handler.dart';
import 'package:hirectt/screens/JobSeeker/ResumeAnalyser/UploadResume.dart';
import 'package:hirectt/screens/typeSelector.dart';
import 'package:flutter/material.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/widgets/ProfileListItem.dart';
import 'package:hirectt/Contants/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final JobSeekerDetails? jobSeeker;
  const Profile({Key? key, this.jobSeeker}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map data = {};
  Map verifyData = {};
  Map itemData = {};
  String fullName = "";
  String email = "";
  String summary = "";

  updateProfileHandler(_email) async {
    final response = await http.post(Uri.parse('$backend_api/profile/update'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'email': _email,
          'updatedDoc': {
            "fullName": fullName,
            "email": email,
            "summary": summary
          }
        }));
    if (response.statusCode == 200) {
      setState(() {
        verifyData = data;
      });
    } else {
      // throw Exception('Failed to load');
    }
  }

  void setItemData(itemJson) {
    setState(() {
      itemData = itemJson;
    });
  }

  @override
  void initState() {
    fullName = widget.jobSeeker?.fullName;
    email = widget.jobSeeker?.email;
    summary = widget.jobSeeker?.summary;

    data = {
      "fullName": widget.jobSeeker?.fullName,
      "email": widget.jobSeeker?.email,
      "summary": widget.jobSeeker?.summary,
      "education": widget.jobSeeker?.education,
      "experience": widget.jobSeeker?.experience,
      "certifications": widget.jobSeeker?.certifications,
    };
    verifyData = data;
    itemData = {"title": "", "name": "", "start": "", "end": ""};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 50,
                  ),
                  const Center(
                    child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                            'https://avatars.dicebear.com/api/open-peeps/somerandomseed.png')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      enabled: false,
                      initialValue: data["fullName"],
                      onChanged: (text) {
                        setState(() {
                          fullName = text;
                          data = {
                            'fullName': text,
                            ...data,
                          };
                        });
                      },
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Full Name',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      enabled: false,
                      initialValue: data["email"],
                      onChanged: (text) {
                        setState(() {
                          email = text;
                          data = {
                            'email': text,
                            ...data,
                          };
                        });
                      },
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      initialValue: data["summary"],
                      minLines: 1,
                      maxLines: 5,
                      onChanged: (text) {
                        summary = text;
                        setState(() {
                          data = {
                            'summary': text,
                            ...data,
                          };
                        });
                      },
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Summary',
                      ),
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
                            const Text("Education"),
                            IconButton(
                                onPressed: () {
                                  showNewItemAlert(
                                      context, "education", data["email"]);
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.blueAccent,
                                  size: 30,
                                ))
                          ],
                        ),
                        for (var item in data['education'])
                          ProfileListItem(
                            data: item,
                            title: "education",
                            email: widget.jobSeeker?.email,
                            showIcon: true,
                          )
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
                            IconButton(
                                onPressed: () {
                                  showNewItemAlert(
                                      context, "experience", data["email"]);
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.blueAccent,
                                  size: 30,
                                ))
                          ],
                        ),
                        for (var item in data['experience'])
                          ProfileListItem(
                            data: item,
                            title: "experience",
                            email: widget.jobSeeker?.email,
                            showIcon: true,
                          )
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
                            const Text("Certifications"),
                            IconButton(
                                onPressed: () {
                                  showNewItemAlert(
                                      context, "certifications", data["email"]);
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.blueAccent,
                                  size: 30,
                                ))
                          ],
                        ),
                        for (var item in data['certifications'])
                          ProfileListItem(
                            data: item,
                            title: "certifications",
                            email: widget.jobSeeker?.email,
                            showIcon: true,
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (data != verifyData)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                      onPressed: () {
                        updateProfileHandler(data["email"]);
                      },
                      child: const Text("Update Profile")),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                    onPressed: () async {
                      final auth = await SharedPreferences.getInstance();
                      auth.remove("auth");
                      Route route = MaterialPageRoute(
                          builder: (context) => const Scaffold(
                                body: TypeSelector(),
                              ));
                      Navigator.pushReplacement(context, route);
                    },
                    child: const Text("Logout")),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                    onPressed: () async {
                      Route route = MaterialPageRoute(
                          builder: (context) =>
                              UploadResume(jobSeekerDetails: widget.jobSeeker));
                      Navigator.push(context, route);
                    },
                    child: const Text("Resume")),
              )
            ],
          ),
        )
      ],
    );
  }
}

showNewItemAlert(BuildContext context, String title, String email) {
  var data = {};

  void handleAdd() async {
    final response =
        await http.post(Uri.parse('$backend_api/profile/add/$title/$email'),
            headers: <String, String>{
              "Accept": "application/json",
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<String, dynamic>{'data': data}));
    if (response.statusCode == 200) {
      updateLocalAuth();
      Navigator.of(context).pop(true);
    }
  }

  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );

  AlertDialog dialog = AlertDialog(
    title: Text(title),
    content: SizedBox(
      height: 300.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              initialValue: data["name"],
              onChanged: (text) {
                data = {...data, "name": text};
                // setItemData({...itemData, "name": text});
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Title',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              initialValue: data["start"],
              onChanged: (text) {
                data = {...data, "start": text};
                // setItemData({...itemData, "start": text});
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Start',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              initialValue: data["end"],
              onChanged: (text) {
                data = {...data, "end": text};
                // setItemData({...itemData, "end": text});
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'End',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              child: const Text("Add"),
              onPressed: () {
                handleAdd();
              },
            ),
          )
        ],
      ),
    ),
    actions: [
      cancelButton,
    ],
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return dialog;
    },
  );
}
