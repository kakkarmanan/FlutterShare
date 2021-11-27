import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/widgets/header.dart';
import 'package:flutter_share/widgets/progress.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
final CollectionReference users =
    FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
  }

  // getUsers() async {
  //   final QuerySnapshot snapshots = await users.get();
  //   setState(() {
  //     userData = snapshots.docs;
  //   });
  // }
  // createUser() {
  //   users.add({
  //     "username": "Jeff",
  //     "isAdmin": false,
  //     "postsCount": 0,
  //   });
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true, pageTitle: "FlutterShare"),
      body: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot>? usernames = snapshot.data?.docs;
            return ListView(
              children: usernames!
                  .map((e) => Container(
                        child: Text(e["username"]),
                      ))
                  .toList(),
            );
          }
          return circularProgress();
        },
      ),
    );
  }
}
