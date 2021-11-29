import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user.dart';
import 'package:flutter_share/pages/home.dart';
import 'package:flutter_share/widgets/header.dart';
import 'package:flutter_share/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final DocumentSnapshot? loginUser;
  final String? postId;
  final String? postOwnerId;
  final String? postMediaUrl;
  Comments({this.loginUser, this.postId, this.postOwnerId, this.postMediaUrl});
  @override
  _CommentsState createState() => _CommentsState(
        loginUser: loginUser,
        postId: postId,
        postOwnerId: postOwnerId,
        postMediaUrl: postMediaUrl,
      );
}

class _CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final DocumentSnapshot? loginUser;
  final String? postId;
  final String? postOwnerId;
  final String? postMediaUrl;
  DocumentSnapshot? loggedUser;
  User logUser = User();
  _CommentsState(
      {this.loginUser, this.postId, this.postOwnerId, this.postMediaUrl});
  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  getCurrentUserDetails() async {
    logUser = User.fromDocument(loginUser);
  }

  buildComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: comments
          .doc(postId)
          .collection('comments')
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> commentsList = [];
        snapshot.data?.docs.forEach((doc) {
          commentsList.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: commentsList,
        );
      },
    );
  }

  addComment() async {
    comments.doc(postId).collection('comments').add({
      "username": logUser.username,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": logUser.photoUrl,
      "userId": logUser.id,
    });
    if (postOwnerId != logUser.id) {
      feed.doc(postOwnerId).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "username": logUser.username,
        "userId": logUser.id,
        "userProfileImg": logUser.photoUrl,
        "postId": postId,
        "mediaUrl": postMediaUrl,
        "timestamp": timestamp,
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: false, pageTitle: "Comments"),
      body: Column(
        children: [
          Expanded(
            child: buildComments(),
          ),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration:
                  const InputDecoration(labelText: "Write a comment..."),
            ),
            trailing: OutlinedButton(
              onPressed: addComment,
              child: const Text("Post"),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp? timestamp;

  Comment(
      {this.username = "",
      this.userId = "",
      this.avatarUrl = "",
      this.comment = "",
      this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc["username"],
      userId: doc["userId"],
      comment: doc["comment"],
      avatarUrl: doc["avatarUrl"],
      timestamp: doc["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp!.toDate())),
        ),
        const Divider(),
      ],
    );
  }
}
