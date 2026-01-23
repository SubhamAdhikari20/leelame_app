// lib/features/auth/presentation/states/buyer_auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

enum BuyerAuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  created,
  verified,
  error,
}

enum IdentifierType { username, email, phoneNumber, id }

class CreatedIdentifier extends Equatable {
  final IdentifierType type;
  final String? value;

  const CreatedIdentifier({required this.type, this.value});

  @override
  List<Object?> get props => [type, value];

  @override
  String toString() => "CreatedIdentifier(type: $type, value: $value)";
}

class BuyerAuthState extends Equatable {
  final BuyerAuthStatus buyerAuthStatus;
  final List<BuyerEntity> buyers;
  final String? errorMessage;
  final CreatedIdentifier? createdIdentifier;

  const BuyerAuthState({
    this.buyerAuthStatus = BuyerAuthStatus.initial,
    this.buyers = const [],
    this.errorMessage,
    this.createdIdentifier,
  });

  // copywith function
  BuyerAuthState copywith({
    BuyerAuthStatus? buyerAuthStatus,
    List<BuyerEntity>? buyers,
    String? errorMessage,
    CreatedIdentifier? createdIdentifier,
  }) {
    return BuyerAuthState(
      buyerAuthStatus: buyerAuthStatus ?? this.buyerAuthStatus,
      buyers: buyers ?? this.buyers,
      errorMessage: errorMessage ?? this.errorMessage,
      createdIdentifier: createdIdentifier ?? this.createdIdentifier,
    );
  }

  @override
  List<Object?> get props => [
    buyerAuthStatus,
    buyers,
    errorMessage,
    createdIdentifier,
  ];
}
