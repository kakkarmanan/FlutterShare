import 'package:flutter/material.dart';
import 'package:flutter_share/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String? username = "";
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  onSubmit() {
    final form = _formKey.currentState;
    if (form != null) {
      if (form.validate()) {
        form.save();
        SnackBar snackbar = SnackBar(content: Text("Welcome: $username !"));
        // ignore: deprecated_member_use
        _scaffoldKey.currentState?.showSnackBar(snackbar);
        timer(const Duration(seconds: 2));
        Navigator.pop(context, username);
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: header(context,
            pageTitle: "Set up your profile", removeBackButton: true),
        body: Container(
          padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Create a username",
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      onSaved: (val) => {username = val},
                      // ignore: deprecated_member_use
                      autovalidate: true,
                      validator: (val) {
                        if (val!.isEmpty || val.trim().length < 3) {
                          return "Username too short";
                        } else if (val!.trim().length > 12) {
                          return "Username too long";
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Username",
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: "Must be at least 3 characters",
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSubmit,
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  alignment: Alignment.center,
                  child: const Center(
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

void timer(Duration duration) {}
