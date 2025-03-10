import 'package:flutter/material.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:email_otp/email_otp.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _resetPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final EmailOTP _emailOTP = EmailOTP();

  @override
  void initState() {
    super.initState();
    _emailOTP.setConfig(
      appEmail: "your-email@example.com",
      appName: "Local Plant Identification",
      userEmail: "user@example.com",
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );
  }

  Future<void> _sendOtp() async {
    await _emailOTP.sendOTP();
  }

  Future<void> _verifyOtpAndResetPassword() async {
    String otp = _otpController.text;
    bool isVerified = await _emailOTP.verifyOTP(otp: otp);
    if (isVerified) {
      // Handle password reset logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP Verified. Password reset successful.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = Theme.of(context).colorScheme;
    return CustomScaffold(
      child: Stack(
        children: [
          Column(
            children: [
              const Expanded(
                flex: 1,
                child: SizedBox(
                  height: 10,
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _resetPasswordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary,
                            ),
                          ),
                          const SizedBox(
                            height: 40.0,
                          ),
                          TextFormField(
                            controller: _otpController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter OTP';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'OTP',
                              labelStyle: TextStyle(
                                color: lightColorScheme.primary,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: lightColorScheme.primary,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: lightColorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter new password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              labelStyle: TextStyle(
                                color: lightColorScheme.primary,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: lightColorScheme.primary,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: lightColorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_resetPasswordFormKey.currentState!.validate()) {
                                _verifyOtpAndResetPassword();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Set the button color to green
                              padding: const EdgeInsets.symmetric(
                                horizontal: 80,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
