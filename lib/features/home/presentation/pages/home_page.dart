import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../../../../core/presentation/widgets/app_icon.dart';
import '../../../../core/presentation/widgets/app_top_bar_actions.dart';
import '../widgets/category_chip_bar.dart';
import '../../../../core/presentation/widgets/placeholder_image.dart';
import '../widgets/promo_banner_carousel.dart';
import '../widgets/search_bar_row.dart';
import '../../../../core/presentation/widgets/segmented_toggle.dart';
import '../widgets/service_feature_card.dart';
import '../../../../core/presentation/widgets/update_notification_banner.dart';

class _Product {
  final String name;
  final String price;
  final String badge;
  final double rating;

  const _Product({
    required this.name,
    required this.price,
    required this.badge,
    required this.rating,
  });
}

class _ExamPackage {
  final String title;
  final String location;
  final String address;
  final String price;

  const _ExamPackage({
    required this.title,
    required this.location,
    required this.address,
    required this.price,
  });
}

const _kCategories = ['All Product', 'Layanan Kesehatan', 'Alat Kesehatan'];

const _kProducts = [
  _Product(
      name: 'Suntik Steril',
      price: 'Rp. 10.000',
      badge: 'Ready Stok',
      rating: 5),
  _Product(
      name: 'Masker Medis',
      price: 'Rp. 25.000',
      badge: 'Ready Stok',
      rating: 5),
  _Product(
      name: 'Hand Sanitizer',
      price: 'Rp. 18.000',
      badge: 'Ready Stok',
      rating: 4),
  _Product(
      name: 'Sarung Tangan Latex',
      price: 'Rp. 32.000',
      badge: 'Ready Stok',
      rating: 5),
  _Product(
      name: 'Alkohol Swab',
      price: 'Rp. 12.000',
      badge: 'Ready Stok',
      rating: 4),
];

const _kPackages = [
  _ExamPackage(
    title: 'PCR Swab Test (Drive Thru) Hasil 1 Hari Kerja',
    location: 'Lenmarc Surabaya',
    address: 'Dukuh Pakis, Surabaya',
    price: 'Rp. 1.400.000',
  ),
  _ExamPackage(
    title: 'PCR Swab Test (Drive Thru) Hasil 1 Hari Kerja',
    location: 'Lenmarc Surabaya',
    address: 'Dukuh Pakis, Surabaya',
    price: 'Rp. 1.400.000',
  ),
  _ExamPackage(
    title: 'Antigen Swab Test Hasil 1 Jam',
    location: 'Grand City Surabaya',
    address: 'Genteng, Surabaya',
    price: 'Rp. 150.000',
  ),
  _ExamPackage(
    title: 'Medical Check Up Lengkap Karyawan',
    location: 'Tunjungan Plaza',
    address: 'Tegalsari, Surabaya',
    price: 'Rp. 850.000',
  ),
  _ExamPackage(
    title: 'PCR Swab Test (Home Service) Hasil 1 Hari Kerja',
    location: 'Pakuwon Mall',
    address: 'Dukuh Pakis, Surabaya',
    price: 'Rp. 1.600.000',
  ),
];

