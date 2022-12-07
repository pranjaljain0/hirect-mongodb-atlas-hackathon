import 'package:flutter/foundation.dart';

class JobSeekerDetails {
  var email;
  var fullName;
  var accountType;
  var password;
  var education;
  var experience;
  var certifications;
  var savedJobs;
  var appliedJobs;
  var id;
  var summary;
  var preferences;
  var chatToken;

  JobSeekerDetails(
      {required this.id,
      required this.email,
      required this.fullName,
      required this.accountType,
      required this.password,
      required this.education,
      required this.experience,
      required this.certifications,
      required this.savedJobs,
      required this.appliedJobs,
      required this.summary,
      required this.preferences,
      required this.chatToken});

  factory JobSeekerDetails.fromJson(Map<String, dynamic> json) {
    return JobSeekerDetails(
        id: json['_id'],
        accountType: json["accountType"],
        email: json["email"],
        password: json["password"],
        fullName: json['fullName'],
        education: json["education"],
        experience: json["experience"],
        certifications: json["certifications"],
        savedJobs: json["savedJobs"],
        appliedJobs: json["appliedJobs"],
        summary: json['summary'],
        preferences: json["preferences"],
        chatToken: json["chatToken"]);
  }

  Map toJson() {
    return {
      "id": id,
      "accountType": accountType,
      "email": email,
      "password": password,
      "fullName": fullName,
      "education": education,
      "experience": experience,
      "certifications": certifications,
      "savedJobs": savedJobs,
      "appliedJobs": appliedJobs,
      "summary": summary,
      "preferences": preferences,
      "chatToken": chatToken
    };
  }
}
