import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:leelame/features/buyer/domain/repositories/buyer_repository.dart';
import 'package:leelame/features/buyer/domain/usecases/buyer_get_current_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockBuyerRepository extends Mock implements IBuyerRepository {}

void main() {
  late BuyerGetCurrentUserUsecase buyerGetCurrentUserUsecase;
  late MockBuyerRepository mockBuyerRepository;

  setUp(() {
    mockBuyerRepository = MockBuyerRepository();
    buyerGetCurrentUserUsecase = BuyerGetCurrentUserUsecase(
      buyerRepository: mockBuyerRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const BuyerEntity(
        fullName: "fallback",
        username: "fallback",
        password: "fallback",
        phoneNumber: "fallback",
        userEntity: UserEntity(
          email: "fallback@email.com",
          role: "fallback",
          isVerified: false,
          isPermanentlyBanned: false,
        ),
      ),
    );

    registerFallbackValue(
      const UserEntity(
        email: "fallback@email.com",
        role: "buyer",
        isVerified: false,
        isPermanentlyBanned: false,
      ),
    );
  });

  const tBuyerId = "test-buyer-user-id";
  const tFullName = "New Buyer";
  const tUsername = "newbuyer123";
  const tPassword = "newuser@123";
  const tPhoneNumber = "9876543210";
  const tEmail = "newuser@gmail.com";
  const tRole = "buyer";
  const tIsVerified = false;
  const tTerms = false;
  const tIsPermanentlyBanned = false;
  const tBaseUserId = "test-base-user-id";

  final tUserEntity = UserEntity(
    userId: tBaseUserId,
    email: tEmail,
    role: tRole,
    isVerified: tIsVerified,
    isPermanentlyBanned: tIsPermanentlyBanned,
  );

  final tBuyerEntity = BuyerEntity(
    buyerId: tBuyerId,
    fullName: tFullName,
    username: tUsername,
    password: tPassword,
    phoneNumber: tPhoneNumber,
    termsAccepted: tTerms,
    userEntity: tUserEntity,
    baseUserId: tBaseUserId,
  );

  group(("buyer get current user usecase"), () {
    test(
      "should return buyer entity when current buyer is fetched up successfully",
      () async {
        // Arrange
        when(() {
          return mockBuyerRepository.getCurrentBuyer(any());
        }).thenAnswer((_) async {
          return Right(tBuyerEntity);
        });

        // Act
        final result = await buyerGetCurrentUserUsecase(
          const BuyerGetCurrentUserUsecaseParams(buyerId: tBuyerId),
        );

        // Assert
        expect(result, Right(tBuyerEntity));
        verify(() {
          return mockBuyerRepository.getCurrentBuyer(any());
        }).called(1);
        verifyNoMoreInteractions(mockBuyerRepository);
      },
    );

    test(
      "should pass buyer entity with correct buyer data to repository",
      () async {
        // Arrange
        String? capturedBuyerId;

        when(() {
          return mockBuyerRepository.getCurrentBuyer(any());
        }).thenAnswer((invocation) {
          capturedBuyerId = invocation.positionalArguments[0] as String;
          return Future.value(Right(tBuyerEntity));
        });

        // Act
        final result = await buyerGetCurrentUserUsecase(
          const BuyerGetCurrentUserUsecaseParams(buyerId: tBuyerId),
        );

        // Assert
        expect(result, Right(tBuyerEntity));
        expect(capturedBuyerId, tBuyerId);
        verify(() => mockBuyerRepository.getCurrentBuyer(any())).called(1);
      },
    );
  });
}
