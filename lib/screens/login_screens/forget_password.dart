import 'package:flutter/material.dart';
import 'package:trabajorapid/widgets/custom_scaffold.dart';

class ForgetPasswordScreen extends StatefulWidget{
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen>{
  @override
  Widget build(BuildContext context) {
     return const CustomScaffold(
      child: Text("Forget Password"),
    );
  }
}