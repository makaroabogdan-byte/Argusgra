import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final List<_Msg> _messages = [
    _Msg(text: 'Привет! Чем я могу помочь?', fromUser: false, time: DateTime.now()),
  ];

  bool _isTyping = false;

  bool get _isRu => Localizations.localeOf(context).languageCode == 'ru';

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _title() => _isRu ? 'АРГУСБОТ' : 'ARGUSBOT';

  String _hint() => _isRu ? 'Напишите сообщение...' : 'Type a message...';

  String _sendLabel() => _isRu ? 'Отправить' : 'Send';

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<String> _askOllama(String prompt) async {
    // Ollama chat API
    final uri = Uri.parse('http://127.0.0.1:11434/api/chat');

    final body = {
      "model": "llama3.1:latest",
      "stream": false,
      "messages": [
        {"role": "system", "content": _isRu ? "Ты дружелюбный ассистент." : "You are a helpful assistant."},
        // small context: last few messages
        ..._messages.takeLast(8).map((m) => {
          "role": m.fromUser ? "user" : "assistant",
          "content": m.text
        }),
        {"role": "user", "content": prompt}
      ]
    };

    final req = await HttpClient().postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();

    if (res.statusCode >= 400) {
      throw Exception('Ollama HTTP ${res.statusCode}: $text');
    }

    final json = jsonDecode(text);
    final msg = json["message"];
    if (msg is Map && msg["content"] is String) return msg["content"] as String;

    // fallback for unexpected shape
    return text;
  }

  Future<void> _send() async {
    final t = _controller.text.trim();
    if (t.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_Msg(text: t, fromUser: true, time: DateTime.now()));
      _controller.clear();
      _isTyping = true;
    });

    await Future.delayed(const Duration(milliseconds: 30));
    _scrollToBottom();

    try {
      final reply = await _askOllama(t);
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(text: reply.trim(), fromUser: false, time: DateTime.now()));
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(text: 'Ошибка: $e', fromUser: false, time: DateTime.now()));
        _isTyping = false;
      });
    }

    await Future.delayed(const Duration(milliseconds: 30));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 200,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      _title(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: isDark ? const Color(0xFF0B0C0E) : const Color(0xFFF2F2F2),
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) {
                    final m = _messages[i];
                    return _bubble(context, m.text, _fmt(m.time), fromUser: m.fromUser);
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: _hint(),
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isTyping ? null : _send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A76D2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_sendLabel()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(BuildContext context, String text, String time, {required bool fromUser}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = fromUser
        ? (isDark ? const Color(0xFF1E3A5F) : const Color(0xFF2A76D2))
        : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEAEAEA));

    final fg = fromUser ? Colors.white : (isDark ? Colors.white : Colors.black);

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: Text(text, style: TextStyle(color: fg, fontSize: 14, height: 1.25))),
            const SizedBox(width: 10),
            Text(time, style: TextStyle(color: fg.withOpacity(0.70), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool fromUser;
  final DateTime time;
  _Msg({required this.text, required this.fromUser, required this.time});
}

extension _TakeLast<T> on List<T> {
  List<T> takeLast(int n) {
    if (length <= n) return List<T>.from(this);
    return sublist(length - n);
  }
}