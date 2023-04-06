// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final Function({String text, File imgFile}) sendMessage;
  TextComposer(this.sendMessage);

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final _controllerEC = TextEditingController();
  bool _isComposing = false;
  final ImagePicker picker = ImagePicker();
  //File? imagemSelecionada;
  late File selectedImage;

//
  void reset() {
    _controllerEC.clear();
    setState(() {
      _isComposing = false;
    });
  }

  // pegarImagemCamera() async {
  //   final XFile? image = await picker.pickImage(source: ImageSource.camera);
  //   if (image != null) {
  //     setState(() {
  //       imagemSelecionada = File(image.path);
  //     });
  //     widget.sendMessage(imgFile: imagemSelecionada);
  //   }
  // }

//
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              final XFile? imgFile =
                  await picker.pickImage(source: ImageSource.camera);
              if (imgFile == null) return;
              selectedImage = File(imgFile.path);
              widget.sendMessage(imgFile: selectedImage);
              //
            },
            icon: const Icon(Icons.photo_camera),
          ),
          Expanded(
            child: TextField(
              controller: _controllerEC,
              decoration: const InputDecoration.collapsed(hintText: "Msg..."),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(text: text);
                reset();
              },
            ),
          ),
          IconButton(
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _controllerEC.text);
                    reset();
                  }
                : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
