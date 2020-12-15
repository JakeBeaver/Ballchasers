
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';

class AdMobService {
  static const String appId = 'ca-app-pub-{appId}';
  static const String nativeAdId = 'ca-app-pub-{nativeId}';
  static const String bannerAdId = 'ca-app-pub-{bannerId}';

  static const String testNativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110';

  static Map<String, NativeAdmobController> _nativeAdControllers = {};
  static Widget nativeAd(String key,
      {bool full = false, Widget error, Widget loading}) {
    if (!_nativeAdControllers.containsKey(key)) {
      _nativeAdControllers[key] = NativeAdmobController();
    }
    var adController = _nativeAdControllers[key];
    return Container(
      height: full ? 330 : 90,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      padding: EdgeInsets.all(10),
      child: NativeAdmob(
        options: NativeAdmobOptions(
          adLabelTextStyle: NativeTextStyle(
              color: buttonColor, backgroundColor: Colors.white),
          bodyTextStyle: NativeTextStyle(color: blueTitleColor),
          advertiserTextStyle: NativeTextStyle(
            color: goldTitleColor,
          ),
          headlineTextStyle: NativeTextStyle(
            color: Colors.white,
          ),
          callToActionStyle: NativeTextStyle(
              color: Colors.white, backgroundColor: buttonColor),
          priceTextStyle: NativeTextStyle(color: goldTitleColor),
          ratingColor: goldTitleColor,
          storeTextStyle: NativeTextStyle(color: goldTitleColor),
        ),
        adUnitID: kReleaseMode
            ? AdMobService.nativeAdId
            : AdMobService.testNativeAdUnitId,
        numberAds: 3,
        controller: adController,
        type: full ? NativeAdmobType.full : NativeAdmobType.banner,
        error: GestureDetector(
          onTap: () {
            adController.reloadAd();
            print("reloading");
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              whiteTitle('Ad failed to load'),
              blueTitle('Tap to try reload'),
            ],
          ),
        ),
        loading: Center(child: CircularProgressIndicator()),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
