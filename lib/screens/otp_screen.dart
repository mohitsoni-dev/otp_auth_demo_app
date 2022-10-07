import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:task_app/screens/auth_screen.dart';
import 'package:task_app/ui/large_elevated_button.dart';
import 'package:telephony/telephony.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  int secondsRemaining = 30;
  bool enableResend = false;
  Timer? timer;

  Telephony telephony = Telephony.instance;
  OtpFieldController otpbox = OtpFieldController();
  String pin = '';

  @override
  void initState() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        // print(message.address); //+977981******67, sender nubmer
        // print(message.body); //Your OTP code is 34567
        // print(message.date); //1659690242000, timestamp

        String sms = message.body.toString(); //get the message

        //verify SMS is sent for OTP with sender number
        String otpcode = sms.substring(0, 6);

        //prase code from the OTP sms
        otpbox.set(otpcode.split(""));
        //split otp code to list of number
        //and populate to otb boxes

        setState(() {
          pin = otpcode;
        });
      },
      listenInBackground: false,
    );
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'PT Serif',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Text('A six digit code has been sent to ${widget.phoneNumber}'),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text('Incorrect number? '),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: Color(0xFFBEFA62),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
            OTPTextField(
              controller: otpbox,
              length: 6,
              width: MediaQuery.of(context).size.width,
              fieldWidth: 50,
              style: const TextStyle(fontSize: 32),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.underline,
              onChanged: (pin) {
                setState(() {
                  this.pin = pin;
                });
              },
            ),
            const SizedBox(height: 44),
            LargeElevatedButton(
              label: pin.length == 6 ? 'Done' : 'Resend OTP',
              enabled: pin.length == 6 || enableResend,
              onPressed: () {
                if (pin.length == 6) {
                  verifyOTP();
                } else {
                  resendOTP();
                }
              },
            ),
            const SizedBox(height: 16.0),
            Center(
              child: !enableResend
                  ? Text('Resend OTP in ${secondsRemaining}s')
                  : Column(
                      children: [
                        const Text(
                          "Didn't receive any code?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        GestureDetector(
                          onTap: () {
                            resendOTP();
                          },
                          child: const Text(
                            'Re-send code',
                            style: TextStyle(
                              color: Color(0xFFBEFA62),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void verifyOTP() async {
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: AuthScreen.verify,
        smsCode: pin,
      );

      // Sign the user in (or link) with the credential
      await auth.signInWithCredential(credential);

      Fluttertoast.showToast(
        msg: 'OTP Verified',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Invalid OTP',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  void resendOTP() async {
    Fluttertoast.showToast(msg: 'Resending code...');
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        AuthScreen.verify = verificationId;
        setState(() {
          secondsRemaining = 30;
          enableResend = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
