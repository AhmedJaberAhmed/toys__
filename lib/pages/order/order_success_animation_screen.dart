import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nyoba/pages/order/order_success_screen.dart';
import 'package:nyoba/pages/order/reveal_route.dart';

class OrderSuccessAnimationScreen extends StatefulWidget {
  const OrderSuccessAnimationScreen({super.key});

  @override
  State<OrderSuccessAnimationScreen> createState() =>
      _OrderSuccessAnimationScreenState();
}

class _OrderSuccessAnimationScreenState
    extends State<OrderSuccessAnimationScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(milliseconds: 2500)).then((value) {
      Navigator.push(
          context,
          RevealRoute(
              page: OrderSuccess(),
              maxRadius: 800,
              centerAlignment: Alignment.center));
    });
  }

  @override
  dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/order/successbg.jpg"),
              fit: BoxFit.cover)),
      height: double.infinity,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: 400,
          height: 400,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Lottie.asset(
              "images/order/successful.json",
              fit: BoxFit.fill,
              repeat: false,
            ),
          ),
        ),
      ),
    ));
  }
}
