import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hirectt/data/Handler.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/Chat/AllChats.dart';
import 'package:hirectt/screens/JobSeeker/Home/Panes/ProfileTabs/TabHandler.dart';
import 'package:hirectt/screens/JobSeeker/Home/Panes/allJobs.dart';
import 'package:hirectt/screens/JobSeeker/Home/Panes/appliedJobs.dart';
import 'package:hirectt/screens/JobSeeker/Home/Panes/savedJobs.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class Home extends StatefulWidget {
  final JobSeekerDetails? jobSeeker;
  const Home({Key? key, this.jobSeeker}) : super(key: key);

  @override
  State<Home> createState() => HhomeState();
}

class HhomeState extends State<Home> {
  int pageIndex = 0;

  Future getAuth() async {
    var auth = await getLocalAuth();
    return json.encode(auth);
  }

  @override
  void initState() {
    getAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      FutureBuilder(
          future: getAuth(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return AllJobs(
                  jobSeeker: JobSeekerDetails.fromJson(
                      json.decode(snapshot.data.toString())));
            } else {
              return const CircularProgressIndicator();
            }
          })),
      FutureBuilder(
          future: getAuth(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return AppliedJobs(JobSeekerDetails.fromJson(
                  json.decode(snapshot.data.toString())));
            } else {
              return const CircularProgressIndicator();
            }
          })),
      FutureBuilder(
          future: getAuth(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return SavedJobs(JobSeekerDetails.fromJson(
                  json.decode(snapshot.data.toString())));
            } else {
              return const CircularProgressIndicator();
            }
          })),
      FutureBuilder(
          future: getAuth(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              // Profile(
              //   jobSeeker: JobSeekerDetails.fromJson(
              //       json.decode(snapshot.data.toString()))
              return TabHandler(
                jobSeeker: JobSeekerDetails.fromJson(
                  json.decode(snapshot.data.toString()),
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          })),
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          StreamChatClient client = StreamChatClient(
            'try43se9tyqm',
            logLevel: Level.INFO,
          );

          await client.connectUser(
            User(id: widget.jobSeeker?.fullName),
            widget.jobSeeker?.chatToken,
          );

          Route route = MaterialPageRoute(
              builder: (context) => Scaffold(
                    body: AllChats(
                      jobSeekerDetails: widget.jobSeeker,
                      client: client,
                    ),
                  ));
          Navigator.push(context, route);
        },
        child: const Icon(Icons.message),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  updateLocalAuth();
                  setState(() {
                    pageIndex = 0;
                  });
                },
                icon: pageIndex == 0
                    ? const Icon(
                        Icons.work,
                        color: Colors.white,
                        size: 35,
                      )
                    : const Icon(
                        Icons.work_outline,
                        color: Colors.white,
                        size: 35,
                      ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  updateLocalAuth();
                  setState(() {
                    pageIndex = 1;
                  });
                },
                icon: pageIndex == 1
                    ? const Icon(
                        Icons.check_box,
                        color: Colors.white,
                        size: 35,
                      )
                    : const Icon(
                        Icons.check_box_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  updateLocalAuth();
                  setState(() {
                    pageIndex = 2;
                  });
                },
                icon: pageIndex == 2
                    ? const Icon(
                        Icons.bookmark,
                        color: Colors.white,
                        size: 35,
                      )
                    : const Icon(
                        Icons.bookmark_outline,
                        color: Colors.white,
                        size: 35,
                      ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  updateLocalAuth();
                  setState(() {
                    pageIndex = 3;
                  });
                },
                icon: pageIndex == 3
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 35,
                      )
                    : const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 35,
                      ),
              ),
            ],
          )),
      body: pages[pageIndex],
      // floatingActionButton: CustomFAB(() {
      //   print("fab clicked");
      // }, Icons.save, "Save"),
    );
  }
}
