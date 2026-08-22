import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/location/brazilian_location.dart';
import 'package:happfest/core/location/ibge_location_datasource.dart';
import 'package:happfest/core/location/via_cep_datasource.dart';

final ibgeLocationDataSourceProvider = Provider<IbgeLocationDataSource>(
  (ref) => IbgeLocationDataSource(),
);

final viaCepDataSourceProvider = Provider<ViaCepDataSource>(
  (ref) => ViaCepDataSource(),
);

final brazilianStatesProvider = FutureProvider<List<BrazilianState>>((ref) {
  return ref.watch(ibgeLocationDataSourceProvider).getStates();
});

// FutureProviderFamily não é exportado publicamente pelo flutter_riverpod,
// então o tipo não pode ser anotado explicitamente aqui.
// ignore: specify_nonobvious_property_types
final brazilianCitiesProvider = FutureProvider.family<List<BrazilianCity>, int>(
  (ref, stateCode) {
    return ref.watch(ibgeLocationDataSourceProvider).getCities(stateCode);
  },
);
