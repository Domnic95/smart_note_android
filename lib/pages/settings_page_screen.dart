import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:note_app/pages/recycle_bin_page_screen.dart';

class SettingsPageScreen extends StatefulWidget {
  final ValueNotifier<int>? notesRefreshToken;
  final VoidCallback toggleTheme;

  const SettingsPageScreen({
    super.key,
    this.notesRefreshToken,
    required this.toggleTheme,
  });

  @override
  State<SettingsPageScreen> createState() => _SettingsPageScreenState();
}

class _SettingsPageScreenState extends State<SettingsPageScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Future<void> onPress({void Function()? callback}) async {
      return await ShowInterstitialAds()
          .showClickInterstitialAds(callback: callback);
    }

    BoxDecoration pageBackdrop(BuildContext context) {
      final cs = Theme.of(context).colorScheme;

      if (isDark) {
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(cs.surface, cs.surfaceContainerHighest, 0.55)!,
              Color.lerp(
                  cs.surfaceContainerHighest, cs.primaryContainer, 0.22)!,
            ],
          ),
        );
      }
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(cs.surface, cs.primaryContainer, 0.5)!,
            Color.lerp(cs.surface, cs.secondaryContainer, 0.42)!,
          ],
        ),
      );
    }

    return DecoratedBox(
      decoration: pageBackdrop(context),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
            child: Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 24),
          child: ListView(
            shrinkWrap: true,
            primary: false,
            children: [
              const SizedBox(height: 10),
              _SettingsCard(
                colorScheme: cs,
                children: [
                  _SettingsTile(
                    onTap: widget.toggleTheme,
                    leading: _IconBubble(
                      icon: Iconsax.paintbucket,
                      background: cs.primaryContainer,
                      foreground: cs.onPrimaryContainer,
                    ),
                    title: 'Theme',
                    subtitle: isDark ? 'Dark mode' : 'Light mode',
                    trailing: _buildThemeToggle(isDark),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SettingsCard(
                colorScheme: cs,
                children: [
                  _SettingsTile(
                    onTap: () {
                      onPress(
                        callback: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => RecycleBinPage(
                              notesRefreshToken: widget.notesRefreshToken,
                            ),
                          ),
                        ),
                      );
                    },
                    leading: _IconBubble(
                      icon: Iconsax.trash,
                      background: cs.errorContainer
                          .withValues(alpha: isDark ? 0.85 : 1),
                      foreground: cs.onErrorContainer,
                    ),
                    title: 'Recycle bin',
                    subtitle: 'Deleted notes',
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return GestureDetector(
      onTap: widget.toggleTheme,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? Colors.blue.shade900 : Colors.yellow.shade800,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x40FFFFFF) : const Color(0x40000000),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              top: 3.0,
              left: isDark ? 30.0 : 0.0,
              right: isDark ? 0.0 : 30.0,
              child: Icon(
                isDark ? Iconsax.moon : Iconsax.sun_1,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.colorScheme,
    required this.children,
  });

  final ColorScheme colorScheme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.onPrimary.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.085 : 1,
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _withDividers(children, colorScheme),
      ),
    );
  }

  static List<Widget> _withDividers(
    List<Widget> tiles,
    ColorScheme cs,
  ) {
    if (tiles.isEmpty) return tiles;
    final out = <Widget>[tiles.first];
    for (var i = 1; i < tiles.length; i++) {
      out.add(
        Divider(
          height: 1,
          thickness: 1,
          indent: 72,
          endIndent: 16,
          color: cs.outlineVariant.withValues(alpha: 0.35),
        ),
      );
      out.add(tiles[i]);
    }
    return out;
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: foreground, size: 22),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: cs.primary.withValues(alpha: 0.12),
        highlightColor: cs.primary.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
