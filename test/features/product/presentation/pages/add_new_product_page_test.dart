// // test/widgets/add_new_product_page_test.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:leelame/features/category/presentation/states/category_state.dart';
// import 'package:leelame/features/category/presentation/view_models/category_view_model.dart';
// import 'package:leelame/features/product/presentation/pages/add_new_product_page.dart';
// import 'package:leelame/features/product/presentation/states/product_state.dart';
// import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
// import 'package:leelame/features/product_condition/presentation/states/product_condition_state.dart';
// import 'package:leelame/features/product_condition/presentation/view_models/product_condition_view_model.dart';
// import 'package:leelame/features/seller/presentation/states/seller_state.dart';
// import 'package:leelame/features/seller/presentation/view_models/seller_view_model.dart';
// import 'package:mocktail/mocktail.dart';

// // Mock ViewModels
// class MockCategoryViewModel extends Mock implements CategoryViewModel {}
// class MockProductConditionViewModel extends Mock implements ProductConditionViewModel {}
// class MockProductViewModel extends Mock implements ProductViewModel {}
// class MockSellerViewModel extends Mock implements SellerViewModel {}

// void main() {
//   late MockCategoryViewModel mockCategoryViewModel;
//   late MockProductConditionViewModel mockProductConditionViewModel;
//   late MockProductViewModel mockProductViewModel;
//   late MockSellerViewModel mockSellerViewModel;

//   setUp(() {
//     mockCategoryViewModel = MockCategoryViewModel();
//     mockProductConditionViewModel = MockProductConditionViewModel();
//     mockProductViewModel = MockProductViewModel();
//     mockSellerViewModel = MockSellerViewModel();

//     // Default successful empty states
//     when(() => mockCategoryViewModel.state).thenReturn(const CategoryState(categories: []));
//     when(() => mockProductConditionViewModel.state).thenReturn(const ProductConditionState(productConditions: []));
//     when(() => mockProductViewModel.state).thenReturn(const ProductState());
//     when(() => mockSellerViewModel.state).thenReturn(const SellerState());
//   });

//   Widget createTestWidget() {
//     return ProviderScope(
//       overrides: [
//         categoryViewModelProvider.overrideWithValue(mockCategoryViewModel),
//         productConditionViewModelProvider.overrideWithValue(mockProductConditionViewModel),
//         productViewModelProvider.overrideWithValue(mockProductViewModel),
//         sellerViewModelProvider.overrideWithValue(mockSellerViewModel),
//       ],
//       child: const MaterialApp(
//         home: AddNewProductPage(sellerId: 'test-seller-123'),
//       ),
//     );
//   }

//   testWidgets('1. displays Scaffold and header title', (tester) async {
//     await tester.pumpWidget(createTestWidget());
//     await tester.pumpAndSettle();
//     expect(find.byType(Scaffold), findsOneWidget);
//     expect(find.text('Add New Product'), findsOneWidget);
//   });

//   testWidgets('2. displays step indicator text and progress dots', (tester) async {
//     await tester.pumpWidget(createTestWidget());
//     await tester.pumpAndSettle();
//     expect(find.text('Step 1 of 3'), findsOneWidget);
//     expect(find.byType(AnimatedContainer), findsNWidgets(3));
//   });

//   testWidgets('3. displays Continue button on step 1', (tester) async {
//     await tester.pumpWidget(createTestWidget());
//     await tester.pumpAndSettle();
//     expect(find.text('Continue'), findsOneWidget);
//   });

//   testWidgets('4. displays Product Images section and add button', (tester) async {
//     await tester.pumpWidget(createTestWidget());
//     await tester.pumpAndSettle();
//     expect(find.text('Product Images'), findsOneWidget);
//     expect(find.text('Add Image'), findsOneWidget);
//     expect(find.byIcon(Icons.add_a_photo_rounded), findsOneWidget);
//   });

//   testWidgets('5. displays Product Name field with hint', (tester) async {
//     await tester.pumpWidget(createTestWidget());
//     await tester.pumpAndSettle();
//     expect(find.text('Product Name'), findsOneWidget);
//     expect(find.widgetWithText(TextFormField, 'e.g., iPhone 17 Pro, Gucci Bag'), findsOneWidget);
//   });

//   testWidgets('6. displays Category dropdown', (tester) async {
//     await tester.pumpWidget(createTestWidget());
//     await tester.pumpAndSettle();
//     expect(find.text('Category'), findsOneWidget);
//     expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
//   });

//   testWidgets('7. displays Condition chips', (tester) async {
//     await tester.pumpWidget(createTestWidget());
//     await tester.pumpAndSettle();
//     expect(find.text('Condition'), findsOneWidget);
//     expect(find.byType(GestureDetector), findsWidgets);
//   });

//   testWidgets('8. tapping Continue moves to Step 2 and shows price fields', (tester) async {
//     await tester.pumpWidget(createTestWidget());
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('Continue'));
//     await tester.pumpAndSettle();
//     expect(find.text('Step 2 of 3'), findsOneWidget);
//     expect(find.text('Start Price'), findsOneWidget);
//     expect(find.text('Bid Interval Price'), findsOneWidget);
//   });

//   testWidgets('9. image picker modal opens on tap Add Image', (tester) async {
//     await tester.pumpWidget(createTestWidget());
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('Add Image'));
//     await tester.pumpAndSettle();
//     expect(find.text('Open Camera'), findsOneWidget);
//     expect(find.text('Open Gallery'), findsOneWidget);
//   });

//   testWidgets('10. displays Publish button on Step 3 after navigation', (tester) async {
//     await tester.pumpWidget(createTestWidget());
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('Continue'));
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('Continue'));
//     await tester.pumpAndSettle();
//     expect(find.text('Step 3 of 3'), findsOneWidget);
//     expect(find.text('Publish'), findsOneWidget);
//   });
// }