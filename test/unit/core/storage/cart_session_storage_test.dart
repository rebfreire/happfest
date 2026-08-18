import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/storage/cart_session_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockFlutterSecureStorage secureStorage;
  late CartSessionStorage storage;

  const key = 'happfest.cart_session_id';

  setUpAll(() {
    registerFallbackValue(AndroidOptions.defaultOptions);
    registerFallbackValue(IOSOptions.defaultOptions);
  });

  setUp(() {
    secureStorage = _MockFlutterSecureStorage();
    storage = CartSessionStorage(secureStorage);
  });

  test(
    'returns the existing session id without generating a new one',
    () async {
      when(
        () => secureStorage.read(key: key),
      ).thenAnswer((_) async => 'existing-id');

      final id = await storage.readOrCreateSessionId();

      expect(id, 'existing-id');
      verifyNever(
        () => secureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      );
    },
  );

  test('generates and persists a v4-shaped id when none exists', () async {
    when(() => secureStorage.read(key: key)).thenAnswer((_) async => null);
    when(
      () => secureStorage.write(
        key: key,
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});

    final id = await storage.readOrCreateSessionId();

    const uuidV4Pattern =
        '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-'
        r'[0-9a-f]{12}$';
    expect(id, matches(RegExp(uuidV4Pattern)));
    verify(() => secureStorage.write(key: key, value: id)).called(1);
  });

  test('clear deletes the stored session id', () async {
    when(() => secureStorage.delete(key: key)).thenAnswer((_) async {});

    await storage.clear();

    verify(() => secureStorage.delete(key: key)).called(1);
  });
}
