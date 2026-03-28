import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';

class ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;

  const ProductImageCarousel({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.pageController,
    this.onPageChanged,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController =
        widget.pageController ??
        PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    if (widget.pageController == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
      children: [
        SizedBox(
          height: 375,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.background,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 375,
      color: AppColors.background,
      child: const Center(
        child: Icon(Icons.image, size: 64, color: AppColors.textSecondary),
      ),
    );
  }
}
