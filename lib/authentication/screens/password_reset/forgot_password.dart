import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:trabajorapid/authentication/controllers/forget_password_controller.dart';
import 'package:trabajorapid/utils/constans/sizes.dart';
import 'package:trabajorapid/utils/constans/text_strings.dart';
import 'package:trabajorapid/utils/validators/validation.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    return Scaffold(
      appBar: AppBar(),
      body:  SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headings
              Text(TText.forgetPasswordTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: TSizes.spaceBtwItems),
        
              Text(TText.forgetPasswordSubtitle, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: TSizes.spaceBtwSections),
        
              //TextFields
              Form(
                key: controller.forgetPasswordformKey,
                child: TextFormField(
                  validator: TValidator.validateEmail,
                  controller: controller.email,
                  decoration: const InputDecoration(
                    labelText: TText.email,
                    prefixIcon: Icon(Iconsax.direct_right),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // Reset Button Password
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.sendPasswordResetEmail(),
                  child: const Text(TText.submit),
                  )
                ),
            ],
          ),
        ),
      ),
    );
  }
}
