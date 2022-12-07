import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hirectt/Contants/Constants.dart';
import 'package:hirectt/data/Handler.dart';

class ProfileListItem extends StatelessWidget {
  final data;
  final email;
  final title;
  final showIcon;
  const ProfileListItem(
      {Key? key, this.data, this.email, this.title, this.showIcon})
      : super(key: key);

  void handleDelete(_title, _email, _data) async {
    final response = await http.post(
        Uri.parse('$backend_api/profile/remove/$_title/$_email'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, dynamic>{'data': _data}));
    if (response.statusCode == 200) {
      updateLocalAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = this.data;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 280,
              child: Text(
                data['name'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Text(data['start'] + "-" + data['end'])
          ],
        ),
        if (showIcon == true)
          IconButton(
              onPressed: () {
                handleDelete(title, email, data);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 20,
              ))
      ],
    );
  }
}
