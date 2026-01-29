// lib/features/auth/presentation/view_models/buyer_auth_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_get_current_user_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_login_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_logout_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_sign_up_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_verify_account_registration_usecase.dart';
import 'package:leelame/features/auth/presentation/states/buyer_auth_state.dart';

// Buyer Auth View Model Notifier Provider
final buyerAuthViewModelProvider =
    NotifierProvider<BuyerAuthViewModel, BuyerAuthState>(() {
      return BuyerAuthViewModel();
    });

class BuyerAuthViewModel extends Notifier<BuyerAuthState> {
  late final BuyerSignUpUsecase _buyerSignUpUsecase;
  late final BuyerLoginUsecase _buyerLoginUsecase;
  late final BuyerLogoutUsecase _buyerLogoutUsecase;
  late final BuyerVerifyAccountRegistrationUsecase
  _buyerVerifyAccountRegistrationUsecase;
  late final BuyerGetCurrentUserUsecase _buyerGetCurrentUserUsecase;

  @override
  BuyerAuthState build() {
    // Initialize
    _buyerSignUpUsecase = ref.read(buyerSignUpUsecaseProvider);
    _buyerLoginUsecase = ref.read(buyerLoginUsecaseProvider);
    _buyerLogoutUsecase = ref.read(buyerLogoutUsecaseProvider);
    _buyerVerifyAccountRegistrationUsecase = ref.read(
      buyerVerifyAccountRegistrationUsecaseProvider,
    );
    _buyerGetCurrentUserUsecase = ref.read(buyerGetCurrentUserUsecaseProvider);
    return BuyerAuthState();
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    String? username,
    String? phoneNumber,
    String? password,
    required bool termsAccepted,
    String? userId,
  }) async {
    state = state.copywith(buyerAuthStatus: BuyerAuthStatus.loading);
    final buyerSignUpParams = BuyerSignUpUsecaseParams(
      fullName: fullName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      termsAccepted: termsAccepted,
    );

    // Wait for few seconds
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
        state = state.copywith(
          buyerAuthStatus: BuyerAuthStatus.created,
          createdIdentifier: CreatedIdentifier(
            type: IdentifierType.username,
            value: username,
          ),
        );
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

    // Wait for few seconds
    await Future.delayed(Duration(seconds: 3));
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

  Future<void> logout() async {
    state = state.copywith(buyerAuthStatus: BuyerAuthStatus.loading);
    // Wait for few seconds
    await Future.delayed(Duration(seconds: 3));
    final result = await _buyerLogoutUsecase();

    result.fold(
      (failure) {
        state = state.copywith(
          buyerAuthStatus: BuyerAuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isLoggedOut) {
        state = state.copywith(
          buyerAuthStatus: BuyerAuthStatus.unauthenticated,
        );
      },
    );
  }

  Future<void> verifyAccountRegistration({
    required String username,
    required String otp,
  }) async {
    state = state.copywith(buyerAuthStatus: BuyerAuthStatus.loading);
    final buyerVerifyAccountRegistrationParams =
        BuyerVerifyAccountRegistrationUsecaseParams(
          username: username,
          otp: otp,
        );

    // Wait for few seconds
    await Future.delayed(Duration(seconds: 3));
    final result = await _buyerVerifyAccountRegistrationUsecase(
      buyerVerifyAccountRegistrationParams,
    );

    result.fold(
      (failure) {
        state = state.copywith(
          buyerAuthStatus: BuyerAuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        state = state.copywith(buyerAuthStatus: BuyerAuthStatus.verified);
      },
    );
  }

  Future<void> getCurrentUser({required String buyerId}) async {
    state = state.copywith(buyerAuthStatus: BuyerAuthStatus.loading);

    final result = await _buyerGetCurrentUserUsecase(
      BuyerGetCurrentUserUsecaseParams(buyerId: buyerId),
    );

    result.fold(
      (failure) {
        state = state.copywith(
          buyerAuthStatus: BuyerAuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (buyer) {
        state = state.copywith(
          buyerAuthStatus: BuyerAuthStatus.loaded,
          buyer: buyer,
        );
      },
    );
  }
}
