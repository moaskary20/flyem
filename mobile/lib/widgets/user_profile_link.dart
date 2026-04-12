import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/screens/public_user_profile_screen.dart';
import 'package:flyem_app/services/auth_service.dart';

Future<void> openPublicUserProfile(BuildContext context, int? userId) async {
  if (userId == null || userId <= 0) return;
  final loggedIn = await AuthService.isLoggedIn();
  if (!context.mounted) return;
  if (!loggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.loginToViewProfile)),
    );
    return;
  }
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => PublicUserProfileScreen(userId: userId),
    ),
  );
}

/// اسم مستخدم قابل للضغط لفتح [PublicUserProfileScreen] عند توفر [userId].
class TappableUserName extends StatelessWidget {
  const TappableUserName({
    super.key,
    required this.userId,
    required this.displayName,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
  });

  final int? userId;
  final String displayName;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      displayName,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
    if (userId == null || userId! <= 0 || displayName.isEmpty) {
      return text;
    }
    return InkWell(
      onTap: () => openPublicUserProfile(context, userId),
      borderRadius: BorderRadius.circular(4),
      child: text,
    );
  }
}
