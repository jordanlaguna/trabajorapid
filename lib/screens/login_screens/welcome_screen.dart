import 'package:flutter/material.dart';
import 'package:trabajorapid/screens/login_screens/signin_screen.dart';
import 'package:trabajorapid/screens/login_screens/signup_screen.dart';
import 'package:trabajorapid/widgets/custom_scaffold.dart';
import 'package:trabajorapid/widgets/welcome_button.dart';
import 'package:trabajorapid/theme/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'RapidJobs',
                          style: TextStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Image.asset(
                              'assets/images/appLogo.png',
                              height: 250,
                            ),
                          ),
                        ),
                        const TextSpan(
                            text: '\n¡Bienvenido!\n',
                            style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.w600,
                            )),
                        const TextSpan(
                            text: '\nPara acceder inicia sesión o registrate\n',
                            style: TextStyle(
                              fontSize: 20,
                              // height: 0,
                            ))
                      ],
                    ),
                  ),
                ),
              )),
          Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  children: [
                    const Expanded(
                      child: WelcomeButton(
                        buttonText: "Iniciar Sesión",
                        onTap: SignInScreen(),
                        color: Colors.transparent,
                        textColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: WelcomeButton(
                        buttonText: "Registrarse",
                        onTap: const SignUpScreen(),
                        color: Colors.white,
                        textColor: lightColorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
