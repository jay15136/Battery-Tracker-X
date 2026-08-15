import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/icon_color.dart';
import '../domain/icon_definition.dart';

class IconVisual extends StatelessWidget {
  const IconVisual({
    required this.definition,
    required this.color,
    required this.fallbackDefinition,
    required this.applicationSupportRoot,
    this.size = 48,
    super.key,
  });

  final IconDefinition definition;
  final IconColor color;
  final IconDefinition fallbackDefinition;
  final Uri applicationSupportRoot;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (definition.source == IconSource.custom) {
      final file =
          File.fromUri(applicationSupportRoot.resolve(definition.location));
      if (!file.existsSync()) {
        return _fallback();
      }
      return _managedFile(file);
    }

    return _svgAsset(definition);
  }

  Widget _managedFile(File file) {
    return switch (definition.fileType) {
      IconFileType.svg => SvgPicture.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.contain,
          semanticsLabel: definition.displayName,
          colorFilter: _colorFilter(definition),
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      IconFileType.png => Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.contain,
          semanticLabel: definition.displayName,
          color: definition.supportsColor ? Color(color.argbValue) : null,
          colorBlendMode: definition.supportsColor ? BlendMode.srcIn : null,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
    };
  }

  Widget _svgAsset(IconDefinition icon) {
    return SvgPicture.asset(
      icon.location,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: icon.displayName,
      colorFilter: _colorFilter(icon),
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  ColorFilter? _colorFilter(IconDefinition icon) => icon.supportsColor
      ? ColorFilter.mode(Color(color.argbValue), BlendMode.srcIn)
      : null;

  Widget _fallback() {
    if (definition.source == IconSource.builtin &&
        definition.key == fallbackDefinition.key) {
      return Icon(
        Icons.battery_unknown_outlined,
        size: size,
        color: Color(color.argbValue),
        semanticLabel: fallbackDefinition.displayName,
      );
    }
    return IconVisual(
      definition: fallbackDefinition,
      color: color,
      fallbackDefinition: fallbackDefinition,
      applicationSupportRoot: applicationSupportRoot,
      size: size,
    );
  }
}
