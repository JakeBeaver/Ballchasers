import 'package:RLRank/providers/adMobService.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: AppColors.appBar,
      ),
      body: FutureBuilder(
        future: AdMobService.getIsGDPR(),
        builder: (context, snapshot) {
          bool isGDPR = snapshot.hasData && snapshot.data;
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  whiteTitle(
                    "Ballchasers",
                    sizeAdjust: 17,
                    textAlign: TextAlign.center,
                  ),
                  icon,
                  LocalButton(
                    Icons.library_books,
                    "Licenses",
                    onPressed: () async {
                      var info = await PackageInfo.fromPlatform();
                      showLicensePage(
                        context: context,
                        applicationIcon: icon,
                        applicationVersion:
                            "version ${info.version} build ${info.buildNumber}",
                        applicationName: "Ballchasers",
                      );
                    },
                  ),
                  // if (isGDPR) SizedBox(height: 10),
                  if (isGDPR)
                    LocalButton(
                      Icons.check,
                      "Consent",
                      onPressed: () => AdMobService.promptForConsent(context),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  final Widget icon = Container(
    padding: EdgeInsets.all(40),
    child: Image.asset('assets/BallChasersLogo_transparentBackground.png'),
  );
}

class LocalButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function() onPressed;
  LocalButton(this.icon, this.text, {this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 50,
      child: RaisedButton(
        color: AppColors.button,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(text),
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }
}
