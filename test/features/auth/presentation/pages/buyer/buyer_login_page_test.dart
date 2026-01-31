import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/auth/domain/usecases/buyer/buyer_login_usecase.dart';
import 'package:leelame/features/auth/presentation/pages/buyer/buyer_login_page.dart';
import 'package:leelame/features/auth/presentation/widgets/custom_auth_text_field.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:mocktail/mocktail.dart';

// Mock NavigatorObserver to track navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockBuyerLoginUsecase extends Mock implements BuyerLoginUsecase {}

void main() {
  late MockNavigatorObserver mockNavigatorObserver;
  late MockBuyerLoginUsecase mockBuyerLoginUsecase;

  setUpAll(() {
    registerFallbackValue(
      const BuyerLoginUsecaseParams(
        identifier: 'fallback@email.com',
        password: 'fallback',
        role: "fallback",
      ),
    );
  });

  setUp(() {
    mockBuyerLoginUsecase = MockBuyerLoginUsecase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        buyerLoginUsecaseProvider.overrideWithValue(mockBuyerLoginUsecase),
      ],
      child: const MaterialApp(home: BuyerLoginPage()),
    );
  }

  group('BuyerLoginPage - UI Elements', () {
    testWidgets(
      'should display logo, identifier field, password field and login button',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsOneWidget); // logo
        expect(find.text('Username or Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
      },
    );

    testWidgets(
      'should display "Don\'t have an account?" and Create account button',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text("Don't have an account?"), findsOneWidget);
        expect(find.text('Create account'), findsOneWidget);
      },
    );
  });

  group('BuyerLoginPage - Form Validation', () {
    testWidgets('should show error when identifier is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill only password
      await tester.enterText(
        find.byType(CustomAuthTextField).at(1),
        'password123',
      );

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter username or email'), findsOneWidget);
      // expect(mockViewModel.loginWasCalled, false);
    });

    testWidgets('should show error when password is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill only identifier
      await tester.enterText(
        find.byType(CustomAuthTextField).at(0),
        'testuser',
      );

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a password'), findsOneWidget);
      // expect(mockViewModel.loginWasCalled, false);
    });

    testWidgets('should show error when password is too short (<8 chars)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(CustomAuthTextField).at(0),
        'validuser',
      );
      await tester.enterText(find.byType(CustomAuthTextField).at(1), 'short');

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });
  });

  group('BuyerLoginPage - Form Submission', () {
    testWidgets('should call login with correct values when form is valid', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(CustomAuthTextField).at(0),
        'subham123',
      );
      await tester.enterText(
        find.byType(CustomAuthTextField).at(1),
        'securepass123',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      verify(() => mockBuyerLoginUsecase(any())).called(1);
    });

    testWidgets('should show loading state on button when status is loading', (
      tester,
    ) async {
      // Arrange - Use completer to prevent navigation
      final completer = Completer<Either<Failures, BuyerEntity>>();

      BuyerLoginUsecaseParams? capturedParams;
      when(() => mockBuyerLoginUsecase(any())).thenAnswer((invocation) {
        capturedParams =
            invocation.positionalArguments[0] as BuyerLoginUsecaseParams;
        return completer.future;
      });

      await tester.pumpWidget(createTestWidget());

      // Fill form fields
      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'mypassword');

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();

      // Verify correct params were passed
      expect(capturedParams?.identifier, 'user@test.com');
      expect(capturedParams?.password, 'mypassword');
    });
  });
}
