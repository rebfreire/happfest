import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/app/app.dart';
import 'package:happfest/app/di/providers.dart';
import 'package:happfest/core/config/env.dart';
import 'package:happfest/core/config/flavor.dart';

Future<void> bootstrap(Flavor flavor) async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final env = Env.fromFlavor(flavor);
      await _initFirebase(env);

      runApp(
        ProviderScope(
          overrides: [envProvider.overrideWithValue(env)],
          child: const HappFestApp(),
        ),
      );
    },
    (error, stackTrace) {
      developer.log('Uncaught error', error: error, stackTrace: stackTrace);
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: true,
        ),
      );
    },
  );
}

/// Firebase precisa de um projeto real configurado via `flutterfire configure`
/// (login interativo) antes de funcionar — ver AGENTS.md seção 0. Sem isso,
/// `Firebase.initializeApp` lança e o app segue rodando sem
/// analytics/crash reporting, para não travar o setup local.
Future<void> _initFirebase(Env env) async {
  try {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
      !env.isDebug,
    );
  } on Exception catch (error, stackTrace) {
    developer.log(
      'Firebase não configurado — rode `flutterfire configure`.',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
