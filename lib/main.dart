import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

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
  String? currentVersion;

  @override
  void initState() {
    super.initState();
    checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(versionUrl));

      if (response.statusCode != 200) {
        setState(() {
          title = 'Failed to check version: ${response.statusCode}';
          features = [];
          bannerUrl = null;
        });
        return;
      }

      final versionData = jsonDecode(response.body);
      final remoteVersion = versionData['version'];
      final layoutUrl = versionData['layout_url'];

      final info = await PackageInfo.fromPlatform();
      final appVersion = info.version;

      currentVersion = appVersion;

      if (remoteVersion != appVersion) {
        // New version available (remote is different)
        print('App version ($appVersion) is outdated. Latest is $remoteVersion');
        // You can show an update prompt here if needed
      }

      // Always fetch layout to reflect UI changes
      await fetchLayout(layoutUrl);
    } catch (e) {
      setState(() {
        title = "Error checking updates";
        features = [e.toString()];
        bannerUrl = null;
      });
    }
  }

  Future<void> fetchLayout(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final layout = jsonDecode(response.body);
        setState(() {
          title = layout['title'];
          features = List<String>.from(layout['features']);
          bannerUrl = layout['banner_url'];
        });
      } else {
        setState(() {
          title = 'Failed to load layout: ${response.statusCode}';
          features = [];
          bannerUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        title = 'Error loading layout';
        features = [e.toString()];
        bannerUrl = null;
      });
    }
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
              if (bannerUrl != null)
                Image.network(
                  '$bannerUrl?v=$currentVersion',
                  errorBuilder: (context, error, stackTrace) => Text('Failed to load image'),
                ),
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
