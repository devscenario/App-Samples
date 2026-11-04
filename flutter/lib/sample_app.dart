import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'backend/backend_strings.dart';
import 'screens/backend_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/dragdrop_screen.dart';
import 'screens/grid_screen.dart';
import 'screens/list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/modals_screen.dart';
import 'screens/network_screen.dart';
import 'screens/pinch_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/search_screen.dart';
import 'screens/showcase_screen.dart';
import 'sample_locale.dart';
import 'sample_strings.dart';
import 'test_tags.dart';

class SampleScreenDef {
  const SampleScreenDef(this.titleOf, this.tag, this.icon, this.builder);

  /// Localized title resolver — the home tile and the detail AppBar read this
  /// against the active [SampleStrings] so titles follow the language toggle.
  final String Function(SampleStrings) titleOf;
  final String tag;
  final IconData icon;
  final WidgetBuilder builder;
}

final List<SampleScreenDef> sampleScreens = [
  SampleScreenDef((s) => s.titleLogin, TestTags.tabLogin, Icons.login, (_) => const LoginScreen()),
  SampleScreenDef((s) => s.titleRegistration, TestTags.tabRegistration, Icons.app_registration, (_) => const RegistrationScreen()),
  SampleScreenDef((s) => s.titleList, TestTags.tabList, Icons.list, (_) => const ListScreen()),
  SampleScreenDef((s) => s.titleGrid, TestTags.tabGrid, Icons.grid_view, (_) => const GridScreen()),
  SampleScreenDef((s) => s.titleShowcase, TestTags.tabShowcase, Icons.widgets, (_) => const ShowcaseScreen()),
  SampleScreenDef((s) => s.titleSearch, TestTags.tabSearch, Icons.search, (_) => const SearchScreen()),
  SampleScreenDef((s) => s.titleCheckout, TestTags.tabCheckout, Icons.shopping_cart_checkout, (_) => const CheckoutScreen()),
  SampleScreenDef((s) => s.titleProfile, TestTags.tabProfile, Icons.person, (_) => const ProfileScreen()),
  SampleScreenDef((s) => s.titlePinch, TestTags.tabPinch, Icons.pinch, (_) => const PinchScreen()),
  SampleScreenDef((s) => s.titleModals, TestTags.tabModals, Icons.layers, (_) => const ModalsScreen()),
  SampleScreenDef((s) => s.titleDragDrop, TestTags.tabDragDrop, Icons.drag_indicator, (_) => const DragDropScreen()),
  SampleScreenDef((s) => s.titleNetwork, TestTags.tabNetwork, Icons.cloud, (_) => const NetworkScreen()),
  SampleScreenDef((s) => backendStringsOf(s).title, TestTags.tabBackend, Icons.dns, (_) => const BackendScreen()),
];

