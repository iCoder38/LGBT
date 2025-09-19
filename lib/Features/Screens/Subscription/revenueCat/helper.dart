import 'package:lgbt_togo/Features/Screens/Subscription/revenueCat/revenuecat_service.dart';

class SubscriptionHelper {
  static Future<Map<String, dynamic>> checkPremiumStatus() async {
    final info = await RevenueCatService.instance.refreshCustomerInfo();
    final ent = info.entitlements.all['premium'];

    if (ent == null || !(ent.isActive)) {
      return {
        "isActive": false,
        "willRenew": false,
        "expirationDate": null,
        "expiryDateTime": null,
        "remainingTime": null,
        "plan": null,
        "price": null,
      };
    }

    // Parse expiry
    DateTime? expiry;
    if (ent.expirationDate != null) {
      expiry = DateTime.tryParse(ent.expirationDate!);
    }

    // Remaining time
    Duration? remaining;
    if (expiry != null) {
      remaining = expiry.difference(DateTime.now().toUtc());
    }

    // Plan ID
    String? planId = ent.productIdentifier;
    String? price;

    // Find price from offerings
    final offerings = await RevenueCatService.instance.fetchOfferings(
      forceRefresh: true,
    );

    if (offerings != null) {
      for (final off in offerings.all.values) {
        for (final pkg in off.availablePackages) {
          if (pkg.storeProduct.identifier == planId) {
            price = pkg.storeProduct.priceString;
          }
        }
      }
    }

    return {
      "isActive": ent.isActive,
      "willRenew": ent.willRenew,
      "expirationDate": ent.expirationDate,
      "expiryDateTime": expiry?.toIso8601String(),
      "remainingTime": remaining != null
          ? {
              "days": remaining.inDays,
              "hours": remaining.inHours % 24,
              "minutes": remaining.inMinutes % 60,
            }
          : null,
      "plan": planId,
      "price": price,
    };
  }

  /// 👉 NEW METHOD: get monthly & yearly prices
  static Future<Map<String, String?>> getPrices() async {
    final offerings = await RevenueCatService.instance.fetchOfferings(
      forceRefresh: true,
    );

    String? monthly;
    String? yearly;

    if (offerings != null) {
      for (final off in offerings.all.values) {
        for (final pkg in off.availablePackages) {
          if (pkg.storeProduct.identifier.startsWith("premium_monthly_09")) {
            monthly = pkg.storeProduct.priceString;
          }
          if (pkg.storeProduct.identifier.startsWith("premium_yearly_99")) {
            yearly = pkg.storeProduct.priceString;
          }
        }
      }
    }

    return {"monthly": monthly, "yearly": yearly};
  }
}
