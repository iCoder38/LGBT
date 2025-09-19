import 'package:purchases_flutter/purchases_flutter.dart';

extension OfferingsDebug on Offerings {
  Map<String, dynamic> toJson() {
    return {
      'current': current?.identifier,
      'all': all.map(
        (key, offering) => MapEntry(key, {
          'identifier': offering.identifier,
          'availablePackages': offering.availablePackages.map((p) {
            final sp = p.storeProduct;
            return {
              'packageIdentifier': p.identifier,
              'productIdentifier': sp.identifier,
              'title': sp.title,
              'description': sp.description,
              'price': sp.priceString,
              'currency': sp.currencyCode,
            };
          }).toList(),
        }),
      ),
    };
  }
}

extension CustomerInfoJson on CustomerInfo {
  Map<String, dynamic> toJson() {
    return {
      'originalAppUserId': originalAppUserId,
      'activeSubscriptions': activeSubscriptions,
      'allPurchasedProductIdentifiers': allPurchasedProductIdentifiers,
      'latestExpirationDate': latestExpirationDate,
      'firstSeen': firstSeen,
      'originalPurchaseDate': originalPurchaseDate,
      'managementURL': managementURL,
      'entitlements': entitlements.all.map(
        (key, ent) => MapEntry(key, {
          'identifier': ent.identifier,
          'isActive': ent.isActive,
          'willRenew': ent.willRenew,
          'latestPurchaseDate': ent.latestPurchaseDate,
          'originalPurchaseDate': ent.originalPurchaseDate,
          'expirationDate': ent.expirationDate,
          'productIdentifier': ent.productIdentifier,
          'store': ent.store.toString(),
          'periodType': ent.periodType.toString(),
          'ownershipType': ent.ownershipType.toString(),
        }),
      ),
    };
  }
}
