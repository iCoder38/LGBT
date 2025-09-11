import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/in_app/in_app_service.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/in_app/premium_service.dart';
import 'package:lgbt_togo/Features/Screens/change_password/change_password.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  final Map<int, String> planProductIds = {
    2: 'premium_monthly_09',
    3: 'premium_yearly_099',
  };

  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int userSelectMembership = 1;

  @override
  void initState() {
    super.initState();

    // Load subscription prices
    Future.microtask(() {
      loadSubscriptionPrices();
      _getActiveSubscription();
    });

    // Listen to purchases
    _subscription = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdates,
      onError: (error) {
        GlobalUtils().customLog("Purchase Error: $error");
      },
    );
  }

  _getActiveSubscription() async {
    // final active = await getActiveAndroidSubscriptions(
    //   phpEndpoint: Uri.parse(
    //     'https://thebluebamboo.in/APIs/Anamak_APIs/lgbt_in_app_android_receipt.php',
    //   ),
    //   packageName: 'com.dev.android.lgbt',
    //   // updateFirestore: true,
    // );
    final token =
        'dfgmmeadknghaimkkpinlkcj.AO-J1OwOZBhSi5FjOF_lyHRwK8BAa7V69BxgRv90fKRcgKQm976wldsWIj0EiRmNBTuwSn94WUK58Lxg7ARE0tJE9BdkviGCQg';
    final isActive = await validateAndroidOnServer(purchaseToken: token);

    if (isActive) {
      // unlock premium
      print("Yes premium");
    } else {
      print("No premium");
      // show not-active / prompt to subscribe
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> loadSubscriptionPrices() async {
    await PremiumService.instance.initSubscription();

    final weekly = PremiumService.instance.weeklyPriceInfo?.priceString ?? '';
    final monthly = PremiumService.instance.monthlyPriceInfo?.priceString ?? '';

    GlobalUtils().customLog("💰 Weekly price: $weekly");
    GlobalUtils().customLog("💰 Monthly price: $monthly");

    if (mounted) {
      setState(() {
        // storeWeekly = weekly;
        // storeMonthly = monthly;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.membership.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: const CustomDrawer(),
      backgroundColor: AppColor().SCREEN_BG,
      body: _UIKitWithBG(context),
    );
  }

  Widget _UIKitWithBG(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Image.asset(AppImage().BG_1, fit: BoxFit.cover)),
        _UIKIT(context),
      ],
    );
  }

  Widget _UIKIT(context) {
    return SafeArea(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                userSelectMembership = 1;
              });
            },
            child: CustomContainer(
              height: 150,
              color: AppColor().kWhite,
              shadow: true,
              borderColor: userSelectMembership == 1
                  ? AppColor().kNavigationColor
                  : Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customText(
                      Localizer.get(AppText.freeTrialMembership.key),
                      22,
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.searchAndView.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.limitedContent.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.limitedContent.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.basicSupport.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 2
          GestureDetector(
            onTap: () {
              setState(() {
                userSelectMembership = 2;
              });
            },
            child: CustomContainer(
              height: 200,
              color: AppColor().kWhite,
              shadow: true,
              borderColor: userSelectMembership == 2
                  ? AppColor().kNavigationColor
                  : Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customText(
                      Localizer.get(AppText.premiumMonthlyPlan.key),
                      22,
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.viewFullProfile.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.accessUnlimitedContent.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.accessPremiumContent.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.prioritySupport.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 3
          GestureDetector(
            onTap: () {
              setState(() {
                userSelectMembership = 3;
              });
            },
            child: CustomContainer(
              height: 220,
              color: AppColor().kWhite,
              shadow: true,
              borderColor: userSelectMembership == 3
                  ? AppColor().kNavigationColor
                  : Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customText(
                      Localizer.get(AppText.premiumYearlyPlan.key),
                      22,
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.viewFullProfile.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.accessUnlimitedContent.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.accessLimitedContent.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.prioritySupport.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText(
                        Localizer.get(AppText.earlyAccess.key),
                        12,
                        context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          userSelectMembership != 1
              ? CustomButton(
                  text: Localizer.get(AppText.subscribe.key),
                  textColor: AppColor().kWhite,
                  color: AppColor().kNavigationColor,
                  onPressed: () {
                    _handlePurchase();
                  },
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      GlobalUtils().customLog("Play Store not available");
      return;
    }

    final selectedProductId = planProductIds[userSelectMembership];
    if (selectedProductId == null) return;

    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails({selectedProductId});

    if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
      GlobalUtils().customLog("Product not found");
      return;
    }

    final productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        GlobalUtils().customLog(
          "✅ Purchase successful: ${purchaseDetails.productID}",
        );
        GlobalUtils().customLog(
          "📦 Token: ${purchaseDetails.verificationData.serverVerificationData}",
        );

        // TODO: Send token to your PHP server for verification

        /*AlertsUtils().showExceptionPopup(
          context: context,
          message:
              "📦 Token: ${purchaseDetails.verificationData.serverVerificationData}",
        );*/

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        GlobalUtils().customLog("❌ Purchase error: ${purchaseDetails.error}");
      } else if (purchaseDetails.status == PurchaseStatus.pending) {
        GlobalUtils().customLog("⏳ Purchase pending...");
      }
    }
  }

  // api
  Future<void> callSaveAnd() async {
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    final userData = await UserLocalStorage.getUserData();
    var payload = {
      "action": "changepassword",
      "userId": userData['userId'].toString(),
    };
    GlobalUtils().customLog(payload);

    try {
      final response = await callCommonNetwordApi(payload);
      GlobalUtils().customLog(response);

      if (response['status'].toString().toLowerCase() == "success") {
        // dismiss keyboard
        FocusScope.of(context).requestFocus(FocusNode());
        // dismiss alert
        Navigator.pop(context);
        // toast
        Fluttertoast.showToast(
          msg: response['msg'].toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        // dismiss keyboard
        FocusScope.of(context).requestFocus(FocusNode());
        // dismiss alert
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: response['msg'].toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // showExceptionPopup(context: context, message: e.toString());
    } finally {
      // customLog('Finally');
    }
  }
}
