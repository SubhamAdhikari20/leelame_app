import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leelame/features/auth/presentation/widgets/custom_auth_text_field.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required TextEditingController controller,
    required String hintText,
    String? labelText,
    bool? isPassword,
    bool? showClearButton,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    GlobalKey<FormState>? formKey,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CustomAuthTextField(
              controller: controller,
              hintText: hintText,
              labelText: labelText,
              isPassword: isPassword,
              showClearButton: showClearButton,
              validator: validator,
              keyboardType: keyboardType,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('CustomAuthTextField rendering/config', () {
    testWidgets('renders hint and label text', (tester) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Email',
        labelText: 'Email Label',
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Email Label'), findsOneWidget);
    });

    testWidgets('uses text keyboard by default', (tester) async {
      final controller = TextEditingController();
      await pumpField(tester, controller: controller, hintText: 'Name');

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.keyboardType, TextInputType.text);
    });

    testWidgets('uses custom keyboard type when provided', (tester) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Email',
        keyboardType: TextInputType.emailAddress,
      );

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('non-password field is not obscured', (tester) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
        isPassword: false,
      );

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.obscureText, isFalse);
    });

    testWidgets('password field is obscured initially', (tester) async {
      final controller = TextEditingController(text: 'secret123');
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Password',
        isPassword: true,
      );

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.obscureText, isTrue);
    });

    testWidgets('clear icon hidden initially for empty non-password field', (
      tester,
    ) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
        isPassword: false,
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('showClearButton true shows clear icon even when empty', (
      tester,
    ) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Name',
        showClearButton: true,
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('password field does not show clear icon', (tester) async {
      final controller = TextEditingController(text: 'abc12345');
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Password',
        isPassword: true,
        showClearButton: true,
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });
  });

  group('CustomAuthTextField interactions', () {
    testWidgets('password field hides visibility icon when empty', (tester) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Password',
        isPassword: true,
      );

      expect(find.byIcon(Icons.visibility_off), findsNothing);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('non-password field never shows visibility icon', (tester) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
      );

      await tester.enterText(find.byType(TextFormField), 'text');
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsNothing);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('password visibility icon hides when text is cleared', (tester) async {
      final controller = TextEditingController(text: 'secret123');
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Password',
        isPassword: true,
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsNothing);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('controller initial text shows clear icon immediately', (tester) async {
      final controller = TextEditingController(text: 'initial');
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('showClearButton true remains clear icon after typing', (tester) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
        showClearButton: true,
      );

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('label can be omitted and widget still renders', (tester) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'No Label',
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('No Label'), findsOneWidget);
    });

    testWidgets('supports number keyboard type', (tester) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Age',
        keyboardType: TextInputType.number,
      );

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.keyboardType, TextInputType.number);
    });

    testWidgets('typing in non-password field shows clear icon', (tester) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
      );

      await tester.enterText(find.byType(TextFormField), 'subham');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('tapping clear icon clears controller text', (tester) async {
      final controller = TextEditingController(text: 'to-be-cleared');
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(controller.text, isEmpty);
    });

    testWidgets('clear icon hides after clearing text', (tester) async {
      final controller = TextEditingController(text: 'abc');
      await pumpField(tester, controller: controller, hintText: 'Username');

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('password visibility icon appears after typing', (tester) async {
      final controller = TextEditingController();
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Password',
        isPassword: true,
      );

      await tester.enterText(find.byType(TextFormField), 'mypassword');
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('tapping visibility icon reveals password', (tester) async {
      final controller = TextEditingController(text: 'mypassword');
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Password',
        isPassword: true,
      );

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('tapping visibility icon twice re-obscures password', (tester) async {
      final controller = TextEditingController(text: 'mypassword');
      await pumpField(
        tester,
        controller: controller,
        hintText: 'Password',
        isPassword: true,
      );

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('programmatic text set shows clear icon', (tester) async {
      final controller = TextEditingController();
      await pumpField(tester, controller: controller, hintText: 'Username');

      controller.text = 'set-programmatically';
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('programmatic text clear hides clear icon', (tester) async {
      final controller = TextEditingController(text: 'present');
      await pumpField(tester, controller: controller, hintText: 'Username');

      controller.clear();
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsNothing);
    });
  });

  group('CustomAuthTextField validation', () {
    testWidgets('default validator returns required message when empty', (
      tester,
    ) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
        formKey: formKey,
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text('Please enter username'), findsOneWidget);
    });

    testWidgets('default validator passes for non-empty value', (tester) async {
      final controller = TextEditingController(text: 'validUser');
      final formKey = GlobalKey<FormState>();

      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
        formKey: formKey,
      );

      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('custom validator message is shown', (tester) async {
      final controller = TextEditingController(text: 'abc');
      final formKey = GlobalKey<FormState>();

      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
        formKey: formKey,
        validator: (value) => 'custom error',
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text('custom error'), findsOneWidget);
    });

    testWidgets('custom validator can pass without error', (tester) async {
      final controller = TextEditingController(text: 'abc');
      final formKey = GlobalKey<FormState>();

      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
        formKey: formKey,
        validator: (value) => null,
      );

      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('custom validator receives entered value', (tester) async {
      final controller = TextEditingController(text: 'entered');
      final formKey = GlobalKey<FormState>();
      String? captured;

      await pumpField(
        tester,
        controller: controller,
        hintText: 'Username',
        formKey: formKey,
        validator: (value) {
          captured = value;
          return null;
        },
      );

      formKey.currentState!.validate();
      expect(captured, 'entered');
    });

    testWidgets('default validator uses hintText in message lowercase', (
      tester,
    ) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await pumpField(
        tester,
        controller: controller,
        hintText: 'Email Address',
        formKey: formKey,
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text('Please enter email address'), findsOneWidget);
    });
  });
}
