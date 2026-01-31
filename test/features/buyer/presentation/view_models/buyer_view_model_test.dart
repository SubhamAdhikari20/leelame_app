import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:leelame/features/buyer/domain/usecases/buyer_get_current_user_usecase.dart';
import 'package:leelame/features/buyer/domain/usecases/upload_buyer_profile_picture_usecase.dart';
import 'package:leelame/features/buyer/presentation/states/buyer_state.dart';
import 'package:leelame/features/buyer/presentation/view_models/buyer_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockBuyerGetCurrentUserUsecase extends Mock
    implements BuyerGetCurrentUserUsecase {}

class MockUploadBuyerProfilePictureUsecase extends Mock
    implements UploadBuyerProfilePictureUsecase {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockTokenService extends Mock implements TokenService {}

void main() {
  late MockBuyerGetCurrentUserUsecase mockBuyerGetCurrentUserUsecase;
  late MockUploadBuyerProfilePictureUsecase
  mockUploadBuyerProfilePictureUsecase;
  late MockSharedPreferences mockSharedPreferences;
  late MockTokenService mockTokenService;
  late ProviderContainer providerContainer;

  setUpAll(() {
    registerFallbackValue(
      const BuyerGetCurrentUserUsecaseParams(buyerId: "fallback"),
    );
    registerFallbackValue(
      UploadBuyerProfilePictureUsecaseParams(
        buyerId: "fallback",
        profilePicture: File("fallback.jpg"),
      ),
    );
  });

  setUp(() {
    mockBuyerGetCurrentUserUsecase = MockBuyerGetCurrentUserUsecase();
    mockUploadBuyerProfilePictureUsecase =
        MockUploadBuyerProfilePictureUsecase();
    mockSharedPreferences = MockSharedPreferences();
    mockTokenService = MockTokenService();

    providerContainer = ProviderContainer(
      overrides: [
        buyerGetCurrentUserUsecaseProvider.overrideWithValue(
          mockBuyerGetCurrentUserUsecase,
        ),
        uploadBuyerProfilePictureUsecaseProvider.overrideWithValue(
          mockUploadBuyerProfilePictureUsecase,
        ),
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        tokenServiceProvider.overrideWithValue(mockTokenService),
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
    profilePictureUrl: "https://example.com/old-pic.jpg",
  );

  const tBuyerId = "test-buyer-user-id";
  final tFile = File("test_profile_picture.jpg");
  const tReturnedUrl =
      "https://http://10.0.2.2:3000/uploads/buyers/profile.jpg";

  group("get current buyer view model test", () {
    test("should emit loaded state and set buyer when successful.", () async {
      // Arrange
      when(() {
        return mockBuyerGetCurrentUserUsecase(any());
      }).thenAnswer((_) async {
        return Right(tBuyerEntity);
      });

      final viewModel = providerContainer.read(buyerViewModelProvider.notifier);

      // Act
      await viewModel.getCurrentUser(buyerId: tBuyerId);

      // Assert
      final state = providerContainer.read(buyerViewModelProvider);
      expect(state.buyerStatus, BuyerStatus.loaded);
      expect(state.buyer, tBuyerEntity);
      expect(state.errorMessage, isNull);
      expect(state.uploadedProfilePictureUrl, isNull);
      verify(() => mockBuyerGetCurrentUserUsecase(any())).called(1);
    });

    test(
      "should emit error state and set message when usecase fails.",
      () async {
        // Arrange
        const failure = ApiFailure(message: 'Buyer not found or server error');
        when(() {
          return mockBuyerGetCurrentUserUsecase(any());
        }).thenAnswer((_) async {
          return const Left(failure);
        });

        final viewModel = providerContainer.read(
          buyerViewModelProvider.notifier,
        );

        // Act
        await viewModel.getCurrentUser(buyerId: tBuyerId);

        // Assert
        final state = providerContainer.read(buyerViewModelProvider);
        expect(state.buyerStatus, BuyerStatus.error);
        expect(state.errorMessage, failure.message);
        expect(state.buyer, isNull);
        verify(() => mockBuyerGetCurrentUserUsecase(any())).called(1);
      },
    );
  });

  group("upload profile picture view model test", () {
    test(
      "should emit imageLoaded and set uploaded url when successful",
      () async {
        // Arrange
        when(() {
          return mockUploadBuyerProfilePictureUsecase(any());
        }).thenAnswer((_) async {
          return Right(tReturnedUrl);
        });

        final viewModel = providerContainer.read(
          buyerViewModelProvider.notifier,
        );

        // Act
        await viewModel.uploadProfilePicture(
          buyerId: tBuyerId,
          profilePicture: tFile,
        );

        // Assert
        final state = providerContainer.read(buyerViewModelProvider);
        expect(state.buyerStatus, BuyerStatus.imageLoaded);
        expect(state.uploadedProfilePictureUrl, tReturnedUrl);
        expect(state.errorMessage, isNull);
        verify(() => mockUploadBuyerProfilePictureUsecase(any())).called(1);
      },
    );

    test(
      "should emit error state and set error message when upload fails",
      () async {
        // Arrange
        const failure = ApiFailure(
          message: 'Image upload failed! storage space exceeded',
        );
        when(() {
          return mockUploadBuyerProfilePictureUsecase(any());
        }).thenAnswer((_) async {
          return const Left(failure);
        });

        final viewModel = providerContainer.read(
          buyerViewModelProvider.notifier,
        );

        // Act
        await viewModel.uploadProfilePicture(
          buyerId: tBuyerId,
          profilePicture: tFile,
        );

        // Assert
        final state = providerContainer.read(buyerViewModelProvider);
        expect(state.buyerStatus, BuyerStatus.error);
        expect(state.errorMessage, failure.message);
        expect(state.uploadedProfilePictureUrl, isNull);
        verify(() => mockUploadBuyerProfilePictureUsecase(any())).called(1);
      },
    );

    test('should call usecase with correct params', () async {
      // Arrange
      UploadBuyerProfilePictureUsecaseParams? capturedParams;

      when(() => mockUploadBuyerProfilePictureUsecase(any())).thenAnswer((
        inv,
      ) async {
        capturedParams =
            inv.positionalArguments[0]
                as UploadBuyerProfilePictureUsecaseParams;
        return const Right(tReturnedUrl);
      });

      final viewModel = providerContainer.read(buyerViewModelProvider.notifier);

      // Act
      await viewModel.uploadProfilePicture(
        buyerId: tBuyerId,
        profilePicture: tFile,
      );

      // Assert
      expect(capturedParams?.buyerId, tBuyerId);
      expect(capturedParams?.profilePicture.path, tFile.path);

      verify(() => mockUploadBuyerProfilePictureUsecase(any())).called(1);
    });
  });
}
