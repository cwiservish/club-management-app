import 'package:flutter/material.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class ProfileWebViewPage extends StatefulWidget {
  final String url;

  const ProfileWebViewPage({super.key, required this.url});

  @override
  State<ProfileWebViewPage> createState() => _ProfileWebViewPageState();
}

class _ProfileWebViewPageState extends State<ProfileWebViewPage> {
  bool _isLoading = true;

  String _cleanUrl(String original) {
    if (original.contains('.com//')) {
      return original.replaceAll('.com//', '.com/');
    }
    return original;
  }

  @override
  Widget build(BuildContext context) {
    final cleanedUrl = _cleanUrl(widget.url);
    final colors = AppColors.current;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.headerBg,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: colors.textPrimary,
            padding: const EdgeInsets.only(left: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 16,
            color: colors.textPrimary,
          ),
          label: Text(
            'Back',
            style: AppTextStyles.body15.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        title: Text(
          'Profile Detail',
          style: AppTextStyles.body16.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: colors.border,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(cleanedUrl),
              ),
              initialSettings: InAppWebViewSettings(
                useHybridComposition: true,
                transparentBackground: true,
                isInspectable: true,
              ),
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _isLoading = false;
                });
              },
              onReceivedError: (controller, request, error) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            if (_isLoading)
              Container(
                color: colors.background,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colors.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
