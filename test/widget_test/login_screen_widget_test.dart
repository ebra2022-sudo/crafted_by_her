import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/presentation/login_screen.dart';
import 'package:crafted_by_her/presentation/register_screen.dart';
import 'package:crafted_by_her/presentation/forget_password_screen.dart';
import 'package:crafted_by_her/presentation/home_screen.dart';
import 'package:mockito/mockito.dart';

// Mock classes
// mock class case of the  current value of the designhte
class MockAuthViewModel extends Mock implements AuthViewModel {
  @override
  TextEditingController get emailController => TextEditingController();
  @override
  TextEditingController get passwordController => TextEditingController();
  @override
  bool get isLoading => false;
  @override
  bool get isPasswordVisible => false;
  @override
  bool get rememberMe => false;
  @override
  String? get emailError => null;
  @override
  String? get passwordError => null;
  @override
  String? get apiError => null;
}

void main() {
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
  });

  // Helper function to create the widget under test
  Widget createWidgetUnderTest({
    AuthViewModel? authViewModel,
  }) {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthViewModel>(
        create: (_) => authViewModel ?? mockAuthViewModel,
        child: const LoginScreen(),
      ),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all UI elements correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Crafted by Her'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Log in to explore crafted treasures'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    // testing code sample case of th sample case

    testWidgets('displays email error when present',
        (WidgetTester tester) async {
      when(mockAuthViewModel.emailError).thenReturn('Invalid email');

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pump();

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('displays password error when present',
        (WidgetTester tester) async {
      when(mockAuthViewModel.passwordError).thenReturn('Password too short');

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pump();

      expect(find.text('Password too short'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      when(mockAuthViewModel.isPasswordVisible).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      when(mockAuthViewModel.isPasswordVisible).thenReturn(true);
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('toggles remember me checkbox', (WidgetTester tester) async {
      when(mockAuthViewModel.rememberMe).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      verify(mockAuthViewModel.setRememberMe(true)).called(1);
    });

    testWidgets('navigates to ForgotPasswordScreen when forgot password tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets('navigates to RegisterScreen when sign up tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (WidgetTester tester) async {
      when(mockAuthViewModel.isLoading).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SIGN IN'), findsNothing);
    });

    testWidgets(
        'successful login navigates to HomeScreen and shows success message',
        (WidgetTester tester) async {
      when(mockAuthViewModel.isLoading).thenReturn(false);
      when(mockAuthViewModel.login()).thenAnswer((_) async => true);
      when(mockAuthViewModel.user).thenReturn({
        'firstName': 'Jane',
        'lastName': 'Doe',
      });

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Login successful! Welcome Jane Doe'), findsOneWidget);
    });

    testWidgets('failed login shows error message',
        (WidgetTester tester) async {
      when(mockAuthViewModel.isLoading).thenReturn(false);
      when(mockAuthViewModel.login()).thenAnswer((_) async => false);
      when(mockAuthViewModel.apiError).thenReturn('Invalid credentials');

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsNothing);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('entering text in email field updates controller',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      when(mockAuthViewModel.emailController).thenReturn(controller);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.pump();

      expect(controller.text, 'test@example.com');
    });

    testWidgets('entering text in password field updates controller',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      when(mockAuthViewModel.passwordController).thenReturn(controller);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pump();

      expect(controller.text, 'password123');
    });
  });
}
