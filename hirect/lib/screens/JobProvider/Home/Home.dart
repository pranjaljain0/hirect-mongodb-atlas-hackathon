import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hirectt/data/Handler.dart';
import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:hirectt/screens/Chat/AllChats.dart';
import 'package:hirectt/screens/JobProvider/Home/NewJob.dart';
import 'package:hirectt/screens/JobProvider/Home/Panes/Applications.dart';
import 'package:hirectt/screens/JobProvider/Home/Panes/JobPostings.dart';
import 'package:hirectt/screens/JobProvider/Home/Panes/Profile.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class JobProviderHome extends StatefulWidget {
  final JobProviderDetails? jobProvider;
  const JobProviderHome({Key? key, this.jobProvider}) : super(key: key);

  @override
  State<JobProviderHome> createState() => _JobProviderHomeState();
}

class _JobProviderHomeState extends State<JobProviderHome> {
  int pageIndex = 0;

  Future getAuth() async {
    var auth = await getLocalAuth();
    return json.encode(auth);
  }

  @override
  Widget build(BuildContext context) {
    var pages = [
      FutureBuilder(
          future: getAuth(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return JobPostings(
                  jobProviderDetails: JobProviderDetails.fromJson(
                      json.decode(snapshot.data.toString())));
            } else {
              return const CircularProgressIndicator();
            }
          })),
      FutureBuilder(
          future: getAuth(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return Applications(
                  details: JobProviderDetails.fromJson(
                      json.decode(snapshot.data.toString())));
            } else {
              return const CircularProgressIndicator();
            }
          })),
      FutureBuilder(
          future: getAuth(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return Profile(
                  jobProviderDetails: JobProviderDetails.fromJson(
                      json.decode(snapshot.data.toString())));
            } else {
              return const CircularProgressIndicator();
            }
          })),
    ];

    return Scaffold(
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NewJob(jobProvider: widget.jobProvider)));
            },
            icon: const Icon(Icons.add),
          ),
          ActionButton(
              onPressed: () async {
                StreamChatClient? client = StreamChatClient(
                  'try43se9tyqm',
                  logLevel: Level.INFO,
                );

                await client.connectUser(
                  User(id: widget.jobProvider?.fullName),
                  widget.jobProvider?.chatToken,
                );

                print(widget.jobProvider?.chatToken);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AllChats(
                              jobProviderDetails: widget.jobProvider,
                              client: client,
                            )));
              },
              icon: const Icon(Icons.message)),
        ],
      ),
      bottomNavigationBar: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  updateLocalAuth();
                  setState(() {
                    pageIndex = 0;
                  });
                },
                icon: pageIndex == 0
                    ? const Icon(
                        Icons.work,
                        color: Colors.white,
                        size: 35,
                      )
                    : const Icon(
                        Icons.work_outline,
                        color: Colors.white,
                        size: 35,
                      ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  updateLocalAuth();
                  setState(() {
                    pageIndex = 1;
                  });
                },
                icon: pageIndex == 1
                    ? const Icon(
                        Icons.checklist,
                        color: Colors.white,
                        size: 35,
                      )
                    : const Icon(
                        Icons.checklist_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  updateLocalAuth();
                  setState(() {
                    pageIndex = 2;
                  });
                },
                icon: pageIndex == 2
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 35,
                      )
                    : const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 35,
                      ),
              ),
            ],
          )),
      body: pages[pageIndex],
    );
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    Key? key,
    this.initialOpen,
    required this.distance,
    required this.children,
  }) : super(key: key);

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.menu),
            backgroundColor: Colors.green,
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    Key? key,
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  }) : super(key: key);

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: Colors.green,
      elevation: 4.0,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: Colors.white,
      ),
    );
  }
}
