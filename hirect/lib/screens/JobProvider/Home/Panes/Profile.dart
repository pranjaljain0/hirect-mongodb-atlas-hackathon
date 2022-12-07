import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:hirectt/screens/typeSelector.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hirectt/Contants/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final JobProviderDetails? jobProviderDetails;
  const Profile({Key? key, this.jobProviderDetails}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var data = {};
  var verifyData = {};

  @override
  void initState() {
    data = {
      "fullName": widget.jobProviderDetails?.fullName,
      "email": widget.jobProviderDetails?.email,
      "companyName": widget.jobProviderDetails?.companyName,
      "upVotes": widget.jobProviderDetails?.upVotes,
      "downVotes": widget.jobProviderDetails?.downVotes,
    };
    verifyData = data;
    super.initState();
  }

  updateProfileHandler(_email) async {
    final response = await http.post(Uri.parse('$backend_api/profile/update'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json
            .encode(<String, dynamic>{'email': _email, 'updatedDoc': data}));
    if (response.statusCode == 200) {
      setState(() {
        verifyData = data;
      });
    } else {
      // throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                const Center(
                  child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://avatars.dicebear.com/api/open-peeps/somerandomseed.png')),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    enabled: false,
                    initialValue: data["fullName"],
                    onChanged: (text) {
                      setState(() {
                        data = {
                          'fullName': text,
                          ...data,
                        };
                      });
                    },
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Full Name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    enabled: false,
                    initialValue: data["email"],
                    onChanged: (text) {
                      setState(() {
                        data = {
                          'email': text,
                          ...data,
                        };
                      });
                    },
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    initialValue: data["companyName"],
                    onChanged: (text) {
                      setState(() {
                        data = {
                          'companyName': text,
                          ...data,
                        };
                      });
                    },
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Company Name',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Rating"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.thumb_up),
                          ),
                          Text(data["upVotes"].toString())
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.thumb_down),
                          ),
                          Text(data["downVotes"].toString())
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (data != verifyData)
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                    onPressed: () {
                      updateProfileHandler(data["email"]);
                    },
                    child: const Text("Update Profile")),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                  onPressed: () async {
                    final auth = await SharedPreferences.getInstance();
                    auth.remove("auth");
                    Route route = MaterialPageRoute(
                        builder: (context) => const Scaffold(
                              body: TypeSelector(),
                            ));
                    Navigator.pushReplacement(context, route);
                  },
                  child: const Text("Logout")),
            )
          ],
        )
      ],
    );
  }
}
