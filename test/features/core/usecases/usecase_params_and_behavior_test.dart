import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:leelame/features/buyer/domain/repositories/buyer_repository.dart';
import 'package:leelame/features/buyer/domain/usecases/buyer_get_current_user_usecase.dart';
import 'package:leelame/features/buyer/domain/usecases/upload_buyer_profile_picture_usecase.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/domain/repositories/product_repository.dart';
import 'package:leelame/features/product/domain/usecases/add_product_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements IProductRepository {}

class MockBuyerRepository extends Mock implements IBuyerRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(File('fallback.jpg'));
    registerFallbackValue(
      ProductEntity(
        productName: 'fallback',
        commission: 0,
        startPrice: 0,
        currentBidPrice: 0,
        bidIntervalPrice: 0,
        endDate: DateTime(2026, 3, 9),
        productImageUrls: const <String>[],
        isVerified: false,
        isSoldOut: false,
      ),
    );
  });

  group('AddProductUsecaseParams', () {
    test('equality works for same values', () {
      final now = DateTime(2026, 3, 9);
      const image = 'a.jpg';

      final a = AddProductUsecaseParams(
        sellerId: 's1',
        productName: 'Phone',
        description: 'Good',
        categoryId: 'c1',
        conditionId: 'pc1',
        startPrice: 100,
        bidIntervalPrice: 10,
        endDate: now,
        buyNowPrice: 500,
        productImages: const [],
        imageSubFolder: image,
      );

      final b = AddProductUsecaseParams(
        sellerId: 's1',
        productName: 'Phone',
        description: 'Good',
        categoryId: 'c1',
        conditionId: 'pc1',
        startPrice: 100,
        bidIntervalPrice: 10,
        endDate: now,
        buyNowPrice: 500,
        productImages: const [],
        imageSubFolder: image,
      );

      expect(a, equals(b));
    });

    test('inequality works for changed startPrice', () {
      final now = DateTime(2026, 3, 9);

      final a = AddProductUsecaseParams(
        productName: 'Phone',
        startPrice: 100,
        bidIntervalPrice: 10,
        endDate: now,
      );

      final b = AddProductUsecaseParams(
        productName: 'Phone',
        startPrice: 200,
        bidIntervalPrice: 10,
        endDate: now,
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('AddProductUsecase behavior', () {
    late MockProductRepository repo;
    late AddProductUsecase usecase;

    setUp(() {
      repo = MockProductRepository();
      usecase = AddProductUsecase(productRepository: repo);
    });

    test('builds entity with expected default flags', () async {
      final now = DateTime(2026, 3, 9);
      final returned = ProductEntity(
        productName: 'returned',
        commission: 0,
        startPrice: 0,
        currentBidPrice: 0,
        bidIntervalPrice: 0,
        endDate: DateTime(2026, 3, 9),
        productImageUrls: <String>[],
        isVerified: false,
        isSoldOut: false,
      );

      when(
        () => repo.createProduct(
          productEntity: any(named: 'productEntity'),
          productImages: null,
          imageSubFolder: null,
        ),
      ).thenAnswer((_) async => Right(returned));

      final result = await usecase(
        AddProductUsecaseParams(
          productName: 'Phone',
          startPrice: 100,
          bidIntervalPrice: 10,
          endDate: now,
        ),
      );

      expect(result.isRight(), isTrue);
      final captured =
          verify(
                () => repo.createProduct(
                  productEntity: captureAny(named: 'productEntity'),
                  productImages: null,
                  imageSubFolder: null,
                ),
              ).captured.single
              as ProductEntity;
      expect(captured, isNotNull);
      expect(captured.commission, 0);
      expect(captured.isVerified, isFalse);
      expect(captured.isSoldOut, isFalse);
    });

    test('sets currentBidPrice equal to startPrice', () async {
      final now = DateTime(2026, 3, 9);
      final returned = ProductEntity(
        productName: 'returned',
        commission: 0,
        startPrice: 0,
        currentBidPrice: 0,
        bidIntervalPrice: 0,
        endDate: DateTime(2026, 3, 9),
        productImageUrls: <String>[],
        isVerified: false,
        isSoldOut: false,
      );

      when(
        () => repo.createProduct(
          productEntity: any(named: 'productEntity'),
          productImages: null,
          imageSubFolder: null,
        ),
      ).thenAnswer((_) async => Right(returned));

      await usecase(
        AddProductUsecaseParams(
          productName: 'Watch',
          startPrice: 1234,
          bidIntervalPrice: 50,
          endDate: now,
        ),
      );

      final captured =
          verify(
                () => repo.createProduct(
                  productEntity: captureAny(named: 'productEntity'),
                  productImages: null,
                  imageSubFolder: null,
                ),
              ).captured.single
              as ProductEntity;

      expect(captured.currentBidPrice, 1234);
      expect(captured.startPrice, 1234);
    });

    test('forwards productImages and imageSubFolder to repository', () async {
      final now = DateTime(2026, 3, 9);
      final image = File('test/sample.jpg');
      final returned = ProductEntity(
        productName: 'returned',
        commission: 0,
        startPrice: 0,
        currentBidPrice: 0,
        bidIntervalPrice: 0,
        endDate: DateTime(2026, 3, 9),
        productImageUrls: <String>[],
        isVerified: false,
        isSoldOut: false,
      );

      when(
        () => repo.createProduct(
          productEntity: any(named: 'productEntity'),
          productImages: any(named: 'productImages'),
          imageSubFolder: any(named: 'imageSubFolder'),
        ),
      ).thenAnswer((_) async => Right(returned));

      await usecase(
        AddProductUsecaseParams(
          productName: 'Bag',
          startPrice: 10,
          bidIntervalPrice: 1,
          endDate: now,
          productImages: [image],
          imageSubFolder: 'products',
        ),
      );

      final captured = verify(
        () => repo.createProduct(
          productEntity: any(named: 'productEntity'),
          productImages: captureAny(named: 'productImages'),
          imageSubFolder: captureAny(named: 'imageSubFolder'),
        ),
      ).captured;

      final capturedFiles = captured[0] as List<File>?;
      final capturedFolder = captured[1] as String?;
      expect(capturedFiles, isNotNull);
      expect(capturedFiles!.single.path, image.path);
      expect(capturedFolder, 'products');
    });

    test('returns repository failure unchanged', () async {
      const failure = ApiFailure(message: 'create failed');
      final now = DateTime(2026, 3, 9);

      when(
        () => repo.createProduct(
          productEntity: any(named: 'productEntity'),
          productImages: null,
          imageSubFolder: null,
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        AddProductUsecaseParams(
          productName: 'X',
          startPrice: 1,
          bidIntervalPrice: 1,
          endDate: now,
        ),
      );

      expect(result, const Left(failure));
    });
  });

  group('BuyerGetCurrentUserUsecase', () {
    test('params equality works for same buyerId', () {
      const a = BuyerGetCurrentUserUsecaseParams(buyerId: 'b1');
      const b = BuyerGetCurrentUserUsecaseParams(buyerId: 'b1');
      expect(a, equals(b));
    });

    test('params inequality works for different buyerId', () {
      const a = BuyerGetCurrentUserUsecaseParams(buyerId: 'b1');
      const b = BuyerGetCurrentUserUsecaseParams(buyerId: 'b2');
      expect(a, isNot(equals(b)));
    });

    test('forwards buyerId and returns success', () async {
      final repo = MockBuyerRepository();
      final usecase = BuyerGetCurrentUserUsecase(buyerRepository: repo);
      String? capturedId;

      const buyer = BuyerEntity(fullName: 'Buyer One');

      when(() => repo.getCurrentBuyer(any())).thenAnswer((invocation) async {
        capturedId = invocation.positionalArguments[0] as String;
        return const Right(buyer);
      });

      final result = await usecase(
        const BuyerGetCurrentUserUsecaseParams(buyerId: 'buyer-1'),
      );

      expect(capturedId, 'buyer-1');
      expect(result, const Right(buyer));
    });

    test('returns failure unchanged', () async {
      final repo = MockBuyerRepository();
      final usecase = BuyerGetCurrentUserUsecase(buyerRepository: repo);
      const failure = ApiFailure(message: 'not found');

      when(() => repo.getCurrentBuyer(any())).thenAnswer((_) async {
        return const Left(failure);
      });

      final result = await usecase(
        const BuyerGetCurrentUserUsecaseParams(buyerId: 'missing'),
      );

      expect(result, const Left(failure));
    });
  });

  group('UploadBuyerProfilePictureUsecase', () {
    test('params equality works when buyerId and file are same', () {
      final fileA = File('same.jpg');
      final a = UploadBuyerProfilePictureUsecaseParams(
        buyerId: 'b1',
        profilePicture: fileA,
      );
      final b = UploadBuyerProfilePictureUsecaseParams(
        buyerId: 'b1',
        profilePicture: fileA,
      );

      expect(a, equals(b));
    });

    test('params inequality works when file path is different', () {
      final a = UploadBuyerProfilePictureUsecaseParams(
        buyerId: 'b1',
        profilePicture: File('a.jpg'),
      );
      final b = UploadBuyerProfilePictureUsecaseParams(
        buyerId: 'b1',
        profilePicture: File('b.jpg'),
      );

      expect(a, isNot(equals(b)));
    });

    test('params equality ignores buyerId when file is same (current behavior)', () {
      final file = File('same.jpg');
      final a = UploadBuyerProfilePictureUsecaseParams(
        buyerId: 'buyer-a',
        profilePicture: file,
      );
      final b = UploadBuyerProfilePictureUsecaseParams(
        buyerId: 'buyer-b',
        profilePicture: file,
      );

      expect(a, equals(b));
    });

    test('forwards buyerId and file to repository', () async {
      final repo = MockBuyerRepository();
      final usecase = UploadBuyerProfilePictureUsecase(buyerRepository: repo);
      String? capturedBuyerId;
      File? capturedFile;

      when(
        () => repo.uploadBuyerProfilePicture(any(), any()),
      ).thenAnswer((invocation) async {
        capturedBuyerId = invocation.positionalArguments[0] as String;
        capturedFile = invocation.positionalArguments[1] as File;
        return const Right('uploaded.jpg');
      });

      final file = File('picked.jpg');
      final result = await usecase(
        UploadBuyerProfilePictureUsecaseParams(
          buyerId: 'buyer-22',
          profilePicture: file,
        ),
      );

      expect(result, const Right('uploaded.jpg'));
      expect(capturedBuyerId, 'buyer-22');
      expect(capturedFile!.path, file.path);
    });

    test('returns failure unchanged from repository', () async {
      final repo = MockBuyerRepository();
      final usecase = UploadBuyerProfilePictureUsecase(buyerRepository: repo);
      const failure = ApiFailure(message: 'upload failed');

      when(
        () => repo.uploadBuyerProfilePicture(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        UploadBuyerProfilePictureUsecaseParams(
          buyerId: 'buyer-22',
          profilePicture: File('picked.jpg'),
        ),
      );

      expect(result, const Left(failure));
    });
  });
}
