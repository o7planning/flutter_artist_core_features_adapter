part of '../flutter_artist_core_features_adapter.dart';

/// Production-ready adapter for core features like SnackBar and Overlay.
class MaterialFlutterArtistCoreFeaturesAdapter
    implements FlutterArtistCoreFeaturesAdapter {
  MaterialFlutterArtistCoreFeaturesAdapter();

  @override
  BuildContext get context => FlutterArtistCore.navigatorKey.currentContext!;

  @override
  bool get isOverlayOpen => _overlayOpen;
  bool _overlayOpen = false;

  @override
  Future<dynamic> runWithOverlay({
    double opacity = 0.2,
    required Future<dynamic> Function() asyncFunction,
  }) async {
    final overlayState = FlutterArtistCore.navigatorKey.currentState?.overlay;
    if (overlayState == null) return await asyncFunction();

    final overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(opacity)),
          ),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );

    overlayState.insert(overlayEntry);
    _overlayOpen = true;

    try {
      return await asyncFunction();
    } finally {
      overlayEntry.remove();
      _overlayOpen = false;
    }
  }

  @override
  void closeAllDialogs() {
    final nav = FlutterArtistCore.navigatorKey.currentState;
    nav?.popUntil((route) => route is PageRoute);
  }

  // --- SNACKBAR IMPLEMENTATIONS ---

  @override
  void showInfoSnackBar({required String message, List<String>? details}) {
    _showSnackBar(
      message: message,
      details: details,
      icon: const Icon(Icons.info_outline, color: Colors.blue),
    );
  }

  @override
  void showWarningSnackBar({required String message, List<String>? details}) {
    _showSnackBar(
      message: message,
      details: details,
      icon: const Icon(Icons.warning_amber, color: Colors.amber),
    );
  }

  @override
  void showErrorSnackBar({required String message, List<String>? details}) {
    _showSnackBar(
      message: message,
      details: details,
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  @override
  void showSavedSnackBar({Duration duration = const Duration(seconds: 2)}) {
    final theme = Theme.of(context);
    _simpleSnackBar(
      icon: const Icon(Icons.check, color: Colors.white),
      text: "Successfully Saved!",
      color: theme.colorScheme.primary,
      duration: duration,
    );
  }

  @override
  void showDeletedSnackBar({
    String? customMessage,
    Duration duration = const Duration(seconds: 2),
  }) {
    final theme = Theme.of(context);
    _simpleSnackBar(
      icon: const Icon(Icons.delete, color: Colors.white),
      text: customMessage ?? "Successfully Deleted!",
      color: theme.colorScheme.error,
      duration: duration,
    );
  }

  /// Hàm hiển thị SnackBar đơn giản (Success/Delete)
  void _simpleSnackBar({
    required Icon icon,
    required String text,
    required Color color,
    required Duration duration,
  }) {
    final navContext = FlutterArtistCore.navigatorKey.currentContext;
    if (navContext == null) return;

    // Sử dụng ScaffoldMessenger từ Navigator Context
    final messenger = ScaffoldMessenger.of(navContext);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar({
    required String message,
    List<String>? details,
    required Icon icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    final navContext = FlutterArtistCore.navigatorKey.currentContext;
    if (navContext == null) return;

    final theme = Theme.of(navContext);
    final messenger = ScaffoldMessenger.of(navContext);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.98,
        ),
        behavior: SnackBarBehavior.fixed,
        elevation: 0,
        padding: EdgeInsets.zero,
        content: Theme(
          data: theme.copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            minTileHeight: 32,
            leading: icon,
            title: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            childrenPadding: EdgeInsets.zero,
            children: details == null
                ? []
                : [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: Column(
                        children: details
                            .map(
                              (d) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Icon(
                                        Icons.arrow_right,
                                        color: theme
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withValues(alpha: 0.6),
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        d,
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withValues(alpha: 0.8),
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