class SampleApp extends StatelessWidget {
  const SampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Root scope holds the in-app language and exposes SampleStrings down the
    // tree. The MaterialApp is built via a Builder *inside* the scope so it
    // depends on SampleLocale and rebuilds when the language toggles — that
    // lets us drive MaterialApp.locale from the same active language.
    return SampleLocaleScope(
      child: Builder(
        builder: (context) {
          final language = SampleLocale.languageOf(context);
          return MaterialApp(
            title: 'Dev Scenario Flutter Sample',
            debugShowCheckedModeBanner: false,
            // The active in-app language IS the app locale: ka -> Georgian,
            // anything else -> English. Framework widgets (date pickers, tooltips,
            // a11y strings) localize via the delegates below.
            locale: Locale(
              language == SampleLanguage.georgian ? 'ka' : 'en',
            ),
            supportedLocales: const [Locale('en'), Locale('ka')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme:
                  ColorScheme.fromSeed(seedColor: const Color(0xFF3D5AFE)),
              useMaterial3: true,
            ),
            // Every route is wrapped with the touch-feedback overlay + app-root tag.
            builder: (context, child) => _TouchFeedback(
              child: KeyedSubtree(
                  key: const ValueKey(TestTags.appRoot), child: child!),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

/// Language chooser rendered in the AppBar `actions` slot (right corner).
/// A [PopupMenuButton] with two items (English, Georgian); the active language
/// is checkmarked. Mirrors the CMP sample's chooser and test tags.
class LanguageChooser extends StatelessWidget {
  const LanguageChooser({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    final active = SampleLocale.languageOf(context);
    return PopupMenuButton<SampleLanguage>(
      key: const ValueKey(TestTags.actionLanguage),
      icon: const Icon(Icons.language),
      tooltip: strings.languageChooser,
      onSelected: (lang) => SampleLocaleScope.of(context).setLanguage(lang),
      itemBuilder: (context) => [
        _item(
          value: SampleLanguage.english,
          label: strings.languageEnglish,
          tag: TestTags.langEnglish,
          active: active == SampleLanguage.english,
        ),
        _item(
          value: SampleLanguage.georgian,
          label: strings.languageGeorgian,
          tag: TestTags.langGeorgian,
          active: active == SampleLanguage.georgian,
        ),
      ],
    );
  }

  PopupMenuItem<SampleLanguage> _item({
    required SampleLanguage value,
    required String label,
    required String tag,
    required bool active,
  }) {
    return PopupMenuItem<SampleLanguage>(
      key: ValueKey(tag),
      value: value,
      child: Row(
        children: [
          Icon(active ? Icons.check : null, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.titleHome, key: const ValueKey(TestTags.navTitle)),
        actions: const [LanguageChooser()],
      ),
      body: GridView.count(
        key: const ValueKey(TestTags.homeGrid),
        crossAxisCount: 2,
        padding: const EdgeInsets.all(12),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
        children: [
          for (final s in sampleScreens)
            Card(
              key: ValueKey(s.tag),
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => DetailPage(def: s)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(s.icon, size: 40),
                    const SizedBox(height: 12),
                    Text(s.titleOf(strings),
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Detail scaffold: a `BackButton` (tagged) + the screen title (tagged), and a
/// deterministic loader before the screen content (parity with the CMP sample).
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.def});
  final SampleScreenDef def;

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(key: const ValueKey(TestTags.navBack)),
        title: Text(def.titleOf(strings),
            key: const ValueKey(TestTags.navTitle)),
        actions: const [LanguageChooser()],
      ),
      body: LoadingGate(child: Builder(builder: def.builder)),
    );
  }
}

/// Shows a spinner for ~1.2s, then the child — mirrors the CMP sample's
/// per-screen loader so flows that wait for content behave the same.
class LoadingGate extends StatefulWidget {
  const LoadingGate({super.key, required this.child});
  final Widget child;

  @override
  State<LoadingGate> createState() => _LoadingGateState();
}

class _LoadingGateState extends State<LoadingGate> {
  bool _ready = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ready
        ? widget.child
        : const Center(child: CircularProgressIndicator());
  }
}

/// Draws a transient green circle at each tap-down — non-consuming, so taps
/// still reach widgets (visual tracing for runs).
class _TouchFeedback extends StatefulWidget {
  const _TouchFeedback({required this.child});
  final Widget child;

  @override
  State<_TouchFeedback> createState() => _TouchFeedbackState();
}

class _TouchFeedbackState extends State<_TouchFeedback> {
  final List<_Ripple> _ripples = [];

  void _add(Offset pos) {
    final r = _Ripple(pos);
    setState(() => _ripples.add(r));
    Timer(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _ripples.remove(r));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => _add(e.position),
      child: Stack(
        children: [
          widget.child,
          for (final r in _ripples)
            Positioned(
              left: r.pos.dx - 24,
              top: r.pos.dy - 24,
              child: IgnorePointer(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.72),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Ripple {
  _Ripple(this.pos);
  final Offset pos;
}
