// test/features/auth/presentation/view_models/buyer_view_model_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_login_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_logout_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_sign_up_usecase.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_verify_account_registration_usecase.dart';
import 'package:leelame/features/auth/presentation/states/buyer_auth_state.dart';
import 'package:leelame/features/auth/presentation/view_models/buyer_auth_view_model.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockBuyerSignUpUsecase extends Mock implements BuyerSignUpUsecase {}

class MockBuyerVerifyAccountRegistrationUsecase extends Mock
    implements BuyerVerifyAccountRegistrationUsecase {}

class MockBuyerLoginUsecase extends Mock implements BuyerLoginUsecase {}

class MockBuyerLogoutUsecase extends Mock implements BuyerLogoutUsecase {}

void main() {
  late MockBuyerSignUpUsecase mockBuyerSignUpUsecase;
  late MockBuyerVerifyAccountRegistrationUsecase
  mockBuyerVerifyAccountRegistrationUsecase;
  late MockBuyerLoginUsecase mockBuyerLoginUsecase;
  late MockBuyerLogoutUsecase mockBuyerLogoutUsecase;
  late ProviderContainer providerContainer;

  setUpAll(() {
    registerFallbackValue(
      const BuyerSignUpUsecaseParams(
        fullName: "fallback",
        email: "fallback",
        username: "fallback",
        password: "fallback",
        phoneNumber: "fallback",
        termsAccepted: true,
      ),
    );
    registerFallbackValue(
      const BuyerVerifyAccountRegistrationUsecaseParams(
        otp: "fallback",
        username: "fallback",
      ),
    );
    registerFallbackValue(
      const BuyerLoginUsecaseParams(
        identifier: "fallback",
        password: "fallback",
        role: "fallback",
      ),
    );
  });

  setUp(() {
    mockBuyerSignUpUsecase = MockBuyerSignUpUsecase();
    mockBuyerVerifyAccountRegistrationUsecase =
        MockBuyerVerifyAccountRegistrationUsecase();
    mockBuyerLoginUsecase = MockBuyerLoginUsecase();
    mockBuyerLogoutUsecase = MockBuyerLogoutUsecase();

    providerContainer = ProviderContainer(
      overrides: [
        buyerSignUpUsecaseProvider.overrideWithValue(mockBuyerSignUpUsecase),
        buyerVerifyAccountRegistrationUsecaseProvider.overrideWithValue(
          mockBuyerVerifyAccountRegistrationUsecase,
        ),
        buyerLoginUsecaseProvider.overrideWithValue(mockBuyerLoginUsecase),
        buyerLogoutUsecaseProvider.overrideWithValue(mockBuyerLogoutUsecase),
      ],
    );
  });

  tearDown(() {
    providerContainer.dispose();
  });

  const tFullName = "New Buyer";
  const tUsername = "newbuyer123";
  const tPassword = "newuser@123";
  const tPhoneNumber = "9876543210";
  const tEmail = "newuser@gmail.com";
  const tRole = "buyer";
  const tIsVerified = false;
  const tTerms = false;
  const tIsPermanentlyBanned = false;
  // const tBaseUserId = "test-base-user-id";

  final tUserEntity = UserEntity(
    email: tEmail,
    role: tRole,
    isVerified: tIsVerified,
    isPermanentlyBanned: tIsPermanentlyBanned,
  );

  final tBuyerEntity = BuyerEntity(
    fullName: tFullName,
    username: tUsername,
    password: tPassword,
    phoneNumber: tPhoneNumber,
    termsAccepted: tTerms,
    userEntity: tUserEntity,
  );

  const tOtp = "123456";

  group("sign up buyer view model", () {
    test("should emit created state when sign up successful.", () async {
      // Arrange
      when(() {
        return mockBuyerSignUpUsecase(any());
      }).thenAnswer((_) async {
        return Right(tBuyerEntity);
      });

      final viewModel = providerContainer.read(
        buyerAuthViewModelProvider.notifier,
      );

      // Act
      await viewModel.signUp(
        email: tEmail,
        fullName: tFullName,
        username: tUsername,
        password: tPassword,
        phoneNumber: tPhoneNumber,
        termsAccepted: tTerms,
      );

      // Assert
      final state = providerContainer.read(buyerAuthViewModelProvider);
      expect(state.buyerAuthStatus, BuyerAuthStatus.created);
      expect(state.createdIdentifier, isNotNull);
      expect(state.createdIdentifier!.type, IdentifierType.username);
      expect(state.createdIdentifier!.value, tUsername);
      verify(() => mockBuyerSignUpUsecase(any())).called(1);
    });

    test("should emit error state when failed during sign up.", () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to sign up buyer');
      when(() {
        return mockBuyerSignUpUsecase(any());
      }).thenAnswer((_) async {
        return const Left(failure);
      });

      final viewModel = providerContainer.read(
        buyerAuthViewModelProvider.notifier,
      );

      // Act
      await viewModel.signUp(
        email: tEmail,
        fullName: tFullName,
        username: tUsername,
        password: tPassword,
        phoneNumber: tPhoneNumber,
        termsAccepted: tTerms,
      );

      // Assert
      final state = providerContainer.read(buyerAuthViewModelProvider);
      expect(state.buyerAuthStatus, BuyerAuthStatus.error);
      expect(state.errorMessage, 'Failed to sign up buyer');
      verify(() => mockBuyerSignUpUsecase(any())).called(1);
    });
  });

  group("verifiy acount", () {
    test("should emit verified state when successful.", () async {
      // Arrange
      when(() {
        return mockBuyerVerifyAccountRegistrationUsecase(any());
      }).thenAnswer((_) async {
        return Right(true);
      });

      final viewModel = providerContainer.read(
        buyerAuthViewModelProvider.notifier,
      );

      // Act
      await viewModel.verifyAccountRegistration(username: tUsername, otp: tOtp);

      // Assert
      final state = providerContainer.read(buyerAuthViewModelProvider);
      expect(state.buyerAuthStatus, BuyerAuthStatus.verified);
      verify(() => mockBuyerVerifyAccountRegistrationUsecase(any())).called(1);
    });

    test(
      "should emit error state when failed during verifying account.",
      () async {
        // Arrange
        const failure = ApiFailure(message: 'Failed to verify account');
        when(() {
          return mockBuyerVerifyAccountRegistrationUsecase(any());
        }).thenAnswer((_) async {
          return const Left(failure);
        });

        final viewModel = providerContainer.read(
          buyerAuthViewModelProvider.notifier,
        );

        // Act
        await viewModel.verifyAccountRegistration(
          username: tUsername,
          otp: tOtp,
        );

        // Assert
        final state = providerContainer.read(buyerAuthViewModelProvider);
        expect(state.buyerAuthStatus, BuyerAuthStatus.error);
        expect(state.errorMessage, 'Failed to verify account');
        verify(
          () => mockBuyerVerifyAccountRegistrationUsecase(any()),
        ).called(1);
      },
    );
  });
}
