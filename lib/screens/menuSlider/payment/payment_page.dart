// ignore_for_file: avoid_print, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:trabajorapid/screens/menuSlider/payment/widgets/payment_screen.dart';
import 'package:trabajorapid/screens/menuSlider/payment/widgets/sinpe_screen.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Método de pago',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 65, 111, 223),
                Color.fromARGB(255, 110, 174, 231),
              ],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              child: Text(
                'Sinpe Móvil',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Tarjeta de debito',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: TabBarView(
          key: Key(_tabController.index.toString()),
          controller: _tabController,
          children: [
            const SinpePage(),
            const CardPayment(),
          ],
        ),
      ),
    );
  }
}
