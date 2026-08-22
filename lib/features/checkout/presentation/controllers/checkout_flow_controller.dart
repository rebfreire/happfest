import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';

enum CheckoutStep { itens, festa, entrega, resumo }

class CheckoutFlowState {
  const CheckoutFlowState({
    this.step = CheckoutStep.itens,
    this.selectedParty,
  });

  final CheckoutStep step;
  final Party? selectedParty;

  CheckoutFlowState copyWith({CheckoutStep? step, Party? selectedParty}) {
    return CheckoutFlowState(
      step: step ?? this.step,
      selectedParty: selectedParty ?? this.selectedParty,
    );
  }
}

final checkoutFlowProvider =
    NotifierProvider<CheckoutFlowController, CheckoutFlowState>(
      CheckoutFlowController.new,
    );

class CheckoutFlowController extends Notifier<CheckoutFlowState> {
  @override
  CheckoutFlowState build() => const CheckoutFlowState();

  void selectParty(Party party) {
    state = state.copyWith(selectedParty: party);
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
    state = const CheckoutFlowState();
  }
}
