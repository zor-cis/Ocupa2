import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/offer_provider.dart';

import 'utils/routes.dart';

import 'views/complete_profile_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';
import 'views/offer_detail_view.dart';
import 'views/offers_view.dart';
import 'views/recover_password_view.dart';
import 'views/register_view.dart';
import 'views/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OfferProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Ocupa2',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashView(),
          AppRoutes.login: (_) => const LoginView(),
          AppRoutes.register: (_) => const RegisterView(),
          AppRoutes.recoverPassword: (_) => const RecoverPasswordView(),
          AppRoutes.completeProfile: (_) => const CompleteProfileView(),
          AppRoutes.home: (_) => const HomeView(),

          // Ofertas
          AppRoutes.offers: (_) => const OffersView(),
          AppRoutes.offerDetail: (_) => const OfferDetailView(),
        },
      ),
    );
  }
}