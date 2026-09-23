import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/utils/idempotency_key.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';

enum CheckoutStep { itens, festa, entrega, resumo }

class CheckoutFlowState {
  const CheckoutFlowState({
    required this.idempotencyKey,
    this.step = CheckoutStep.itens,
    this.selectedParty,
  });

  final CheckoutStep step;
  final Party? selectedParty;

  /// Chave estável reusada em retries técnicos da mesma tentativa de
  /// checkout; regenerada quando a festa selecionada muda ou o fluxo é
  /// reiniciado — ver `POST /orders/checkout` em `docs/api/openapi.json`.
  final String idempotencyKey;

  CheckoutFlowState copyWith({
    CheckoutStep? step,
    Party? selectedParty,
    String? idempotencyKey,
  }) {
    return CheckoutFlowState(
      step: step ?? this.step,
      selectedParty: selectedParty ?? this.selectedParty,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }
}

final checkoutFlowProvider =
    NotifierProvider<CheckoutFlowController, CheckoutFlowState>(
      CheckoutFlowController.new,
    );

class CheckoutFlowController extends Notifier<CheckoutFlowState> {
  @override
  CheckoutFlowState build() =>
      CheckoutFlowState(idempotencyKey: generateIdempotencyKey());

  void selectParty(Party party) {
    final changed = state.selectedParty?.id != party.id;
    state = state.copyWith(
      selectedParty: party,
      idempotencyKey: changed ? generateIdempotencyKey() : null,
    );
  }

  void goTo(CheckoutStep step) {
    state = state.copyWith(step: step);
  }

  void next() {
    const steps = CheckoutStep.values;
    final index = steps.indexOf(state.step);
    if (index < steps.length - 1) {
      state = state.copyWith(step: steps[index + 1]);
    }
  }

  void back() {
    const steps = CheckoutStep.values;
    final index = steps.indexOf(state.step);
    if (index > 0) {
      state = state.copyWith(step: steps[index - 1]);
    }
  }

  void reset() {
    state = CheckoutFlowState(idempotencyKey: generateIdempotencyKey());
  }
}
