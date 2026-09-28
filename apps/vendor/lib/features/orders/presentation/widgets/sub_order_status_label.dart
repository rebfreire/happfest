import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';

String subOrderStatusLabel(SubOrderStatus status) {
  return switch (status) {
    SubOrderStatus.awaitingPayment => 'Aguardando pagamento',
    SubOrderStatus.pending => 'Pendente',
    SubOrderStatus.accepted => 'Aceito',
    SubOrderStatus.delivered => 'Entregue',
    SubOrderStatus.contested => 'Contestado',
    SubOrderStatus.completed => 'Concluído',
    SubOrderStatus.cancelled => 'Cancelado',
    SubOrderStatus.rejected => 'Rejeitado',
  };
}
