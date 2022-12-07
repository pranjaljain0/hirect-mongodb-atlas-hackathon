import 'package:flutter/material.dart';
import 'package:hirectt/data/JobDetail.dart';
import 'package:us_states/us_states.dart';

class JobListItem extends StatelessWidget {
  final JobDetail data;
  final bool applied;
  final bool saved;
  JobListItem(this.data, this.applied, this.saved);

  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = this.data;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 240,
                    child: Text(
                      data.jobTitle,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  if (data.sponsored == true)
                    const Chip(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        label: Text(
                          "S",
                          style: TextStyle(color: Colors.white),
                        ))
                ],
              ),
              Text('\$${data.jobSalery}')
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: <Widget>[
                  for (var item in data.jobTags) _buildChip(item)
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 300,
                      child: Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: Chip(
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.white70,
                                  child:
                                      Text(data.jobPostOwner[0].toUpperCase()),
                                ),
                                label: Text(data.jobPostOwner)),
                          ),
                          if (applied)
                            const Padding(
                                padding: EdgeInsets.all(2),
                                child: Chip(
                                  label: Text("Applied"),
                                  avatar: Icon(
                                    Icons.check_box_outlined,
                                    color: Colors.green,
                                  ),
                                )),
                          if (saved)
                            const Padding(
                                padding: EdgeInsets.all(2),
                                child: Chip(
                                  label: Text("Saved"),
                                  avatar: Icon(
                                    Icons.bookmark,
                                    color: Colors.orange,
                                  ),
                                ))
                        ],
                      ),
                    )),
                Text(
                  data.jobLocation,
                  style: const TextStyle(color: Color(0xff1d1d1d)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              height: 3,
              decoration: const BoxDecoration(color: Color(0xffdddddd)),
            ),
          )
        ],
      ),
    );
  }
}
