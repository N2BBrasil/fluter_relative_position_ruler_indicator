import 'package:flutter/material.dart';
import 'package:relative_position_ruler_indicator/src/painter.dart';

typedef RelativePositionRulerValueLabelFormatter = String Function(
  double value,
);

class RelativePositionRulerPainterValue {
  RelativePositionRulerPainterValue({
    required this.minNormal,
    required this.maxNormal,
    required this.current,
    double? below,
    double? above,
  })  : below = below ?? minNormal * .7,
        above = above ?? maxNormal * 1.3;

  final double minNormal;
  final double current;
  final double maxNormal;
  final double below;
  final double above;
}

class RelativePositionRulerIndicator extends StatelessWidget {
  const RelativePositionRulerIndicator({
    super.key,
    required this.size,
    required this.value,
    this.allowCurrentValueIndicator = true,
    this.aboveLabel = 'Acima',
    this.belowLabel = 'Abaixo',
    this.normalLabel = 'Normal',
    this.rulerHeight = 20.0,
    this.gradient,
    this.borderColor,
    this.labelStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black,
    ),
    this.valueLabelFormatter = _defaultRulerValueLabelFormatter,
    this.allowBelowBar = true,
    this.allowRepaint = false,
  });

  final Size size;
  final RelativePositionRulerPainterValue value;
  final bool allowCurrentValueIndicator;
  final double rulerHeight;
  final String belowLabel;
  final String normalLabel;
  final String aboveLabel;
  final TextStyle labelStyle;
  final bool allowRepaint;
  final Gradient? gradient;
  final Color? borderColor;
  final RelativePositionRulerValueLabelFormatter valueLabelFormatter;
  final bool allowBelowBar;

  static String _defaultRulerValueLabelFormatter(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: RelativePositionRulerPainter(
        aboveLabel: aboveLabel,
        aboveValue: value.above,
        belowLabel: belowLabel,
        belowValue: value.below,
        normalLabel: normalLabel,
        currentValue: value.current,
        minNormalValue: value.minNormal,
        maxNormalValue: value.maxNormal,
        rulerHeight: rulerHeight,
        allowRepaint: allowRepaint,
        textStyle: labelStyle,
        gradientColor: gradient,
        borderColor: borderColor,
        valueLabelFormatter: valueLabelFormatter,
        allowCurrentValueIndicator: allowCurrentValueIndicator,
        allowBelowBar: allowBelowBar,
      ),
    );
  }
}
