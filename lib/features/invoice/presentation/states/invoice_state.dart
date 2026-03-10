// lib/features/presentation/states/invoice_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/invoice/domain/entities/invoice_entity.dart';

enum InvoiceViewStatus { initial, loading, generated, error }

class InvoiceState extends Equatable {
  final InvoiceViewStatus status;
  final InvoiceEntity? invoice;
  final String? errorMessage;

  const InvoiceState({
    this.status = InvoiceViewStatus.initial,
    this.invoice,
    this.errorMessage,
  });

  InvoiceState copyWith({
    InvoiceViewStatus? status,
    InvoiceEntity? invoice,
    String? errorMessage,
  }) {
    return InvoiceState(
      status: status ?? this.status,
      invoice: invoice ?? this.invoice,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, invoice, errorMessage];
}
