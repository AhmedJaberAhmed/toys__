import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/models/order_model.dart';
import 'package:nyoba/pages/chat/chat_page.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/order/order_detail_shimmer.dart';
import 'package:nyoba/widgets/webview/checkout_webview.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uiblock/uiblock.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../app_localizations.dart';

class OrderDetail extends StatefulWidget {
  final String? orderId;
  OrderDetail({Key? key, this.orderId}) : super(key: key);

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  _launchWAURL(String? phoneNumber) async {
    String url = 'https://api.whatsapp.com/send?phone=$phoneNumber&text=Hi';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  TextEditingController chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOrder();
  }

  bool viaWallet = false;
  String amount = "0";
  loadOrder() async {
    await Provider.of<OrderProvider>(context, listen: false)
        .fetchDetailOrder(widget.orderId)
        .then((value) {
      if (Provider.of<OrderProvider>(context, listen: false)
              .detailOrder!
              .feeLines!
              .length >
          0) {
        for (int i = 0;
            i <
                Provider.of<OrderProvider>(context, listen: false)
                    .detailOrder!
                    .feeLines!
                    .length;
            i++) {
          if (Provider.of<OrderProvider>(context, listen: false)
                  .detailOrder!
                  .feeLines![i]
                  .name ==
              "Via wallet") {
            amount = Provider.of<OrderProvider>(context, listen: false)
                .detailOrder!
                .feeLines![i]
                .amount!
                .substring(1);
            viaWallet = true;
          }
        }
      } else {
        amount = "0";
      }
      loadOrderedItems();
    });
  }

  loadOrderedItems() async {
    await Provider.of<OrderProvider>(context, listen: false)
        .loadItemOrder(context);
    Session.data.remove('order_number');
    this.setState(() {});
  }

