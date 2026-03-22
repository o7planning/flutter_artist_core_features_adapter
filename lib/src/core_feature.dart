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
    _simpleSnackBar(
      icon: const Icon(Icons.check, color: Colors.white),
      text: "Successfully Saved!",
      color: Colors.green.shade400,
      duration: duration,
    );
  }

  @override
  void showDeletedSnackBar({
    String? customMessage,
    Duration duration = const Duration(seconds: 2),
  }) {
    _simpleSnackBar(
      icon: const Icon(Icons.delete, color: Colors.white),
      text: customMessage ?? "Successfully Deleted!",
      color: Colors.deepOrange.shade300,
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

  /// Hàm hiển thị SnackBar chi tiết (Error/Warning/Info)
  void _showSnackBar({
    required String message,
    List<String>? details,
    required Icon icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    final navContext = FlutterArtistCore.navigatorKey.currentContext;
    if (navContext == null) return;

    final messenger = ScaffoldMessenger.of(navContext);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        content: Theme(
          // Dùng Theme của Navigator Context để đảm bảo style chuẩn
          data: Theme.of(navContext).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            initiallyExpanded: true,
            tilePadding: EdgeInsets.zero,
            leading: icon,
            title: Text(
              message,
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
            children: details == null
                ? []
                : details
                      .map(
                        (d) => ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.arrow_right,
                            color: Colors.white,
                            size: 16,
                          ),
                          title: Text(
                            d,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
          ),
        ),
      ),
    );
  }
}
