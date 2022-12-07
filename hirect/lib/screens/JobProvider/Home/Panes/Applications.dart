import 'dart:convert';
import 'dart:io';
import 'package:hirectt/Contants/Constants.dart';
import 'package:flutter/material.dart';
import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/JobProvider/SeekerProfile/SeekerProfile.dart';
import 'package:hirectt/widgets/ApplicantListItem.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class Applications extends StatefulWidget {
  final JobProviderDetails details;
  const Applications({Key? key, required this.details}) : super(key: key);

  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  late Future<Map<String, dynamic>> apps;

  @override
  void initState() {
    super.initState();

    apps = sortApplicants();
  }

  Future<Map<String, dynamic>> sortApplicants() async {
    final response = await http
        .get(Uri.parse('$backend_api/jobs/sorted/${widget.details.email}'));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load album');
    }
    // /jobs/sorted/
  }

  List<Widget> getApplicantList(Map<String, dynamic>? _list) {
    List<Widget> applicants = List.generate(0, (index) => Text('$index'));
    if (_list != null) {
      for (var key in _list.keys) {
        applicants.add(
          Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.lightBlue,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      key,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  PopupMenuButton(
                      itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text("Export as CSV"),
                              value: 1,
                              onTap: () async {
                                List<List<String>> data = [];
                                String csvData =
                                    const ListToCsvConverter().convert(data);
                                final String directory =
                                    (await getApplicationSupportDirectory())
                                        .path;
                                final path =
                                    "$directory/csv-${DateTime.now()}.csv";
                                final File file = File(path);
                                await file.writeAsString(csvData).then(
                                    (value) => ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text("Exporting"),
                                        )));
                              },
                            ),
                          ])
                ],
              )),
        );
        var val = Map<String, dynamic>.from(_list[key]);
        var jobID = val["jobID"];
        var applications = val["applications"];
        for (var val in applications) {
          JobSeekerDetails jobSeekerDetails = JobSeekerDetails.fromJson(val);
          applicants.add(ApplicantListItem(jobSeekerDetails, () async {
            final response = await http.get(Uri.parse(
                '$backend_api/profile/get/email?email=${jobSeekerDetails.email}'));
            if (response.statusCode == 200) {
              var jobSeekerJson = json.decode(response.body)[0];
              if (jobSeekerJson["accountType"] == 1) {
                JobSeekerDetails jobSeeker =
                    JobSeekerDetails.fromJson(jobSeekerJson);
                Route route = MaterialPageRoute(
                    builder: (context) => SeekerProfile(
                          jobProviderDetails: widget.details,
                          jobSeekerDetails: jobSeeker,
                          applicantEmail: jobSeeker.email,
                          jobID: jobID,
                        ));
                Navigator.push(context, route);
              }
            }
          }));
        }
      }
      return applicants;
    }

    return applicants;
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
                "Applications",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ))),
        Expanded(
          child: SingleChildScrollView(
            // Future<Map<String, dynamic>>
            child: FutureBuilder<Map<String, dynamic>>(
              future: apps,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [...getApplicantList(snapshot.data)],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

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
    ));
  }
}
