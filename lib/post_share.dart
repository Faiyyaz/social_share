// To parse this JSON data, do
//
//     final postShare = postShareFromJson(jsonString);

import 'dart:convert';

PostShare postShareFromJson(String str) => PostShare.fromJson(json.decode(str));

String postShareToJson(PostShare data) => json.encode(data.toJson());

class PostShare {
  PostShare({
    this.phoneNumber,
    this.message,
    this.type,
  });

  String phoneNumber;
  String message;
  String type;

  factory PostShare.fromJson(Map<String, dynamic> json) => PostShare(
        phoneNumber: json["phoneNumber"],
        message: json["message"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "phoneNumber": phoneNumber,
        "message": message,
        "type": type,
      };
}
