import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'database_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List to store fetched data
  List<dynamic> data = [];
  List mydata = [];

  Future<void> fetchDataFromDatabase() async {
    final dbHelper = DatabaseHelper();
    final rows = await dbHelper.getData();
    setState(() {
      mydata = rows;
    });
  }

  Future<void> onDeleteAllData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteAllData();
    // After deleting all data, you might want to refresh the UI or show a message.
    // For example:
    setState(() {
      data = []; // Clear the data list to reflect the changes in the UI.
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('All data deleted.'),
    ));
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();

    //fetchData(); // Fetch data when the app starts
  }

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse('https://smis.soco.gov.gh/pages/api/stafftry.php'));

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
      });

      final dbHelper = DatabaseHelper();
      for (final item in data) {
        final row = {
          'fname': item['fname'],
          'lname': item['lname'],
        };
        var senddata = await dbHelper.insertOrReplaceData(row);
        if (senddata == 1) {
          print("dd");
        } else {
          print(" eeror");
        }
      }
      // If the API call is successful, parse the response data
    } else {
      // If the API call fails, handle the error
      print('Failed to fetch data from the API.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.rectangle_outlined),
            onPressed: () {
              fetchDataFromDatabase();
            },
          ),
          IconButton(
            icon: const Icon(Icons.wifi_tethering_outlined),
            onPressed: () {
              fetchData();
              fetchDataFromDatabase();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDeleteAllData();
            },
          ),
        ],
        title: const Text('Online 2 offline'),
      ),
      body: Center(
        child: mydata.isEmpty
            ? const Text('No data in device')
            : ListView.builder(
                itemCount: mydata.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(mydata[index]['fname']),
                    subtitle: Text(mydata[index]['lname']),
                  );
                },
              ),
      ),
    );
  }
}
