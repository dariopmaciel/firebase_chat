import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage(this.data, {super.key});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              data['senderPhotoURL'],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              data["imgUrl"] != null
                  ? Image.network(
                      data["imgUrl"],
                      width: 250,
                    )
                  : Text(
                      data['text'],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
              Text(
                data["senderName"],
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
