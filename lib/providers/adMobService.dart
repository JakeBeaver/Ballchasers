import 'dart:convert';

import 'package:RLRank/widgets/textWidgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AdMobService {
  static const String appId = 'ca-app-pub-{appId}';
  static const String nativeAdId = 'ca-app-pub-{nativeId}';
  static const String bannerAdId = 'ca-app-pub-{bannerId}';

  static const String testNativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110';

  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static bool _isGDPR;

  static Future<bool> getIsGDPR() async {
    if (_isGDPR == null) {
      try {
        String url = "https://adservice.google.com/getconfig/pubvendors";
        var response = await http.get(url);
        var parsedResponse = json.decode(response.body) as Map<String, dynamic>;
        _isGDPR = parsedResponse['is_request_in_eea_or_unknown'];
      } catch (ex) {
        _isGDPR = false;
      }
    }
    return _isGDPR;
  }

  static const String adConsentKey = "AdMob Personalized ads consent";
  static Future<bool> _consentFuture;
  static Future promptForConsent(BuildContext context) async {
    var prefs = await _prefs;
    if (_consentFuture == null) {
      _consentFuture = showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Container(
                      height: 100,
                      // padding: EdgeInsets.all(40),
                      child: Image.asset(
                          'assets/BallChasersLogo_transparentBackground.png'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "We keep this app free by showing you ads, and alive by analyzing crashes.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Can we use your data fo ad personalization and crash analysis?",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "You can change your choice anytime for this anytime in settings (cog icon) under consents. Our partners will collect your data and use a unique identifier on your device to show you relevant ads and analyze app performance. This choice wont decrease the number of ads.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),
                    FlatButton(
                      height: 10,
                      onPressed: () => launch(
                          "https://safety.google/privacy/ads-and-data/"),
                      child:
                          deepBlueTitle("Learn more (AdMob)", sizeAdjust: -2),
                    ),
                    FlatButton(
                      height: 10,
                      onPressed: () => launch(
                          "https://firebase.google.com/terms/data-processing-terms"),
                      child: deepBlueTitle("Learn more (Firebase Analytics)",
                          sizeAdjust: -2),
                    ),
                    // SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10),
                      child: RaisedButton(
                        padding: EdgeInsets.all(20),
                        color: AppColors.button,
                        child: Text(
                          "Yes",
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10),
                      child: RaisedButton(
                        color: AppColors.button,
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No",
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      bool consent = await _consentFuture;

      prefs.setBool(adConsentKey, consent);
      _nativeAdControllers.forEach((key, value) {
        value.setNonPersonalizedAds(!consent);
        value.reloadAd(forceRefresh: true);
      });

      await FirebaseAnalytics().setAnalyticsCollectionEnabled(consent);

      _consentFuture = null;
    } else {
      await _consentFuture;
    }
  }

  static Future<bool> getHasConsent(BuildContext context) async {
    var isGDPR = await getIsGDPR();
    if (!isGDPR) return true;

    var prefs = await _prefs;
    if (!prefs.containsKey(adConsentKey)) await promptForConsent(context);
    return prefs.containsKey(adConsentKey)
        ? prefs.getBool(adConsentKey)
        : false;
  }

  static final Map<String, NativeAdmobController> _nativeAdControllers = {};
  static Widget nativeAd(
    BuildContext context,
    String key, {
    bool full = false,
  }) {
    return FutureBuilder(
      future: getHasConsent(context),
      builder: (context, snapshot) {
        if (!_nativeAdControllers.containsKey(key)) {
          _nativeAdControllers[key] = NativeAdmobController();
        }
        final adController = _nativeAdControllers[key];
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.done:
            break;
          case ConnectionState.waiting:
            return AdContainer(
              full: full,
              child: const Center(child: const CircularProgressIndicator()),
            );
        }
        if (snapshot.hasError) {
          return AdContainer(
            full: full,
            child: AdLoadError(adController: adController),
          );
        }
        bool consent = snapshot.data;
        adController.setNonPersonalizedAds(!consent);
        return AdContainer(
          full: full,
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
            error: AdLoadError(adController: adController),
            loading: const Center(child: const CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}

class AdLoadError extends StatelessWidget {
  const AdLoadError({
    Key key,
    @required this.adController,
  }) : super(key: key);

  final NativeAdmobController adController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}

class AdContainer extends StatelessWidget {
  final bool full;
  final Widget child;

  const AdContainer({Key key, this.full, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: full ? 330 : 90,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      padding: const EdgeInsets.all(10),
      child: child,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.gold,
        ),
      ),
    );
  }
}
