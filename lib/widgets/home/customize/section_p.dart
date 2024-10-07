import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/provider/flash_sale_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/flashsale/flash_sale_countdown.dart';
import 'package:provider/provider.dart';

class SectionP extends StatefulWidget {
  const SectionP({Key? key}) : super(key: key);

  @override
  State<SectionP> createState() => _SectionPState();
}

class _SectionPState extends State<SectionP> with TickerProviderStateMixin {
  AnimationController? _colorAnimationController;
  AnimationController? _textAnimationController;
  Animation? _colorTween, _titleColorTween, _iconColorTween, _moveTween;

  @override
  void initState() {
    super.initState();
    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween = ColorTween(
      begin: primaryColor.withOpacity(0.0),
      end: primaryColor.withOpacity(1.0),
    ).animate(_colorAnimationController!);
    _titleColorTween = ColorTween(
      begin: Colors.white,
      end: HexColor("ED625E"),
    ).animate(_colorAnimationController!);
    _iconColorTween = ColorTween(begin: Colors.white, end: HexColor("#4A3F35"))
        .animate(_colorAnimationController!);
    _textAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _moveTween = Tween(
      begin: Offset(0, 0),
      end: Offset(-25, 0),
    ).animate(_colorAnimationController!);
  }

  @override
  Widget build(BuildContext context) {
    // final home = Provider.of<HomeProvider>(context, listen: false);
    // //flash sale countdown & card product item
    return Consumer2<HomeProvider, FlashSaleProvider>(
        builder: (context, value, value2, child) {
      if (value.flashSales.isEmpty) {
        return Container();
      }
      return FlashSaleCountdown(
        dataFlashSaleCountDown: value.flashSales,
        dataFlashSaleProducts: value2.flashSaleProducts,
        textAnimationController: _textAnimationController,
        colorAnimationController: _colorAnimationController,
        colorTween: _colorTween,
        iconColorTween: _iconColorTween,
        moveTween: _moveTween,
        titleColorTween: _titleColorTween,
        loading: value.loading,
      );
    });
  }
}