  void _showDialogChat() {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext contextdialog) {
        return SimpleDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  Text(
                    "Chat to Admin",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "*After you send your message here, you will be redirect to our live chat",
                    style: TextStyle(fontSize: 12, color: HexColor('9e9e9e')),
                    softWrap: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: chatController,
                    maxLines: 5,
                    maxLength: 200,
                    style: TextStyle(
                      fontSize: responsiveFont(11),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: secondaryColor),
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(color: secondaryColor),
                            borderRadius: BorderRadius.circular(10)),
                        hintText: "Type your message here ...",
                        hintStyle: TextStyle(
                            fontSize: responsiveFont(11),
                            color: HexColor('9e9e9e')),
                        counterText: ''),
                    textInputAction: TextInputAction.done,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: secondaryColor),
                              borderRadius: BorderRadius.circular(5.0)),
                          elevation: 0,
                          height: 40,
                          color: secondaryColor,
                          onPressed: () async {
                            Navigator.pop(contextdialog, 200);
                          },
                          child: Text(
                            "Send",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == 200) {
        UIBlock.block(context);
        context
            .read<ChatProvider>()
            .sendChat(
                message: chatController.text,
                type: "order",
                postId: int.parse(widget.orderId!))
            .then((data) {
          printLog("data : $data");
          if (data["status"] == "success") {
            UIBlock.unblock(context);

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(),
                ));
          } else {
            UIBlock.unblock(context);
            Navigator.pop(context);
            snackBar(context,
                message: AppLocalizations.of(context)!
                    .translate('snackbar_message_failed')!);
          }
        });

        chatController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contact = Provider.of<HomeProvider>(context, listen: false);
    final order = Provider.of<OrderProvider>(context, listen: false);
    final isChatActive = Provider.of<HomeProvider>(context).isChatActive;
    Widget buildOrder = ListenableProvider.value(
      value: order,
      child: Consumer<OrderProvider>(builder: (context, value, child) {
        if (value.isLoading) {
          return OrderDetailShimmer();
        } else {
          final _aftershipOrder = order.detailOrder!.aftershipOrder;
          final _aftershipCheck =
              Provider.of<HomeProvider>(context, listen: false).afterShipCheck;
          final isDarkMode =
              Provider.of<AppNotifier>(context, listen: false).isDarkMode;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      width: double.infinity,
                      color: HexColor("#def1ef"),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: QrImageView(
                            data: value.detailOrder!.id.toString(),
                            version: QrVersions.auto,
                            size: 180.w,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15, left: 15, right: 15),
                      child: Row(
                        children: [
                          Container(
                              width: 30.w,
                              height: 30.h,
                              child: Icon(Icons.shopping_bag_outlined)),
                          Container(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .translate("order_id")!,
                                    style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    " ${order.detailOrder!.id}",
                                    style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        fontWeight: FontWeight.w500,
                                        color: secondaryColor),
                                  )
                                ],
                              ),
                              Text(
                                "${AppLocalizations.of(context)!.translate('status')} : ${value.statusOrder}",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          Spacer(),
                          order.detailOrder!.biteshipData != null
                              ? Visibility(
                                  visible: order.detailOrder!.biteshipData!
                                          .deliveryStatus ==
                                      "delivered",
                                  child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: secondaryColor,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('delivered')!,
                                        style: TextStyle(
                                            fontSize: responsiveFont(10),
                                            color: Colors.white),
                                      )),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Container(
                      color: HexColor("EEEEEE"),
                      margin: EdgeInsets.all(15),
                      height: 2,
                      width: double.infinity,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 30.w,
                              height: 30.h,
                              child: Icon(Icons.local_shipping_outlined)),
                          Container(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate('shipping_information')!,
                                  style: TextStyle(
                                      fontSize: responsiveFont(12),
                                      fontWeight: FontWeight.w500),
                                ),
                                order.detailOrder!.shippingServices!.isEmpty
                                    ? Text(
                                        "-",
                                        style: TextStyle(
                                            fontSize: responsiveFont(10)),
                                      )
                                    : Text(
                                        "${order.detailOrder!.shippingServices![0].serviceName} ",
                                        style: TextStyle(
                                            fontSize: responsiveFont(10)),
                                      ),
                                order.detailOrder!.biteshipData != null
                                    ? Visibility(
                                        visible: order.detailOrder!
                                                .biteshipData!.shipmentNumber !=
                                            "",
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .translate('no_resi')!,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )
                                    : Container(),
                                order.detailOrder!.biteshipData != null
                                    ? Visibility(
                                        visible: order.detailOrder!
                                                .biteshipData!.shipmentNumber !=
                                            "",
                                        child: Row(
                                          children: [
                                            Text(
                                              "${order.detailOrder!.biteshipData!.shipmentNumber} ",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                await Clipboard.setData(
                                                    ClipboardData(
                                                        text:
                                                            "${order.detailOrder!.biteshipData!.shipmentNumber}"));
                                                snackBar(context,
                                                    message:
                                                        "Success Copy Shipment Number");
                                              },
                                              child: Icon(
                                                Icons.copy,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          (_aftershipOrder != null &&
                                      _aftershipCheck!.pluginActive!) ||
                                  (order.detailOrder!.biteshipData != null &&
                                      order.detailOrder!.biteshipData!
                                              .linkTracking !=
                                          "")
                              ? GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    var _url;
                                    final _baseUrl =
                                        _aftershipCheck!.aftershipDomain;
                                    if (_aftershipOrder != null) {
                                      _url =
                                          "https://$_baseUrl/${_aftershipOrder.trackingNumber}?detect-slug=${_aftershipOrder.slug!}";
                                    } else if (order
                                            .detailOrder!.biteshipData !=
                                        null) {
                                      _url = order.detailOrder!.biteshipData!
                                          .linkTracking;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WebViewScreen(
                                          title: 'Tracking',
                                          url: _url,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: secondaryColor,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text(
                                        "Tracking",
                                        style: TextStyle(
                                            fontSize: responsiveFont(10),
                                            color: Colors.white),
                                      )),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    Container(
                      color: HexColor("EEEEEE"),
                      margin: EdgeInsets.all(15),
                      height: 2,
                      width: double.infinity,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 30.w,
                              height: 30.h,
                              child: Icon(Icons.location_on_outlined)),
                          Container(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate('shipping_address')!,
                                  style: TextStyle(
                                      fontSize: responsiveFont(12),
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "${order.detailOrder!.shippingInfo!.firstName} ${order.detailOrder!.shippingInfo!.lastName}",
                                  style:
                                      TextStyle(fontSize: responsiveFont(11)),
                                ),
                                Text(
                                  order.detailOrder!.shippingInfo!.phone!,
                                  style:
                                      TextStyle(fontSize: responsiveFont(11)),
                                ),
                                Text(
                                  order
                                      .detailOrder!.shippingInfo!.firstAddress!,
                                  style:
                                      TextStyle(fontSize: responsiveFont(11)),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      color: HexColor("EEEEEE"),
                      margin: EdgeInsets.all(15),
                      height: 2,
                      width: double.infinity,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 30.w,
                              height: 30.h,
                              child: Icon(Icons.credit_card_outlined)),
                          Container(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .translate('payment_info')!,
                                      style: TextStyle(
                                          fontSize: responsiveFont(12),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    buildBtnPay()
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate('payment_method')!,
                                  style: TextStyle(
                                      fontSize: responsiveFont(10),
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "${order.detailOrder!.paymentMethodTitle}",
                                  style: TextStyle(
                                      fontSize: responsiveFont(12),
                                      fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate('payment_description')!,
                                  style: TextStyle(
                                      fontSize: responsiveFont(10),
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "${order.detailOrder!.paymentDescription}",
                                  style: TextStyle(
                                      fontSize: responsiveFont(12),
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: order.detailOrder!.customerNote!.isNotEmpty,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            color: HexColor("EEEEEE"),
                            height: 2,
                            width: double.infinity,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width: 30.w,
                                    height: 30.h,
                                    child: Icon(Icons.assignment_outlined)),
                                Container(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .translate('order_notes')!,
                                        style: TextStyle(
                                            fontSize: responsiveFont(12),
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${order.detailOrder!.customerNote}",
                                        style: TextStyle(
                                            fontSize: responsiveFont(12),
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: HexColor("EEEEEE"),
                      margin: EdgeInsets.only(top: 15, bottom: 15),
                      height: 5,
                      width: double.infinity,
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: order.detailOrder!.productItems!.length,
                        itemBuilder: (context, i) {
                          return item(order.detailOrder!.productItems![i],
                              order.detailOrder!);
                        }),
                    // Container(
                    //   height: 5,
                    // ),
                    Visibility(
                      visible:
                          order.detailOrder!.feeLines!.length > 0 && viaWallet,
                      child: Column(
                        children: [
                          Container(
                            color: HexColor("EEEEEE"),
                            margin: EdgeInsets.only(top: 15, bottom: 15),
                            height: 5,
                            width: double.infinity,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Container(
                                  width: 20.w,
                                  height: 20.h,
                                  child: Image(
                                    image:
                                        AssetImage("images/lobby/wallet.png"),
                                    height: 20.h,
                                    color: Colors.black,
                                  ),
                                ),
                                Container(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .translate('via_wallet')!,
                                        style: TextStyle(
                                            fontSize: responsiveFont(12),
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        "-${stringToCurrency(double.parse(amount), context, currencyDetail: value.detailOrder!.currencyDetail)} ",
                                        style: TextStyle(
                                            fontSize: responsiveFont(10)),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: HexColor("EEEEEE"),
                            margin: EdgeInsets.only(top: 15, bottom: 15),
                            height: 5,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .translate('subtotal')!,
                                style: TextStyle(
                                    fontSize: responsiveFont(11),
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                stringToCurrency(
                                    order.detailOrder!.subTotal!, context,
                                    currencyDetail:
                                        value.detailOrder!.currencyDetail),
                                style: TextStyle(fontSize: responsiveFont(11)),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!
                                      .translate('shipping_cost')!,
                                  style: TextStyle(
                                      fontSize: responsiveFont(11),
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500)),
                              Text(
                                  stringToCurrency(
                                      double.parse(
                                          order.detailOrder!.shippingTotal!),
                                      context,
                                      currencyDetail:
                                          value.detailOrder!.currencyDetail),
                                  style:
                                      TextStyle(fontSize: responsiveFont(11))),
                            ],
                          ),
                          Visibility(
                            visible: order.detailOrder!.discountTotal != "0.0",
                            child: Column(children: [
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!
                                          .translate('discount')!,
                                      style: TextStyle(
                                          fontSize: responsiveFont(11),
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                      "-${stringToCurrency(double.parse(order.detailOrder!.discountTotal!), context, currencyDetail: value.detailOrder!.currencyDetail)}",
                                      style: TextStyle(
                                          fontSize: responsiveFont(11),
                                          color: primaryColor)),
                                ],
                              ),
                            ]),
                          ),
                          Visibility(
                            visible: order.detailOrder!.totalTax != "0",
                            child: Column(children: [
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "${AppLocalizations.of(context)!.translate('tax')}",
                                      style: TextStyle(
                                          fontSize: responsiveFont(11),
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                      "${stringToCurrency(double.parse(order.detailOrder!.totalTax!), context, currencyDetail: value.detailOrder!.currencyDetail)}",
                                      style: TextStyle(
                                        fontSize: responsiveFont(11),
                                      )),
                                ],
                              ),
                            ]),
                          ),
                          Visibility(
                            visible: order.detailOrder!.feeLines!.length > 0,
                            child: Column(children: [
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!
                                          .translate('via_wallet')!,
                                      style: TextStyle(
                                          fontSize: responsiveFont(11),
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                      "-${stringToCurrency(double.parse(amount), context, currencyDetail: value.detailOrder!.currencyDetail)}",
                                      style: TextStyle(
                                          fontSize: responsiveFont(11),
                                          color: primaryColor)),
                                ],
                              ),
                            ]),
                          ),
                          Container(
                            color: HexColor("EEEEEE"),
                            margin: EdgeInsets.only(top: 5, bottom: 5),
                            height: 1,
                            width: double.infinity,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!
                                      .translate('total_order')!,
                                  style: TextStyle(
                                      fontSize: responsiveFont(12),
                                      fontWeight: FontWeight.w600)),
                              order.detailOrder!.discountTotal != "0"
                                  ? Text(
                                      stringToCurrency(
                                          double.parse(
                                              order.detailOrder!.total!),
                                          context,
                                          currencyDetail: value
                                              .detailOrder!.currencyDetail),
                                      style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        fontWeight: FontWeight.w600,
                                      ))
                                  : Text(
                                      stringToCurrency(
                                          double.parse(
                                              order.detailOrder!.total!),
                                          context,
                                          currencyDetail: value
                                              .detailOrder!.currencyDetail),
                                      style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        fontWeight: FontWeight.w600,
                                      )),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? null : Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 15.0,
                        )
                      ],
                    ),
                    height: 45.h,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        //buy again
                        buildBtnBuyAgain(),
                        Container(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 30.h,
                            margin:
                                Session.data.getString('language_code') != 'ar'
                                    ? EdgeInsets.only(right: 15)
                                    : EdgeInsets.only(left: 15),
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color:
                                          secondaryColor, //Color of the border
                                      //Style of the border
                                    ),
                                    alignment: Alignment.center,
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(5))),
                                onPressed: () {
                                  _launchWAURL(contact.wa.description);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "images/order/wa.png",
                                      width: 20.w,
                                      height: 20.h,
                                    ),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('contact_seller')!,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: responsiveFont(9),
                                            color: secondaryColor),
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        )
                      ],
                    )),
              ),
            ],
          );
        }
      }),
    );

    return Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              // color: Colors.black,
            ),
          ),
          actions: [
            Visibility(
              visible: isChatActive,
              child: Container(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () async {
                    _showDialogChat();
                  },
                  child: Row(children: [
                    Image(
                      image: AssetImage("images/lobby/icon-cs-app-bar.png"),
                      height: 18.h,
                      // color: Colors.black,
                    ),
                  ]),
                ),
              ),
            ),
          ],
          title: Text(
            AppLocalizations.of(context)!.translate("order_detail")!,
            style: TextStyle(
                // color: Colors.black,
                fontSize: responsiveFont(16),
                fontWeight: FontWeight.w500),
          ),
        ),
        body: buildOrder);
  }

  Widget item(ProductItems productItems, OrderModel order) {
    double pricePerProduct = double.parse(productItems.subTotal!) /
        productItems.quantity!.toDouble();
    String variation = "";
    String addOn = "";
    for (int i = 0; i < productItems.selectedVariation!.length; i++) {
      if (i == productItems.selectedVariation!.length - 1) {
        variation =
            variation + productItems.selectedVariation![i].variationValue!;
      } else {
        variation = variation +
            productItems.selectedVariation![i].variationValue! +
            ", ";
      }
    }
    for (int i = 0; i < productItems.selectedAddOns!.length; i++) {
      if (i == productItems.selectedAddOns!.length - 1) {
        addOn = addOn + productItems.selectedAddOns![i].value!;
      } else {
        addOn = addOn + productItems.selectedAddOns![i].value! + ", ";
      }
    }
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 55.h,
                height: 55.h,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: HexColor("c4c4c4")),
                child: productItems.image == null && productItems.image == ''
                    ? Icon(
                        Icons.image_not_supported_outlined,
                      )
                    : CachedNetworkImage(
                        imageUrl: productItems.image!,
                        placeholder: (context, url) => Container(),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.image_not_supported_outlined)),
              ),
              SizedBox(
                width: 15,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        convertHtmlUnescape(productItems.productName!),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: responsiveFont(12),
                            fontWeight: FontWeight.w600),
                      ),
                      Visibility(
                        visible: variation != "",
                        child: Text(
                          "Variation : " + variation,
                          style: TextStyle(fontSize: responsiveFont(10)),
                        ),
                      ),
                      Visibility(
                        visible: addOn != "",
                        child: Text(
                          "Add-On : " + addOn,
                          style: TextStyle(fontSize: responsiveFont(10)),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "${productItems.quantity} x ${stringToCurrency((pricePerProduct), context, currencyDetail: order.currencyDetail)}",
                            style: TextStyle(fontSize: responsiveFont(10)),
                          ),
                          Spacer(),
                          Text(
                            "${stringToCurrency(double.parse(productItems.subTotal!), context, currencyDetail: order.currencyDetail)}",
                            style: TextStyle(fontSize: responsiveFont(10)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            width: double.infinity,
            height: 2,
            color: HexColor("EEEEEE"),
          )
        ],
      ),
    );
  }

  buildBtnBuyAgain() {
    final order = Provider.of<OrderProvider>(context, listen: false);

    return ListenableProvider.value(
      value: order,
      child: Consumer<OrderProvider>(builder: (context, value, child) {
        if (value.loadDataOrder) {
          return Expanded(
            child: Container(
              margin: Session.data.getString('language_code') != 'ar'
                  ? EdgeInsets.only(left: 15)
                  : EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.grey),
              height: 30.h,
              child: TextButton(
                onPressed: null,
                child: Text(
                  AppLocalizations.of(context)!.translate('buy_again')!,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveFont(12),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        }
        return Expanded(
          child: Container(
            margin: Session.data.getString('language_code') != 'ar'
                ? EdgeInsets.only(left: 15)
                : EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primaryColor, secondaryColor])),
            height: 30.h,
            child: TextButton(
              onPressed: () {
                order.actionBuyAgain(context);
              },
              child: Text(
                AppLocalizations.of(context)!.translate('buy_again')!,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: responsiveFont(10),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      }),
    );
  }

  buildBtnPay() {
    final order = Provider.of<OrderProvider>(context, listen: false);

    if (order.isLoading) {
      return Container();
    }
    return Visibility(
      visible: order.detailOrder!.paymentMethodTitle == 'OVO' ||
          order.detailOrder!.paymentMethodTitle == 'GOPAY' &&
              order.detailOrder!.datePaid == null,
      child: order.detailOrder!.status == 'pending' ||
              order.detailOrder!.status == 'on-hold'
          ? Container(
              margin: EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [primaryColor, secondaryColor])),
              height: 30.h,
              width: 50.w,
              child: TextButton(
                onPressed: () async {
                  print(order.detailOrder!.paymentUrl);
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CheckoutWebView(
                                url: order.detailOrder!.paymentUrl,
                                fromOrder: true,
                              ))).then((value) {
                    this.setState(() {});
                    this.loadOrder();
                  });
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('pay')!,
                  style: TextStyle(
                      color: Colors.white, fontSize: responsiveFont(10)),
                ),
              ),
            )
          : Container(),
    );
  }
}