// test/features/auth/domain/usecases/buyer/buyer_sign_up_usecase_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/auth/domain/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_sign_up_usecase.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockBuyerAuthRepository extends Mock implements IBuyerAuthRepository {}

void main() {
  late BuyerSignUpUsecase buyerSignUpUsecase;
  late MockBuyerAuthRepository mockBuyerAuthRepository;

  setUp(() {
    mockBuyerAuthRepository = MockBuyerAuthRepository();
    buyerSignUpUsecase = BuyerSignUpUsecase(
      buyerAuthRepository: mockBuyerAuthRepository,
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

  group(("BuyerSignUpUsecase"), () {
    test(
      "should return buyer entity when buyer is signed up successfully",
      () async {
        // Arrange
        when(() {
          return mockBuyerAuthRepository.signUp(any(), any());
        }).thenAnswer((_) async {
          return Right(tBuyerEntity);
        });

        // Act
        final result = await buyerSignUpUsecase(
          const BuyerSignUpUsecaseParams(
            fullName: tFullName,
            email: tEmail,
            phoneNumber: tPhoneNumber,
            username: tUsername,
            password: tPassword,
            baseUserId: tBaseUserId,
            termsAccepted: tTerms,
          ),
        );

        // Assert
        expect(result, Right(tBuyerEntity));
        verify(() {
          return mockBuyerAuthRepository.signUp(any(), any());
        }).called(1);
        verifyNoMoreInteractions(mockBuyerAuthRepository);
      },
    );

    test(
      "should pass Batch Entity with correct buyer data to repository",
      () async {
        // Arrange
        UserEntity? capturedUser;
        BuyerEntity? capturedBuyer;

        when(() {
          return mockBuyerAuthRepository.signUp(any(), any());
        }).thenAnswer((invocation) {
          capturedUser = invocation.positionalArguments[0] as UserEntity;
          capturedBuyer = invocation.positionalArguments[1] as BuyerEntity;
          return Future.value(Right(tBuyerEntity));
        });

        // Act
        await buyerSignUpUsecase(
          const BuyerSignUpUsecaseParams(
            fullName: tFullName,
            email: tEmail,
            username: tUsername,
            phoneNumber: tPhoneNumber,
            password: tPassword,
            baseUserId: tBaseUserId,
            termsAccepted: tTerms,
          ),
        );

        // Assert
        expect(capturedBuyer?.fullName, tFullName);
        expect(capturedBuyer?.username, tUsername);
        expect(capturedBuyer?.phoneNumber, tPhoneNumber);
        expect(capturedBuyer?.password, tPassword);
        expect(capturedBuyer?.termsAccepted, tTerms);
        expect(capturedBuyer?.buyerId, isNull);
        expect(capturedBuyer?.baseUserId, isNotNull);

        expect(capturedUser?.email, tEmail);
        expect(capturedUser?.role, tRole);
        expect(capturedUser?.isVerified, tIsVerified);
        expect(capturedUser?.isPermanentlyBanned, tIsPermanentlyBanned);
      },
    );
  });
}
