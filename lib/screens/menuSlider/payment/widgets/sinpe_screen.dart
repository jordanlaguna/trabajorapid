// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SinpePage extends StatefulWidget {
  const SinpePage({super.key});

  @override
  State<SinpePage> createState() => _SinpePageState();
}

class _SinpePageState extends State<SinpePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Image(
                image: const AssetImage('assets/logos/sinpeLogo.png'),
                height: size.height * 0.20,
              ),
              SizedBox(height: size.height * 0.005),
              const Text(
                'Sinpe Móvil',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Divider(),
              SizedBox(height: size.height * 0.01),
              TextFormField(
                decoration: InputDecoration(
                  suffixIcon: Icon(FontAwesome.id_card,
                      color: Theme.of(context).colorScheme.secondary),
                  labelText: 'Ingrese su cédula',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.7),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              TextFormField(
                decoration: InputDecoration(
                  suffixIcon: Icon(FontAwesome.phone_solid,
                      color: Theme.of(context).colorScheme.secondary),
                  labelText: 'Número de teléfono',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.7),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              TextFormField(
                decoration: InputDecoration(
                  suffixIcon: Icon(FontAwesome.money_bill_transfer_solid,
                      color: Theme.of(context).colorScheme.secondary),
                  labelText: 'Ingrese el monto a pagar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.7),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              TextFormField(
                decoration: InputDecoration(
                  suffixIcon: Icon(FontAwesome.check_solid,
                      color: Theme.of(context).colorScheme.secondary),
                  labelText: 'Ingrese el detalle del pago',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.7),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 90,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Pagar',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
