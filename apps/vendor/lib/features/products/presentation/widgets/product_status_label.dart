import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';

String productStatusLabel(ProductStatus status) {
  return switch (status) {
    ProductStatus.draft => 'Rascunho',
    ProductStatus.published => 'Publicado',
    ProductStatus.paused => 'Pausado',
    ProductStatus.archived => 'Arquivado',
  };
}
