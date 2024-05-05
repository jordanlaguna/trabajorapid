import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/authentication/controllers/signup_controller.dart';
import 'package:trabajorapid/utils/constans/colors.dart';
import 'package:trabajorapid/utils/constans/sizes.dart';
import 'package:trabajorapid/utils/constans/text_strings.dart';
import 'package:trabajorapid/utils/helpers/helpers_functions.dart';


class TSignupTermsConditions extends StatelessWidget {
  const TSignupTermsConditions({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final controller = SignupController.instance;
    final dark = THelperFunctions.isDarkMode(context);
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child:Obx(
            () => Checkbox(
              value: controller.privacyPolicy.value,
              onChanged: (value) => controller.privacyPolicy.value = !controller.privacyPolicy.value))),

        const SizedBox(width: TSizes.spaceBtwItems),

        Text.rich(
          TextSpan(
          children: [
          TextSpan(text: '${TText.iAgreeTo} ',style: Theme.of(context).textTheme.bodySmall),

          TextSpan(
            text: '${TText.privacyPolicy} ',
            style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: dark ? Colors.white : Colors.black,
                    decoration: TextDecoration.underline,
                    decorationColor: dark ? Colors.white : TColors.primaryColor,
            )
          ),
        
          TextSpan(text: '${TText.and} ', style: Theme.of(context).textTheme.bodySmall),

          TextSpan(text: TText.termsOfService, style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: dark ? Colors.white : Colors.black,
                    decoration: TextDecoration.underline,
                    decorationColor: dark ? Colors.white : TColors.primaryColor,
          )),
        ]))
      ],
    );
  }
}