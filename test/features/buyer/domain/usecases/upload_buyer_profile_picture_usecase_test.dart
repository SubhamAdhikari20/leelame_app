import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/buyer/domain/repositories/buyer_repository.dart';
import 'package:leelame/features/buyer/domain/usecases/upload_buyer_profile_picture_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockBuyerRepository extends Mock implements IBuyerRepository {}

void main() {
  late UploadBuyerProfilePictureUsecase uploadBuyerProfilePictureUsecase;
  late MockBuyerRepository mockBuyerRepository;

  setUp(() {
    mockBuyerRepository = MockBuyerRepository();
    uploadBuyerProfilePictureUsecase = UploadBuyerProfilePictureUsecase(
      buyerRepository: mockBuyerRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(File("fallback.jpg"));
  });

  const tBuyerId = "test-buyer-user-id";
  final tFile = File("test_profile_picture.jpg");
  const tReturnedUrl =
      "https://http://10.0.2.2:3000/uploads/buyers/profile.jpg";

  group(("upload buyer profile picture usecase"), () {
    test("should return profile filename when upload succeeds", () async {
      // Arrange
      String? capturedBuyerId;
      File? capturedFile;

      when(
        () => mockBuyerRepository.uploadBuyerProfilePicture(any(), any()),
      ).thenAnswer((invocation) async {
        capturedBuyerId = invocation.positionalArguments[0] as String;
        capturedFile = invocation.positionalArguments[1] as File;
        return const Right(tReturnedUrl);
      });

      // Act
      final result = await uploadBuyerProfilePictureUsecase(
        UploadBuyerProfilePictureUsecaseParams(
          buyerId: tBuyerId,
          profilePicture: tFile,
        ),
      );

      // Assert
      expect(result, const Right(tReturnedUrl));
      expect(capturedBuyerId, tBuyerId);
      expect(capturedFile, isNotNull);
      expect(capturedFile!.path, tFile.path);
      verify(
        () => mockBuyerRepository.uploadBuyerProfilePicture(tBuyerId, any()),
      ).called(1);
      verifyNoMoreInteractions(mockBuyerRepository);
    });

    test("should return failure when upload fails", () async {
      const failure = ApiFailure(message: "Upload failed");

      when(
        () => mockBuyerRepository.uploadBuyerProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await uploadBuyerProfilePictureUsecase(
        UploadBuyerProfilePictureUsecaseParams(
          buyerId: tBuyerId,
          profilePicture: tFile,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockBuyerRepository.uploadBuyerProfilePicture(tBuyerId, any()),
      ).called(1);
      verifyNoMoreInteractions(mockBuyerRepository);
    });
  });
}
