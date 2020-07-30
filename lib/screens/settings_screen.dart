import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/settings.dart';

class SettingsScreen extends StatelessWidget {
  static const ROUTE_NAME = '/settings';

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    DateFormat df = settings.timeFormat ? DateFormat.Hm() : DateFormat.jm();
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
              onChanged: (value) => settings.toggleTimeFormat(value),
              value: settings.timeFormat,
            ),
          )
        ],
      ),
    );
  }
}
