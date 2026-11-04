import 'package:devscenario_app_instrumentation/devscenario_app_instrumentation.dart';
import 'package:devscenario_httpinterceptor/devscenario_httpinterceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'sample_app.dart';

/// Where the Dev Scenario desktop server is reachable (network interceptor).
/// Override for a physical device, e.g.
/// `flutter run --dart-define=DEVSCENARIO_HOST=192.168.1.20`.
const String _desktopHost =
    String.fromEnvironment('DEVSCENARIO_HOST', defaultValue: 'localhost');
const int _desktopPort =
    int.fromEnvironment('DEVSCENARIO_PORT', defaultValue: 8080);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug builds only — both open the app to the host machine.
  if (kDebugMode) {
    // Network: capture/mocking in the desktop Network tab.
    DevScenarioHttpInterceptor.enable(host: _desktopHost, port: _desktopPort);
    // Automation: the desktop Inspector / flows drive the app (In-app SDK mode).
    DevScenarioAppInstrumentation.start();
  }

  runApp(const SampleApp());
}
