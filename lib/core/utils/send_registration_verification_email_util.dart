// lib/core/utils/send_registration_verification_email_util.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/email/email_service.dart';

final sendRegistrationVerificationEmailUtilProvider =
    Provider<SendRegistrationVerificationEmailUtil>((ref) {
      final emailService = ref.read(emailServiceProvider);
      return SendRegistrationVerificationEmailUtil(emailService: emailService);
    });

class SendRegistrationVerificationEmailUtil {
  final EmailService _emailService;

  SendRegistrationVerificationEmailUtil({required EmailService emailService})
    : _emailService = emailService;

  Future<bool> call({
    required String toEmail,
    required String fullName,
    required String verifyCode,
  }) async {
    final subject = "Verify Your Account Registration";
    final body =
        """
    <p>Hello, $fullName</p>
    <p>Thank you for registering with us!</p>
    <p>Your verification code is: <strong>$verifyCode</strong></p>
    <p>Please enter this code in the app to complete your registration.</p>
    <p>If you did not initiate this request, please ignore this email.</p>
    <br/>
    <p>Best regards,<br/>The Leelame Team</p>
    """;
    final result = await _emailService.sendEmail(
      toEmail: toEmail,
      subject: subject,
      body: body,
    );
    return result;
  }
}
