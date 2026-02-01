import 'dart:math';
import 'package:flutter/material.dart';
import 'package:monochat/src/core/widgets/mono_background.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late final List<_ChatItem> _chats;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _chats = _buildChats();
    _selected = _chats.isNotEmpty ? 0 : null;
  }

  String _title(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'ru' ? 'АРГУСГРАМ' : 'ARGUSGRAM';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_title(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: MonoBackground(
        seed: "chats_list",
        child: SafeArea(
          child: isDesktop ? _desktop(context) : _mobile(context),
        ),
      ),
    );
  }

  Widget _mobile(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _chats.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0x22FFFFFF)
            : const Color(0x22000000),
      ),
      itemBuilder: (context, i) => _ChatRow(
        item: _chats[i],
        selected: false,
        onTap: () {
          final c = _chats[i];
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                chatTitle: c.title,
                initialMessage: c.last,
                initialTime: c.lastAt,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _desktop(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? const Color(0x22FFFFFF) : const Color(0x22000000);

    return Row(
      children: [
        // Left list
        SizedBox(
          width: 360,
          child: Column(
            children: [
              // Search bar imitation (Telegram-style)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xAA111111) : const Color(0xCCFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 18, color: isDark ? Colors.white70 : Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'ru' ? 'Поиск' : 'Search',
                          style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _chats.length,
                  separatorBuilder: (_, __) => Divider(height: 1, thickness: 1, color: dividerColor),
                  itemBuilder: (context, i) => _ChatRow(
                    item: _chats[i],
                    selected: _selected == i,
                    onTap: () => setState(() => _selected = i),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Middle divider
        Container(width: 1, color: dividerColor),

        // Right preview
        Expanded(
          child: _selected == null
              ? Center(
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ru'
                        ? 'Выберите чат слева'
                        : 'Select a chat on the left',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  ),
                )
              : ChatDetailPane(
                  key: ValueKey("pane_${_chats[_selected!].title}"),
                  chatTitle: _chats[_selected!].title,
                  initialMessage: _chats[_selected!].last,
                  initialTime: _chats[_selected!].lastAt,
                  showTopBar: true,
                ),
        ),
      ],
    );
  }

  List<_ChatItem> _buildChats() {
    final rng = Random(1337);

    const firstNames = [
      'Александр','Михаил','Иван','Даниил','Максим','Артём','Егор','Никита','Кирилл','Павел',
      'Анна','Мария','Екатерина','Алина','Полина','Дарья','София','Виктория','Ксения','Елена',
      'James','Michael','Robert','William','David','Daniel','Matthew','Anthony','Andrew','Joseph',
      'Emily','Olivia','Sophia','Emma','Ava','Mia','Isabella','Amelia','Charlotte','Lily',
    ];

    const lastNames = [
      'Иванов','Смирнов','Кузнецов','Попов','Соколов','Лебедев','Козлов','Новиков','Морозов','Петров',
      'Волков','Соловьёв','Васильев','Зайцев','Павлов','Семёнов','Голубев','Виноградов','Богданов','Фёдоров',
      'Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez',
      'Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas','Taylor','Moore','Jackson','Martin',
    ];

    const previews = [
      'Ок, понял 👍',
      'Скинь, пожалуйста, файл',
      'Давай созвонимся вечером',
      'Готово, посмотри',
      'Я сейчас занят, напишу позже',
      'Супер! 🔥',
      'Можешь уточнить детали?',
      'Ща проверю',
      'Отправил',
      'Спасибо!',
    ];

    final now = DateTime.now();
    final items = <_ChatItem>[];

    for (var i = 0; i < 50; i++) {
      final fn = firstNames[rng.nextInt(firstNames.length)];
      final ln = lastNames[rng.nextInt(lastNames.length)];
      final title = '$fn $ln';

      final last = previews[rng.nextInt(previews.length)];
      final hour = 9 + rng.nextInt(12); // 09..20
      final minuteInt = rng.nextInt(60);
      final minute = minuteInt.toString().padLeft(2, '0');
      final time = '$hour:$minute';

      // ✅ Это "истина" для чата: превью + первое сообщение используют одно и то же время
      final lastAt = DateTime(now.year, now.month, now.day, hour, minuteInt);

      final unread = rng.nextInt(6);
      items.add(_ChatItem(title: title, last: last, time: time, unread: unread, lastAt: lastAt));
    }

    return items;
  }
}

class _ChatRow extends StatelessWidget {
  final _ChatItem item;
  final bool selected;
  final VoidCallback onTap;
  const _ChatRow({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ чтобы текст читался на фоне: делаем ряд чуть плотнее и с мягким подложением
    final rowBg = selected
        ? (isDark ? const Color(0x442E7DFF) : const Color(0x332E7DFF))
        : (isDark ? const Color(0x22000000) : const Color(0x22FFFFFF));

    return Material(
      color: rowBg,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              TelegramAvatar(name: item.title, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(item.last, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item.time, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  if (item.unread > 0) _UnreadBadge(count: item.unread),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7DFF), Color(0xFF00C7BE)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _ChatItem {
  final String title;
  final String last;
  final String time;
  final int unread;

  /// ✅ добавили, чтобы чат мог показать то же время, что и в превью
  final DateTime lastAt;

  _ChatItem({
    required this.title,
    required this.last,
    required this.time,
    required this.unread,
    required this.lastAt,
  });
}
