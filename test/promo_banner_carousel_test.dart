import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vascomm_test/features/home/presentation/widgets/promo_banner_card.dart';
import 'package:vascomm_test/features/home/presentation/widgets/promo_banner_carousel.dart';
import 'package:vascomm_test/core/theme/app_theme.dart';

const _banners = [
  PromoBanner(
    assetPath: 'assets/images/service_special.png',
    title: 'Solusi,',
    titleEmphasis: 'Kesehatan Anda',
    subtitle: 'Update informasi seputar kesehatan semua bisa disini !',
    ctaLabel: 'Selengkapnya',
  ),
  PromoBanner(
    assetPath: 'assets/images/test_register.png',
    title: 'Tes Covid,',
    titleEmphasis: 'Tanpa Antre',
    subtitle: 'Daftar swab & antigen langsung dari aplikasi !',
    ctaLabel: 'Daftar Tes',
  ),
  PromoBanner(
    assetPath: 'assets/images/track_pemeriksaan.png',
    title: 'Pantau,',
    titleEmphasis: 'Hasil Pemeriksaan',
    subtitle: 'Cek progress pemeriksaanmu kapan saja !',
    ctaLabel: 'Track Sekarang',
  ),
];

int _activeDot(WidgetTester tester) =>
    tester.widget<PromoBannerDots>(find.byType(PromoBannerDots)).activeIndex;

void main() {
  testWidgets('auto-advances on the configured interval and wraps around',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(20),
            child: PromoBannerCarousel(
              banners: _banners,
              interval: Duration(seconds: 5),
            ),
          ),
        ),
      ),
    );

    expect(_activeDot(tester), 0);
    expect(find.text('Selengkapnya'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(_activeDot(tester), 1);
    expect(find.text('Daftar Tes'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(_activeDot(tester), 2);

    // Wraps back to the first slide.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(_activeDot(tester), 0);

    // A manual swipe moves a page and restarts the countdown.
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(_activeDot(tester), 1);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(_activeDot(tester), 1, reason: 'timer restarted after the swipe');

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(_activeDot(tester), 2);
  });

  testWidgets('interval: null disables auto-advance', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(20),
            child: PromoBannerCarousel(banners: _banners, interval: null),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(_activeDot(tester), 0);
  });
}
