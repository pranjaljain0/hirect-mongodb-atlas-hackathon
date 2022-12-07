import 'package:flutter/material.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:us_states/us_states.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hirectt/Contants/Constants.dart';

class Preferences extends StatefulWidget {
  final JobSeekerDetails? details;
  const Preferences({Key? key, this.details}) : super(key: key);

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  String? location = "All";
  var stateList = ["All", ...USStates.getAllAbbreviations()];
  var userTags = [];
  var tags = [];

  void updatePreferences(email) async {
    await http
        .post(Uri.parse('$backend_api/profile/preferences/update/$email'),
            headers: <String, String>{
              "Accept": "application/json",
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<dynamic, dynamic>{
              'preferences': {"location": location, "tags": userTags},
            }))
        .then((value) => getTags());
  }

  void getTags() async {
    final response = await http.get(Uri.parse('$backend_api/jobs/tags/all'));
    if (response.statusCode == 200) {
      setState(() {
        tags = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load Jobs');
    }
  }

  @override
  void initState() {
    getTags();
    if (widget.details?.preferences != null) {
      if (widget.details?.preferences.length != 0) {
        userTags = widget.details?.preferences["tags"];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Text("Location"),
              ),
              DropdownButton<String>(
                value: location,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.blueAccent),
                underline: Container(
                  height: 2,
                  color: Colors.blueAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    location = newValue;
                  });
                },
                items: stateList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          Expanded(
              child: SingleChildScrollView(
            child: ListView(
              primary: true,
              shrinkWrap: true,
              children: <Widget>[
                Wrap(
                  spacing: 2.0,
                  runSpacing: 0.0,
                  children: List<Widget>.generate(tags.length, (int index) {
                    return !userTags.contains(tags[index])
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                userTags.add(tags[index]);
                              });
                            },
                            child: Chip(
                              label: Text(tags[index]),
                            ))
                        : InkWell(
                            onTap: () {
                              setState(() {
                                userTags.remove(tags[index]);
                              });
                            },
                            child: Chip(
                              backgroundColor: Colors.blueAccent,
                              label: Text(tags[index]),
                            ));
                  }).toList(),
                ),
              ],
            ),
          )),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  updatePreferences(widget.details?.email);
                },
                child: const Text("Update Preferences")),
          ),
        ],
      ),
    ));
  }
}
