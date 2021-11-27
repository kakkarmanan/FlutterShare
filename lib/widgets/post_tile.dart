import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/pages/post_screen.dart';
import 'package:flutter_share/widgets/custom_image.dart';
import 'package:flutter_share/widgets/post.dart';

class PostTile extends StatelessWidget {
  final DocumentSnapshot? loginuser;
  final Post post;
  PostTile(this.loginuser, this.post);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  loginuser: loginuser,
                  postId: post.postId,
                  userId: post.ownerId,
                )),
      ),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
