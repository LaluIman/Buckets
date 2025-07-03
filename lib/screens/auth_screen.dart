import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:income_tracker/services/auth_service.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:income_tracker/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset(
              "assets/icons/logo.svg",
              width: 70,
              height: 70,
              colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Welcome to ',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextSpan(
                    text: 'Buckets',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: primaryColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Manage your income with ease',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Image.asset("assets/images/Login.png"),
            SizedBox(height: 20),
            Container(
              height: 250,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Text(
                    "Continue using Google to use the App!",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<AuthProvider>(
                    builder: (context, authService, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, _){
                            return CustomButton(
                            text: "Continue with Google",
                            icon: "assets/icons/google_icon.svg",
                            onPressed: authProvider.isLoading
                                ? () {}
                                : authProvider.signInWithGoogle,
                          );
                          }
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
