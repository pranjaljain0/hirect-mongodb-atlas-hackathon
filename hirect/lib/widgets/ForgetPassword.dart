import 'package:flutter/material.dart';
import 'package:hirectt/screens/typeSelector.dart';
import 'package:http/http.dart' as http;
import 'package:hirectt/Contants/Constants.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  var email = "";

  void handleForgetPassword() async {
    final response =
        await http.get(Uri.parse('$backend_api/auth/forget?email=$email'));

    if (response.statusCode == 200) {
      Route route =
          MaterialPageRoute(builder: (context) => const TypeSelector());
      Navigator.pushReplacement(context, route);
    }
  }

  @override
  void initState() {
    email = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Forget Password?"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              initialValue: email,
              onChanged: (text) {
                setState(() {
                  email = text;
                });
              },
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Email',
                  helperText: "abc@xyz.com"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  handleForgetPassword();
                },
                child: const Text("Get Password on email")),
          ),
        ],
      )),
    );
  }
}
