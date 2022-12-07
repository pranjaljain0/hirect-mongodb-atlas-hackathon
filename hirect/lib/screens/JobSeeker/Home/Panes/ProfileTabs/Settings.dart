import 'package:flutter/material.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';

class Settings extends StatefulWidget {
  final JobSeekerDetails? details;
  const Settings({Key? key, this.details}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Show Notifications"),
              Switch(
                  value: isSwitched,
                  onChanged: (val) {
                    setState(() {
                      isSwitched = val;
                    });
                  })
            ],
          )
        ],
      ),
    ));
  }
}
