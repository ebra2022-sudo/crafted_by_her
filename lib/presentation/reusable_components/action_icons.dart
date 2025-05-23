import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomButtonRow extends StatelessWidget {
  final VoidCallback? onLanguagePressed;
  final VoidCallback? onSellPressed;
  final VoidCallback? onLoginPressed;

  const CustomButtonRow({
    super.key,
    this.onLanguagePressed,
    this.onSellPressed,
    this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
            child: FittedBox(
          fit: BoxFit.scaleDown,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: SvgPicture.asset('assets/icon/language.svg'),
            onPressed: onLanguagePressed,
          ),
        )),
        // SAMPL CASE DESING THE SATE OF THE DEISGN
        Flexible(
            child: FittedBox(
          fit: BoxFit.scaleDown,
          child: OutlinedButton(
            onPressed: onSellPressed,
            style: OutlinedButton.styleFrom(
                fixedSize: const Size(80, 30),
                side: const BorderSide(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
            child: const Text(
              'Sell',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        )),
        ElevatedButton(
          onPressed: onLoginPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Row(
            children: [Text('Login')],
          ),
        )
      ],
    );
  }
}
