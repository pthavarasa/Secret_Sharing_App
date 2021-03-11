import 'package:intl/intl.dart';

class Secret {
  String title;
  String share;
  DateTime date;
  String type;

  Secret({this.title, this.share, this.date, this.type});

  String get formatedDate => DateFormat("dd/MM/y H:mm").format(date);

  Secret.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        share = json['share'],
        date = DateFormat("dd/MM/y H:mm").parse(json['date']),
        type = json['type'];

  Map<String, dynamic> toJson() =>
      {'title': title, 'share': share, 'date': formatedDate, 'type': type};

  String toString() {
    return "Title : $title, Share : $share, Date : $formatedDate, Type : $type";
  }
}
