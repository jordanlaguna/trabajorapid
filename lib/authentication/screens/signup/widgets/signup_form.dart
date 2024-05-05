import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:trabajorapid/authentication/controllers/signup_controller.dart';
import 'package:trabajorapid/authentication/screens/login/login.dart';
import 'package:trabajorapid/authentication/screens/signup/widgets/signup_terms_conditions.dart';
import 'package:trabajorapid/utils/constans/sizes.dart';
import 'package:trabajorapid/utils/constans/text_strings.dart';
import 'package:trabajorapid/utils/validators/validation.dart';

class TSignupForm extends StatelessWidget {
  const TSignupForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    return Form(
      key: controller.signupformKey,
      child: Column(
        children: [
          TextFormField(
            validator: (value) => TValidator.validateEmptyText('Nombre Completo', value),
            controller: controller.fullname,
            //expands: false,
            decoration: const InputDecoration(
                labelText: TText.fullName, prefixIcon: Icon(Iconsax.user)),
          ),

          const SizedBox(width: TSizes.spaceBtwInputFields),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Email
          TextFormField(
            validator: (value) => TValidator.validateEmail(value),
            controller: controller.email,
            decoration: const InputDecoration(
                labelText: TText.email, prefixIcon: Icon(Iconsax.direct_right)),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Phone Number
          TextFormField(
            validator: (value) => TValidator.validatePhoneNumber(value),
            controller: controller.phone,
            decoration: const InputDecoration(
                labelText: TText.phone, prefixIcon: Icon(Iconsax.call)),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Password
          Obx(
            () => TextFormField(
              validator: (value) => TValidator.validatePassword(value),
              controller: controller.password,
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                labelText: TText.password,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => controller.hidePassword.value =
                      !controller.hidePassword.value,
                  icon: Icon(controller.hidePassword.value
                      ? Iconsax.eye_slash
                      : Iconsax.eye),
                ),
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Terms & Conditions
          const TSignupTermsConditions(),
          const SizedBox(height: TSizes.spaceBtwSections),

          //SignUp Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.signup(),
              child: const Text(TText.signUp),
            ),
          ),

          const SizedBox(height: TSizes.spaceBtwItems),
          // Create Account
          SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  child: const Text(TText.alreadyHaveAccount))),
        ],
      ),
    );
  }
}
