import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/login_and_registration/otp_verification.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:email_otp/email_otp.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final EmailOTP _emailOTP = EmailOTP();
  bool rememberPassword = true;

  @override
  void initState() {
    super.initState();
    _emailOTP.config(
      appEmail: "contact@localplantapp.com",
      appName: "Local Plant Identification",
      email: _emailController.text,
      otpLength: 6,
      //otpType: OTPType.digitsOnly
    );
  }

  Future<void> _sendOtp() async {
    try {
      bool otpSent = await _emailOTP.sendOTP();
      if (otpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              email: _emailController.text,
              emailOTP: _emailOTP,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
                      key: _forgetPasswordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Forget Password',
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
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Email',
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
                            onPressed: () async {
                              if (_forgetPasswordFormKey.currentState!.validate()) {
                                await _sendOtp();
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
                              'Send OTP',
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