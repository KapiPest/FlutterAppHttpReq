import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamController<double> temperatureStreamController =
      StreamController<double>();
  double temperatureValue = -1.0;

  @override
  void initState() {
    super.initState();

    // Start a periodic timer to fetch data every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      fetchDataFromAPI().then((result) {
        temperatureStreamController.sink.add(result);
      });
    });
  }

  @override
  void dispose() {
    // Close the stream when the widget is disposed
    temperatureStreamController.close();
    super.dispose();
  }

  Future<double> fetchDataFromAPI() async {
    final response =
        await http.get(Uri.parse('https://realm-admin.onrender.com/api/realm/alldata'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('JSON Response: $jsonResponse');

      final temperatureValue = jsonResponse[0]['temperature_value'];

      if (temperatureValue is int) {
        return temperatureValue.toDouble();
      } else if (temperatureValue is String) {
        return double.parse(temperatureValue);
      } else if (temperatureValue is double) {
        return temperatureValue;
      } else {
        throw Exception('Unexpected data type for temperature_value');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      throw Exception('Failed to load data from the API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature Value Example'),
      ),
      body: Center(
        child: StreamBuilder<double>(
          stream: temperatureStreamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                'Temperature Value: ${snapshot.data?.toStringAsFixed(1) ?? "N/A"}',
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
