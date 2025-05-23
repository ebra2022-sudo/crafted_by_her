import 'package:flutter/material.dart';

Widget searchBar({
  String hintText = '',
  required TextEditingController controller,
  required void Function(String)? onChanged,
  required void Function()? onPressed,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: const [
        BoxShadow(
          color: Color(0xFFDADADA),
          offset: Offset(2, 1),
          blurRadius: 4,
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          fontSize: 14,
          color: Colors.black,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 242, 92, 5),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: onPressed,
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
    ),
  );
}
