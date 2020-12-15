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

  static final Map<String, NativeAdmobController> _nativeAdControllers = {};
  static Widget nativeAd(
    String key, {
    bool full = false,
  }) {
    if (!_nativeAdControllers.containsKey(key)) {
      _nativeAdControllers[key] = NativeAdmobController();
    }
    final adController = _nativeAdControllers[key];
    return Container(
      height: full ? 330 : 90,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      padding: const EdgeInsets.all(10),
      child: NativeAdmob(
        options: const NativeAdmobOptions(
          showMediaContent: true,
          adLabelTextStyle: const NativeTextStyle(
              color: AppColors.button, backgroundColor: Colors.white),
          bodyTextStyle: NativeTextStyle(color: AppColors.blue),
          advertiserTextStyle: const NativeTextStyle(color: AppColors.gold),
          headlineTextStyle: const NativeTextStyle(color: Colors.white),
          callToActionStyle: const NativeTextStyle(
              color: Colors.white, backgroundColor: AppColors.button),
          priceTextStyle: const NativeTextStyle(color: AppColors.gold),
          ratingColor: AppColors.gold,
          storeTextStyle: const NativeTextStyle(color: AppColors.gold),
        ),
        adUnitID: kReleaseMode
            ? AdMobService.nativeAdId
            : AdMobService.testNativeAdUnitId,
        numberAds: 1,
        controller: adController,
        type: full ? NativeAdmobType.full : NativeAdmobType.banner,
        error: GestureDetector(
          onTap: () {
            adController.reloadAd();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              whiteTitle('Ad failed to load'),
              blueTitle('Tap to try reload'),
            ],
          ),
        ),
        loading: const Center(child: const CircularProgressIndicator()),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.gold,
        ),
      ),
    );
  }
}
