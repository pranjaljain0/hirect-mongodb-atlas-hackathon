import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hirectt/Contants/Constants.dart';
import 'package:hirectt/data/Handler.dart';
import 'package:hirectt/data/JobDetail.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/JobSeeker/Home/JobPage.dart';
import 'package:hirectt/widgets/JobListItem.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:us_states/us_states.dart';

class AllJobs extends StatefulWidget {
  final JobSeekerDetails? jobSeeker;
  const AllJobs({Key? key, this.jobSeeker}) : super(key: key);

  @override
  State<AllJobs> createState() => _AllJobsState();
}

class _AllJobsState extends State<AllJobs> {
  late Future<List<JobDetail>> jobDetails;
  dynamic voteCount = {};
  Map<dynamic, dynamic> filter = {
    "location": "All",
    "orderBy": false,
    "tags": []
  };
  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.jobSeeker?.preferences != null) {
      if (widget.jobSeeker?.preferences.length != 0) {
        filter = {
          ...filter,
          "location": widget.jobSeeker?.preferences["location"],
          "tags": widget.jobSeeker?.preferences["tags"]
        };
      }
    }
    jobDetails = fetchJobs();
  }

  Future<List<JobDetail>> fetchJobs() async {
    List<JobDetail> _allJobs;
    final response = await http.get(Uri.parse('$backend_api/jobs/all'));
    if (response.statusCode == 200) {
      _allJobs = (json.decode(response.body) as List)
          .map((e) => JobDetail.fromJson(e))
          .toList();
      return _allJobs;
    } else {
      throw Exception('Failed to load Jobs');
    }
  }

  void setFilter(filterJson) {
    setState(() {
      filter = filterJson;
    });
  }

  bool checkApplied(JobDetail _job) {
    for (var x in widget.jobSeeker?.appliedJobs) {
      if (_job.jobPostOwnerEmail == x["jobPostOwnerEmail"] &&
          _job.jobTitle == x["jobTitle"] &&
          _job.jobLocation == x["jobLocation"]) return true;
    }
    return false;
  }

  bool checkSaved(JobDetail _job) {
    for (var x in widget.jobSeeker?.savedJobs) {
      if (_job.jobPostOwnerEmail == x["jobPostOwnerEmail"] &&
          _job.jobTitle == x["jobTitle"] &&
          _job.jobLocation == x["jobLocation"]) return true;
    }
    return false;
  }

  List<Widget> getJobList(List<JobDetail>? _jobDetails, showStatus) {
    List<Widget> jobs = List.generate(0, (index) => Text('$index'));

    getVal(str) {
      return NumberFormat().parse(str);
    }

    _jobDetails?.sort((a, b) {
      if (filter["orderBy"] == "True") {
        if (getVal(a.jobSalery) > getVal(b.jobSalery)) return -1;
        if (getVal(a.jobSalery) < getVal(b.jobSalery)) return 1;
      } else if (filter["orderBy"] == 'False') {
        if (getVal(a.jobSalery) > getVal(b.jobSalery)) return 1;
        if (getVal(a.jobSalery) < getVal(b.jobSalery)) return -1;
      } else {
        if (a.sponsored) return -1;
        if (!a.sponsored) return 1;
      }

      return 0;
    });

    void addTagToArray(tagArray) {
      for (var item in tagArray) {
        tags.firstWhere((element) => element == item, orElse: () {
          tags.add(item);
          return item;
        });
        // tags.i
      }
    }

    if (_jobDetails != null) {
      for (var x in _jobDetails) {
        addTagToArray(x.jobTags);
        if (showStatus == 0) {
          jobs.add(InkWell(
            onTap: () {
              Route route = MaterialPageRoute(
                  builder: (context) => Scaffold(
                        body: JobPage(
                          jobDetail: x,
                          jobSeekerDetails: widget.jobSeeker,
                        ),
                      ));
              Navigator.push(context, route);
            },
            child: JobListItem(x, checkApplied(x), checkSaved(x)),
          ));
        } else {
          if (filter["location"] == "All") {
            if (filter["tags"].length > 0) {
              for (var _tag in x.jobTags) {
                if (filter["tags"].contains(_tag)) {
                  jobs.add(InkWell(
                    onTap: () {
                      Route route = MaterialPageRoute(
                          builder: (context) => Scaffold(
                                body: JobPage(
                                  jobDetail: x,
                                  jobSeekerDetails: widget.jobSeeker,
                                  applied: checkApplied(x),
                                ),
                              ));
                      Navigator.push(context, route);
                    },
                    child: JobListItem(x, checkApplied(x), checkSaved(x)),
                  ));
                }
              }
            } else {
              jobs.add(InkWell(
                onTap: () {
                  Route route = MaterialPageRoute(
                      builder: (context) => Scaffold(
                            body: JobPage(
                              jobDetail: x,
                              jobSeekerDetails: widget.jobSeeker,
                            ),
                          ));
                  Navigator.push(context, route);
                },
                child: JobListItem(x, checkApplied(x), checkSaved(x)),
              ));
            }
          } else if (x.jobLocation == filter["location"]) {
            if (filter["tags"].length > 0) {
              for (var _tag in x.jobTags) {
                if (filter["tags"].contains(_tag)) {
                  jobs.add(InkWell(
                    onTap: () {
                      Route route = MaterialPageRoute(
                          builder: (context) => Scaffold(
                                body: JobPage(
                                  jobDetail: x,
                                  jobSeekerDetails: widget.jobSeeker,
                                ),
                              ));
                      Navigator.push(context, route);
                    },
                    child: JobListItem(x, checkApplied(x), checkSaved(x)),
                  ));
                }
              }
            } else {
              jobs.add(InkWell(
                onTap: () {
                  Route route = MaterialPageRoute(
                      builder: (context) => Scaffold(
                            body: JobPage(
                              jobDetail: x,
                              jobSeekerDetails: widget.jobSeeker,
                            ),
                          ));
                  Navigator.push(context, route);
                },
                child: JobListItem(x, checkApplied(x), checkSaved(x)),
              ));
            }
          }
        }
      }
    }

    return jobs;
  }

  var matchJobs = false;

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
                  "All Jobs",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ))),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.blue[200]),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        showFilterDialog(context, filter, setFilter, tags);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Text(
                              "Filters",
                            )),
                      ),
                    ),
                  ),
                  matchJobs == false
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                matchJobs = true;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    "Match jobs using AI",
                                  )),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                matchJobs = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    "Match jobs using AI",
                                    style: TextStyle(color: Colors.black),
                                  )),
                            ),
                          ),
                        ),
                ],
              ),
            )),
          ),
          matchJobs
              ? Expanded(
                  child: SingleChildScrollView(
                    child: FutureBuilder<List<JobDetail>>(
                      future: jobDetails,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<JobDetail>> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [...getJobList(snapshot.data, 0)],
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
              : Expanded(
                  child: SingleChildScrollView(
                    child: FutureBuilder<List<JobDetail>>(
                      future: jobDetails,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<JobDetail>> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [...getJobList(snapshot.data, 1)],
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
      ),
    );
  }
}

showAlertDialog(
    BuildContext context, String _email, JobDetail _jobDetail, _userDetails) {
  Future<int> fetchUpVoteCount(email) async {
    final response = await http
        .get(Uri.parse('$backend_api/profile/votecount?email=$email'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['upVotes'];
    }
    return 0;
  }

  Future<int> fetchDownVoteCount(email) async {
    final response = await http
        .get(Uri.parse('$backend_api/profile/votecount?email=$email'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['downVotes'];
    }
    return 0;
  }

  var upVotes = fetchUpVoteCount(_jobDetail.jobPostOwnerEmail);
  var downVotes = fetchDownVoteCount(_jobDetail.jobPostOwnerEmail);

  handleUpVote(email, _upVotes) async {
    await http.post(Uri.parse('$backend_api/profile/rate/up'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'email': email,
          'upvote': _upVotes,
        }));
  }

  handleDownVote(email, _downVotes) async {
    await http.post(Uri.parse('$backend_api/profile/rate/down'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'email': email,
          'downvote': _downVotes,
        }));
  }

  saveJobHandler(_email, _jobDetail) async {
    await http.post(Uri.parse('$backend_api/profile/add/savedJobs/'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'email': _email,
          'jobDetail': _jobDetail,
        }));
    updateLocalAuth();
  }

  appliedJobHandler(_email, _jobDetail, _userDetails) async {
    await http.post(Uri.parse('$backend_api/profile/add/appliedJobs/'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'email': _email,
          'jobDetail': _jobDetail,
          "userDetails": _userDetails,
        }));
    updateLocalAuth();
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );

  Widget rateRecruiter = Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      FutureBuilder(
          future: upVotes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                        onPressed: () {
                          handleUpVote(
                              _jobDetail.jobPostOwnerEmail, snapshot.data);
                        },
                        icon: const Icon(Icons.thumb_up)),
                  ),
                  Text(snapshot.data.toString())
                ],
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(child: CircularProgressIndicator()),
              ],
            );
          }),
      FutureBuilder(
          future: downVotes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                        onPressed: () {
                          handleDownVote(
                              _jobDetail.jobPostOwnerEmail, snapshot.data);
                        },
                        icon: const Icon(Icons.thumb_down)),
                  ),
                  Text(snapshot.data.toString())
                ],
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(child: CircularProgressIndicator()),
              ],
            );
          }),
    ],
  );

  Widget saveButton = TextButton(
    child: const Text("Save"),
    onPressed: () {
      saveJobHandler(_email, _jobDetail.toJson());
    },
  );

  Widget applyButton = TextButton(
    child: const Text("Apply"),
    onPressed: () {
      appliedJobHandler(_email, _jobDetail.toJson(), _userDetails);
      _launchURL(_jobDetail.jobUrl);
    },
  );

  AlertDialog alert = AlertDialog(
    title: const Text("Selected Job"),
    content: SizedBox(
      height: 230.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Job description"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(_jobDetail.description),
          ),
          const Text("Rate Recruiter"),
          rateRecruiter,
        ],
      ),
    ),
    actions: [
      cancelButton,
      saveButton,
      applyButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showFilterDialog(BuildContext context, filter, Function setFilter, _tags) {
  var stateList = ["All", ...USStates.getAllAbbreviations()];
  List selectedTags = filter["tags"];
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      setFilter({...filter, "tags": selectedTags});
      Navigator.of(context).pop(true);
    },
  );

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      List tags = _tags;
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text("Filters"),
          content: SizedBox(
            height: 250.0,
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Filters"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Text("Location"),
                    ),
                    DropdownButton<String>(
                      value: filter["location"],
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Colors.blueAccent),
                      underline: Container(
                        height: 2,
                        color: Colors.blueAccent,
                      ),
                      onChanged: (String? newValue) {
                        setFilter({...filter, "location": newValue});
                        Navigator.of(context).pop(true);
                      },
                      items: stateList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Order By"),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () {
                            setFilter({
                              ...filter,
                              "orderBy":
                                  filter["orderBy"] == "True" ? "False" : "True"
                            });
                            Navigator.of(context).pop(true);
                          },
                          // child: Text(filter["orderBy"]),
                          child: filter["orderBy"] == "True"
                              ? const Text("Salery High to Low")
                              : const Text("Salery Low to High")),
                    )
                  ],
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: ListView(
                    primary: true,
                    shrinkWrap: true,
                    children: <Widget>[
                      Wrap(
                        spacing: 2.0,
                        runSpacing: 0.0,
                        children:
                            List<Widget>.generate(tags.length, (int index) {
                          return !selectedTags.contains(tags[index])
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedTags.add(tags[index]);
                                    });
                                  },
                                  child: Chip(
                                    label: Text(tags[index]),
                                  ))
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedTags.add(tags[index]);
                                    });
                                  },
                                  child: Chip(
                                    backgroundColor: Colors.blueAccent,
                                    label: Text(tags[index]),
                                  ));
                        }).toList(),
                      ),
                    ],
                  ),
                ))
              ],
            ),
          ),
          actions: [
            cancelButton,
          ],
        );
      });
    },
  );
}
