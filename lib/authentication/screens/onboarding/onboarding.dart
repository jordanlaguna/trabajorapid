import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/authentication/screens/onboarding/controller/onboarding_controller.dart';
import 'package:trabajorapid/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:trabajorapid/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:trabajorapid/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:trabajorapid/authentication/screens/onboarding/widgets/onboarding_smooth_indicator.dart';
import 'package:trabajorapid/utils/constans/image_strings.dart';
import 'package:trabajorapid/utils/constans/text_strings.dart';


class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                image: TImages.onBoardingImage1,
                title: TText.onboardingTitle1,
                subTitle: TText.onboardingSubtitle1,
              ),
              OnBoardingPage(
                image: TImages.onBoardingImage2,
                title: TText.onboardingTitle2,
                subTitle: TText.onboardingSubtitle2,
              ),
              OnBoardingPage(
                image: TImages.onBoardingImage3,
                title: TText.onboardingTitle3,
                subTitle: TText.onboardingSubtitle3,
              ),
            ],
          ),
          
          //Skip Button
          const OnBoardingSkip(),

          //Smooth Indicator
           const OnBoardingSmoothIndicator(),

           //Circular Button
          const OnBoardingNextButton()
        ],
      ),
    );
  }
}
