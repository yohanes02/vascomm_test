import 'dart:async';

import 'package:flutter/material.dart';

import 'promo_banner_card.dart';

/// One slide of [PromoBannerCarousel].
class PromoBanner {
  final String assetPath;
  final IconData fallbackIcon;

  /// Regular-weight first half of the headline.
  final String title;

  /// Bold second half of the headline.
  final String? titleEmphasis;

  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onCtaPressed;

  const PromoBanner({
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.titleEmphasis,
    this.fallbackIcon = Icons.image_outlined,
    this.onCtaPressed,
  });
}

/// Swipeable, auto-advancing stack of [PromoBannerCard]s. The dots drawn
/// inside each card track the visible page.
class PromoBannerCarousel extends StatefulWidget {
  final List<PromoBanner> banners;

  /// How long each slide stays on screen. Auto-advance is disabled when
  /// this is null or there is only one banner.
  final Duration? interval;

  /// How long the slide animation itself takes.
  final Duration transitionDuration;

  /// Slides are laid out to a fixed height because [PageView] can't size
  /// itself to its children. The default fits a two-line headline plus a
  /// two-line subtitle down to ~360dp-wide screens; raise it if a banner's
  /// copy needs more room.
  final double height;

  const PromoBannerCarousel({
    super.key,
    required this.banners,
    this.interval = const Duration(seconds: 5),
    this.transitionDuration = const Duration(milliseconds: 400),
    this.height = 200,
  });

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant PromoBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval ||
        oldWidget.banners.length != widget.banners.length) {
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    final interval = widget.interval;
    if (interval == null || widget.banners.length < 2) return;
    _timer = Timer.periodic(interval, (_) => _advance());
  }

  void _advance() {
    if (!mounted || !_controller.hasClients) return;
    _controller.animateToPage(
      (_index + 1) % widget.banners.length,
      duration: widget.transitionDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        // Soft left-to-right wash: near-white behind the copy, cooling
        // to a pale blue-grey behind the illustration.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDFDFF), Color(0xFFE7ECF5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0C2461),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            // A manual swipe restarts the countdown, so the slide the user
            // landed on gets a full interval before moving on.
            onNotification: (notification) {
              if (notification is ScrollEndNotification) _restartTimer();
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return PromoBannerCard(
                  assetPath: banner.assetPath,
                  fallbackIcon: banner.fallbackIcon,
                  title: banner.title,
                  titleEmphasis: banner.titleEmphasis,
                  subtitle: banner.subtitle,
                  ctaLabel: banner.ctaLabel,
                  onCtaPressed: banner.onCtaPressed,
                  // The indicator is painted once, below, instead of once
                  // per page — the cards only reserve room for it.
                  dotCount: 0,
                  reserveDotSpace: true,
                );
              },
            ),
          ),
          // Sits in the same bottom-right corner as the card's own dots, but
          // outside the PageView so it stays put while slides move.
          Positioned(
            right: PromoBannerDots.insetRight,
            bottom: PromoBannerDots.insetBottom,
            child: IgnorePointer(
              child: PromoBannerDots(
                count: widget.banners.length,
                activeIndex: _index,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
