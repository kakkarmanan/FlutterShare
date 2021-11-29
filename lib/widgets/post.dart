import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user.dart';
import 'package:flutter_share/pages/comments.dart';
import 'package:flutter_share/pages/home.dart';
import 'package:flutter_share/pages/profile.dart';
import 'package:flutter_share/widgets/custom_image.dart';
import 'package:flutter_share/widgets/progress.dart';

class Post extends StatefulWidget {
  final DocumentSnapshot? loginUser;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final Map? likes;

  Post({
    this.loginUser,
    this.postId = "",
    this.ownerId = "",
    this.username = "",
    this.location = "",
    this.description = "",
    this.mediaUrl = "",
    this.likes,
  });
  factory Post.fromDocument(
      DocumentSnapshot? doc, DocumentSnapshot? loginuser) {
    print(doc!.data());
    print(loginuser!.data());
    return Post(
      loginUser: loginuser,
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    if (likes == {}) {
      return 0;
    }

    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count = count + 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        loginUser: this.loginUser,
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  User currentLoggedUser = User();
  final DocumentSnapshot? loginUser;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  Map? likes;
  int likeCount;
  bool? isLiked;
  bool showHeart = false;
  bool isPostOwner = true;
  String? userId;

  _PostState({
    this.loginUser,
    this.postId = "",
    this.ownerId = "",
    this.username = "",
    this.location = "",
    this.description = "",
    this.mediaUrl = "",
    this.likes,
    this.likeCount = 0,
  });
  @override
  void initState() {
    getCurrentUserDetails();
    super.initState();
  }

  getCurrentUserDetails() async {
    currentLoggedUser = User.fromDocument(loginUser);
    setState(() {
      isPostOwner = ownerId == currentLoggedUser.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentLoggedUser.id != ownerId;
    if (isNotPostOwner) {
      feed.doc(ownerId).collection('feedItems').doc(postId).set({
        "type": "like",
        "username": currentLoggedUser.username,
        "userId": currentLoggedUser.id,
        "userProfileImg": currentLoggedUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikefromActivityFeed() {
    bool isNotPostOwner = currentLoggedUser.id != ownerId;
    if (isNotPostOwner) {
      feed.doc(ownerId).collection('feeditema').doc(postId).get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  handleLikePost() {
    bool _isLiked = (likes![currentLoggedUser.id] == true);
    setState(() {
      isLiked = _isLiked;
    });
    if (_isLiked) {
      posts
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.${currentLoggedUser.id}': false});
      setState(() {
        likeCount = (likeCount - 1);
        _isLiked = false;
        likes![currentLoggedUser.id] = false;
        isLiked = _isLiked;
      });
      removeLikefromActivityFeed();
    } else if (!_isLiked) {
      posts
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.${currentLoggedUser.id}': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount = (likeCount + 1);
        _isLiked = true;
        likes![currentLoggedUser.id] = true;
        isLiked = _isLiked;
      });
    }
  }

  deletePost() async {
    posts.doc(ownerId).collection('userPosts').doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    postsRef.child('post_$postId.jpg').delete();

    QuerySnapshot activityFeedSnapshot = await feed
        .doc(ownerId)
        .collection('feedItems')
        .where("postId", isEqualTo: postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    QuerySnapshot commentSnapshot =
        await comments.doc(postId).collection('comments').get();
    commentSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  void handleDeletePost(BuildContext parentContext) async {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Remove This Post?"),
            children: [
              SimpleDialogOption(
                onPressed: () => {Navigator.pop(context), deletePost()},
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          );
        });
  }

  buildPostHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => {
              userId = user.id,
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(
                            user: loginUser,
                            currentinUser: loginUser,
                            userId: userId,
                          )))
            },
            child: Text(
              user.username,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: Icon(Icons.more_vert),
                )
              : const Text(""),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
          showHeart
              ? Icon(
                  Icons.favorite,
                  size: 80.0,
                  color: Colors.grey,
                )
              : Text(""),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () => handleLikePost(),
              child: Icon(
                isLiked! ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.red,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40.0, right: 20.0),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Comments(
                            loginUser: loginUser,
                            postId: postId,
                            postOwnerId: ownerId,
                            postMediaUrl: mediaUrl,
                          ))),
              child: const Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                "$username: ",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            ),
          ],
        ),
      ],
    );
  }
}
