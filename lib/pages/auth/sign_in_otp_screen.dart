import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/pages/auth/create_username_screen.dart';
import 'package:nyoba/pages/auth/input_otp_screen.dart';
import 'package:nyoba/pages/auth/login_screen.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/provider/login_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../app_localizations.dart';
import '../../provider/app_provider.dart';
import '../../provider/home_provider.dart';
import '../../utils/utility.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SignInOTPScreen extends StatefulWidget {
  final bool? isFromNavBar;
  SignInOTPScreen({Key? key, this.isFromNavBar}) : super(key: key);

  @override
  _SignInOTPScreenState createState() => _SignInOTPScreenState();
}

class _SignInOTPScreenState extends State<SignInOTPScreen> {
  bool isVisible = false;

  bool isFromNavBar = true;
  bool otpInvalid = false;
  int? _forceResendingToken;

  TextEditingController phone = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isFromNavBar != null) {
      isFromNavBar = widget.isFromNavBar!;
    }
    if (Provider.of<LoginProvider>(context, listen: false)
            .countryCode!
            .substring(0, 1) !=
        "+") {
      Provider.of<LoginProvider>(context, listen: false)
          .countryCode = CountryCode.fromCountryCode(
              Provider.of<LoginProvider>(context, listen: false).countryCode!)
          .dialCode;
    }
  }

  loginGoogle() async {
    loadingPop(context);
    await Provider.of<LoginProvider>(context, listen: false)
        .signInWithGoogle(context)
        .then((value) {
      if (Session.data.getString('cookie') != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
            (Route<dynamic> route) => false);
      } else {
        snackBar(context,
            message:
                "Invalid error when trying sign in using google, please contact admin or developer",
            color: Colors.red);
        Navigator.pop(context);
      }
    });
  }

  loginApple() async {
    loadingPop(context);
    await Provider.of<LoginProvider>(context, listen: false)
        .signInWithApple(context)
        .then((value) {
      if (Session.data.getString('cookie') != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
            (Route<dynamic> route) => false);
      } else {
        snackBar(context,
            message:
                "Invalid error when trying sign in using apple, please contact admin or developer",
            color: Colors.red);
        Navigator.pop(context);
      }
    });
  }

  loginFacebook() async {
    loadingPop(context);
    await Provider.of<LoginProvider>(context, listen: false)
        .signInWithFacebook(context)
        .then((value) {
      if (Session.data.getString('cookie') != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
            (Route<dynamic> route) => false);
      } else {
        snackBar(context,
            message:
                "Invalid error when trying sign in using facebook, please contact admin or developer",
            color: Colors.red);
        Navigator.pop(context);
      }
    });
  }

  loginOTP(var _phone, countryCode) async {
    await Provider.of<LoginProvider>(context, listen: false)
        .signInOTPv2(
      context,
      _phone,
      countryCode,
      username: "",
    )
        .then((value) {
      if (Provider.of<LoginProvider>(context, listen: false).messageError ==
          "create username first") {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateUsernameScreen(
                phone: _phone,
                countryCode: countryCode,
                from: "otp",
              ),
            ));
      } else if (Session.data.getString('cookie') != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
            (Route<dynamic> route) => false);
      }
    });
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  bool otp = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<LoginProvider>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;

    signInOTP(String phoneNumber, LoginProvider loginProvider) async {
      FirebaseAuth auth = FirebaseAuth.instance;
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      if (phoneNumber.startsWith('0')) {
        phoneNumber = phoneNumber.substring(1);
      }

      var phone =
          Provider.of<LoginProvider>(context, listen: false).countryCode! +
              phoneNumber;
      var phoneUser = Provider.of<LoginProvider>(context, listen: false)
              .countryCode!
              .replaceAll("+", "") +
          phoneNumber;

      await auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(minutes: 1),
        verificationCompleted: (credential) {
          print("completed $credential");
        },
        verificationFailed: (e) {
          print(e.message);
          snackBar(context, message: e.message!, color: Colors.red);
          setState(() {
            loginProvider.loading = false;
          });
        },
        forceResendingToken: _forceResendingToken,
        codeSent: (verificationId, [forceResendingToken]) async {
          _forceResendingToken = forceResendingToken;
          final code = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InputOTP(phone: phoneNumber)));
          if (code != null) {
            print(code);
            PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId: verificationId, smsCode: code);
            await auth
                .signInWithCredential(phoneAuthCredential)
                .then((value) async {
              if (value.user!.uid != '') {
                /*If Success*/
                print('Success');
                loginOTP(
                    phoneUser,
                    Provider.of<LoginProvider>(context, listen: false)
                        .countryCode!
                        .substring(1));
              }
            }).catchError((error) {
              print(error);
              print('Failed');
              snackBar(context,
                  message:
                      AppLocalizations.of(context)!.translate('otp_invalid')!,
                  color: Colors.red);
              setState(() {
                loginProvider.loading = false;
                otpInvalid = true;
              });
            });
          } else {
            setState(() {
              loginProvider.loading = false;
              otpInvalid = true;
            });
            snackBar(context, message: 'Login by OTP cancelled.');
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          print('timeout');
        },
      );
    }

    Widget buildButton = Container(
      child: ListenableProvider.value(
        value: auth,
        child: Consumer<LoginProvider>(builder: (context, value, child) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            height: 30.h,
            child: TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  backgroundColor:
                      value.loading ? Colors.grey : secondaryColor),
              onPressed: () async {
                if (phone.text.isNotEmpty) {
                  setState(() {
                    value.loading = true;
                    otpInvalid = false;
                  });
                  var signCode = await SmsAutoFill().getAppSignature;
                  print(signCode);

                  await SmsAutoFill().listenForCode();
                  signInOTP(phone.text, value);
                }
              },
              child: value.loading
                  ? customLoading()
                  : Text(
                      otpInvalid
                          ? 'Resend OTP'
                          : AppLocalizations.of(context)!.translate('login')!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsiveFont(12),
                      ),
                    ),
            ),
          );
        }),
      ),
    );

    if (otp && home.design == "modern") {
      return Consumer<HomeProvider>(
        builder: (context, value, child) => ColorfulSafeArea(
          color: HexColor(value.bgColor),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: HexColor(value.bgColor),
              elevation: 0,
              titleSpacing: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: HexColor(value.textColor),
                  size: 18,
                ),
              ),
            ),
            body: Container(
              color: HexColor(value.bgColor),
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                        imageUrl: value.bgImage,
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),
                    child: Column(
                      children: [
                        Text(
                          "${value.textHeading}",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: HexColor(value.textColor)),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "${value.text}",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17, color: HexColor(value.textColor)),
                        ),
                        SizedBox(height: 40),
                        Text(
                          "${AppLocalizations.of(context)!.translate('enter_your_mobile_number')}",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: HexColor(value.textColor),
                              fontWeight: FontWeight.w600),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        // color: Color(0xFFFAFAFA),
                                        // border: Border.all(
                                        //   width: 1,
                                        //   color: accentColor,
                                        // ),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10)),
                                      ),
                                      child: CountryCodePicker(
                                        padding: const EdgeInsets.all(0),
                                        alignLeft: true,
                                        onChanged: (e) {
                                          Provider.of<LoginProvider>(context,
                                                  listen: false)
                                              .countryCode = e.dialCode;
                                          print(e);
                                        },
                                        textStyle: TextStyle(
                                            fontSize: 15, color: Colors.black),
                                        initialSelection:
                                            Provider.of<LoginProvider>(context,
                                                    listen: false)
                                                .countryCode,
                                        showCountryOnly: false,
                                        showOnlyCountryWhenClosed: false,
                                        flagWidth: 30,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          otp = false;
                                        });
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        height: 50,
                                        width: 120,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      otp = false;
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.only(right: 25),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10))),
                                    child: Center(
                                      child: Text(
                                        "811-1234-5678",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text(
                                  "${AppLocalizations.of(context)!.translate('continue_with_email')}",
                                  style: TextStyle(
                                      color: HexColor(value.textColor),
                                      fontSize: 15)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!otp && home.design == "modern")
      return Consumer<HomeProvider>(
        builder: (context, value, child) => Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: HexColor(value.bgColor),
          appBar: AppBar(
            backgroundColor: HexColor(value.bgColor),
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () {
                setState(() {
                  otp = true;
                });
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: HexColor(value.textColor),
                size: 18,
              ),
            ),
            centerTitle: true,
            title: Text(
              "${AppLocalizations.of(context)!.translate('sign_in_otp')}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HexColor(value.textColor),
              ),
            ),
          ),
          body: Container(
            margin: EdgeInsets.only(left: 15, top: 20, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.translate('enter_your_mobile_number')}",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: HexColor(value.textColor)),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                        ),
                        child: CountryCodePicker(
                          padding: const EdgeInsets.all(0),
                          alignLeft: true,
                          onChanged: (e) {
                            Provider.of<LoginProvider>(context, listen: false)
                                .countryCode = e.dialCode;
                            print(e);
                          },
                          textStyle: TextStyle(color: Colors.black),
                          dialogTextStyle: TextStyle(color: Colors.black),
                          searchStyle: TextStyle(color: Colors.black),
                          searchDecoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder()),
                          initialSelection:
                              Provider.of<LoginProvider>(context, listen: false)
                                  .countryCode,
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          flagWidth: 30,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          // scrollPadding: EdgeInsets.only(bottom: widget.paddingScroll),
                          controller: phone,
                          // style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                              ),
                              contentPadding: EdgeInsets.only(left: 20),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                              ),
                              // hintStyle: TextStyle(
                              //     color: value.isDarkMode
                              //         ? Colors.white
                              //         : Colors.black26),
                              // labelStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.white,
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: "811-1234-5678"),
                          style: TextStyle(color: Colors.black),
                          validator: (value) {
                            print("value");
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .translate("empty");
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                buildButton,
                // auth.status == StatusAuth.Authenticating
                //     ? Container(
                //         width: double.infinity,
                //         margin: EdgeInsets.symmetric(vertical: 16),
                //         padding: const EdgeInsets.symmetric(vertical: 14),
                //         decoration: BoxDecoration(
                //             color: Colors.grey[200],
                //             borderRadius: BorderRadius.circular(10)),
                //         child: customLoading(),
                //       )
                //     : Container(
                //         margin: EdgeInsets.only(top: 20),
                //         width: double.infinity,
                //         child: MaterialButton(
                //           elevation: 0,
                //           shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.all(Radius.circular(5))),
                //           color: HexColor(value.btnColor),
                //           onPressed: auth.status == StatusAuth.Authenticating
                //               ? null
                //               : () async {
                //                   if (phone.text.isNotEmpty) {
                //                     setState(() {
                //                       otpInvalid = false;
                //                     });
                //                     this.setState(() {
                //                       auth.setStatusAuth(
                //                           StatusAuth.Authenticating);
                //                     });
                //                     await signInOTP(phone.text, auth);
                //                   }
                //                 },
                //           child: Padding(
                //             padding: const EdgeInsets.symmetric(vertical: 14),
                //             child: Text(
                //               AppLocalizations.of(context)!.translate("login")!,
                //               style: TextStyle(color: HexColor(value.textColor)),
                //             ),
                //           ),
                //         ),
                //       ),
                SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.translate('continue_agree')} "),
                      TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.translate('terms_condition')}",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewScreen(
                                      title: AppLocalizations.of(context)!
                                          .translate('terms_conditions')!
                                          .toUpperCase(),
                                      url: Provider.of<HomeProvider>(context,
                                              listen: false)
                                          .terms
                                          .description),
                                )),
                          style:
                              TextStyle(decoration: TextDecoration.underline)),
                      TextSpan(text: " and "),
                      TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.translate('privacy')}",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewScreen(
                                      title: AppLocalizations.of(context)!
                                          .translate('privacy')!
                                          .toUpperCase(),
                                      url: Provider.of<HomeProvider>(context,
                                              listen: false)
                                          .privacy
                                          .description),
                                )),
                          style:
                              TextStyle(decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: !isFromNavBar
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ))
            : null,
        title: AutoSizeText(
          AppLocalizations.of(context)!.translate('login')!,
          style: TextStyle(fontSize: responsiveFont(16), color: secondaryColor),
        ),
        centerTitle: true,
        // backgroundColor: Colors.white
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: home.logo.image!,
                  height: 100.h,
                  placeholder: (context, url) => Container(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported_rounded,
                    size: 15,
                  ),
                ),
              ),
              Container(
                height: 20,
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('welcome')}!",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: responsiveFont(14),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.translate('title_otp')!,
                style: TextStyle(
                  fontSize: responsiveFont(14),
                ),
              ),
              Container(
                height: 20,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                          border: Border.all(color: secondaryColor),
                          borderRadius: BorderRadius.circular(8)),
                      child: CountryCodePicker(
                        onChanged: (e) {
                          Provider.of<LoginProvider>(context, listen: false)
                              .countryCode = e.dialCode;
                          print(e);
                        },
                        dialogBackgroundColor:
                            isDarkMode ? Colors.black45 : null,
                        barrierColor: Colors.transparent,
                        initialSelection: "+974",
                        padding: EdgeInsets.zero,
                        showFlagDialog: true,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: secondaryColor),
                            borderRadius: BorderRadius.circular(8)),
                        child: TextField(
                          controller: phone,
                          onChanged: (value) {
                            this.setState(() {});
                          },
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: responsiveFont(14),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                          ],
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              hintStyle: TextStyle(
                                fontSize: responsiveFont(14),
                              ),
                              hintText: AppLocalizations.of(context)!
                                  .translate('input_otp_hint')),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: phone.text.length < 5 && phone.text.isNotEmpty,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    alertPhone(context)!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              Container(
                height: 20,
              ),
              buildButton,
              Container(
                height: 15,
              ),
              signInButton(
                  "${AppLocalizations.of(context)!.translate('sign_in_email')}",
                  "email"),
              SizedBox(
                height: 20.h,
              ),
              Image.asset("images/account/baris.png"),
              Container(
                height: 15,
              ),
              // signInButton(
              //     "${AppLocalizations.of(context)!.translate('sign_in')} Google",
              //     "google"),
              // Container(
              //   height: 10,
              // ),
              // signInButton(
              //     "${AppLocalizations.of(context)!.translate('sign_in')} Facebook",
              //     "facebook"),
              // Container(
              //   height: 10,
              // ),
              // if (Platform.isIOS)
              //   signInButton(
              //       "${AppLocalizations.of(context).translate('sign_in')} Apple",
              //       "apple"),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: responsiveFont(13),
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            "${AppLocalizations.of(context)!.translate('continue_agree')} ",
                      ),
                      TextSpan(
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WebViewScreen(
                                          url: home.terms.description,
                                          title: AppLocalizations.of(context)!
                                              .translate('terms_conditions'),
                                        ))),
                          text: AppLocalizations.of(context)!
                              .translate('terms_condition'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: secondaryColor)),
                      TextSpan(
                          text: " & ",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      TextSpan(
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WebViewScreen(
                                            url: home.privacy.description,
                                            title: AppLocalizations.of(context)!
                                                .translate('privacy'),
                                          )));
                            },
                          text: AppLocalizations.of(context)!
                              .translate('privacy'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: secondaryColor)),
                      TextSpan(
                          text: " ${home.packageInfo?.appName} ",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget signInButton(String title, String image) {
    return InkWell(
      onTap: () {
        if (image == 'email') {
          Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login()))
              .then((value) => this.setState(() {}));
        } else if (image == 'google') {
          loginGoogle();
        } else if (image == 'facebook') {
          loginFacebook();
        } else if (image == 'apple') {
          loginApple();
        }
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: HexColor("c4c4c4"))),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                  width: 17.w,
                  height: 17.h,
                  child: image == 'email'
                      ? Icon(Icons.email)
                      : Image.asset("images/account/$image.png")),
              SizedBox(
                width: 20,
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: responsiveFont(10), color: HexColor("464646")),
              )
            ],
          )),
    );
  }
}
