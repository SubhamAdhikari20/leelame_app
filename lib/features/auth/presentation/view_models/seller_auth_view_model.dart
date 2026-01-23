// lib/features/auth/presentation/view_models/seller_auth_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/auth/domain/usecases/seller/seller_login_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/seller/seller_logout_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/seller/seller_sign_up_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/seller/seller_verify_account_registration_usecase.dart';
import 'package:leelame/features/auth/presentation/states/seller_auth_state.dart';

// Seller Auth View Model Notifier Provider
final sellerAuthViewModelProvider =
    NotifierProvider<SellerAuthViewModel, SellerAuthState>(() {
      return SellerAuthViewModel();
    });

class SellerAuthViewModel extends Notifier<SellerAuthState> {
  late final SellerSignUpUsecase _sellerSignUpUsecase;
  late final SellerLoginUsecase _sellerLoginUsecase;
  late final SellerLogoutUsecase _sellerLogoutUsecase;
  late final SellerVerifyAccountRegistrationUsecase
  _sellerVerifyAccountRegistrationUsecase;

  @override
  SellerAuthState build() {
    // Initialize
    _sellerSignUpUsecase = ref.read(sellerSignUpUsecaseProvider);
    _sellerLoginUsecase = ref.read(sellerLoginUsecaseProvider);
    _sellerLogoutUsecase = ref.read(sellerLogoutUsecaseProvider);
    _sellerVerifyAccountRegistrationUsecase = ref.read(
      sellerVerifyAccountRegistrationUsecaseProvider,
    );
    return SellerAuthState();
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? password,
    String? userId,
  }) async {
    state = state.copywith(sellerAuthStatus: SellerAuthStatus.loading);
    final sellerSignUpParams = SellerSignUpUsecaseParams(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );

    // Wait for few seconds
    await Future.delayed(Duration(seconds: 2));
    final result = await _sellerSignUpUsecase(sellerSignUpParams);

    result.fold(
      (failure) {
        state = state.copywith(
          sellerAuthStatus: SellerAuthStatus.signUpError,
          errorMessage: failure.message,
        );
      },
      (seller) {
        state = state.copywith(
          sellerAuthStatus: SellerAuthStatus.created,
          createdIdentifier: CreatedIdentifier(
            type: IdentifierType.email,
            value: email,
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
    state = state.copywith(sellerAuthStatus: SellerAuthStatus.loading);
    final sellerLoginParams = SellerLoginUsecaseParams(
      identifier: identifier,
      password: password,
      role: role,
    );

    // Wait for few seconds
    await Future.delayed(Duration(seconds: 3));
    final result = await _sellerLoginUsecase(sellerLoginParams);

    result.fold(
      (failure) {
        state = state.copywith(
          sellerAuthStatus: SellerAuthStatus.loginError,
          errorMessage: failure.message,
        );
      },
      (seller) {
        state = state.copywith(
          sellerAuthStatus: SellerAuthStatus.authenticated,
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copywith(sellerAuthStatus: SellerAuthStatus.loading);
    // Wait for few seconds
    await Future.delayed(Duration(seconds: 3));
    final result = await _sellerLogoutUsecase();

    result.fold(
      (failure) {
        state = state.copywith(
          sellerAuthStatus: SellerAuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isLoggedOut) {
        state = state.copywith(
          sellerAuthStatus: SellerAuthStatus.unauthenticated,
        );
      },
    );
  }

  Future<void> verifyAccountRegistration({
    required String email,
    required String otp,
  }) async {
    state = state.copywith(sellerAuthStatus: SellerAuthStatus.loading);
    final sellerVerifyAccountRegistrationParams =
        SellerVerifyAccountRegistrationUsecaseParams(email: email, otp: otp);

    // Wait for few seconds
    await Future.delayed(Duration(seconds: 3));
    final result = await _sellerVerifyAccountRegistrationUsecase(
      sellerVerifyAccountRegistrationParams,
    );

    result.fold(
      (failure) {
        state = state.copywith(
          sellerAuthStatus: SellerAuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        state = state.copywith(sellerAuthStatus: SellerAuthStatus.verified);
      },
    );
  }
}
