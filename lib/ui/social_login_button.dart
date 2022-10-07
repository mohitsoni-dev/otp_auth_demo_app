import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String name;
  final String image;
  final void Function()? onPressed;
  final Color bgColor;

  const SocialLoginButton({
    Key? key,
    required this.bgColor,
    required this.name,
    required this.image,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/logo/$image'),
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 4.0),
              Text(
                'Connect to ',
                style: TextStyle(
                    color: (name.compareTo('Apple') == 0)
                        ? Colors.white
                        : Colors.black),
              ),
              Text(
                name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (name.compareTo('Apple') == 0)
                        ? Colors.white
                        : Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }
}
