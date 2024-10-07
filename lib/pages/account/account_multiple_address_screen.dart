import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/address_model.dart';
import 'package:nyoba/pages/account/account_address_edit_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:super_banners/super_banners.dart';

class AccountMultipleAddress extends StatefulWidget {
  const AccountMultipleAddress({super.key});

  @override
  State<AccountMultipleAddress> createState() => _AccountMultipleAddressState();
}

class _AccountMultipleAddressState extends State<AccountMultipleAddress> {
  int idx = 0;
  String tempDefault = "";
  String idDefault = "";
  UserProvider? userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    context.read<UserProvider>().getAddress();
    context.read<UserProvider>().fetchCountries();
    // if (Provider.of<UserProvider>(context, listen: false)
    //         .customer!
    //         .defaultAddress !=
    //     null) {
    //   idDefault = Provider.of<UserProvider>(context, listen: false)
    //       .customer!
    //       .defaultAddress!
    //       .id!;
    // }

    // tempDefault = idDefault;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('my_address')!,
            style: TextStyle(fontSize: responsiveFont(16))),
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
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                if (Provider.of<HomeProvider>(context, listen: false)
                        .limitMultipleAddress >
                    userProvider!.address.length) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountAddressEditScreen(
                          title: 'billing',
                          address: userProvider!.address[idx],
                          isEdit: false,
                        ),
                      ));
                } else {
                  snackBar(context,
                      message: "Your address has exceeded the limit");
                }
              },
              child: Container(
                margin: EdgeInsets.only(right: 20),
                child: Text(
                  AppLocalizations.of(context)!.translate('add_address')!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor),
                ),
              ),
            ),
          )
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, value, child) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(children: [
              if (value.address.isEmpty)
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 32,
                        ),
                        Text(
                          "${AppLocalizations.of(context)!.translate('you_dont_have_address')}\n ${AppLocalizations.of(context)!.translate('pls_add_address')}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: value.address.length,
                  itemBuilder: (context, index) {
                    String id = value.address[index].addressKey!;
                    if (value.loadingAddress) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[400]!,
                        highlightColor: Colors.grey[200]!,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          width: MediaQuery.of(context).size.width,
                          height: 100.h,
                          color: Colors.white,
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          idx = index;
                          tempDefault = id;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 2,
                                color: index == idx
                                    ? primaryColor
                                    : Colors.grey[300]!)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            detailAddressNew(userProvider!.address[index]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              value.loadingAddress
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (userProvider!.address[idx].defaultAddress !=
                                    "1" &&
                                userProvider!.address.isNotEmpty) {
                              context
                                  .read<UserProvider>()
                                  .setDefaultAddress(
                                      userProvider!.address[idx].addressKey)
                                  .then((value) {
                                if (value) {
                                  snackBar(context,
                                      message: "Success Set Default Address");
                                } else {
                                  snackBar(context,
                                      message: "Failed Set Default Address");
                                }
                                setState(() {
                                  idx = 0;
                                  // tempDefault = Provider.of<UserProvider>(context,
                                  //         listen: false)
                                  //     .address;

                                  idDefault = tempDefault;
                                });
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    userProvider!.address[idx].defaultAddress ==
                                                "1" ||
                                            userProvider!.address.isEmpty
                                        ? Colors.grey
                                        : primaryColor),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('set_as_default')!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (userProvider!.address.isNotEmpty)
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AccountAddressEditScreen(
                                      title: 'billing',
                                      address: userProvider!.address[idx],
                                      isEdit: true,
                                    ),
                                  ));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: userProvider!.address.isEmpty
                                    ? Colors.grey
                                    : primaryColor),
                            child: Text(
                              AppLocalizations.of(context)!.translate('edit')!,
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (userProvider!.address.isNotEmpty) {
                              await context.read<UserProvider>().deleteAddress(
                                  userProvider!.address[idx].addressKey);
                              await context.read<UserProvider>().getAddress();
                              setState(() {
                                idx = 0;
                                // tempDefault =
                                //     userProvider!.customer!.addresses![idx].id!;
                                idDefault = tempDefault;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: userProvider!.address.isEmpty
                                    ? Colors.grey
                                    : primaryColor),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('delete')!,
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
            ]),
          );
        },
      ),
    );
  }

  Widget detailAddressNew(AddressModel address) {
    // String id = value.customer!.addresses![index].id!;
    // String idDefault = value.customer!.defaultAddress!.id!;
    return Container(
      width: MediaQuery.of(context).size.width - 34,
      height: MediaQuery.of(context).size.height * 0.22,
      child: Stack(children: [
        Visibility(
          visible: address.defaultAddress == "1",
          child: Positioned(
            right: 0,
            top: 0,
            child: CornerBanner(
                bannerColor: primaryColor,
                child: Text(
                  AppLocalizations.of(context)!.translate('default')!,
                  style: TextStyle(color: Colors.white),
                ),
                bannerPosition: CornerBannerPosition.topRight),
          ),
        ),
        Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10, bottom: 10),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      width: 2, color: primaryColor)),
                              child: Image.asset(
                                "images/account/homeicon.png",
                                width: 25,
                                height: 25,
                              ),
                            ),
                            Positioned(
                              top: -1,
                              right: -1,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        width: 2, color: Colors.white)),
                                child: Image.asset(
                                  "images/account/checkicon.png",
                                  color: Colors.white,
                                  width: 7,
                                  height: 7,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: Text(
                            "${address.firstName} ${address.lastName}",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: address.defaultAddress == "1"
                                    ? primaryColor
                                    : null),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(address.address1!,
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      "${address.city!}, ${address.stateName!}",
                      style: TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(
                      "${address.countryName!}, ${address.postcode}",
                      style: TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(address.phone ?? "",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ]),
            )),
      ]),
    );
  }
}
