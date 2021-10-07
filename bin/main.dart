import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';

import 'config.dart';
import 'package:http/http.dart' as http;

import 'model/station.dart';

import 'package:string_similarity/string_similarity.dart';

void main(List<String> arguments) async {
  // var stationsNames = await getStationsNames();
  // saveToFile('stations_names.json', stationsNames);

  // var stations = await getStationsFromWikipedia();
  // saveToFile('stations.json', stations);

  // var stationsNames = getStationsNamesFromFile();
  generateJavascriptMap();
}

void generateJavascriptMap() {
  var stations = getStationsFromFile();

  var map = 'const mapPriority = new Map([';

  stations.forEach((element) {
    map += '["${element.name}", ${element.priority}],\n';
  });

  map += '});';

  // print(stations);
  saveToJavascript('priorities.ts', map);
}

void saveToJavascript(String fileName, String object) {
  var file = File(fileName);
  file.writeAsStringSync(object);
}

void findMissingStation() {
  var stationsNames = getStationsNamesFromFile();

  var stations = getStationsFromFile();

  var oldStations = <String>[];

  stations.forEach((station) {
    if (!stationsNames.contains(station.name)) {
      oldStations.add(station.name);

      // var matchedName = station.name.bestMatch(stationsNames).bestMatch.target;

      // print('${station.name} - $matchedName');

      // var match = stdin.readLineSync();

      // if (match == 'y') {
      //   station.name = matchedName ?? station.name;
      // } else if (match == 'n') {
      //   notMatched++;
      // } else {
      //   print(notMatched);
      //   return;
      // }

      // saveToFile('stations.new.json', stations);
    }
  });

  print(oldStations.length);

  // saveToFile('stations.new.json', stations);
}

List<Station> getStationsFromFile() {
  var file = File('stations.new.json');
  var json = jsonDecode(file.readAsStringSync());
  var stations =
      (json as List).map((station) => Station.fromJson(station)).toList();
  return stations;
}

List<String> getStationsNamesFromFile() {
  var file = File('stations_names.json');
  var json = jsonDecode(file.readAsStringSync());
  var stationsNames =
      (json as List).map((station) => station.toString()).toList();
  return stationsNames;
}

void saveToFile(String fileName, var object) {
  var file = File(fileName);
  file.writeAsStringSync(jsonEncode(object));
}

Future<List<Station>> getStationsFromWikipedia() async {
  var stations = <Station>[];

  await Future.forEach(REGIONS, (String region) async {
    var url = Uri.parse(WIKIPEDIA_BASE_URL + region);

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var document = parse(response.body);
      print(document.getElementsByTagName('h1')[0].text);
      var table = document.getElementsByTagName('table')[0];
      var tableRows = table.getElementsByTagName('tr');
      tableRows.removeAt(0);
      tableRows.forEach((row) {
        stations.add(Station.fromElement(row));
      });
    }
  });
  return stations;
}

Future<List<String>> getStationsNames() async {
  var stations = <String>[];

  await Future.forEach(ALPHABET, (String letter) async {
    var url = Uri.parse(TRENINOO_BASE_URL + letter);

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var body = (jsonDecode(response.body))['stations'];

      var list = (body as List)
          .map((station) => station['stationName'].toString())
          .toList();

      stations.addAll(list);
    }
  });

  return stations;
}
