import 'dart:convert';

import 'package:intl/intl.dart';

class Secret {
  String title;
  String share;
  DateTime date;

  Secret({this.title, this.share, this.date});

  String get formatedDate => DateFormat("dd/MM/y H:mm").format(date);

  Secret.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        share = json['share'],
        date = DateFormat("dd/MM/y H:mm").parse(json['date']);

  Map<String, dynamic> toJson() => {
        'title': title,
        'share': share,
        'date': formatedDate,
      };

  String toString() {
    return "Title : $title, Share : $share, Date : $formatedDate";
  }
}
