import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/chat_message.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  bool _isLoading = false;
  // final GlobalKey<ScaffoldMessengerState> _scaffoldKey =      GlobalKey<ScaffoldMessengerState>();

  //
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currenteUser = user;
      });
    });
  }
  //----------------------

  //
  Future<User?> _getUser() async {
    if (_currenteUser != null) return _currenteUser;
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      
      final User? user = authResult.user;
      
      return user;
      //
    } catch (e) {
      print("ERRO EM: $e");
      return null;
    }
  }

//----------------------
  void _sendMessage({String? text, File? imgFile}) async {
//----------------------
    final User? user = await _getUser();
//----------------------
    if (user == null) {
      // _scaffoldKey.currentState!.showSnackBar(const SnackBar(content: Text("Não foi possivel logar. Tente novamente")));
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //       content: Text("Login failed"),
      //       backgroundColor: Colors.red,
      //       duration: Duration(milliseconds: 500)),
      // );
      print("NÃO LOGADO>>");
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //       content: Text("Logado!!!"),
      //       backgroundColor: Colors.green,
      //       duration: Duration(milliseconds: 500)),
      // );
      print("LOGADO>>");
    }
//----------------------
    Map<String, dynamic> data = {
      "uid": user!.uid,
      "time": Timestamp.now(),
      "senderName": user.displayName,
      "senderPhotoURL": user.photoURL,
      "senderEmail": user.email,
      "senderPhoneNumber": user.phoneNumber
    };

    if (imgFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("casa")
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      TaskSnapshot snapshot = await task;
      String url = await snapshot.ref.getDownloadURL();
      print("LINK DA FOTO: $url");
      data["imgUrl"] = url;

      setState(() {
        _isLoading = false;
      });
    }
    if (text != null) data['text'] = text;

    FirebaseFirestore.instance.collection("msg").add(data);
  }
//

//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currenteUser != null
            ? "Olá, ${_currenteUser!.displayName}"
            : "Chat App"),
        elevation: 0,
        centerTitle: true,
        actions: [
          _currenteUser != null
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Você saiu com Sucesso!"),
                          duration: Duration(milliseconds: 500)),
                    );
                  },
                )
              : Container(),
        ],
      ),
      drawer: Drawer(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("msg")
                  .orderBy("time")
                  .snapshots(),
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
                        // return ListTile(title: Text(documents[index].get("text")));
                        return ChatMessage(
                            documents[index].data() as Map<String, dynamic>,
                            true);
                        //documents[index].data == _currenteUser?.uid);
                      },
                    );
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
