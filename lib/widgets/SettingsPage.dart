import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../util/settings.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    DateFormat df = settings['H24'] ? DateFormat.Hm() : DateFormat.jm();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Settings"),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              "24 Hour Format",
            ),
            subtitle: Text(df.format(DateTime.now())),
            trailing: Switch(
              onChanged: (value) {
                setState(() {
                  settings['H24'] = !settings['H24'];
                });
              },
              value: settings['H24'],
            ),
          )
        ],
      ),
    );
  }
}
