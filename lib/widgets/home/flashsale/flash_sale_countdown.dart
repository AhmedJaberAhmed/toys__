import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:nyoba/pages/product/product_more_screen.dart';
import 'package:nyoba/provider/flash_sale_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/flashsale/flash_sale_container.dart';
import 'package:provider/provider.dart';
import '../../../app_localizations.dart';
import '../../../models/product_model.dart';

class FlashSaleCountdown extends StatelessWidget {
  final List<dynamic>? dataFlashSaleCountDown;
  final List<ProductModel>? dataFlashSaleProducts;
  final AnimationController? colorAnimationController;
  final AnimationController? textAnimationController;

  final bool? loading;
  final Animation? colorTween, titleColorTween, iconColorTween, moveTween;

  FlashSaleCountdown({
    Key? key,
    this.dataFlashSaleCountDown,
    this.dataFlashSaleProducts,
    this.colorAnimationController,
    this.textAnimationController,
    this.colorTween,
    this.titleColorTween,
    this.iconColorTween,
    this.moveTween,
    this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flashSale = Provider.of<FlashSaleProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context);

    if (homeProvider.loading) {
      return customLoading();
    }

    int endTime = _getEndTime();
    if (dataFlashSaleCountDown == null || endTime < DateTime.now().millisecondsSinceEpoch) {
      return Container();
    }

    return Column(
      children: [
        Visibility(
          visible: dataFlashSaleCountDown!.isNotEmpty && endTime > DateTime.now().millisecondsSinceEpoch,
          child: CountdownTimer(
            endTime: endTime,
            widgetBuilder: (_, CurrentRemainingTime? time) {
              if (time == null) {
                flashSale.fetchFlashSale();
                return _buildCountdownEndWidget();
              }
              return _buildCountdownTimerWidget(context, flashSale, time);
            },
          ),
        ),
      ],
    );
  }

  int _getEndTime() {
    if (dataFlashSaleCountDown != null && !loading! && dataFlashSaleCountDown!.isNotEmpty) {
      return DateTime.parse(dataFlashSaleCountDown![0].endDate).millisecondsSinceEpoch;
    }
    return DateTime.now().millisecondsSinceEpoch + 1000 * 30; // default 30 seconds
  }

  Widget _buildCountdownEndWidget() {
    return Container(
      child: Text('Flash Sale END'),
    );
  }

  Widget _buildCountdownTimerWidget(BuildContext context, FlashSaleProvider flashSale, CurrentRemainingTime time) {
    int hours = _calculateTotalHours(time);

    return Column(
      children: [
        _buildHeader(context, flashSale),
        _buildCountdownDisplay(hours, time),
        if (!loading!)
          FlashSaleContainer(
            textAnimationController: textAnimationController,
            colorAnimationController: colorAnimationController,
            colorTween: colorTween,
            iconColorTween: iconColorTween,
            moveTween: moveTween,
            titleColorTween: titleColorTween,
            dataProducts: dataFlashSaleProducts,
            loading: loading,
            customImage: dataFlashSaleCountDown![0].image,
          ),
      ],
    );
  }

  int _calculateTotalHours(CurrentRemainingTime time) {
    int hours = time.hours ?? 0;
    if (time.days != null && time.days != 0) {
      hours += (time.days! * 24);
    }
    return hours;
  }

  Widget _buildHeader(BuildContext context, FlashSaleProvider flashSale) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 15, bottom: 6, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.translate('flashsale')!,
            style: TextStyle(fontSize: responsiveFont(14), fontWeight: FontWeight.w600),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductMoreScreen(
                    include: flashSale.flashSales[0].products,
                    name: AppLocalizations.of(context)!.translate('flashsale'),
                  ),
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.translate('more')!,
              style: TextStyle(fontSize: responsiveFont(12), fontWeight: FontWeight.w600, color: secondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownDisplay(int hours, CurrentRemainingTime time) {
    return Container(
      height: 30,
      margin: EdgeInsets.only(left: 15, bottom: 10),
      child:Row(
        children: [
          Icon(Icons.electric_bolt_sharp, color: primaryColor, size: responsiveFont(24)),
          SizedBox(width: 10),
          _buildTimeBox(hours < 100 ? hours.toString().padLeft(2, '0') : hours.toString()),
          SizedBox(width: 5),
          Text(
            "hours",
            style: TextStyle(fontSize: responsiveFont(14), color:  Color(0xFF2C3E70)),
          ),
          SizedBox(width: 5),
          _buildColon(),
          SizedBox(width: 5),
          _buildTimeBox(time.min?.toString().padLeft(2, '0') ?? "00"),
          SizedBox(width: 5),
          Text(
            "minutes",
            style: TextStyle(fontSize: responsiveFont(14), color:  Color(0xFF2C3E70)),
          ),
          SizedBox(width: 5),
          _buildColon(),
          SizedBox(width: 5),
          _buildTimeBox(time.sec?.toString().padLeft(2, '0') ?? "00"),
          SizedBox(width: 5),
          Text(
            "seconds",
            style: TextStyle(fontSize: responsiveFont(14), color: Color(0xFF2C3E70)),
          ),
        ],
      )


    );
  }

  Widget _buildTimeBox(String timeValue) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(5)),
      width: 30,
      child: Text(
        timeValue,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: responsiveFont(10)),
      ),
    );
  }

  Widget _buildColon() {
    return Text(
      ":",
      style: TextStyle(color: secondaryColor, fontSize: responsiveFont(12)),
    );
  }
}
