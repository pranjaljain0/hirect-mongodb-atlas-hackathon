import 'package:flutter/material.dart';
import 'dart:math';
import 'package:hirectt/data/Handler.dart';
import 'package:hirectt/data/JobDetail.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:hirectt/Contants/Constants.dart';
import 'package:timelines/timelines.dart';

class JobPage extends StatefulWidget {
  final JobDetail? jobDetail;
  final JobSeekerDetails? jobSeekerDetails;
  final bool? applied;
  const JobPage({Key? key, this.jobDetail, this.jobSeekerDetails, this.applied})
      : super(key: key);

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  var upVotes;
  var downVotes;
  var _reviews = [];
  var _reviewMessage;
  var _processIndex = 0;

  @override
  void initState() {
    super.initState();
    getReviews();
    upVotes = fetchUpVoteCount(widget.jobDetail?.jobPostOwnerEmail);
    downVotes = fetchDownVoteCount(widget.jobDetail?.jobPostOwnerEmail);
    _reviewMessage = "";
    if (widget.jobDetail?.status != null) {
      _processIndex = int.parse(widget.jobDetail?.status);
    }
  }

  getReviews() async {
    final response = await http.get(Uri.parse(
        '$backend_api/profile/reviews/${widget.jobDetail?.jobPostOwnerEmail}'));
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      setState(() {
        _reviews = json.decode(response.body)["reviews"];
      });
      print(_reviews);
    }
  }

  getMissingSkills() {
    var list = [
      'AWS',
      'Masters',
      'REST',
      'SQL',
      'Java',
      'Linux',
      'Scripting',
      'Agile',
      'OS',
    ];
    final _random = new Random();
    var element = list[_random.nextInt(list.length)];
    return element;
  }

  postReview() async {
    await http.post(Uri.parse('$backend_api/profile/review/post'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{
          'email': widget.jobDetail?.jobPostOwnerEmail,
          'review': {
            'name': widget.jobSeekerDetails?.fullName,
            "message": _reviewMessage
          },
        }));
  }

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
    await http
        .post(Uri.parse('$backend_api/profile/add/savedJobs/'),
            headers: <String, String>{
              "Accept": "application/json",
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<String, dynamic>{
              'email': _email,
              'jobDetail': _jobDetail,
            }))
        .then((value) => Navigator.of(context).pop(true));
    updateLocalAuth();
  }

  appliedJobHandler(_email, _jobDetail, _userDetails) async {
    await http
        .post(Uri.parse('$backend_api/profile/add/appliedJobs/'),
            headers: <String, String>{
              "Accept": "application/json",
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<String, dynamic>{
              'email': _email,
              'jobDetail': _jobDetail,
              "userDetails": _userDetails,
            }))
        .then((value) => Navigator.of(context).pop(true));
    updateLocalAuth();
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<Widget> getTags(_tags) {
    List<Widget> tags = [];
    for (var x in _tags) {
      tags.add(Chip(label: Text(x)));
    }
    return tags;
  }

  int random(min, max) {
    print({min, max});
    return min + Random().nextInt(max - min);
  }

  String getStartSalery(sal) {
    var __sal = sal.replaceAll(',', '');
    var _sal = int.parse(__sal);
    return random((_sal - .30 * _sal).toInt(), (_sal + .30 * _sal).toInt())
            .toString() +
        " \$";
  }

  String getEndSalery(sal) {
    var __sal = sal.replaceAll(',', '');
    var _sal = int.parse(__sal);
    return random((_sal - (.30 * _sal)).toInt(), (_sal + (.30 * _sal)).toInt())
            .toString() +
        " \$";
  }

  @override
  Widget build(BuildContext context) {
    var _processes = ["Applied", "In Process", "Job Offered"];
    const completeColor = Color(0xff5e6172);
    const inProgressColor = Color(0xff5ec792);
    const todoColor = Color(0xffd1d2d7);

    Color getColor(int index) {
      if (index == _processIndex) {
        return inProgressColor;
      } else if (index < _processIndex) {
        return completeColor;
      } else {
        return todoColor;
      }
    }

    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.blueAccent),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Text(
                widget.jobDetail?.jobTitle,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(widget.jobDetail?.jobSalery),
                            Text(widget.jobDetail?.jobLocation),
                          ],
                        ),
                        Wrap(
                          spacing: 2.0,
                          runSpacing: 0.0,
                          children: List<Widget>.generate(
                              widget.jobDetail?.jobTags.length, (int index) {
                            return Chip(
                              label: Text(widget.jobDetail?.jobTags[index]),
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(widget.jobDetail?.description),
                        ),
                        Chip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.white70,
                              child: Text(widget.jobDetail?.jobPostOwner[0]
                                  .toUpperCase()),
                            ),
                            label: Text(widget.jobDetail?.jobPostOwner)),
                      ],
                    ),
                  ),
                  if (widget.applied == true)
                    const Center(
                      child: Text("Status"),
                    ),
                  if (widget.applied == true)
                    SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: Timeline.tileBuilder(
                        theme: TimelineThemeData(
                          direction: Axis.horizontal,
                          connectorTheme: const ConnectorThemeData(
                            space: 30.0,
                            thickness: 5.0,
                          ),
                        ),
                        builder: TimelineTileBuilder.connected(
                          connectionDirection: ConnectionDirection.before,
                          itemExtentBuilder: (_, __) =>
                              MediaQuery.of(context).size.width /
                              _processes.length,
                          contentsBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                _processes[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: getColor(index),
                                ),
                              ),
                            );
                          },
                          indicatorBuilder: (_, index) {
                            var color;
                            var child;
                            if (index == _processIndex) {
                              color = inProgressColor;
                              child = const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                  value: 100,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              );
                            } else if (index < _processIndex) {
                              color = completeColor;
                              child = const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 15.0,
                              );
                            } else {
                              color = todoColor;
                            }

                            if (index <= _processIndex) {
                              return Stack(
                                children: [
                                  CustomPaint(
                                    size: const Size(30.0, 30.0),
                                    painter: _BezierPainter(
                                      color: color,
                                      drawStart: index > 0,
                                      drawEnd: index < _processIndex,
                                    ),
                                  ),
                                  DotIndicator(
                                    size: 30.0,
                                    color: color,
                                    child: child,
                                  ),
                                ],
                              );
                            } else {
                              return Stack(
                                children: [
                                  CustomPaint(
                                    size: const Size(15.0, 15.0),
                                    painter: _BezierPainter(
                                      color: color,
                                      drawEnd: index < _processes.length - 1,
                                    ),
                                  ),
                                  OutlinedDotIndicator(
                                    borderWidth: 4.0,
                                    color: color,
                                  ),
                                ],
                              );
                            }
                          },
                          connectorBuilder: (_, index, type) {
                            if (index > 0) {
                              if (index == _processIndex) {
                                final prevColor = getColor(index - 1);
                                final color = getColor(index);
                                List<Color> gradientColors;
                                if (type == ConnectorType.start) {
                                  gradientColors = [
                                    Color.lerp(prevColor, color, 0.5)!,
                                    color
                                  ];
                                } else {
                                  gradientColors = [
                                    prevColor,
                                    Color.lerp(prevColor, color, 0.5)!
                                  ];
                                }
                                return DecoratedLineConnector(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                    ),
                                  ),
                                );
                              } else {
                                return SolidLineConnector(
                                  color: getColor(index),
                                );
                              }
                            } else {
                              return null;
                            }
                          },
                          itemCount: _processes.length,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Review Recruiter",
                          style: TextStyle(fontSize: 20),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: TextFormField(
                                onChanged: (text) {
                                  setState(() {
                                    _reviewMessage = text;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Review',
                                ),
                              ),
                            ),
                            Ink(
                              decoration: const ShapeDecoration(
                                color: Colors.blue,
                                shape: CircleBorder(),
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    postReview();
                                  },
                                  color: Colors.white,
                                  icon: const Icon(Icons.chevron_right)),
                            )
                          ],
                        ),
                        if (_reviews.isNotEmpty)
                          SizedBox(
                            height: 80,
                            child: Column(
                              children: List<Widget>.generate(_reviews.length,
                                  (int index) {
                                return Text(_reviews[index]);
                              }).toList(),
                            ),
                          )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Estimated Salery",
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              getStartSalery(widget.jobDetail?.jobSalery),
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Missing Skills",
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              '${getMissingSkills()}, ${getMissingSkills()}, ${getMissingSkills()}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Text("Rate Recruiter"),
                  Row(
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
                                              widget
                                                  .jobDetail?.jobPostOwnerEmail,
                                              snapshot.data);
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
                                const Center(
                                    child: CircularProgressIndicator()),
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
                                              widget
                                                  .jobDetail?.jobPostOwnerEmail,
                                              snapshot.data);
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
                                const Center(
                                    child: CircularProgressIndicator()),
                              ],
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                    onPressed: () {
                      saveJobHandler(widget.jobSeekerDetails?.email,
                          widget.jobDetail?.toJson());
                    },
                    child: const Text("Save")),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                    onPressed: () {
                      appliedJobHandler(widget.jobSeekerDetails?.email,
                          widget.jobDetail?.toJson(), widget.jobSeekerDetails);
                      _launchURL(widget.jobDetail?.jobUrl);
                    },
                    child: const Text("Apply")),
              )
            ],
          )
        ],
      )),
    );
  }
}

class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius, radius)
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(
            size.width, size.height / 2, size.width + radius, radius)
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
