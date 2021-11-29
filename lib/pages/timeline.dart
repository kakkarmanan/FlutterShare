import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user.dart';
import 'package:flutter_share/pages/home.dart';
import 'package:flutter_share/pages/search.dart';
import 'package:flutter_share/widgets/header.dart';
import 'package:flutter_share/widgets/post.dart';
import 'package:flutter_share/widgets/progress.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
final CollectionReference users =
    FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final DocumentSnapshot? logInUser;
  Timeline({this.logInUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  User currentLoggedUser = User();
  List<Post> myPosts = [];
  List<String> followingList = [];
  User resultUsers = User();
  @override
  void initState() {
    super.initState();
    getCurrentUserLogin();
    getTimeline();
    getFollowing();
  }

  getFollowing() async {
    QuerySnapshot snapshot = await following
        .doc(currentLoggedUser.id)
        .collection('userFollowing')
        .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timeline
        .doc(currentLoggedUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> myPosts = snapshot.docs
        .map((doc) => Post.fromDocument(doc, widget.logInUser))
        .toList();
    setState(() {
      myPosts = myPosts;
    });
  }

  getCurrentUserLogin() {
    User logUser = User.fromDocument(widget.logInUser);
    setState(() {
      currentLoggedUser = logUser;
    });
  }

  buildTimeline() {
    if (myPosts == null) {
      return circularProgress();
    } else if (myPosts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(
        children: myPosts,
      );
    }
  }

  buildUsersToFollow() {
    return StreamBuilder<dynamic>(
      stream: users.orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.docs.forEach((doc) {
          User resultUsers = User.fromDocument(doc);
          final bool isAuthUser = currentLoggedUser.id == resultUsers.id;
          final bool isFollowingUser = followingList.contains(resultUsers.id);
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult =
                UserResult(widget.logInUser, widget.logInUser, resultUsers);
            userResults.add(userResult);
          }
        });
        return Container(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30.0,
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      "Users To Follow",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 30.0,
                      ),
                    )
                  ],
                ),
              ),
              Column(
                children: userResults,
              )
            ],
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true, pageTitle: "FlutterShare"),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
