import 'package:flutter/material.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';

class ApplicantListItem extends StatelessWidget {
  final JobSeekerDetails _jobSeekerDetails;
  final Function tapHandler;
  const ApplicantListItem(this._jobSeekerDetails, this.tapHandler);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        tapHandler();
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        height: 40,
        width: double.infinity,
        child: Center(
          child: Text(_jobSeekerDetails.fullName),
        ),
      ),
    );
  }
}
