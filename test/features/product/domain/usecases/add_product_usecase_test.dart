// import 'dart:io';
// import 'package:dartz/dartz.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:leelame/features/product/domain/usecases/add_product_usecase.dart';
// import 'package:leelame/features/product/domain/repositories/product_repository.dart';
// import 'package:leelame/features/product/domain/entities/product_entity.dart';
// import 'package:leelame/core/error/failures.dart';

// class MockProductRepository extends Mock implements IProductRepository {}

// void main() {
//   late MockProductRepository mockRepo;
//   late AddProductUsecase usecase;

//   setUpAll(() {
//     registerFallbackValue(
//       AddProductUsecaseParams(
//         productName: 'n',
//         startPrice: 0,
//         bidIntervalPrice: 0,
//         endDate: DateTime.now(),
//       ),
//     );
//     registerFallbackValue(
//       const ProductEntity(
//         sellerId: 's',
//         productName: 'n',
//         description: 'd',
//         categoryId: 'c',
//         conditionId: 'con',
//         commission: 0,
//         startPrice: 0,
//         currentBidPrice: 0,
//         bidIntervalPrice: 0,
//         endDate: , productImageUrls: [], isVerified: false, isSoldOut: false,
//       ),
//     );
//   });

//   setUp(() {
//     mockRepo = MockProductRepository();
//     usecase = AddProductUsecase(productRepository: mockRepo);
//   });

//   test('should call createProduct and return ProductEntity', () async {
//     final params = AddProductUsecaseParams(
//       sellerId: 's1',
//       productName: 'Phone',
//       description: 'Nice',
//       categoryId: 'cat1',
//       conditionId: 'cond1',
//       startPrice: 1000,
//       bidIntervalPrice: 100,
//       endDate: DateTime.now().add(const Duration(days: 7)),
//       buyNowPrice: 5000,
//     );

//     final created = ProductEntity(
//       sellerId: 's1',
//       productName: 'Phone',
//       description: 'Nice',
//       categoryId: 'cat1',
//       conditionId: 'cond1',
//       commission: 0,
//       startPrice: 1000,
//       currentBidPrice: 1000,
//       bidIntervalPrice: 100,
//       endDate: params.endDate,
//       productImageUrls: [],
//       buyNowPrice: 5000,
//       isVerified: false,
//       isSoldOut: false,
//     );

//     when(
//       () => mockRepo.createProduct(
//         productEntity: any(named: 'productEntity'),
//         productImages: any(named: 'productImages'),
//         imageSubFolder: any(named: 'imageSubFolder'),
//       ),
//     ).thenAnswer((_) async => Right(created));

//     final res = await usecase(params);

//     expect(res.isRight(), true);
//     res.fold((l) => fail('left'), (r) => expect(r.productName, 'Phone'));
//     verify(
//       () => mockRepo.createProduct(
//         productEntity: any(named: 'productEntity'),
//         productImages: any(named: 'productImages'),
//         imageSubFolder: any(named: 'imageSubFolder'),
//       ),
//     ).called(1);
//   });

//   test('should pass buyNowPrice through to repository entity', () async {
//     final params = AddProductUsecaseParams(
//       productName: 'X',
//       startPrice: 10,
//       bidIntervalPrice: 1,
//       endDate: DateTime.now(),
//       buyNowPrice: 1234,
//     );
//     when(
//       () => mockRepo.createProduct(
//         productEntity: any(named: 'productEntity'),
//         productImages: any(named: 'productImages'),
//         imageSubFolder: any(named: 'imageSubFolder'),
//       ),
//     ).thenAnswer((inv) async {
//       final ent = inv.positionalArguments[0] as ProductEntity;
//       return Right(ent);
//     });

//     final res = await usecase(params);
//     expect(res.isRight(), true);
//     res.fold((l) => fail('left'), (r) {
//       expect(r.buyNowPrice, 1234);
//     });
//   });

//   test('should handle repository failure', () async {
//     final params = AddProductUsecaseParams(
//       productName: 'X',
//       startPrice: 1,
//       bidIntervalPrice: 1,
//       endDate: DateTime.now(),
//     );
//     final failure = ApiFailure(message: 'create failed');
//     when(
//       () => mockRepo.createProduct(
//         productEntity: any(named: 'productEntity'),
//         productImages: any(named: 'productImages'),
//         imageSubFolder: any(named: 'imageSubFolder'),
//       ),
//     ).thenAnswer((_) async => Left(failure));

//     final res = await usecase(params);
//     expect(res.isLeft(), true);
//     res.fold((l) => expect(l, failure), (r) => fail('expected left'));
//   });

//   test('should call repository with provided images and folder', () async {
//     final tmp = File('test/tmp.jpg');
//     final params = AddProductUsecaseParams(
//       productName: 'I',
//       startPrice: 1,
//       bidIntervalPrice: 1,
//       endDate: DateTime.now(),
//       productImages: [tmp],
//       imageSubFolder: 'product-images',
//     );
//     when(
//       () => mockRepo.createProduct(
//         productEntity: any(named: 'productEntity'),
//         productImages: any(named: 'productImages'),
//         imageSubFolder: any(named: 'imageSubFolder'),
//       ),
//     ).thenAnswer(
//       (_) async => Right(
//         ProductEntity(
//           sellerId: 's',
//           productName: 'I',
//           description: null,
//           categoryId: null,
//           conditionId: null,
//           commission: 0,
//           startPrice: 1,
//           currentBidPrice: 1,
//           bidIntervalPrice: 1,
//           endDate: DateTime.now(),
//           productImageUrls: [],
//           buyNowPrice: null,
//           isVerified: false,
//           isSoldOut: false,
//         ),
//       ),
//     );

//     await usecase(params);
//     verify(
//       () => mockRepo.createProduct(
//         productEntity: any(named: 'productEntity'),
//         productImages: any(named: 'productImages'),
//         imageSubFolder: 'product-images',
//       ),
//     ).called(1);
//   });
// }
