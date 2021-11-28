import 'package:flutter/material.dart';
import 'package:flutter_google_ads/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Mobile App Instance
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late BannerAd _bannerAd;

  bool _isBannerAdReady = false;

  late InterstitialAd _interstitialAd;

  bool _isInterstitialAdReady = false;

  bool _isRewardedAdReady = false;

  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
        // Change Banner Size According to Ur Need
        size: AdSize.mediumRectangle,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        }, onAdFailedToLoad: (ad, LoadAdError error) {
          print("Failed to Load A Banner Ad${error.message}");
          _isBannerAdReady = false;
          ad.dispose();
        }),
        request: AdRequest())
      ..load();
    //Interstitial Ads
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          this._interstitialAd = ad;
          _isInterstitialAdReady = true;
        }, onAdFailedToLoad: (LoadAdError error) {
          print("failed to Load Interstitial Ad ${error.message}");
        }));

    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
        this._rewardedAd = ad;
        ad.fullScreenContentCallback =
            FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
          setState(() {
            _isRewardedAdReady = false;
          });
          _loadRewardedAd();
        });
        setState(() {
          _isRewardedAdReady = true;
        });
      }, onAdFailedToLoad: (error) {
        print('Failed to load a rewarded ad: ${error.message}');
        setState(() {
          _isRewardedAdReady = false;
        });
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
    _interstitialAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter Mobile Ads"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Simple Container
              Container(
                height: 70,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              //Simple Container
              Container(
                height: 70,
                color: Colors.indigo,
              ),
              SizedBox(height: 20),
              if (_isBannerAdReady)
                Container(
                  height: _bannerAd.size.height.toDouble(),
                  width: _bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              SizedBox(height: 20),
              Container(
                height: 70,
                color: Colors.deepOrange,
              ),
              SizedBox(height: 20),
              Container(
                height: 70,
                color: Colors.purple,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed:
                      _isInterstitialAdReady ? _interstitialAd.show : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("interstitial Ad"),
                  )),
              if (_isRewardedAdReady)
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Need a hint?'),
                          content: Text('Watch an Ad to get a hint!'),
                          actions: [
                            TextButton(
                              child: Text('cancel'.toUpperCase()),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text('ok'.toUpperCase()),
                              onPressed: () {
                                Navigator.pop(context);
                                _rewardedAd?.show(
                                  onUserEarnedReward: (_, reward) {
                                    // QuizManager.instance.useHint();
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("hint"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
