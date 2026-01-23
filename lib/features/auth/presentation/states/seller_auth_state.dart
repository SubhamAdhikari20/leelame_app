// lib/features/auth/presentation/states/seller_auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';

enum SellerAuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  created,
  verified,
  error,
}

enum IdentifierType { email, phoneNumber, id }

class CreatedIdentifier extends Equatable {
  final IdentifierType type;
  final String? value;

  const CreatedIdentifier({required this.type, this.value});

  @override
  List<Object?> get props => [type, value];

  @override
  String toString() => "CreatedIdentifier(type: $type, value: $value)";
}

class SellerAuthState extends Equatable {
  final SellerAuthStatus sellerAuthStatus;
  final List<SellerEntity> sellers;
  final String? errorMessage;
  final CreatedIdentifier? createdIdentifier;

  const SellerAuthState({
    this.sellerAuthStatus = SellerAuthStatus.initial,
    this.sellers = const [],
    this.errorMessage,
    this.createdIdentifier,
  });

  // copywith function
  SellerAuthState copywith({
    SellerAuthStatus? sellerAuthStatus,
    List<SellerEntity>? sellers,
    String? errorMessage,
    CreatedIdentifier? createdIdentifier,
  }) {
    return SellerAuthState(
      sellerAuthStatus: sellerAuthStatus ?? this.sellerAuthStatus,
      sellers: sellers ?? this.sellers,
      errorMessage: errorMessage ?? this.errorMessage,
      createdIdentifier: createdIdentifier ?? this.createdIdentifier,
    );
  }

  @override
  List<Object?> get props => [
    sellerAuthStatus,
    sellers,
    errorMessage,
    createdIdentifier,
  ];
}
