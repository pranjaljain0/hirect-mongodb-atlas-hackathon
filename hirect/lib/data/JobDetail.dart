class JobDetail {
  final jobTitle;
  final jobTags;
  final jobSalery;
  final jobPostOwner;
  final jobLocation;
  final jobUrl;
  final jobPostOwnerEmail;
  final sponsored;
  final description;
  final status;
  final jobID;

  JobDetail(
      {required this.jobTitle,
      required this.jobSalery,
      required this.jobTags,
      required this.jobLocation,
      required this.jobPostOwner,
      required this.jobUrl,
      required this.jobPostOwnerEmail,
      required this.sponsored,
      required this.description,
      required this.jobID,
      this.status});

  factory JobDetail.fromJson(Map<String, dynamic> json) {
    return JobDetail(
        jobTitle: json["jobTitle"],
        jobSalery: json["jobSalery"],
        jobTags: json["jobTags"],
        jobLocation: json["jobLocation"],
        jobPostOwner: json["jobPostOwner"],
        jobPostOwnerEmail: json["jobPostOwnerEmail"],
        jobUrl: json["jobUrl"],
        sponsored: json["sponsored"],
        description: json["description"],
        status: json["status"],
        jobID: json["jobID"]);
  }

  Map toJson() {
    return {
      "jobTitle": jobTitle,
      "jobTags": jobTags,
      "jobSalery": jobSalery,
      "jobPostOwner": jobPostOwner,
      "jobLocation": jobLocation,
      "jobUrl": jobUrl,
      "jobPostOwnerEmail": jobPostOwnerEmail,
      "sponsored": sponsored,
      "description": description,
      "jobID": jobID,
    };
  }
}