/// Home / landing screen shown once the user is authenticated.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedCategory = 0;
  bool _showSatuan = true;

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: const AppMenuButton(),
        actions: const [AppTopBarActions()],
      ),
      body: ListView(
        // No horizontal padding here: the update banner at the bottom runs
        // edge-to-edge, so everything above it carries the 20px inset itself.
        // Top inset matches the gap below the carousel, so the banner sits
        // evenly between the app bar and the card under it.
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PromoBannerCarousel(
                  // Slides advance on their own every 5s; pass a different
                  // `interval` (or null to disable) to change that.
                  interval: const Duration(seconds: 5),
                  banners: [
                    PromoBanner(
                      assetPath: 'assets/images/service_special.png',
                      fallbackIcon: Icons.biotech_outlined,
                      title: 'Solusi,',
                      titleEmphasis: 'Kesehatan Anda',
                      subtitle:
                          'Update informasi seputar kesehatan semua bisa disini !',
                      ctaLabel: 'Selengkapnya',
                      onCtaPressed: () => _comingSoon(context),
                    ),
                    PromoBanner(
                      assetPath: 'assets/images/test_register.png',
                      fallbackIcon: Icons.coronavirus_outlined,
                      title: 'Tes Covid,',
                      titleEmphasis: 'Tanpa Antre',
                      subtitle:
                          'Daftar swab & antigen langsung dari aplikasi !',
                      ctaLabel: 'Daftar Tes',
                      onCtaPressed: () => _comingSoon(context),
                    ),
                    PromoBanner(
                      assetPath: 'assets/images/track_pemeriksaan.png',
                      fallbackIcon: Icons.search,
                      title: 'Pantau,',
                      titleEmphasis: 'Hasil Pemeriksaan',
                      subtitle: 'Cek progress pemeriksaanmu kapan saja !',
                      ctaLabel: 'Track Sekarang',
                      onCtaPressed: () => _comingSoon(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ServiceFeatureCard(
                  assetPath: 'assets/images/test_register.png',
                  fallbackIcon: Icons.coronavirus_outlined,
                  title: 'Layanan Khusus',
                  subtitle: 'Tes Covid 19, Cegah Corona Sedini Mungkin',
                  ctaLabel: 'Daftar Tes',
                  imageSide: ServiceImageSide.right,
                  onTap: () => _comingSoon(context),
                  imageOverflow: 32,
                ),
                const SizedBox(height: 14),
                ServiceFeatureCard(
                  assetPath: 'assets/images/track_pemeriksaan.png',
                  fallbackIcon: Icons.search,
                  title: 'Track Pemeriksaan',
                  subtitle: 'Kamu dapat mengecek progress pemeriksaanmu disini',
                  ctaLabel: 'Track',
                  imageSide: ServiceImageSide.left,
                  // The magnifier artwork is wider/flatter than the vaccine one,
                  // so it needs a shorter column and more bottom clearance.
                  imageWidth: 118,
                  imageBottomMargin: 34,
                  onTap: () => _comingSoon(context),
                ),
                const SizedBox(height: 28),
                SearchBarRow(
                  onFilterPressed: () => _comingSoon(context),
                ),
                const SizedBox(height: 22),
                CategoryChipBar(
                  labels: _kCategories,
                  selectedIndex: _selectedCategory,
                  onSelected: (index) =>
                      setState(() => _selectedCategory = index),
                ),
                const SizedBox(height: 20),
                // Product carousel for the selected category. The extra height
                // beyond the tile leaves room for the cards' drop shadow, which
                // the horizontal viewport would otherwise clip.
                SizedBox(
                  height: 206,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: _kProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) => SizedBox(
                      width: 162,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ProductCard(product: _kProducts[index]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pilih Tipe Layanan Kesehatan Anda',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                      fontSize: 17),
                ),
                const SizedBox(height: 16),
                SegmentedToggle(
                  leftLabel: 'Satuan',
                  rightLabel: 'Paket Pemeriksaan',
                  leftSelected: _showSatuan,
                  expanded: false,
                  onChanged: (left) => setState(() => _showSatuan = left),
                ),
                const SizedBox(height: 20),
                // Exam packages get their own vertical scroll area so the list can
                // grow without pushing the rest of the page down. Both toggle
                // options render the same source for now — swap `_kPackages` for
                // the per-tab list once the catalogue API is wired up.
                SizedBox(
                  height: 440,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _kPackages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) =>
                        _PackageCard(package: _kPackages[index]),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => _comingSoon(context),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 18, color: AppColors.textSecondary),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Tampilkan Lebih Banyak',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const UpdateNotificationBanner(borderRadius: BorderRadius.zero),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(
                  child: PlaceholderImage(
                    assetPath: 'assets/images/product_placeholder.png',
                    fallbackIcon: Icons.science_outlined,
                    fit: BoxFit.contain,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                // Rating sits top-right over the product shot.
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/star_icon.png',
                        width: 18,
                        height: 18,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.star,
                                color: AppColors.star, size: 18),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          // Price and stock badge share one line in a fairly narrow grid
          // tile, so both scale down rather than overflow.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    product.price,
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.badge,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final _ExamPackage package;

  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    package.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.35,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    package.price,
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.apartment_rounded,
                          size: 16, color: AppColors.navy),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          package.location,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: AppColors.navy),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          package.address,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Photo hugs the card's right edge and matches its height.
            PlaceholderImage(
              assetPath: 'assets/images/package_placeholder.png',
              fallbackIcon: Icons.local_hospital_outlined,
              width: 120,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      ),
    );
  }
}
