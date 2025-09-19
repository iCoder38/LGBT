// lib/services/revenuecat_service.dart
// RevenueCat helper (compatible with purchases_flutter: ^9.6.2)

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  RevenueCatService._private();
  static final RevenueCatService instance = RevenueCatService._private();

  // Configurable (change if your dashboard uses other ids)
  String offeringIdentifier = 'default';
  String entitlementId = 'premium';

  // Internal
  String? _publicSdkKey;
  bool _initialized = false;
  Offerings? _cachedOfferings;

  final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  Offerings? get cachedOfferings => _cachedOfferings;

  /// Initialize the Purchases SDK (v9+ compatible).
  /// If you want to identify a user on revenuecat, pass appUserId (will call Purchases.logIn).
  Future<void> init({required String apiKey, String? appUserId}) async {
    if (_initialized && _publicSdkKey == apiKey) return;

    _publicSdkKey = apiKey;
    try {
      final config = PurchasesConfiguration(apiKey);
      await Purchases.configure(config);
      _initialized = true;

      // If you manage your own user ids, log in:
      if (appUserId != null && appUserId.isNotEmpty) {
        try {
          await Purchases.logIn(appUserId);
        } catch (_) {
          // login can fail for many reasons; don't block initialization.
        }
      }

      // initial load
      await fetchOfferings(forceRefresh: true);
      await refreshCustomerInfo();

      // listen for remote updates
      try {
        Purchases.addCustomerInfoUpdateListener((info) {
          _customerInfoController.add(info);
        });
      } catch (_) {
        // listener may already be registered or not available in rare edge-cases;
        // non-fatal.
      }
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  // -------- Offerings --------
  Future<Offerings?> fetchOfferings({bool forceRefresh = false}) async {
    if (!_initialized) {
      throw Exception('RevenueCat not initialized. Call init() first.');
    }
    try {
      if (!forceRefresh && _cachedOfferings != null) {
        return _cachedOfferings;
      }
      final off = await Purchases.getOfferings();
      _cachedOfferings = off;
      return off;
    } on PlatformException {
      rethrow;
    }
  }

  Offering? getCurrentOffering() {
    if (_cachedOfferings == null) return null;
    if (_cachedOfferings!.current != null) return _cachedOfferings!.current;
    return _cachedOfferings!.all[offeringIdentifier];
  }

  /// Find a sensible "monthly" package from the current offering.
  Package? getPreferredMonthlyPackage() {
    final offering = getCurrentOffering();
    if (offering == null) return null;

    // 1) prefer symbolic $rc_monthly
    for (final p in offering.availablePackages) {
      final id = p.identifier ?? '';
      if (id == r'$rc_monthly') return p;
    }

    // 2) prefer packages whose identifier or storeProduct identifier contains 'monthly'
    for (final p in offering.availablePackages) {
      final id = (p.identifier ?? '').toLowerCase();
      final spId = (p.storeProduct.identifier ?? '').toLowerCase();
      if (id.contains('monthly') || spId.contains('monthly')) return p;
    }

    // 3) fallback to first package
    if (offering.availablePackages.isNotEmpty) {
      return offering.availablePackages.first;
    }
    return null;
  }

  // -------- Purchases --------
  /// Purchase a Package (recommended flow when using Offerings)
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_initialized)
      throw Exception('RevenueCat not initialized. Call init() first.');

    try {
      await Purchases.purchasePackage(package);
      // fetch latest info after purchase
      final info = await Purchases.getCustomerInfo();
      _customerInfoController.add(info);
      return info;
    } on PlatformException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Purchase by Play product identifier (SKU). Searches cached offerings.
  Future<CustomerInfo?> purchaseProductById(String productId) async {
    if (!_initialized)
      throw Exception('RevenueCat not initialized. Call init() first.');

    final offerings = _cachedOfferings ?? await fetchOfferings();
    if (offerings == null) throw Exception('No offerings available.');

    Package? found;
    for (final of in offerings.all.values) {
      for (final p in of.availablePackages) {
        final spId = p.storeProduct.identifier ?? '';
        if (spId == productId) {
          found = p;
          break;
        }
      }
      if (found != null) break;
    }

    if (found == null) {
      throw Exception('Product "$productId" not found in cached offerings.');
    }

    return await purchasePackage(found);
  }

  /// Restore purchases and emit customer info
  Future<CustomerInfo?> restorePurchases() async {
    if (!_initialized)
      throw Exception('RevenueCat not initialized. Call init() first.');
    final info = await Purchases.restorePurchases();
    _customerInfoController.add(info);
    return info;
  }

  // -------- Customer info / entitlements --------
  Future<CustomerInfo> refreshCustomerInfo() async {
    if (!_initialized)
      throw Exception('RevenueCat not initialized. Call init() first.');
    final info = await Purchases.getCustomerInfo();
    _customerInfoController.add(info);
    return info;
  }

  Future<bool> isEntitlementActive(String entitlement) async {
    final info = await refreshCustomerInfo();
    return info.entitlements.all[entitlement]?.isActive ?? false;
  }

  /// expirationDate in v9 may be String? (ISO8601) or DateTime - handle both safely
  DateTime? getEntitlementExpiration(CustomerInfo info, String entitlement) {
    final ent = info.entitlements.all[entitlement];
    if (ent == null) return null;

    final dynamic maybeExp = ent.expirationDate;
    if (maybeExp == null) return null;
    if (maybeExp is DateTime) return maybeExp;
    if (maybeExp is String) return DateTime.tryParse(maybeExp);
    return null;
  }

  // -------- Helpers for UI --------
  /// Returns a simple map with title and price to show in UI
  Map<String, String> packageDisplayInfo(Package package) {
    final sp = package.storeProduct;
    final title = (sp.title != null && sp.title!.isNotEmpty)
        ? sp.title!
        : (sp.identifier ?? ''); // fallback to identifier when title absent
    final price = sp.priceString ?? '';
    return {'title': title, 'price': price};
  }

  // -------- Debug --------
  Future<String> debugSummary() async {
    final sb = StringBuffer();
    sb.writeln('RevenueCat initialized: $_initialized');
    sb.writeln('Cached offerings present: ${_cachedOfferings != null}');
    if (_cachedOfferings != null) {
      sb.writeln('Offerings keys: ${_cachedOfferings!.all.keys.join(', ')}');
      final cur = _cachedOfferings!.current;
      sb.writeln('Current offering id: ${cur?.identifier}');
      if (cur != null) {
        for (final p in cur.availablePackages) {
          sb.writeln(
            ' - package ${p.identifier} → storeId ${p.storeProduct.identifier}, price ${p.storeProduct.priceString}',
          );
        }
      }
    }
    try {
      final info = await Purchases.getCustomerInfo();
      sb.writeln('Entitlements: ${info.entitlements.all.keys}');
    } catch (_) {
      sb.writeln('No customer info available');
    }
    return sb.toString();
  }

  Future<void> dispose() async {
    await _customerInfoController.close();
  }
}
