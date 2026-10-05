import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final bool isVerified;
  final bool showBorder;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 20,
    this.isVerified = false,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join()
        : 'U';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.beigeMedium,
            border: showBorder
                ? Border.all(color: AppColors.offWhiteSurface, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _fallbackInitials(initials),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _fallbackInitials(initials);
                  },
                )
              : _fallbackInitials(initials),
        ),
        if (isVerified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.offWhiteSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.accentAmber,
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallbackInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.black,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
