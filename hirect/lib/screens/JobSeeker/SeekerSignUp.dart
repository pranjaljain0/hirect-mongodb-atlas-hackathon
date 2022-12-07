import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/JobSeeker/Home/home.dart';
import 'package:http/http.dart' as http;
import 'package:hirectt/Contants/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeekerSignUp extends StatefulWidget {
  const SeekerSignUp({Key? key}) : super(key: key);

  @override
  State<SeekerSignUp> createState() => _SeekerSignUpState();
}

class _SeekerSignUpState extends State<SeekerSignUp> {
  String email = "";
  String password = "";
  String fullName = "";
  bool showErr = false;
  var _emailOk = true;
  var _passwordOK = true;

  @override
  void initState() {
    super.initState();
    email = "";
    password = "";
    fullName = "";
    showErr = false;
  }

  validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }

  bool validatePassword(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  signUpHandler(_email, _password, _fullName) async {
    final auth = await SharedPreferences.getInstance();
    JobSeekerDetails jobSeekerDetails;

    final response = await http.post(
        Uri.parse('$backend_api/auth/JobSeekerSignUp'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, String>{
          'email': _email,
          'password': _password,
          'fullName': _fullName
        }));
    if (response.statusCode == 200) {
      var jobSeekerDetailsJson = json.decode(response.body)['res'];
      auth.setString("auth", json.encode(jobSeekerDetailsJson));
      jobSeekerDetails = JobSeekerDetails.fromJson(jobSeekerDetailsJson);
      Route route = MaterialPageRoute(
          builder: (context) => Home(jobSeeker: jobSeekerDetails));
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
            "Job Seeker",
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
                email = text;
                _emailOk = validateEmail(email);
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
                _passwordOK = validatePassword(text);
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
              "User already exist",
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                signUpHandler(email, password, fullName);
              },
              child: const Text("Sign Up")),
        )
      ],
    );
  }
}
