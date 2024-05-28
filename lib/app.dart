import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabajorapid/bindings/general_bindings.dart';
import 'package:trabajorapid/screens/menuSlider/profile_drawer/profile_drawer.dart';
import 'package:trabajorapid/utils/constans/colors.dart';
import 'package:trabajorapid/utils/theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'RapidJobs',
        debugShowCheckedModeBanner: false,
        routes: {
          '/profile': (context) => const ProfileDrawer(),
        },
        themeMode: ThemeMode.system,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        initialBinding: GeneralBindings(),
        home: const Scaffold(
            backgroundColor: TColors.colorCyan,
            body: Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ))));
  }
}
