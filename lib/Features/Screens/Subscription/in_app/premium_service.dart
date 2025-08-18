import 'dart:async';

// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/in_app/keys.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class PremiumService {
  PremiumService._privateConstructor();

  static final PremiumService _instance = PremiumService._privateConstructor();
  static PremiumService get instance => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  bool isAvailable = false;
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _isInitialized = false;

  ProductDetails? _weeklyProduct;
  ProductDetails? _monthlyProduct;

  ProductDetails? get weeklyProduct => _weeklyProduct;
  ProductDetails? get monthlyProduct => _monthlyProduct;

  ProductPriceInfo? get weeklyPriceInfo => _weeklyProduct != null
      ? ProductPriceInfo(
          priceString: _weeklyProduct!.price,
          currencyCode: _weeklyProduct!.currencyCode,
          rawPrice: _weeklyProduct!.rawPrice,
        )
      : null;

  ProductPriceInfo? get monthlyPriceInfo => _monthlyProduct != null
      ? ProductPriceInfo(
          priceString: _monthlyProduct!.price,
          currencyCode: _monthlyProduct!.currencyCode,
          rawPrice: _monthlyProduct!.rawPrice,
        )
      : null;

  Future<bool> initSubscription() async {
    if (_isInitialized) {
      await _loadProducts(); // refresh prices
      return _isPremium;
    }

    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      // customLog('❌ In-app purchases not available');
      return false;
    }

    _subscription = _iap.purchaseStream.listen(
      (purchases) async {
        for (final purchase in purchases) {
          final isSubscription =
              purchase.productID == IAPKeys.premiumMonthlyKey ||
              purchase.productID == IAPKeys.premiumYearlyKey;

          if (!isSubscription) {
            GlobalUtils().customLog(
              "🔁 Non-subscription purchase skipped in PremiumService",
            );
            continue; // ✅ Skip coins or other IAP
          }

          if (purchase.status == PurchaseStatus.purchased) {
            final expiry = purchase.productID == IAPKeys.premiumMonthlyKey
                ? DateTime.now().add(Duration(days: 7))
                : DateTime.now().add(Duration(days: 30));

            // in FIREBASE
            /*await SubscriptionService.saveSubscription(
              purchase: purchase,
              expiryDate: expiry,
              platform: 'android',
            );*/

            _isPremium = true;
            await _iap.completePurchase(purchase);
            GlobalUtils().customLog("✅ Subscription saved to Firestore");
          } else if (purchase.status == PurchaseStatus.error) {
            GlobalUtils().customLog("❌ Purchase error: ${purchase.error}");
          }
        }
      },
      onDone: () => _subscription.cancel(),
      onError: (error) =>
          GlobalUtils().customLog('❌ Purchase stream error: $error'),
    );

    _isInitialized = true;
    await _loadProducts();
    return _isPremium;
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(IAPKeys.allProductIds);
    if (response.notFoundIDs.isNotEmpty) {
      GlobalUtils().customLog("⚠️ Not found: ${response.notFoundIDs}");
    }

    final products = response.productDetails;
    _weeklyProduct = products.firstWhereOrNull(
      (p) => p.id == IAPKeys.premiumMonthlyKey,
    );
    _monthlyProduct = products.firstWhereOrNull(
      (p) => p.id == IAPKeys.premiumYearlyKey,
    );
  }

  Future<void> buySubscription(ProductDetails product) async {
    try {
      final param = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: param);
      GlobalUtils().customLog("🛒 Started subscription: ${product.id}");
    } on PlatformException catch (e) {
      GlobalUtils().customLog("⚠️ Purchase failed: ${e.message}");
    }
  }

  Future<void> restoreUserPurchases({
    required Function(PurchaseDetails) onSuccess,
    required Function(String) onError,
  }) async {
    final sub = _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          final duration = purchase.productID == IAPKeys.premiumMonthlyKey
              ? const Duration(days: 7)
              : const Duration(days: 30);

          final expiry = DateTime.now().add(duration);

          // in FIREBASE
          /*await SubscriptionService.saveSubscription(
            purchase: purchase,
            expiryDate: expiry,
            platform: 'android',
          );*/

          _isPremium = true;
          onSuccess(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          onError(purchase.error?.message ?? "Unknown error");
        }
      }
    }, onError: (error) => onError(error.toString()));

    try {
      await _iap.restorePurchases();
    } catch (e) {
      onError("Restore failed: $e");
    }

    Future.delayed(const Duration(seconds: 5), () => sub.cancel());
  }

  Future<Map<String, String>> getFormattedSubscriptionPrices() async {
    await initSubscription();
    return {
      'weekly': weeklyPriceInfo?.priceString ?? '',
      'monthly': monthlyPriceInfo?.priceString ?? '',
    };
  }

  void dispose() {
    _subscription.cancel();
    _isInitialized = false;
  }
}

class ProductPriceInfo {
  final String priceString;
  final String currencyCode;
  final double rawPrice;

  ProductPriceInfo({
    required this.priceString,
    required this.currencyCode,
    required this.rawPrice,
  });
}

extension IterableExtensions<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
