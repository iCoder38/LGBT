// levels_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Model for a level entry
class LevelInfo {
  final int id;
  final int points; // e.g. 10000
  final String title; // e.g. "Level 1 Member"
  final List<String> benefits;

  LevelInfo({
    required this.id,
    required this.points,
    required this.title,
    required this.benefits,
  });
}

/// Reusable bottom sheet to show levels & points.
///
/// - startLevel: int (1-based) -> we'll show startLevel and up to next 2 levels
/// - levels: optional custom list, otherwise default 3-level list is used
/// - onUpgrade: optional callback when user taps Upgrade (gets selected LevelInfo)
/// - lockToStartLevel: if true, user cannot change selection (stuck on first visible)
///
/// NOTE: bottom action buttons (Select / Upgrade) were removed per request.
/// The close (X) button now returns current visible selected level to the caller:
///   Navigator.pop(context, {'action': 'current', 'level': selectedLevel});
///
/// Returns Future<Map<String, dynamic>?> where:
///   {'action': 'current', 'level': LevelInfo}  => user closed sheet (no explicit action)
///   {'action': 'upgrade', 'level': LevelInfo}  => (only used if onUpgrade is invoked programmatically)
///   null => dismissed by system
class LevelsBottomSheet {
  static final List<LevelInfo> _defaultLevels = [
    LevelInfo(
      id: 1,
      points: 10000,
      title: "Level 1 Member",
      benefits: [
        "Post up to 200 times on dashboard",
        "Send up to 50 friend requests",
        "Send direct messages to 10 users",
        // "Limited swipes",
      ],
    ),
    LevelInfo(
      id: 2,
      points: 30000,
      title: "Level 2 Member",
      benefits: [
        "Unlimited posts",
        "Unlimited friend requests",
        "Send direct messages to 50 users",
        // "Unlimited swipes",
      ],
    ),
    LevelInfo(
      id: 3,
      points: 50000,
      title: "Level 3 Member",
      benefits: [
        "All Level 2 benefits +",
        "Block other users",
        "Send direct messages",
        "Unlock any Premium photo",
      ],
    ),
  ];

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    int startLevel = 1,
    List<LevelInfo>? levels,
    Future<void> Function(LevelInfo level)? onUpgrade,
    String title = "Membership Levels",
    String subtitle =
        "Earn points to increase your level and unlock more benefits.",
    // NEW: lock selection to the start level (user cannot change selection)
    bool lockToStartLevel = false,
  }) {
    final list = levels ?? _defaultLevels;

    // compute start index (clamp)
    final startIndex = math.max(0, math.min(list.length - 1, startLevel - 1));

    // slice up to 3 items starting from startIndex
    final endIndex = math.min(list.length, startIndex + 3);
    final visible = list.sublist(startIndex, endIndex);

    return showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        // always start with the first visible item's id
        final int lockedSelectedId =
            visible.first.id; // fixed selection id when locked
        int selectedId = visible.first.id;
        // if locked, we want to prevent any change to selectedId
        final bool locked = lockToStartLevel;

        return StatefulBuilder(
          builder: (ctx, setState) {
            // enforce lock: if locked, keep selectedId equal to lockedSelectedId
            if (locked && selectedId != lockedSelectedId) {
              selectedId = lockedSelectedId;
            }

            final selectedLevel = visible.firstWhere(
              (l) => l.id == selectedId,
              orElse: () => visible.first,
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // CLOSE button now returns current selection
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey.shade700),
                          onPressed: () => Navigator.of(
                            ctx,
                          ).pop({'action': 'current', 'level': selectedLevel}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // attractive banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.orange,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade900,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Upgrade & earn points ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "to increase your level and unlock up to ${_maxPoints(list)} points benefits.",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // level cards
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: visible.map((lvl) {
                          final isSelected = selectedId == lvl.id;
                          // if locked and this is not the selected card, show visually disabled
                          final cardOpacity = (locked && !isSelected)
                              ? 0.55
                              : 1.0;

                          // Use IgnorePointer so non-selected cards are truly non-interactive when locked.
                          return Opacity(
                            opacity: cardOpacity,
                            child: IgnorePointer(
                              ignoring: locked && !isSelected,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.08)
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x11000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: locked
                                              ? null
                                              : () {
                                                  // if not locked, allow selecting by tapping the badge/points too
                                                  setState(() {
                                                    selectedId = lvl.id;
                                                  });
                                                },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "${lvl.points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+$)'), (m) => "${m[1]},")} pts",
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade800,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            lvl.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        // LABEL: "You are here" instead of "Selected"
                                        if (isSelected)
                                          Chip(
                                            label: const Text("You are here"),
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            labelStyle: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // benefits
                                    ...lvl.benefits.map(
                                      (b) => Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.check, size: 14),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                b,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Buttons removed as requested. Close/X (top-right) returns current selection.
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // helper to show maximum points in banner (just picks largest points value)
  static String _maxPoints(List<LevelInfo> levels) {
    final maxPts = levels
        .map((e) => e.points)
        .fold<int>(0, (a, b) => math.max(a, b));
    return maxPts.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+$)'),
      (m) => "${m[1]},",
    );
  }
}
