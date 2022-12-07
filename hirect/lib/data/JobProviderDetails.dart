import 'package:hirectt/screens/JobProvider/Home/Panes/Applications.dart';

class JobProviderDetails {
  final email;
  final fullName;
  final accountType;
  final password;
  final companyName;
  final jobPosts;
  final upVotes;
  final downVotes;
  final reviews;
  final applications;
  final chatToken;

  JobProviderDetails(
      {required this.email,
      required this.fullName,
      required this.accountType,
      required this.password,
      required this.jobPosts,
      required this.companyName,
      required this.upVotes,
      required this.downVotes,
      required this.reviews,
      required this.applications,
      required this.chatToken});

  factory JobProviderDetails.fromJson(Map<String, dynamic> json) {
    return JobProviderDetails(
        accountType: json["accountType"],
        email: json["email"],
        password: json["password"],
        fullName: json['fullName'],
        jobPosts: json["jobPosts"],
        companyName: json["companyName"],
        upVotes: json["upVotes"],
        downVotes: json["downVotes"],
        reviews: json["reviews"],
        applications: json["applications"],
        chatToken: json["chatToken"]);
  }
}
