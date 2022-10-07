import 'package:flutter/material.dart';

class LargeElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final bool? enabled;
  const LargeElevatedButton({
    Key? key,
    this.enabled,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
            backgroundColor: enabled! ? const Color(0xFFBEFA62) : const Color(0xFFECFED0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
