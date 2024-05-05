import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/utils/constans/image_strings.dart';
import 'package:trabajorapid/utils/constans/sizes.dart';
import 'package:trabajorapid/utils/constans/text_strings.dart';
import 'package:trabajorapid/utils/helpers/helpers_functions.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => Get.back(), icon: const Icon(CupertinoIcons.clear))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Image 60% of the screen
            Image(
              image: const AssetImage(TImages.emailIlustration),
              width: THelperFunctions.screenWidth() * 0.6,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            //Title
            Text(TText.changeYourPasswordTitle, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: TSizes.spaceBtwItems),

            Text(TText.changeYourPasswordSubtitle, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
            const SizedBox(height: TSizes.spaceBtwItems),

            //Buttons
            SizedBox(
                width: double.infinity,
                child:
                ElevatedButton(
                    onPressed: (){},
                    child: const Text(TText.tContinue)
                )
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

             SizedBox(
                width: double.infinity,
                child:
                TextButton(
                    onPressed: (){},
                    child: const Text(TText.resendEmail)
                )
            ),
            
          ],)
          )
      )
    );
  }
}