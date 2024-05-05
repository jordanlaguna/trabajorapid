import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/authentication/screens/login/widgets/login_divider.dart';
import 'package:trabajorapid/authentication/screens/login/widgets/login_form.dart';
import 'package:trabajorapid/authentication/screens/login/widgets/login_header.dart';
import 'package:trabajorapid/authentication/screens/login/widgets/login_social_buttons.dart';
import 'package:trabajorapid/common/styles/spacing_styles.dart';
import 'package:trabajorapid/utils/constans/sizes.dart';
import 'package:trabajorapid/utils/constans/text_strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              // Logo Rapid Jobs
              const TLoginHeader(),

              // Form
              const TLoginForm(),

              // Divider
              TFormDivider(dividerText: TText.orSignInWith.capitalize!),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Footer
              const TSocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

