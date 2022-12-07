import 'package:flutter/material.dart';
import 'package:hirectt/Contants/Constants.dart';
import 'package:hirectt/data/Handler.dart';
import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:us_states/us_states.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewJob extends StatefulWidget {
  final JobProviderDetails? jobProvider;
  const NewJob({Key? key, this.jobProvider}) : super(key: key);

  @override
  State<NewJob> createState() => _NewJobState();
}

class _NewJobState extends State<NewJob> {
  var newPost = {};
  String? jobTitle;
  String? jobDesc;
  String? jobTags;
  String? jobSalery;
  String? jobPostOwner;
  String? jobLocation;
  String? jobUrl;
  String? jobPostOwnerEmail;
  bool? sponsored;

  @override
  void initState() {
    newPost = {
      "jobTitle": "",
      "jobTags": "",
      "jobSalery": "",
      "jobPostOwner": widget.jobProvider?.fullName,
      "jobLocation": "CA",
      "jobUrl": "",
      "jobPostOwnerEmail": widget.jobProvider?.email,
      "sponsored": false,
    };

    jobTitle = "";
    jobTags = "";
    jobSalery = "";
    jobPostOwner = widget.jobProvider?.fullName;
    jobLocation = "";
    jobUrl = "";
    jobPostOwnerEmail = widget.jobProvider?.email;
    sponsored = false;

    super.initState();
  }

  newPostHandler(context, _email, _data) async {
    // print(_data);
    final response = await http.post(Uri.parse('$backend_api/jobs/post'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json
            .encode(<String, dynamic>{'email': _email, 'jobDetails': _data}));
    if (response.statusCode == 200) {
      updateLocalAuth();
      Navigator.of(context).pop(true);
    } else {
      // throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    var stateList = USStates.getAllAbbreviations();
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                ),
                child: const Center(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "New Job",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ))),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                initialValue: newPost["jobTitle"],
                onChanged: (text) {
                  setState(() {
                    jobTitle = text;
                    newPost = {
                      'jobTitle': text,
                      ...newPost,
                    };
                  });
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Job Title',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                minLines: 3,
                maxLines: 5,
                initialValue: newPost["description"],
                onChanged: (text) {
                  setState(() {
                    jobDesc = text;
                    newPost = {
                      'description': text,
                      ...newPost,
                    };
                  });
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Job Description',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                initialValue: newPost["jobSalery"],
                onChanged: (text) {
                  setState(() {
                    jobSalery = text;
                    newPost = {
                      'jobSalery': text,
                      ...newPost,
                    };
                  });
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Salery',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                initialValue: "",
                onChanged: (text) {
                  setState(() {
                    jobTags = text;
                    newPost = {
                      'jobTags': text,
                      ...newPost,
                    };
                  });
                },
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Tags',
                    hintText: "Enter comma seperated values"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Text("Location"),
                ),
                DropdownButton<String>(
                  value: newPost['jobLocation'],
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.blueAccent),
                  underline: Container(
                    height: 2,
                    color: Colors.blueAccent,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      newPost = {...newPost, "jobLocation": newValue};
                    });
                  },
                  items:
                      stateList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                initialValue: newPost["jobUrl"],
                onChanged: (text) {
                  setState(() {
                    newPost = {
                      ...newPost,
                      'jobUrl': text,
                    };
                  });
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Link',
                ),
              ),
            ),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 10,
                ), //SizedBox
                const Text(
                  'Sponsored: ',
                  style: TextStyle(fontSize: 17.0),
                ), //Text
                const SizedBox(width: 10), //SizedBox
                /** Checkbox Widget **/
                Checkbox(
                  value: newPost["sponsored"],
                  onChanged: (bool? value) async {
                    setState(() {
                      newPost = {...newPost, "sponsored": value};
                    });
                  },
                ), //Checkbox
              ], //<Widget>[]
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                  onPressed: () {
                    newPost = {
                      ...newPost,
                      'jobTitle': jobTitle,
                      'description': jobDesc,
                      'jobSalery': jobSalery,
                      'jobTags': [...jobTags!.replaceAll(" ", '').split(",")]
                    };

                    newPostHandler(context, widget.jobProvider?.email, newPost);
                  },
                  child: const Text("Post Job")),
            ),
          ],
        ),
      )),
    );
  }
}
