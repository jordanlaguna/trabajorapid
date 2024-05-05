import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:trabajorapid/authentication/screens/onboarding/controller/onboarding_controller.dart';
import 'package:trabajorapid/utils/constans/colors.dart';
import 'package:trabajorapid/utils/constans/sizes.dart';
import 'package:trabajorapid/utils/device/device_utility.dart';
import 'package:trabajorapid/utils/helpers/helpers_functions.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Positioned(
      right: TSizes.defaultSpace,
      bottom: TDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: dark ? TColors.primaryColor: Colors.black),
        child: const Icon(Iconsax.arrow_right_3)
      )
    );
  }
}