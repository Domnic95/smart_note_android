import 'package:flutter/material.dart';

class AppTheme {
  static const AppBarTheme _kAppBarThemeLight = AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
  );

  static AppBarTheme _appBarThemeDark(ColorScheme scheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: scheme.onSurface),
      actionsIconTheme: IconThemeData(color: scheme.onSurface),
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkScheme.surface,
      dialogTheme: DialogThemeData(
        backgroundColor: darkScheme.surface,
      ),
      appBarTheme: _appBarThemeDark(darkScheme),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkScheme.surfaceContainer,
        selectedItemColor: darkScheme.primary,
        unselectedItemColor: darkScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.transparent,
        indicatorColor: darkScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkScheme.onSurface,
            );
          }
          return TextStyle(
            fontSize: 12,
            color: darkScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? darkScheme.onPrimaryContainer
                : darkScheme.onSurfaceVariant,
          );
        }),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightScheme.surface,
      dialogTheme: DialogThemeData(
        backgroundColor: lightScheme.surface,
      ),
      appBarTheme: _kAppBarThemeLight,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightScheme.surfaceContainer,
        selectedItemColor: lightScheme.primary,
        unselectedItemColor: lightScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.transparent,
        indicatorColor: lightScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: lightScheme.onSurface,
            );
          }
          return TextStyle(
            fontSize: 12,
            color: lightScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? lightScheme.onPrimaryContainer
                : lightScheme.onSurfaceVariant,
          );
        }),
      ),
    );
  }
}

Color seedColor = const Color(0xFF019DFF);

final lightScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.light,
);

final darkScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.dark,
);

class NotebookAppBarDecoration {
  NotebookAppBarDecoration._();

  static const LinearGradient _gradientLight = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF1976D2),
      Color(0xFF42A5F5),
    ],
  );

  static Widget flexibleSpaceForTheme(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = scheme.brightness == Brightness.light;

    final BoxDecoration fill;
    if (isLight) {
      fill = const BoxDecoration(gradient: _gradientLight);
    } else {
      fill = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            scheme.surfaceContainerLow,
            scheme.surfaceContainerHigh,
          ],
        ),
      );
    }

    final Color edge = isLight
        ? Colors.white.withValues(alpha: 0.34)
        : scheme.outline.withValues(alpha: 0.45);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: fill, child: const SizedBox.expand()),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 1,
          child: ColoredBox(color: edge),
        ),
      ],
    );
  }
}
