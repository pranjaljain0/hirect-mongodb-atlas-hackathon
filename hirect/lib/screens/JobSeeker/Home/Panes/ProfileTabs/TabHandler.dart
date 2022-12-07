import 'package:flutter/material.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/JobSeeker/Home/Panes/ProfileTabs/Preference.dart';
import 'package:hirectt/screens/JobSeeker/Home/Panes/ProfileTabs/Settings.dart';
import 'package:hirectt/screens/JobSeeker/Home/Panes/ProfileTabs/profile.dart';

class TabHandler extends StatefulWidget {
  final JobSeekerDetails? jobSeeker;
  const TabHandler({Key? key, this.jobSeeker}) : super(key: key);

  @override
  State<TabHandler> createState() => _TabHandlerState();
}

class _TabHandlerState extends State<TabHandler> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const TabBar(
              tabs: [
                Tab(text: "Profile"),
                Tab(text: "Preference"),
                Tab(text: "Settings"),
              ],
              labelColor: Colors.black,
              indicatorColor: Colors.blue,
              unselectedLabelColor: Colors.black,
            ),
            Expanded(
              child: TabBarView(children: [
                Profile(
                  jobSeeker: widget.jobSeeker,
                ),
                Preferences(
                  details: widget.jobSeeker,
                ),
                Settings(
                  details: widget.jobSeeker,
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
