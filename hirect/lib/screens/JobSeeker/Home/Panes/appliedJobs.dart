import 'dart:convert';
import 'package:hirectt/Contants/Constants.dart';
import 'package:flutter/material.dart';
import 'package:hirectt/data/JobDetail.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/JobSeeker/Home/JobPage.dart';
import 'package:hirectt/widgets/JobListItem.dart';
import 'package:http/http.dart' as http;

class AppliedJobs extends StatefulWidget {
  final JobSeekerDetails jobSeeker;
  const AppliedJobs(this.jobSeeker);

  @override
  State<AppliedJobs> createState() => _AppliedJobsState();
}

class _AppliedJobsState extends State<AppliedJobs> {
  late Future<List<JobDetail>> jobDetails;

  @override
  void initState() {
    super.initState();
    jobDetails = fetchJobs();
  }

  Future<List<JobDetail>> fetchJobs() async {
    List<JobDetail> _allJobs;
    final response = await http.get(Uri.parse(
        '$backend_api/profile/get/appliedJobs?email=${widget.jobSeeker.email}'));

    if (response.statusCode == 200) {
      _allJobs = (json.decode(response.body) as List)
          .map((e) => JobDetail.fromJson(e))
          .toList();
      return _allJobs;
    } else {
      throw Exception('Failed to load album');
    }
  }

  List<Widget> getJobList(List<JobDetail>? _jobDetails) {
    List<Widget> jobs = List.generate(0, (index) => Text('$index'));
    if (_jobDetails != null) {
      for (var x in _jobDetails) {
        jobs.add(InkWell(
            onTap: () {
              Route route = MaterialPageRoute(
                  builder: (context) => Scaffold(
                        body: JobPage(
                          jobDetail: x,
                          jobSeekerDetails: widget.jobSeeker,
                          applied: true,
                        ),
                      ));
              Navigator.push(context, route);
            },
            child: JobListItem(x, true, false)));
      }
    }

    return jobs;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Applied",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ))),
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder<List<JobDetail>>(
                future: jobDetails,
                builder: (BuildContext context,
                    AsyncSnapshot<List<JobDetail>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [...getJobList(snapshot.data)],
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  // By default, show a loading spinner.
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(child: CircularProgressIndicator()),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
