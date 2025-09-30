import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/revenueCat/extenstion.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/revenueCat/helper.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/revenueCat/revenuecat_service.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  int userSelectMembership = 1;

  bool _isPremium = false;
  bool _willRenew = false;
  String? _expiryDate;
  Map<String, dynamic>? _remaining;
  String? _plan;
  String? _price;

  String? _monthlyPrice;
  String? _yearlyPrice;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _checkSubscription();
      await _loadPrices();
    });
  }

  Future<void> _checkSubscription() async {
    final status = await SubscriptionHelper.checkPremiumStatus();

    setState(() {
      _isPremium = status["isActive"] ?? false;
      _willRenew = status["willRenew"] ?? false;
      _expiryDate = status["expiryDateTime"];
      _remaining = status["remainingTime"];
      _plan = status["plan"];
      _price = status["price"];
    });

    /// UPDATE PREMIUM STATUS IN CLOUD
    await UserService().updateUser(FIREBASE_AUTH_UID(), {
      "premium": _isPremium,
    });

    GlobalUtils().customLog("Subscription status: $status");
  }

  Future<void> _loadPrices() async {
    final prices = await SubscriptionHelper.getPrices();

    setState(() {
      _monthlyPrice = prices["monthly"] ?? "—";
      _yearlyPrice = prices["yearly"] ?? "—";
    });

    GlobalUtils().customLog("💰 Prices: $prices");
  }

  /// REVENUE CAT: PURCHASE
  Future<void> _purchase() async {
    GlobalUtils().customLog("RevenueCatPurchase");
    final pkg = RevenueCatService.instance.getPreferredMonthlyPackage();
    if (pkg == null) return;

    try {
      final customerInfo = await RevenueCatService.instance.purchasePackage(
        pkg,
      );
      if (customerInfo != null) {
        GlobalUtils().customLog("CustomerInfo JSON: ${customerInfo.toJson()}");
      }

      final active = await RevenueCatService.instance.isEntitlementActive(
        'premium',
      );
      if (active) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("🎉 Premium unlocked!")));
        await _checkSubscription();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Purchase failed: $e")));
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Localizer.get(AppText.membership.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.arrow_back,
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context, true),
      ),
      backgroundColor: AppColor().SCREEN_BG,
      body: _UIKitWithBG(context),

      // --- ONLY ADDED: fixed subscribe button at bottom (no other UI changes) ---
      bottomNavigationBar: (!_isPremium && userSelectMembership != 1)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: SizedBox(
                  height: 48, // adjust if you want a different button height
                  child: CustomButton(
                    text: Localizer.get(AppText.subscribe.key),
                    textColor: AppColor().kWhite,
                    color: AppColor().kNavigationColor,
                    onPressed: _purchase,
                  ),
                ),
              ),
            )
          : null,
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

  Widget _UIKIT(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _plansWithFocusUI(context),
      ),
    );
  }

  // ----------------- FOCUS UI -----------------
  Widget _plansWithFocusUI(BuildContext context) {
    final bool monthlyIsActive =
        _isPremium && (_plan?.startsWith('premium_monthly_09') ?? false);

    return Column(
      children: [
        // Free Plan
        buildPlanCard(
          index: 1,
          title: Localizer.get(AppText.freeTrialMembership.key),
          height: 150.0,
          isFocused: monthlyIsActive ? false : (userSelectMembership == 1),
          dimmed: monthlyIsActive,
          onTap: () {
            if (!monthlyIsActive) setState(() => userSelectMembership = 1);
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(Localizer.get(AppText.freeTrialMembership.key)),
              const Divider(),
              _featureRow(Localizer.get(AppText.searchAndView.key)),
              _featureRow(Localizer.get(AppText.limitedContent.key)),
              _featureRow(Localizer.get(AppText.basicSupport.key)),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Monthly Plan
        buildPlanCard(
          index: 2,
          title: Localizer.get(AppText.premiumMonthlyPlan.key),
          height: 220.0,
          isFocused: monthlyIsActive ? true : (userSelectMembership == 2),
          dimmed: false,
          onTap: () => setState(() => userSelectMembership = 2),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(Localizer.get(AppText.premiumMonthlyPlan.key)),
              const Divider(),
              _featureRow(Localizer.get(AppText.viewFullProfile.key)),
              _featureRow(Localizer.get(AppText.accessUnlimitedContent.key)),
              _featureRow(Localizer.get(AppText.accessPremiumContent.key)),
              _featureRow(Localizer.get(AppText.prioritySupport.key)),
              const SizedBox(height: 8),

              // Price + Badge
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      _monthlyPrice ?? "₹---",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (monthlyIsActive)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor().kNavigationColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _willRenew
                            ? "Active"
                            : "Expires ${formatRemainingHuman(_remaining ?? {})}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Yearly Plan
        buildPlanCard(
          index: 3,
          title: Localizer.get(AppText.premiumYearlyPlan.key),
          height: 300,
          isFocused: monthlyIsActive ? false : (userSelectMembership == 3),
          dimmed: monthlyIsActive,
          onTap: () {
            if (!monthlyIsActive) setState(() => userSelectMembership = 3);
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(Localizer.get(AppText.premiumYearlyPlan.key)),
              const Divider(),
              _featureRow(Localizer.get(AppText.viewFullProfile.key)),
              _featureRow(Localizer.get(AppText.accessUnlimitedContent.key)),
              _featureRow(Localizer.get(AppText.accessLimitedContent.key)),
              _featureRow(Localizer.get(AppText.prioritySupport.key)),
              _featureRow(Localizer.get(AppText.earlyAccess.key)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  _yearlyPrice ?? "₹---",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action button
        // if (!_isPremium && userSelectMembership != 1)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //     child: CustomButton(
        //       text: Localizer.get(AppText.subscribe.key),
        //       textColor: AppColor().kWhite,
        //       color: AppColor().kNavigationColor,
        //       onPressed: _purchase,
        //     ),
        //   ),
      ],
    );
  }

  // -------------- HELPERS -----------------
  Widget buildPlanCard({
    required int index,
    required String title,
    required double height,
    required Widget body,
    required VoidCallback onTap,
    required bool isFocused,
    required bool dimmed,
  }) {
    final double scale = isFocused ? 1.03 : 1.0;
    final double opacity = dimmed ? 0.45 : 1.0;
    final borderColor = isFocused
        ? AppColor().kNavigationColor
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(scale),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: opacity,
              child: CustomContainer(
                height: height,
                color: AppColor().kWhite,
                shadow: true,
                borderColor: borderColor,
                child: body,
              ),
            ),
            if (dimmed)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(color: Colors.black.withOpacity(0.35)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(String text) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Icon(Icons.check, color: AppColor().GREEN, size: 16),
        const SizedBox(width: 6),
        Expanded(child: customText(text, 12, context)),
      ],
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: customText(text, 22, context, fontWeight: FontWeight.w600),
    );
  }

  String formatRemainingHuman(Map<String, dynamic> remaining) {
    final int days = remaining['days'] ?? 0;
    final int hours = remaining['hours'] ?? 0;
    final int minutes = remaining['minutes'] ?? 0;

    if (days > 0) return "in $days day${days > 1 ? 's' : ''}";
    if (hours > 0) return "in $hours hour${hours > 1 ? 's' : ''}";
    if (minutes > 0) return "in $minutes minute${minutes > 1 ? 's' : ''}";
    return "soon";
  }
}
