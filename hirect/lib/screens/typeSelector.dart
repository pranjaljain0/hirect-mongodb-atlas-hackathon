import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/JobProvider/Home/Home.dart';
import 'package:hirectt/screens/JobProvider/JobProviderLoginHandler.dart';
import 'package:hirectt/screens/JobSeeker/Home/home.dart';
import 'package:hirectt/screens/JobSeeker/JobSeekerLoginHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hirectt/Contants/Constants.dart';

class TypeSelector extends StatefulWidget {
  const TypeSelector({Key? key}) : super(key: key);

  @override
  State<TypeSelector> createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector> {
  // JobSeekerDetails _jobSeekerDetails;
  // JobProviderDetails _jobProviderDetails;

  verifyAuth() async {
    final auth = await SharedPreferences.getInstance();
    String? authData = auth.getString("auth");
    var authJson;
    if (authData != null) {
      authJson = json.decode(authData);

      final response = await http.get(Uri.parse(
          '$backend_api/auth/login?email=${authJson["email"]}&password=${authJson["password"]}'));
      if (response.statusCode == 200) {
        var resJson = json.decode(response.body)[0];
        auth.setString("auth", json.encode(resJson));
        if (authJson['accountType'] == 1) {
          JobSeekerDetails jobSeeker = JobSeekerDetails.fromJson(resJson);
          Route route = MaterialPageRoute(
              builder: (context) => Home(jobSeeker: jobSeeker));
          Navigator.push(context, route);
        } else if (authJson['accountType'] == 0) {
          JobProviderDetails jobProvider = JobProviderDetails.fromJson(resJson);
          Route route = MaterialPageRoute(
              builder: (context) => JobProviderHome(jobProvider: jobProvider));
          Navigator.push(context, route);
        }
      }
    }
  }

  @override
  void initState() {
    verifyAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(padding: EdgeInsets.all(20.0)),
          Image.asset(
            "assets/images/JobSeeker.png",
            height: 200,
          ),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  Route route = MaterialPageRoute(
                      builder: (context) => const JobSeekerLoginHandler());
                  Navigator.pushReplacement(context, route);
                },
                child: const Text("Join as a job applicant")),
          ),
          Image.asset(
            "assets/images/JobProvider.png",
            height: 200,
          ),
          ElevatedButton(
              onPressed: () {
                Route route = MaterialPageRoute(
                    builder: (context) => const JobProviderLoginHandler());
                Navigator.pushReplacement(context, route);
              },
              child: Text("Join as a job provider")),
          const Padding(padding: EdgeInsets.all(20.0)),
        ],
      ),
    ));
    ;
  }
}
