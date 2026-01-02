// lib/features/auth/presentation/view_model/buyer_auth_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/auth/domain/usecases/buyer_login_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/buyer_sign_up_usecase.dart';
import 'package:leelame/features/auth/presentation/state/buyer_auth_state.dart';

// Buyer Auth View Model Notifier Provider
final buyerAuthViewModelProvider =
    NotifierProvider<BuyerAuthViewModel, BuyerAuthState>(() {
      return BuyerAuthViewModel();
    });

class BuyerAuthViewModel extends Notifier<BuyerAuthState> {
  late final BuyerSignUpUsecase _buyerSignUpUsecase;
  late final BuyerLoginUsecase _buyerLoginUsecase;

  @override
  BuyerAuthState build() {
    // Initialize
    _buyerSignUpUsecase = ref.read(buyerSignUpUsecaseProvider);
    _buyerLoginUsecase = ref.read(buyerLoginUsecaseProvider);
    return BuyerAuthState();
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    String? username,
    String? phoneNumber,
    String? password,
    required String role,
    required bool isVerified,
    required bool termsAccepted,
    required bool isPermanentlyBanned,
    String? userId,
  }) async {
    state = state.copywith(buyerAuthStatus: BuyerAuthStatus.loading);
    final buyerSignUpParams = BuyerSignUpUsecaseParams(
      fullName: fullName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      role: role,
      isVerified: isVerified,
      termsAccepted: termsAccepted,
      isPermanentlyBanned: isPermanentlyBanned,
    );

    // Wait for new seconds
    await Future.delayed(Duration(seconds: 2));
    final result = await _buyerSignUpUsecase(buyerSignUpParams);

    result.fold(
      (failure) {
        state = state.copywith(
          buyerAuthStatus: BuyerAuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (buyer) {
        state = state.copywith(buyerAuthStatus: BuyerAuthStatus.created);
      },
    );
  }

  Future<void> login({
    required String identifier,
    required String password,
    required String role,
  }) async {
    state = state.copywith(buyerAuthStatus: BuyerAuthStatus.loading);
    final buyerLoginParams = BuyerLoginUsecaseParams(
      identifier: identifier,
      password: password,
      role: role,
    );

    final result = await _buyerLoginUsecase(buyerLoginParams);

    result.fold(
      (failure) {
        state = state.copywith(
          buyerAuthStatus: BuyerAuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (buyer) {
        state = state.copywith(buyerAuthStatus: BuyerAuthStatus.authenticated);
      },
    );
  }
}
