import 'package:flutter/widgets.dart';

class S {
  final Locale locale;
  S(this.locale);

  static S of(BuildContext context) => S(Localizations.localeOf(context));

  bool get isRu => locale.languageCode.toLowerCase() == 'ru';

  String get chats => isRu ? 'Чаты' : 'Chats';
  String get settings => isRu ? 'Настройки' : 'Settings';
  String get ai => isRu ? 'ИИ' : 'AI';

  String get lastMessagePreview => isRu ? 'Последнее сообщение...' : 'Last message preview...';

  String get aiChatTitle => isRu ? 'АРГУСБОТ' : 'ARGUSBOT';
  String get aiHint => isRu ? 'Напишите сообщение…' : 'Type a message…';
  String get send => isRu ? 'Отправить' : 'Send';

  String get theme => isRu ? 'Тема' : 'Theme';
  String get language => isRu ? 'Язык' : 'Language';
  String get system => isRu ? 'системная' : 'system';
  String get light => isRu ? 'светлая' : 'light';
  String get dark => isRu ? 'тёмная' : 'dark';

  String get english => isRu ? 'Английский' : 'English';
  String get russian => isRu ? 'Русский' : 'Russian';

  String chatN(int i) => isRu ? 'Чат #$i' : 'Chat #$i';

  String aiReply(String userText) =>
      isRu ? 'Понял: "$userText". (заглушка ИИ)' : 'Got it: "$userText". (AI stub)';
}

