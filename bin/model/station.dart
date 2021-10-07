import 'package:html/dom.dart';

import '../config.dart';

class Station {
  late String name;
  late String category;
  late int priority;

  Station(this.name, this.category);

  Station.fromElement(Element e)
      : name = e
            .getElementsByTagName('a')[0]
            .text
            .toUpperCase()
            .replaceAll("'", '`')
            .replaceAll('-', ' ')
            .replaceAll('SAN ', 'S.'),
        category = e.getElementsByTagName('td')[3].text.replaceAll('\n', '');

  Station.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        category = json['category'],
        priority = CATEGORIES[json['category']] ?? 0;

  // Station.fromElement(Element e) {
  //   var name = e.getElementsByTagName('a')[0].text;
  //   var category = e.getElementsByTagName('td')[3].text;
  //   return new Station(name, category);
  // }

  Map<String, dynamic> toJson() =>
      {'name': name, 'category': category, 'priority': priority};
}
