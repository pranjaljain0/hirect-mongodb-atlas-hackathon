import 'package:flutter/material.dart';
import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:hirectt/screens/JobProvider/Home/Home.dart';
import 'package:hirectt/widgets/ForgetPassword.dart';
import 'package:hirectt/Contants/Constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProviderLogin extends StatefulWidget {
  const ProviderLogin({Key? key}) : super(key: key);

  @override
  State<ProviderLogin> createState() => _ProviderLoginState();
}

class _ProviderLoginState extends State<ProviderLogin> {
  String email = "";
  String password = "";
  bool showErr = false;
  var _emailOk = false;
  var _passwordOK = false;

  @override
  void initState() {
    email = "";
    password = "";
    showErr = false;
    super.initState();
  }

  loginHandler(_email, _password) async {
    final auth = await SharedPreferences.getInstance();
    final response = await http.get(
        Uri.parse('$backend_api/auth/login?email=$_email&password=$_password'));

    if (response.statusCode == 200) {
      var jobSeekerJson = json.decode(response.body)[0];
      if (jobSeekerJson["accountType"] == 0) {
        auth.setString("auth", json.encode(jobSeekerJson));
        JobProviderDetails jobProvider =
            JobProviderDetails.fromJson(jobSeekerJson);
        Route route = MaterialPageRoute(
            builder: (context) => JobProviderHome(jobProvider: jobProvider));
        Navigator.pushReplacement(context, route);
      } else {
        setState(() {
          showErr = true;
        });
      }
    } else if (response.statusCode == 401) {
      setState(() {
        showErr = true;
      });
    } else {
      throw Exception('Failed to load album');
    }
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
        if (showErr || _emailOk || _passwordOK)
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(
              "Problem with email or password.",
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                loginHandler(email, password);
              },
              child: const Text("login")),
        ),
        InkWell(
          onTap: () {
            Route route =
                MaterialPageRoute(builder: (context) => const ForgetPassword());
            Navigator.push(context, route);
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text("Forget password"),
          ),
        )
      ],
    );
  }
}
