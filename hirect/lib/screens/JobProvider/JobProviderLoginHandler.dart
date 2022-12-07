import 'package:flutter/material.dart';
import 'package:hirectt/screens/JobProvider/ProviderLogin.dart';
import 'package:hirectt/screens/JobProvider/ProviderSignUp.dart';

class JobProviderLoginHandler extends StatefulWidget {
  const JobProviderLoginHandler({Key? key}) : super(key: key);

  @override
  State<JobProviderLoginHandler> createState() =>
      _JobProviderLoginHandlerState();
}

class _JobProviderLoginHandlerState extends State<JobProviderLoginHandler> {
  int pageIndex = 0;
  final pages = [const ProviderLogin(), const ProviderSignUp()];

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
