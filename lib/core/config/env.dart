import 'package:happfest/core/config/flavor.dart';

/// App-wide runtime configuration, resolved from `--dart-define` values
/// injected per flavor (see `app/di/providers.dart` and the `main_*.dart`
/// entrypoints). All three flavors currently point at the same production
/// API — see AGENTS.md seção 0.
class Env {
  const Env({
    required this.flavor,
    required this.apiBaseUrl,
    required this.isDebug,
  });

  factory Env.fromFlavor(Flavor flavor) {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://happ-api.comcode.com.br/api/v1',
    );
    return Env(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      isDebug: flavor != Flavor.prod,
    );
  }

  final Flavor flavor;
  final String apiBaseUrl;
  final bool isDebug;
}
