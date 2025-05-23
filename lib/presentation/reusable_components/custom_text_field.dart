import 'package:flutter/material.dart';

Widget customTextField(
    {TextEditingController? controller,
    String? errorText,
    String hintText = '',
    String textFieldTitle = '',
    bool isDescription = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        textFieldTitle,
        style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.2),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        maxLines: isDescription? 4: 1,
        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color.fromARGB(255, 110, 110, 110),
              letterSpacing: 0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color.fromARGB(140, 18, 18, 18)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorText: errorText,
          errorStyle: const TextStyle(color: Colors.red),
          suffixIcon: (controller?.text ?? '').isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    controller?.clear();
                  },
                )
              : null,
        ),
      )
    ],
  );
}
