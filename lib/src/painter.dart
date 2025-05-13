import 'package:flutter/material.dart';
import 'package:relative_position_ruler_indicator/src/indicator.dart';

/// Typedef for a function that calculates the x position for value labels.
typedef XPositionCalculator = double Function(double painterWidth);

class RelativePositionRulerPainter extends CustomPainter {
  /// Creates a custom painter for the relative position ruler.
  RelativePositionRulerPainter({
    required this.currentValue,
    required this.belowValue,
    required this.minNormalValue,
    required this.maxNormalValue,
    required this.aboveValue,
    required this.rulerHeight,
    required this.aboveLabel,
    required this.belowLabel,
    required this.normalLabel,
    required this.textStyle,
    required this.allowRepaint,
    required this.valueLabelFormatter,
    required this.allowCurrentValueIndicator,
    this.allowBelowBar = true,
    this.borderColor,
    this.gradientColor,
  });

  final double rulerHeight;
  final double belowValue;
  final double minNormalValue;
  final double maxNormalValue;
  final double aboveValue;
  final double currentValue;
  final Gradient? gradientColor;
  final Color? borderColor;
  final String belowLabel;
  final String normalLabel;
  final String aboveLabel;
  final TextStyle textStyle;
  final bool allowRepaint;
  final bool allowCurrentValueIndicator;
  final bool allowBelowBar;
  final RelativePositionRulerValueLabelFormatter valueLabelFormatter;

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the start and end positions of the ruler.
    const startX = 0.0;
    final endX = size.width;
    final centerY = size.height / 2;
    final halfBarHeight = rulerHeight / 2;
    const belowPosition = startX;

    // Calculate the positions for the normal and above sections.
    final positions = _calculateSectionPositions(
      startX: startX,
      endX: endX,
      belowValue: belowValue,
      minNormalValue: minNormalValue,
      maxNormalValue: maxNormalValue,
      aboveValue: aboveValue,
    );
    double normalStartPosition = positions[0];
    double normalEndPosition = positions[1];
    double abovePosition = positions[2];

    // Draw the main ruler bar, border, gradient, and separators.
    _drawRuler(
      canvas,
      size,
      startX,
      endX,
      centerY,
      halfBarHeight,
      normalStartPosition,
      normalEndPosition,
    );

    // Draw the current value indicator (triangle and line) if enabled.
    if (allowCurrentValueIndicator) {
      _drawXIndicator(canvas, startX, endX, centerY);
    }

