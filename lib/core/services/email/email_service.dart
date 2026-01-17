// lib/core/services/email/email_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emailServiceProvider = Provider<EmailService>((ref) {
  return EmailService();
});

class EmailService {
  // Simulated email sending function
  Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String body,
  }) async {
    // Here you would integrate with an actual email sending service
    // For simulation, we just print the email details and return true
    // print("Sending email to: $toEmail");
    // print("Subject: $subject");
    // print("Body: $body");
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return true; // Simulate successful email sending
  }
}
