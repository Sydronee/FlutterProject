import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

const versionUrl = 'https://raw.githubusercontent.com/Sydronee/FlutterProject/Dev/version.json';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String title = 'Checking for updates...';
  List<String> features = [];
  String? bannerUrl;

  @override
  void initState() {
    super.initState();
    checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(versionUrl));
      final versionData = jsonDecode(response.body);
      final remoteVersion = versionData['version'];
      final layoutUrl = versionData['layout_url'];

      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getString('version') ?? '0.0.0';

      if (remoteVersion != localVersion) {
        prefs.setString('version', remoteVersion);
        await fetchLayout(layoutUrl);
      } else {
        await fetchLayout(layoutUrl); // Still load layout
      }
    } catch (e) {
      setState(() {
        title = "Error checking updates";
        features = [e.toString()];
      });
    }
  }

  Future<void> fetchLayout(String url) async {
    final response = await http.get(Uri.parse(url));
    final layout = jsonDecode(response.body);
    setState(() {
      title = layout['title'];
      features = List<String>.from(layout['features']);
      bannerUrl = layout['banner_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Update Demo',
      home: Scaffold(
        appBar: AppBar(title: Text("Dynamic App")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (bannerUrl != null) Image.network(bannerUrl!),
              SizedBox(height: 20),
              Text(title, style: TextStyle(fontSize: 22)),
              SizedBox(height: 20),
              ...features.map((f) => Text("• $f")).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
