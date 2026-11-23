import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

enum PaymentWebViewResult {
  finished,
  closed,
}

/// Screen for displaying Midtrans Snap Payment WebView
class PaymentWebViewScreen extends StatefulWidget {
  final String redirectUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.redirectUrl,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isClosed = false;

  void _closeScreen(PaymentWebViewResult result) {
    if (_isClosed) return;
    _isClosed = true;
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted && !_isClosed) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted && !_isClosed) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // Intercept finish URL
            if (url.startsWith('https://example.com/sportiva-finish')) {
              _closeScreen(PaymentWebViewResult.finished);
              return NavigationDecision.prevent;
            }

            // Block non-HTTP/HTTPS schemes (e.g. gopay://, intent://) without crashing
            final uri = Uri.parse(url);
            if (uri.scheme != 'http' && uri.scheme != 'https') {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _closeScreen(PaymentWebViewResult.closed);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingXLarge,
                  vertical: AppTheme.iconSizeSmall,
                ),
                child: AppHeader(
                  title: 'Pembayaran',
                  showBackButton: true,
                  onBackTap: () => _closeScreen(PaymentWebViewResult.closed),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(
                          color: colors.successForeground,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
