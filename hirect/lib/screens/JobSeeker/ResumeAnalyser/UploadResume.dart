import 'dart:convert';
import 'package:filesize/filesize.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
import 'package:hirectt/screens/JobSeeker/ResumeAnalyser/ResumeResult.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hirectt/Contants/Constants.dart';

class UploadResume extends StatefulWidget {
  final JobSeekerDetails? jobSeekerDetails;
  const UploadResume({Key? key, this.jobSeekerDetails}) : super(key: key);

  @override
  State<UploadResume> createState() => _UploadResumeState();
}

class _UploadResumeState extends State<UploadResume> {
  var data;
  bool loader = false;
  bool _error_show = false;
  String _error_message = "";
  bool uploadStatus = false;
  String? uploadedResume;
  bool showScore = false;

  Future fetchUploadedResume() async {
    var response = await http.get(Uri.parse(
        '$backend_api/profile/get/email?email=${widget.jobSeekerDetails?.email}'));
    if (response.statusCode == 200) {
      if (json.decode(response.body)[0]['resume'] != null) {
        setState(() {
          uploadedResume = json.decode(response.body)[0]['resume']["name"];
        });
      }
      return JobSeekerDetails.fromJson(json.decode(response.body)[0]);
    }
  }

  void uploadResume(String filepath, String url, String filename) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['email'] = widget.jobSeekerDetails?.email;
    request.files.add(await http.MultipartFile.fromPath(
      "resume",
      filepath,
      filename: filename,
    ));

    await request.send().then((result) {
      if (result.statusCode == 200) {
        http.Response.fromStream(result).then((response) {
          if (response.statusCode == 200) {
            print(response.body);
            setState(() {
              uploadStatus = true;
            });
          }
        }).catchError((err) {
          setState(() {
            loader = false;
          });
        });
      } else {
        setState(() {
          _error_show = true;
          _error_message = "Error with parsing your resume";
          loader = false;
        });
      }
    });
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      data = {
        "name": result.files.first.name,
        "size": result.files.first.size,
        "path": result.files.first.path,
      };
    });
    uploadResume(
        data["path"], '$backend_api/helper/resumeParser', data["name"]);
  }

  @override
  void initState() {
    data = null;
    fetchUploadedResume();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                    "Upload Resume",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ))),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("Upload Resume"),
            ),
            uploadStatus
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.upload,
                            color: Colors.green,
                          ),
                          const Text(
                            "Uploaded",
                            style: TextStyle(color: Colors.green),
                          )
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        _pickFile();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.upload),
                            Text("Click to upload")
                          ],
                        ),
                      ),
                    ),
                  ),
            if (data != null)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text("Selected File"),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (data != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(data["name"]),
                  ),
                if (data != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(filesize(data["size"])),
                  ),
              ],
            ),
            if (data != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showScore = true;
                      });
                    },
                    child: loader
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("Analyse")),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Uploaded Resume"),
                    ),
                    if (uploadedResume != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(uploadedResume!),
                      ),
                    if (uploadedResume == null)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("No Resume Uploaded"),
                      ),
                  ],
                ),
              ),
            ),
            if (showScore)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text("Your Resume Score is 57"),
              ),
            if (_error_show == true)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  _error_message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
