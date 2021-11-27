import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User({
    this.id = "",
    this.username = "",
    this.email = "",
    this.photoUrl = "",
    this.displayName = "",
    this.bio = "",
  });

  factory User.fromDocument(DocumentSnapshot? doc) {
    print("From user model");
    print(doc!.data());
    return User(
      id: doc['id'],
      username: doc['username'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }
}