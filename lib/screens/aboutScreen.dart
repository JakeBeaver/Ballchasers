import 'package:RLRank/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("About"),
        backgroundColor: AppColors.appBar,
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          Text(
            "Ballchasers",
            style: TextStyle(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          icon,
          LocalButton(
            "Consents",
          ),
          LocalButton(
            "Licenses",
            onPressed: () async {
              var info = await PackageInfo.fromPlatform();
              showLicensePage(
                context: context,
                applicationVersion:
                    "version ${info.version} build ${info.buildNumber}",
                applicationName: "Ballchasers",
              );
            },
          )
        ],
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
  final void Function() onPressed;
  LocalButton(this.text, {this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 50,
      child: RaisedButton(
        color: AppColors.button,
        child: Text(text),
        onPressed: onPressed,
      ),
    );
  }
}
