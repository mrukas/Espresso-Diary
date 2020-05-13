import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    developer.log('Initialized Settings');
  }

  void _navigateToPage(String pageName) {
    Navigator.pushNamed(context, pageName);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Portafilters'),
          onTap: () => _navigateToPage('portafilters'),
        ),
        ListTile(
          title: Text('Beans'),
          onTap: () => _navigateToPage('beans'),
        )
      ],
    );
  }
}
