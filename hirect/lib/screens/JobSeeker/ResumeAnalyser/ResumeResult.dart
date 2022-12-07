import 'package:flutter/material.dart';

class ResumeResults extends StatefulWidget {
  final resumeData;
  const ResumeResults(this.resumeData);

  @override
  State<ResumeResults> createState() => _ResumeResultsState();
}

class _ResumeResultsState extends State<ResumeResults> {
  @override
  Widget build(BuildContext context) {
    print(widget.resumeData["resume"]["data"]["name"]["raw"]);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("Resume Results"),
            ),
          ],
        ),
      ),
    );
  }
}
