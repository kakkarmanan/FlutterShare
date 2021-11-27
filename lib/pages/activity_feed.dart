import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user.dart';
import 'package:flutter_share/pages/home.dart';
import 'package:flutter_share/pages/post_screen.dart';
import 'package:flutter_share/pages/profile.dart';
import 'package:flutter_share/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  final DocumentSnapshot? loginUser;
  ActivityFeed({this.loginUser});

  @override
  _ActivityFeedState createState() => _ActivityFeedState(
        loginUser: loginUser,
      );
}

class _ActivityFeedState extends State<ActivityFeed> {
  final DocumentSnapshot? loginUser;
  User logUser = User();
  _ActivityFeedState({this.loginUser});
  @override
  void initState() {
    getCurrentUserDetails();
    super.initState();
  }

  getCurrentUserDetails() {
    logUser = User.fromDocument(loginUser);
  }

  getActivityFeed() async {
    QuerySnapshot snapshot = await feed
        .doc(logUser.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    List<ActivityFeedItem> feedItems = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc, loginUser));
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      appBar: header(context, isAppTitle: false, pageTitle: "Acitivity Feed"),
      body: Container(
        child: FutureBuilder<dynamic>(
            future: getActivityFeed(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              return ListView(
                children: snapshot.data!,
              );
            }),
      ),
    );
  }
}

Widget? mediaPreview;
String? activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final DocumentSnapshot? loginUser;
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp? timestamp;

  ActivityFeedItem({
    this.loginUser,
    this.username = "",
    this.userId = "",
    this.type = "",
    this.mediaUrl = "",
    this.postId = "",
    this.userProfileImg = "",
    this.commentData = "",
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(
      DocumentSnapshot? doc, DocumentSnapshot? loginUser) {
    print(doc!.data());
    return ActivityFeedItem(
      loginUser: loginUser,
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }

  configureMediaPreview(context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostScreen(
                      loginuser: loginUser,
                      userId: userId,
                      postId: postId,
                    ))),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }

    if (type == 'like') {
      activityItemText = 'liked your post';
    } else if (type == 'follow') {
      activityItemText = 'started following you';
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else {
      activityItemText = 'Error: Unknown type $type';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(
                          user: loginUser,
                          currentinUser: loginUser,
                        ))),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' $activityItemText'),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp!.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
