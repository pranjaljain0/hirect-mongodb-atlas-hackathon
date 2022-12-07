import 'package:flutter/material.dart';
import 'package:hirectt/screens/JobSeeker/SeekerLogin.dart';
import 'package:hirectt/screens/JobSeeker/SeekerSignUp.dart';

class JobSeekerLoginHandler extends StatefulWidget {
  const JobSeekerLoginHandler({Key? key}) : super(key: key);

  @override
  State<JobSeekerLoginHandler> createState() => _JobSeekerLoginHandlerState();
}

class _JobSeekerLoginHandlerState extends State<JobSeekerLoginHandler> {
  int pageIndex = 0;
  final pages = [const SeekerLogin(), const SeekerSignUp()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          pages[pageIndex],
          GestureDetector(
              onTap: () {
                setState(() {
                  if (pageIndex == 1) {
                    pageIndex = 0;
                  } else {
                    pageIndex = 1;
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: pageIndex == 0
                    ? const Text("Want to join?")
                    : const Text("Already have an account?"),
              ))
        ],
      ),
    );
  }
}
