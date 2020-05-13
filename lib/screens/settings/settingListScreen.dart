import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SettingListScreen extends StatefulWidget {
  final String title;
  final String itemName;
  final String settingKey;

  SettingListScreen(
      {@required this.settingKey,
      @required this.title,
      @required this.itemName});

  @override
  State<StatefulWidget> createState() => _SettingListScreenState();
}

class _SettingListScreenState extends State<SettingListScreen> {
  final SlidableController slidableController = SlidableController();

  List<String> items = [];
  bool fetchingItems = false;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future _fetchSettings() async {
    setState(() {
      fetchingItems = true;
    });

    var prefs = await SharedPreferences.getInstance();
    var fetchedItems = prefs.getStringList(widget.settingKey) ?? [];
    fetchedItems.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));

    setState(() {
      fetchingItems = false;
      items = fetchedItems ?? [];
    });
  }

  Widget _addButton() {
    if (fetchingItems) {
      return null;
    }
    return FloatingActionButton(
      onPressed: () async {
        var result = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text('Add ${widget.itemName}'),
                children: <Widget>[_AddItemForm()],
              );
            });

        if (result != null) {
          await _addItems(result);
        }
      },
      child: Icon(Icons.add),
      backgroundColor: Colors.green,
    );
  }

  Future _addItems(String itemName) async {
    if (!items.contains(itemName)) {
      setState(() {
        items.add(itemName);
        items.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));
      });

      var prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(widget.settingKey, items);
    }
  }

  Future _deleteItem(String itemName) async {
    setState(() {
      items.remove(itemName);
    });

    var prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(widget.settingKey, items);
  }

  Future<String> _openEditForm(String itemName) async {
    var result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Add ${widget.itemName}'),
            children: <Widget>[
              _AddItemForm(
                initialValue: itemName,
              )
            ],
          );
        });

    if (result != null) {
      await _editItem(itemName, result);
    }

    return result;
  }

  Future _editItem(String oldValue, String newValue) async {
    setState(() {
      items.remove(oldValue);
      items.add(newValue);

      items.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));
    });

    var prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(widget.settingKey, items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Builder(builder: (BuildContext context) {
          return ListView(
            children: items
                .map((filter) => Slidable(
                      controller: slidableController,
                      actionPane: SlidableDrawerActionPane(),
                      child: Container(
                        child: ListTile(
                          title: Text(filter),
                        ),
                      ),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'Edit',
                          color: Colors.blue,
                          icon: Icons.edit,
                          onTap: () async {
                            await _openEditForm(filter);

                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('${widget.itemName} deleted'),
                              duration: Duration(seconds: 2),
                            ));
                          },
                        ),
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () async {
                            await _deleteItem(filter);

                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('${widget.itemName} deleted'),
                              duration: Duration(seconds: 2),
                            ));
                          },
                        ),
                      ],
                    ))
                .toList(),
          );
        }),
        floatingActionButton: _addButton());
  }
}

class _AddItemForm extends StatefulWidget {
  final String initialValue;

  _AddItemForm({this.initialValue});

  @override
  State<StatefulWidget> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<_AddItemForm> {
  final _formKey = GlobalKey<FormState>();
  final formController = TextEditingController();

  @override
  void initState() {
    super.initState();
    formController.text = widget.initialValue;
  }

  @override
  void dispose() {
    formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: formController,
                autofocus: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a value.';
                  }

                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  FlatButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Navigator.pop(context, formController.text);
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
