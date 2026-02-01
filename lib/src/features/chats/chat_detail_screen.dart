import 'package:flutter/material.dart';
import 'package:monochat/src/core/widgets/mono_background.dart';

class ChatDetailScreen extends StatelessWidget {
  final String chatTitle;
  final String initialMessage;
  final DateTime initialTime;

  const ChatDetailScreen({
    super.key,
    required this.chatTitle,
    required this.initialMessage,
    required this.initialTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 10,
        title: Row(
          children: [
            TelegramAvatar(name: chatTitle, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Text(chatTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: MonoBackground(
        seed: chatTitle,
        child: SafeArea(
          child: ChatDetailPane(
            key: ValueKey("pane_$chatTitle"),
            chatTitle: chatTitle,
            initialMessage: initialMessage,
            initialTime: initialTime,
            showTopBar: false, // AppBar уже есть
          ),
        ),
      ),
    );
  }
}

/// ✅ Панель для правой части (embedded)
class ChatDetailPane extends StatefulWidget {
  final String chatTitle;
  final String initialMessage;
  final DateTime initialTime;
  final bool showTopBar; // для десктопа сверху справа (как Telegram)

  const ChatDetailPane({
    super.key,
    required this.chatTitle,
    required this.initialMessage,
    required this.initialTime,
    this.showTopBar = true,
  });

  @override
  State<ChatDetailPane> createState() => _ChatDetailPaneState();
}

class _ChatDetailPaneState extends State<ChatDetailPane> {
  final _controller = TextEditingController();
  late List<_Msg> _messages;

  @override
  void initState() {
    super.initState();
    // ✅ сообщение в чате = превью в списке
    _messages = [
      _Msg(widget.initialMessage, fromMe: false, at: widget.initialTime),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Msg(t, fromMe: true, at: DateTime.now()));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topBarBg = isDark ? const Color(0xB0121212) : const Color(0xCCFFFFFF);
    final topBorder = isDark ? const Color(0x22FFFFFF) : const Color(0x22000000);

    return Column(
      children: [
        if (widget.showTopBar)
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: topBarBg,
              border: Border(bottom: BorderSide(color: topBorder, width: 1)),
            ),
            child: Row(
              children: [
                TelegramAvatar(name: widget.chatTitle, size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.chatTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final m = _messages[i];
              return Align(
                alignment: m.fromMe ? Alignment.centerRight : Alignment.centerLeft,
                child: TelegramBubble(text: m.text, fromMe: m.fromMe, at: m.at),
              );
            },
          ),
        ),
        _Composer(controller: _controller, onSend: _send),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _Composer({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xCC111111) : const Color(0xCCFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0x22FFFFFF) : const Color(0x22000000)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Напишите сообщение…",
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7DFF), Color(0xFF00C7BE)],
                  ),
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// bubble + хвостик + время
class TelegramBubble extends StatelessWidget {
  final String text;
  final bool fromMe;
  final DateTime at;

  const TelegramBubble({
    super.key,
    required this.text,
    required this.fromMe,
    required this.at,
  });

  String _hhmm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleGradient = fromMe
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7DFF), Color(0xFF00C7BE)],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF1B1B1B), Color(0xFF101010)]
                : const [Color(0xFFFFFFFF), Color(0xFFF2F2F2)],
          );

    final fg = fromMe ? Colors.white : (isDark ? Colors.white : Colors.black);
    final timeColor = fromMe
        ? Colors.white.withOpacity(0.78)
        : (isDark ? Colors.white.withOpacity(0.65) : Colors.black.withOpacity(0.55));

    final borderColor = fromMe ? const Color(0x22FFFFFF) : const Color(0x22000000);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: bubbleGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: TextStyle(color: fg, height: 1.2)),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _hhmm(at),
                        style: TextStyle(color: timeColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: fromMe ? null : -8,
            right: fromMe ? -8 : null,
            child: ClipPath(
              clipper: _TailClipper(fromMe: fromMe),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  gradient: bubbleGradient,
                  border: Border.all(color: borderColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TailClipper extends CustomClipper<Path> {
  final bool fromMe;
  _TailClipper({required this.fromMe});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    if (fromMe) {
      return Path()..moveTo(0, h * 0.25)..lineTo(w, h * 0.55)..lineTo(0, h)..close();
    } else {
      return Path()..moveTo(w, h * 0.25)..lineTo(0, h * 0.55)..lineTo(w, h)..close();
    }
  }

  @override
  bool shouldReclip(covariant _TailClipper oldClipper) => oldClipper.fromMe != fromMe;
}

class _Msg {
  final String text;
  final bool fromMe;
  final DateTime at;
  _Msg(this.text, {required this.fromMe, required this.at});
}

/// telegram-like gradient avatar
class TelegramAvatar extends StatelessWidget {
  final String name;
  final double size;
  const TelegramAvatar({super.key, required this.name, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final idx = _hash(name) % _grads.length;
    final g = _grads[idx];
    final initials = _initials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: g,
        boxShadow: [BoxShadow(blurRadius: 14, offset: const Offset(0, 8), color: Colors.black.withOpacity(0.18))],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.34, letterSpacing: 0.6),
      ),
    );
  }

  static String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

int _hash(String s) {
  var h = 0;
  for (final c in s.codeUnits) {
    h = 31 * h + c;
  }
  return h.abs();
}

const _grads = <LinearGradient>[
  LinearGradient(colors: [Color(0xFF5B9DFF), Color(0xFF2E7DFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  LinearGradient(colors: [Color(0xFF00C7BE), Color(0xFF34C759)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  LinearGradient(colors: [Color(0xFFFF9500), Color(0xFFFFCC00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  LinearGradient(colors: [Color(0xFFFF2D55), Color(0xFFAF52DE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  LinearGradient(colors: [Color(0xFFAF52DE), Color(0xFF5B9DFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  LinearGradient(colors: [Color(0xFF34C759), Color(0xFF00C7BE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
];
