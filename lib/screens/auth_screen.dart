import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:task_app/screens/otp_screen.dart';
import 'package:task_app/ui/large_elevated_button.dart';
import 'package:task_app/ui/social_login_button.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static String verify = '';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'IN';
  PhoneNumber number = PhoneNumber(isoCode: 'IN');
  bool isPhoneValid = false;
  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ToggleSwitch(
                  minWidth: 90.0,
                  cornerRadius: 20.0,
                  activeBgColors: const [
                    [Color(0xFFBEFA62)],
                    [Color(0xFFBEFA62)]
                  ],
                  activeFgColor: Colors.black,
                  inactiveBgColor: Colors.white,
                  inactiveFgColor: Colors.black,
                  borderWidth: 1,
                  borderColor: [Colors.grey[300]!, Colors.grey[300]!],
                  initialLabelIndex: isSignIn ? 0 : 1,
                  totalSwitches: 2,
                  labels: const ['Signin', 'Signup'],
                  radiusStyle: true,
                  onToggle: (index) {
                    setState(() {
                      isSignIn = index == 0;
                    });
                  },
                ),
                const SizedBox(height: 44.0),
                Text(
                  'Welcome ${isSignIn ? 'Back!!' : 'to App'}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'PT Serif',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 44.0),
                Text(
                  isSignIn
                      ? 'Please login with your phone number'
                      : 'Please signup with your phone number to get registered',
                ),
                const SizedBox(height: 16.0),
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    setState(() {
                      phoneNumber = number.phoneNumber!;
                    });
                  },
                  onInputValidated: (bool value) {
                    setState(() {
                      isPhoneValid = value;
                    });
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: const TextStyle(color: Colors.black),
                  initialValue: number,
                  textFieldController: controller,
                  formatInput: false,
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  // inputBorder: const OutlineInputBorder(),
                  searchBoxDecoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  onSaved: (PhoneNumber number) {
                    // print('On Saved: $number');
                  },
                ),
                const SizedBox(height: 24.0),
                LargeElevatedButton(
                  label: 'Continue',
                  enabled: isPhoneValid,
                  onPressed: () {
                    if (isPhoneValid) {
                      Fluttertoast.showToast(msg: 'Sending OTP...');
                      sendOtp();
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Please enter valid phone number');
                    }
                  },
                ),
                const SizedBox(height: 18.0),
                Row(
                  children: const <Widget>[
                    Expanded(child: Divider(thickness: 1.5)),
                    Text(
                      "  OR  ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1.5)),
                  ],
                ),
                const SizedBox(height: 18),
                SocialLoginButton(
                  name: 'Metamask',
                  image: 'MetaMask_Fox.svg',
                  bgColor: const Color(0xFFF5FFF3),
                  onPressed: () {},
                ),
                const SizedBox(height: 4),
                SocialLoginButton(
                  name: 'Google',
                  bgColor: const Color(0xFFF5FFF3),
                  image: 'Google_Logo.png',
                  onPressed: () {
                  },
                ),
                const SizedBox(height: 4),
                SocialLoginButton(
                  name: 'Apple',
                  bgColor: Colors.black,
                  image: 'Apple_logo.png',
                  onPressed: () {
                    // signature is Y2yBVl+i2N7
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSignIn
                          ? "Don't have an account? "
                          : "Already have any accont? ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSignIn = !isSignIn;
                        });
                      },
                      child: Text(
                        isSignIn ? 'Signup' : 'Signin',
                        style: const TextStyle(
                          color: Color(0xFFBEFA62),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendOtp() async {
    // print('Sending otp...');
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        AuthScreen.verify = verificationId;
        // print('Code sent...');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(phoneNumber: phoneNumber),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
