import 'package:flutter/material.dart';
import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/JobProvider/Home/Home.dart';
import 'package:hirectt/screens/JobSeeker/Home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hirectt/Contants/Constants.dart';

getLocalAuth() async {
  final auth = await SharedPreferences.getInstance();
  String? authData = auth.getString("auth");
  var authJson = json.decode(authData!);
  return authJson;
}

setAuth(authJson) async {
  final auth = await SharedPreferences.getInstance();
  auth.setString("auth", json.encode(authJson));
}

updateLocalAuth() async {
  final auth = await SharedPreferences.getInstance();
  var authJson = await getLocalAuth();
  await http
      .get(Uri.parse(
          '$backend_api/auth/login?email=${authJson["email"]}&password=${authJson["password"]}'))
      .then((value) =>
          {auth.setString("auth", json.encode(json.decode(value.body)[0]))});

  //
}
