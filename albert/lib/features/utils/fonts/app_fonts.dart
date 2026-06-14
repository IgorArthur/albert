import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

enum TextSize {
  small,
  normal,
  large;

  double get scale {
    switch (this) {
      case TextSize.small:
        return 0.8;
      case TextSize.normal:
        return 1.0;
      case TextSize.large:
        return 1.2;
    }
  }
}

class TextSizeManager {
  static TextSize _currentSize = TextSize.normal;

  static TextSize get currentSize => _currentSize;

  static void setSize(TextSize size) {
    _currentSize = size;
  }
}

TextStyle _displayStyle({Color? color}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 28 * TextSizeManager.currentSize.scale,
  fontWeight: FontWeight.w800,
  letterSpacing: -0.5,
  color: color ?? AppColors.neutral100,
);

TextStyle _headlineStyle({Color? color}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 22 * TextSizeManager.currentSize.scale,
  fontWeight: FontWeight.bold,
  color: color ?? AppColors.neutral100,
);

TextStyle _subtitle1Style({Color? color}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 18 * TextSizeManager.currentSize.scale,
  fontWeight: FontWeight.w600,
  color: color ?? AppColors.neutral100,
);

TextStyle _subtitle2Style({Color? color}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 16 * TextSizeManager.currentSize.scale,
  fontWeight: FontWeight.w500,
  color: color ?? AppColors.neutral100,
);

TextStyle _body1Style({Color? color}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 15 * TextSizeManager.currentSize.scale,
  fontWeight: FontWeight.normal,
  color: color ?? AppColors.neutral100,
);

TextStyle _body2Style({Color? color}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14 * TextSizeManager.currentSize.scale,
  fontWeight: FontWeight.normal,
  color: color ?? AppColors.neutral100,
);

TextStyle _body2BoldStyle({Color? color}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14 * TextSizeManager.currentSize.scale,
  fontWeight: FontWeight.bold,
  color: color ?? AppColors.neutral100,
);

TextStyle _captionStyle({Color? color}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12 * TextSizeManager.currentSize.scale,
  fontWeight: FontWeight.normal,
  color: color ?? AppColors.neutral60, // Muted grey for captions
);

TextStyle _captionBoldStyle({Color? color}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12 * TextSizeManager.currentSize.scale,
  fontWeight: FontWeight.bold,
  color: color ?? AppColors.neutral100, // Bold captions for active tab
);

TextStyle _overlineStyle({Color? color}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 11 * TextSizeManager.currentSize.scale,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.5,
  color: color ?? AppColors.primary100, // Vibrant orange for overline tags/streak labels
);

extension AppFonts on Text {
  Text _applyStyle(TextStyle style) => Text(
    data ?? '',
    style: style,
    key: key,
    strutStyle: strutStyle,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaler: textScaler,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
  );

  Text display({Color? color}) => _applyStyle(_displayStyle(color: color));

  Text headline({Color? color}) => _applyStyle(_headlineStyle(color: color));

  Text subtitle1({Color? color}) => _applyStyle(_subtitle1Style(color: color));

  Text subtitle2({Color? color}) => _applyStyle(_subtitle2Style(color: color));

  Text body1({Color? color}) => _applyStyle(_body1Style(color: color));

  Text body2({Color? color}) => _applyStyle(_body2Style(color: color));

  Text body2Bold({Color? color}) => _applyStyle(_body2BoldStyle(color: color));

  Text caption({Color? color}) => _applyStyle(_captionStyle(color: color));

  Text captionBold({Color? color}) => _applyStyle(_captionBoldStyle(color: color));

  Text overline({Color? color}) => _applyStyle(_overlineStyle(color: color));
}