    // Prepare a text painter for labels.
    final rulerLabelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    );

    // Draw section labels (BAIXO, NORMAL, ALTO)
    if (allowBelowBar) {
      _paintRulerLabel(
        painter: rulerLabelPainter,
        label: belowLabel,
        canvas: canvas,
        centerY: centerY,
        startX: belowPosition,
        endX: normalStartPosition,
      );
    }

    _paintRulerLabel(
      painter: rulerLabelPainter,
      label: normalLabel,
      canvas: canvas,
      centerY: centerY,
      startX: normalStartPosition,
      endX: normalEndPosition,
    );

    _paintRulerLabel(
      painter: rulerLabelPainter,
      label: aboveLabel,
      canvas: canvas,
      centerY: centerY,
      startX: normalEndPosition,
      endX: abovePosition,
    );

    // Prepare a text painter for value labels.
    final valueLabelPainter = TextPainter(textDirection: TextDirection.ltr);

    if (allowBelowBar) {
      _paintValueLabel(
        value: minNormalValue,
        painter: valueLabelPainter,
        canvas: canvas,
        centerY: centerY,
        x: (width) {
          if (allowBelowBar) {
            return normalStartPosition - (width / 2);
          }
          return startX;
        },
      );
    }

    _paintValueLabel(
      value: maxNormalValue,
      painter: valueLabelPainter,
      canvas: canvas,
      centerY: centerY,
      x: (width) => normalEndPosition - (width / 2),
    );
  }

  /// Calculates the positions for the normal and above sections on the ruler.
  List<double> _calculateSectionPositions({
    required double startX,
    required double endX,
    required double belowValue,
    required double minNormalValue,
    required double maxNormalValue,
    required double aboveValue,
  }) {
    double normalStartPosition = startX + (minNormalValue - belowValue) / (aboveValue - belowValue) * (endX - startX);
    double normalEndPosition = startX + (maxNormalValue - belowValue) / (aboveValue - belowValue) * (endX - startX);
    double abovePosition = startX + (aboveValue - belowValue) / (aboveValue - belowValue) * (endX - startX);

    // Fallbacks in case of NaN values
    if (normalStartPosition.isNaN) normalStartPosition = endX / 3;
    if (normalEndPosition.isNaN) normalEndPosition = (endX / 3) * 2;
    if (abovePosition.isNaN) abovePosition = endX;

    return [normalStartPosition, normalEndPosition, abovePosition];
  }

  /// Paints a section label (e.g., BAIXO, NORMAL, ALTO) centered in its section.
  void _paintRulerLabel({
    required TextPainter painter,
    required String label,
    required Canvas canvas,
    required double centerY,
    required double startX,
    required double endX,
  }) {
    painter.text = TextSpan(
      text: label,
      style: textStyle,
    );
    painter.layout(maxWidth: endX - startX);

    painter.paint(
      canvas,
      Offset(
        startX + (endX - startX - painter.width) / 2,
        centerY - (textStyle.fontSize! / 2) - 1,
      ),
    );
  }

  /// Paints a value label (e.g., 0) at a calculated x position below the ruler.
  void _paintValueLabel({
    required TextPainter painter,
    required double value,
    required Canvas canvas,
    required double centerY,
    required XPositionCalculator x,
  }) {
    final label = valueLabelFormatter(value);
    painter.text = TextSpan(text: label, style: textStyle);
    painter.layout(maxWidth: label.length * 10);
    painter.paint(
      canvas,
      Offset(
        x(painter.width),
        centerY + (rulerHeight / 2) + (textStyle.fontSize! / 2),
      ),
    );
  }

  /// Draws the main ruler bar, border, gradient, and section separators.
  void _drawRuler(
    Canvas canvas,
    Size size,
    double startX,
    double endX,
    double centerY,
    double halfBarHeight,
    double normalStartPosition,
    double normalEndPosition,
  ) {
    // Rounded corners for the ruler bar.
    const radius = Radius.circular(20.0);

    // Draw border if specified.
    if (borderColor != null) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRRect(
        RRect.fromLTRBR(
          startX,
          centerY - halfBarHeight,
          endX,
          centerY + halfBarHeight,
          radius,
        ),
        borderPaint,
      );
    }

    // Draw gradient fill if specified.
    if (gradientColor != null) {
      canvas.drawRRect(
        RRect.fromLTRBR(
          startX,
          centerY - halfBarHeight,
          endX,
          centerY + halfBarHeight,
          radius,
        ),
        Paint()
          ..shader = gradientColor!.createShader(
            Rect.fromPoints(
              Offset.zero,
              Offset(size.width, 0),
            ),
          ),
      );
    }

    // Draw section separators (vertical lines).
    final separatorPaint = Paint()
      ..color = borderColor ?? Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    // Draw the separator for the below section.
    if (allowBelowBar) {
      canvas.drawLine(
        Offset(normalStartPosition, centerY - halfBarHeight),
        Offset(normalStartPosition, centerY + halfBarHeight),
        separatorPaint,
      );
    }

    // Draw the separator for the normal section.
    canvas.drawLine(
      Offset(normalEndPosition, centerY - halfBarHeight),
      Offset(normalEndPosition, centerY + halfBarHeight),
      separatorPaint,
    );
  }

  /// Draws the current value indicator (triangle and line) above the ruler.
  void _drawXIndicator(
    Canvas canvas,
    double startX,
    double endX,
    double centerY,
  ) {
    final halfBarHeight = rulerHeight / 2;

    // Calculate the x position for the indicator.
    double xPosition = startX + (currentValue - belowValue) / (aboveValue - belowValue) * (endX - startX);

    // Clamp the indicator position to avoid drawing outside the ruler.
    if (xPosition < 8) xPosition = 8; // 8 px padding from the left
    if (xPosition > (endX - 8)) xPosition = endX - 8; // 8 px padding from the right

    // Draw the triangle indicator.
    var trianglePath = Path();
    const triangleHeight = 10.0;
    const halfBase = triangleHeight / 2;

    trianglePath
      ..moveTo(
        xPosition,
        centerY - halfBarHeight + (triangleHeight / 2),
      )
      ..lineTo(
        xPosition + halfBase,
        centerY - triangleHeight - halfBarHeight + triangleHeight,
      )
      ..lineTo(
        xPosition - halfBase,
        centerY - triangleHeight - halfBarHeight + triangleHeight,
      )
      ..close();

    // Draw the vertical line for the indicator.
    canvas.drawLine(
      Offset(xPosition, centerY - halfBarHeight),
      Offset(xPosition, centerY + halfBarHeight - 1),
      Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0,
    );

    // Draw the filled triangle.
    canvas.drawPath(trianglePath, Paint()..color = Colors.black);
    // Draw the triangle border for emphasis.
    canvas.drawPath(
      trianglePath,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => allowRepaint;
}
