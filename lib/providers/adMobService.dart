import 'dart:convert';

import 'package:RLRank/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

class AdMobService {
  static const String appId = 'ca-app-pub-{appId}';
  static const String nativeAdId = 'ca-app-pub-{nativeId}';
  static const String bannerAdId = 'ca-app-pub-{bannerId}';

  static const String testNativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110';


  // static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  // static bool _isGDPR;

  // static Future<bool> getIsGDPR() async {
  //   if (_isGDPR == null) {
  //     try {
  //       String url = "https://adservice.google.com/getconfig/pubvendors";
  //       var response = await http.get(url);
  //       var parsedResponse = json.decode(response.body) as Map<String, dynamic>;
  //       _isGDPR = parsedResponse['is_request_in_eea_or_unknown'];
  //     } catch (ex) {
  //       _isGDPR = false;
  //     }
  //   }
  //   return _isGDPR;
  // }

  // static const String adConsentKey = "adConsent";
  // static Future promptForConsent(BuildContext context) async {
  //   var prefs = await _prefs;
  // }

  // static Future<bool> getHasConsent(BuildContext context) async {
  //   return false;
  //   var isGDPR = await getIsGDPR();
  //   if (!isGDPR) return true;

  //   var prefs = await _prefs;
  //   if (prefs.containsKey(adConsentKey))
  //     await promptForConsent(context);
  //   return prefs.containsKey(adConsentKey) ? prefs.getBool(adConsentKey) : false;
  // }

  static final Map<String, NativeAdmobController> _nativeAdControllers = {};
  static Widget nativeAd(
    BuildContext context,
    String key, {
    bool full = false,
  }) {
    return FutureBuilder(
      // future: getHasConsent(context),
      future:  null,
      builder: (context, snapshot) {
        // bool consent = snapshot.data;
        bool consent = false;
        if (!_nativeAdControllers.containsKey(key)) {
          _nativeAdControllers[key] = NativeAdmobController();
        }
        final adController = _nativeAdControllers[key];
        adController.setNonPersonalizedAds(!consent);
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
      },
    );
  }
}
