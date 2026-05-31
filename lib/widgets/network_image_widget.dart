import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? backgroundColor;
  final double? borderRadius;
  final Widget Function(BuildContext, String)? loadingWidget;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.borderRadius,
    this.loadingWidget,
  });

  static const List<Color> _palette = [
    Color(0xFFE8F5E9),
    Color(0xFFE3F2FD),
    Color(0xFFFFF3E0),
    Color(0xFFF3E5F5),
    Color(0xFFE0F7FA),
    Color(0xFFFFEBEE),
    Color(0xFFF1F8E9),
    Color(0xFFFFF8E1),
    Color(0xFFE8EAF6),
    Color(0xFFFCE4EC),
    Color(0xFFE0F2F1),
    Color(0xFFF9FBE7),
  ];

  Color _resolveBackground() {
    if (backgroundColor != null) return backgroundColor!;
    return _palette[imageUrl.hashCode.abs() % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _resolveBackground();

    Widget child = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder:
          loadingWidget ?? (context, url) => _buildPlaceholder(bgColor),
      errorWidget: (context, url, error) => _buildPlaceholder(bgColor),
    );

    if (borderRadius != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: child,
      );
    }

    return child;
  }

  Widget _buildPlaceholder(Color bgColor) {
    return Container(
      width: width,
      height: height,
      color: bgColor,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size:
              (width != null && width! < 80) || (height != null && height! < 80)
              ? 20
              : 32,
          color: bgColor.computeLuminance() > 0.5
              ? Colors.black26
              : Colors.white38,
        ),
      ),
    );
  }
}
