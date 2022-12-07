import 'dart:convert';
import 'package:hirectt/Contants/Constants.dart';
import 'package:flutter/material.dart';
import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/JobProvider/Home/Home.dart';
import 'package:hirectt/screens/JobSeeker/Home/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProviderSignUp extends StatefulWidget {
  const ProviderSignUp({Key? key}) : super(key: key);

  @override
  State<ProviderSignUp> createState() => _ProviderSignUpState();
}

class _ProviderSignUpState extends State<ProviderSignUp> {
  String username = "";
  String password = "";
  String fullName = "";
  String companyName = "";
  bool showErr = false;

  @override
  void initState() {
    super.initState();
    username = "";
    password = "";
    fullName = "";
    companyName = "";
    showErr = false;
  }

  signUpHandler(_email, _password, _fullName, _companyName) async {
    final auth = await SharedPreferences.getInstance();
    JobProviderDetails jobProviderDetails;

    final response =
        await http.post(Uri.parse('$backend_api/auth/JobProviderSignUp'),
            headers: <String, String>{
              "Accept": "application/json",
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<String, String>{
              'email': _email,
              'password': _password,
              'fullName': _fullName,
              'companyName': _companyName,
            }));
    if (response.statusCode == 200) {
      var jobProviderDetailsJson = json.decode(response.body)['res'];
      auth.setString("auth", json.encode(jobProviderDetailsJson));
      jobProviderDetails = JobProviderDetails.fromJson(jobProviderDetailsJson);
      Route route = MaterialPageRoute(
          builder: (context) =>
              JobProviderHome(jobProvider: jobProviderDetails));
      Navigator.pushReplacement(context, route);
    } else {
      setState(() {
        showErr = true;
      });
      // throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Job Provider",
            style: TextStyle(fontSize: 35),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            onChanged: (text) {
              setState(() {
                fullName = text;
              });
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Full Name',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            onChanged: (text) {
              setState(() {
                companyName = text;
              });
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Company Name',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            onChanged: (text) {
              setState(() {
                username = text;
              });
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Email',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            obscureText: true,
            onChanged: (text) {
              setState(() {
                password = text;
              });
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Password',
            ),
          ),
        ),
        if (showErr)
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(
              "Error Msg",
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                signUpHandler(username, password, fullName, companyName);
              },
              child: const Text("Sign Up")),
        )
      ],
    );
  }
}
