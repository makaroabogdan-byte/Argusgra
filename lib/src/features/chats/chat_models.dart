import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String text;
  final DateTime time;
  final bool fromMe;

  ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.fromMe,
  });
}

class ChatItem {
  final String id;
  final String firstName;
  final String lastName;
  final bool isRu; // RU name+surname OR EN name+surname
  final List<ChatMessage> messages;
  final int unread;
  final Color avatarA;
  final Color avatarB;

  ChatItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.isRu,
    required this.messages,
    required this.unread,
    required this.avatarA,
    required this.avatarB,
  });

  String get title => ' ';

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}
