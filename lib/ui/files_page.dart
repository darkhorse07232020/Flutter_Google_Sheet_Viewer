import 'dart:ui';

import 'package:meena_supplies/authentication/auth_manager.dart';
import 'package:meena_supplies/other/my_client.dart';
import 'package:meena_supplies/ui/routing/router.dart';
import 'package:meena_supplies/ui/widgets/ripple_widget.dart';
import 'package:meena_supplies/ui/widgets/progress_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:kt_dart/collection.dart';
import 'package:kt_dart/kt.dart';
import 'package:intl/intl.dart';

class FilesPage extends StatefulWidget {
  FilesPage({Key key}) : super(key: key);

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  GoogleSignInAccount _currentUser;
  List<File> _items = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _signInSilently();
  }

  Future<void> _signInSilently() async {
    var account = await AuthManager.signInSilently();
    setState(() {
      _currentUser = account;
      if (account != null) {
        _loadFiles();
      } else {
        Navigator.pushReplacementNamed(context, AppRoute.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = _currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(loggedIn ? _currentUser.email : ''),
        actions: <Widget>[
          if (loggedIn)
            FlatButton(
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _logout();
              },
            )
        ],
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: (loggedIn && _loaded) ? _listView : _progressLoader,
          ),
        ),
      ),
    );
  }

  Widget get _progressLoader => Stack(
        children: <Widget>[
          Align(child: ProgressLoaderWidget(width: 50.0, height: 50.0)),
        ],
      );

  Widget get _listView {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: ListView.separated(
        itemBuilder: (context, index) {
          var item = _items[index];
          final formatter = DateFormat('hh:mm EEE, MMM d, yyyy');

          return Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.0, color: Colors.blue.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Colors.white.withOpacity(0.8),
            child: RippleWidget(
              radius: 8.0,
              onTap: () {
                var args = {Args.fileId: item.id};
                Navigator.pushNamed(context, AppRoute.document,
                    arguments: args);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            formatter.format(item.createdDate),
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          KtList.from(item.ownerNames).joinToString(),
                          style: TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 8.0);
        },
        itemCount: _items.length,
        padding: const EdgeInsets.all(8.0),
      ),
    );
  }

  Future<void> _loadFiles() async {
    if (_currentUser == null) return;

    GoogleSignInAuthentication authentication =
        await _currentUser.authentication;
    print('authentication: $authentication');
    final client = MyClient(defaultHeaders: {
      'Authorization': 'Bearer ${authentication.accessToken}'
    });
    DriveApi driveApi = DriveApi(client);
    var files = await driveApi.files
        .list(q: 'mimeType=\'application/vnd.google-apps.spreadsheet\'');
    setState(() {
      _items = files.items;
      _loaded = true;
    });
  }

  void _logout() async {
    setState(() {
      _currentUser = null;
    });
    await AuthManager.signOut();
    Navigator.pushReplacementNamed(context, AppRoute.login);
  }
}
