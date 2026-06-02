import 'package:flutter/material.dart';

// ─── Sponsor Banner ───────────────────────────────────────────────────────────
// Full-width sponsor banner shown at the top of the Events list.
// When a network imageUrl is provided it renders that image.
// When no URL is provided it renders a built-in Rawlings-style banner.

class SponsorBanner extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;

  const SponsorBanner({
    super.key,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _BannerContent(imageUrl: imageUrl),
        ),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final String? imageUrl;
  const _BannerContent({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;

    if (hasUrl) {
      return Image.network(
        imageUrl!,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _RawlingsBanner();
        },
        errorBuilder: (context, error, stack) => const _RawlingsBanner(),
      );
    }

    return const _RawlingsBanner();
  }
}

// ─── Built-in Rawlings-style banner ──────────────────────────────────────────

class _RawlingsBanner extends StatelessWidget {
  const _RawlingsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 108,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCC1111), Color(0xFFE82020), Color(0xFFCC1111)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Subtle diagonal shine overlay
          Positioned.fill(
            child: CustomPaint(painter: _ShimmerPainter()),
          ),
          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rawlings wordmark
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rawlings',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Color(0x55000000),
                              offset: Offset(1, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: '®',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // R logo badge
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: Colors.transparent,
                  ),
                  child: const Center(
                    child: Text(
                      'R',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width * 0.55, 0)
      ..lineTo(size.width * 0.25, size.height)
      ..lineTo(size.width * 0.0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
