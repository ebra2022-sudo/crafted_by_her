import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/domain/models/product.dart';
import 'package:crafted_by_her/presentation/super_admin_main.dart';
import 'package:crafted_by_her/presentation/reusable_components/admin_card.dart';
import 'package:crafted_by_her/presentation/reusable_components/admin_product_card.dart';
import 'package:crafted_by_her/presentation/reusable_components/product_review_card.dart';
import 'package:crafted_by_her/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'presentation/account_screen.dart';
import 'presentation/profile_screen.dart';
import 'presentation/reusable_components/avatar.dart';
import 'presentation/reusable_components/score_to_rating_stars.dart';
import 'presentation/seller_form_submission.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          //
          ChangeNotifierProvider<AuthViewModel>(
            create: (_) => AuthViewModel(),
          ),
          ChangeNotifierProvider(create: (_) => ProductData()),
        ],
        child: MaterialApp(
            theme: ThemeData(primaryColor: Colors.green),
            debugShowCheckedModeBanner: false,
            home: Container(
                color: Colors.white,
                height: double.infinity,
                width: double.infinity,
                child: const SplashScreen())));
  }
}
