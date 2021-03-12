# Duration Picker for flutter

Fork from flutter_duration_picker. https://github.com/cdharris/flutter_duration_picker

A little widget for picking durations. Heavily inspired from the Material Design time picker widget.

<img src="https://raw.githubusercontent.com/juliansteenbakker/duration_picker/master/example.gif" height="480px" >

## Example Usage:

```yaml
dependencies:
  duration_picker: "^1.0.0"
```

```dart
import 'package:flutter/material.dart';
import 'package:duration_picker/duration_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duration Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Duration Picker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Duration _duration = Duration(hours: 0, minutes: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: DurationPicker(
              duration: _duration,
              onChange: (val) {
                setState(() => _duration = val);
              },
              snapToMins: 5.0,
            ))
          ],
        ),
      ),
      floatingActionButton: Builder(
          builder: (BuildContext context) => FloatingActionButton(
                onPressed: () async {
                  var resultingDuration = await showDurationPicker(
                    context: context,
                    initialTime: Duration(minutes: 30),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Chose duration: $resultingDuration')));
                },
                tooltip: 'Popup Duration Picker',
                child: Icon(Icons.add),
              )),
    );
  }
}

```

