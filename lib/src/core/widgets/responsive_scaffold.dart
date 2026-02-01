import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../i18n/strings.dart';

class ResponsiveScaffold extends StatefulWidget {
  final Widget child;
  const ResponsiveScaffold({super.key, required this.child});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/settings')) return 1;
    return 0; // chats
  }

  void _goByIndex(BuildContext context, int index) {
    if (index == 0) context.go('/chats');
    if (index == 1) context.go('/settings');
  }

  /// ✅ Твоя иконка (чёрная для светлой темы, белая для тёмной)
  Widget _argusAiIcon(BuildContext context, {double size = 22}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark ? 'assets/icons/argus_white.png' : 'assets/icons/argus_black.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 700;

    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexFromLocation(location);

    final isEn = Localizations.localeOf(context).languageCode.toLowerCase() == 'en';
    final aiTooltip = isEn ? 'ARGUSBOT' : 'АРГУСБОТ';

    if (isDesktop) {
      // WINDOWS layout: Rail слева
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => _goByIndex(context, i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FloatingActionButton(
                  tooltip: aiTooltip,
                  heroTag: 'ai_btn_desktop',
                  onPressed: () => context.push('/ai_chat'),
                  child: _argusAiIcon(context, size: 24), // ✅ заменили "ИИ" на твою иконку
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(s.chats),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings),
                  label: Text(s.settings),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // MOBILE/narrow layout: bottom nav + AI кнопка снизу слева
    return Scaffold(
      body: widget.child,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: aiTooltip,
        heroTag: 'ai_btn_mobile',
        onPressed: () => context.push('/ai_chat'),
        child: _argusAiIcon(context, size: 24), // ✅ заменили "ИИ" на твою иконку
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _goByIndex(context, i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: ''),
          const NavigationDestination(icon: Icon(Icons.settings), label: ''),
        ].asMap().entries.map((e) {
          // чтобы не ломать локализацию лейблов, соберём корректно:
          final idx = e.key;
          final dest = e.value;
          if (idx == 0) {
            return NavigationDestination(icon: dest.icon, label: s.chats);
          }
          return NavigationDestination(icon: dest.icon, label: s.settings);
        }).toList(),
      ),
    );
  }
}
