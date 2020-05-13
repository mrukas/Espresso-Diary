import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Portafilters'),
          onTap: () => Navigator.pushNamed(context, 'portafilters'),
        ),
        ListTile(
          title: Text('Beans'),
          onTap: () => Navigator.pushNamed(context, 'beans'),
        )
      ],
    );
  }
}
