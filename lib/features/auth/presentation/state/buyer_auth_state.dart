// lib/features/auth/presentation/state/buyer_auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

enum BuyerAuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  created,
  error,
}

class BuyerAuthState extends Equatable {
  final BuyerAuthStatus buyerAuthStatus;
  final List<BuyerEntity> buyers;
  final String? errorMessage;

  const BuyerAuthState({
    this.buyerAuthStatus = BuyerAuthStatus.initial,
    this.buyers = const [],
    this.errorMessage,
  });

  // copywith function
  BuyerAuthState copywith({
    BuyerAuthStatus? buyerAuthStatus,
    List<BuyerEntity>? buyers,
    String? errorMessage,
  }) {
    return BuyerAuthState(
      buyerAuthStatus: buyerAuthStatus ?? this.buyerAuthStatus,
      buyers: buyers ?? this.buyers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [buyerAuthStatus, buyers, errorMessage];
}
