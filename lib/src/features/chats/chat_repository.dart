import 'dart:math' as math;
import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool fromMe;
  final DateTime time;
  ChatMessage({required this.text, required this.fromMe, required this.time});
}

class ChatItem {
  final String id;
  final String title;
  final String initials;
  final Color a;
  final Color b;
  final List<ChatMessage> messages;
  final int unread;

  ChatItem({
    required this.id,
    required this.title,
    required this.initials,
    required this.a,
    required this.b,
    required this.messages,
    required this.unread,
  });

  ChatMessage get last => messages.isNotEmpty
      ? messages.last
      : ChatMessage(text: '', fromMe: false, time: DateTime.now());
}

class ChatRepository {
  ChatRepository._();
  static final ChatRepository instance = ChatRepository._();

  List<ChatItem> chatsForLang(String lang) {
    return lang == 'ru' ? _buildRu() : _buildEn();
  }

  List<ChatItem> _buildRu() {
    const first = [
      'Александр','Егор','Кирилл','Павел','Тимофей','Михаил','Илья','Андрей','Дмитрий','Никита',
      'Анна','Елена','Ксения','Мария','Полина','София','Алина','Дарья','Виктория','Ольга'
    ];
    const last = [
      'Иванов','Петров','Сидоров','Лебедев','Смирнов','Морозов','Васильев','Новиков','Фёдоров','Михайлов',
      'Орлов','Козлов','Волков','Зайцев','Павлов','Соколов','Попов','Андреев','Макаров','Николаев'
    ];

    const pool = [
      'Супер! 🔥',
      'Ок, понял 👍',
      'Давай созвонимся вечером',
      'Готово, посмотри',
      'Скинь, пожалуйста, файл',
      'Я сейчас занят, напишу позже',
      'Отправил',
      'Спасибо!',
      'Договорились ✅',
      'Можешь уточнить детали?'
    ];

    return _buildChats(first, last, pool, seed: 42);
  }

  List<ChatItem> _buildEn() {
    const first = [
      'Daniel','Emma','Mia','Lily','David','Joseph','Charlotte','Anthony','Robert','Isabella',
      'Oliver','James','Sophia','Amelia','Lucas','Henry','Noah','Evelyn','Ava','Jackson'
    ];
    const last = [
      'Smith','Johnson','Williams','Brown','Jones','Miller','Davis','Garcia','Martinez','Taylor',
      'Anderson','Thomas','Jackson','White','Harris','Martin','Thompson','Moore','Clark','Lewis'
    ];

    const pool = [
      'Awesome! 🔥',
      'Ok, got it 👍',
      'Let’s call later',
      'Done, take a look',
      'Please send the file',
      'I’m busy, text later',
      'Sent',
      'Thanks!',
      'Deal ✅',
      'Can you уточнить details?'
    ];

    // Fix accidental RU word in EN pool:
    final fixed = pool.map((s) => s.replaceAll('уточнить', 'clarify')).toList();

    return _buildChats(first, last, fixed, seed: 99);
  }

  List<ChatItem> _buildChats(List<String> first, List<String> last, List<String> pool, {required int seed}) {
    final rng = math.Random(seed);
    final items = <ChatItem>[];

    // nice gradient palette pairs
    const colors = [
      [Color(0xFFFC5C7D), Color(0xFF6A82FB)],
      [Color(0xFF36D1DC), Color(0xFF5B86E5)],
      [Color(0xFF11998E), Color(0xFF38EF7D)],
      [Color(0xFFFFB347), Color(0xFFFFCC33)],
      [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
      [Color(0xFF00C6FF), Color(0xFF0072FF)],
      [Color(0xFFF953C6), Color(0xFFB91D73)],
      [Color(0xFF43E97B), Color(0xFF38F9D7)],
    ];

    for (int i = 0; i < 24; i++) {
      final f = first[rng.nextInt(first.length)];
      final l = last[rng.nextInt(last.length)];
      final title = '$f $l';
      final initials = _initials(f, l);

      final pair = colors[i % colors.length];
      final a = pair[0];
      final b = pair[1];

      final baseTime = DateTime.now().subtract(Duration(minutes: 15 * (i + 1)));
      final msgCount = 5 + rng.nextInt(5);

      final messages = <ChatMessage>[];
      for (int m = 0; m < msgCount; m++) {
        final fromMe = m.isOdd; // alternate
        final text = pool[(i * 3 + m * 5) % pool.length];
        messages.add(ChatMessage(
          text: text,
          fromMe: fromMe,
          time: baseTime.add(Duration(minutes: m * (2 + (i % 3)))),
        ));
      }

      // last message must be "from other" sometimes to look real:
      if (messages.isNotEmpty && messages.last.fromMe == true && i.isEven) {
        final t = messages.last.time.add(const Duration(minutes: 2));
        messages.add(ChatMessage(text: pool[(i * 7) % pool.length], fromMe: false, time: t));
      }

      final unread = (i % 5 == 0) ? (1 + (i % 4)) : 0;

      items.add(ChatItem(
        id: 'c$i',
        title: title,
        initials: initials,
        a: a,
        b: b,
        messages: messages,
        unread: unread,
      ));
    }

    return items;
  }

  String _initials(String first, String last) {
    final a = first.isNotEmpty ? first[0].toUpperCase() : '?';
    final b = last.isNotEmpty ? last[0].toUpperCase() : '?';
    return '$a$b';
  }
}