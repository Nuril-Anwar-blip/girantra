import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.1,
    fontFamily: 'Montserrat',
  );

  static const subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
    fontFamily: 'Montserrat',
  );

  static const link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
    fontFamily: 'Montserrat',
  );
}

