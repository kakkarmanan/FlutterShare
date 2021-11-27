import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/pages/home.dart';
import 'package:flutter_share/widgets/header.dart';
import 'package:flutter_share/widgets/post.dart';
import 'package:flutter_share/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final DocumentSnapshot? loginuser;
  final String userId;
  final String postId;
  PostScreen({this.loginuser, this.userId = "", this.postId = ""});
  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: posts.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        Post post = Post.fromDocument(snapshot.data, loginuser);
        return Center(
          child: Scaffold(
            appBar: header(context, pageTitle: post.description),
            body: ListView(
              children: [
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
