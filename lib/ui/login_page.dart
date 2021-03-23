import 'package:meena_supplies/authentication/auth_manager.dart';
import 'package:meena_supplies/ui/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    _signInSilently();
  }

  Future<void> _signInSilently() async {
    var account = await AuthManager.signInSilently();
    if (account != null) {
      Navigator.pushReplacementNamed(context, AppRoute.files);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepPurple,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Text(
                'Log in using your Google account',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                child: Text('Log in'),
                onPressed: _handleSignIn,
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    var account = await AuthManager.signIn();
    if (account != null) {
      Navigator.pushReplacementNamed(context, AppRoute.files);
    }
  }
}
