import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/text_composer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //----------------------
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currenteUser;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  //
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currenteUser = user!;
    });
  }
  //----------------------

  //
  // Future<User?> _getUser() async {
  //   if (_currenteUser != null) return _currenteUser;
  //   try {
  //     final GoogleSignInAccount? googleSignInAccount =
  //         await googleSignIn.signIn();
  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleSignInAccount!.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //         idToken: googleSignInAuthentication.idToken,
  //         accessToken: googleSignInAuthentication.accessToken);
  //     final UserCredential authResult =
  //         await FirebaseAuth.instance.signInWithCredential(credential);
  //     final User? user = authResult.user;
  //     return user;
  //     //
  //   } catch (e) {
  //     return null;
  //   }
  // }

//----------------------
  void _sendMessage({String? text, File? imgFile}) async {
//----------------------
    //final User? user = await _getUser();
//----------------------
    // if (user == null) {
    //   //_scaffoldKey.currentState!.showSnackBar(const SnackBar(content: Text("NÃO LOGADO")));
    //   scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
    //     content: Text("NÃO LOGADO"),
    //     backgroundColor: Colors.red,
    //   ));
    //   print("NÃO LOGADO");
    // } else {
    //   scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
    //     content: Text(" LOGADO"),
    //     backgroundColor: Colors.green,
    //   ));
    //   print("LOGADO");
    // }
//----------------------
    Map<String, dynamic> data = {
      // "uid": user!.uid,
      // "senderName": user.displayName,
      // "senderPhotoURL": user.photoURL,
      // "senderEmail": user.email,
      // "senderPhoneNumber": user.phoneNumber
    };

    if (imgFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("casa")
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      TaskSnapshot snapshot = await task;
      String url = await snapshot.ref.getDownloadURL();
      print("LINK DA FOTO: $url");
      data["imgUrl"] = url;
    }
    if (text != null) data['text'] = text;

    FirebaseFirestore.instance.collection("msg").add(data);
  }
//

//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Olá'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("msg").snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                      reverse: true,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(documents[index].get("text")),
                        );
                      },
                    );
                }
              },
            ),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
