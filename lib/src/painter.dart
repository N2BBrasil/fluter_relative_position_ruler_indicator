import 'package:flutter/material.dart' '';
import 'package:relative_position_ruler_indicator/src/indicator.dart';

class RelativePositionRulerPainter extends CustomPainter {
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
    this.allowBellowBar = true,
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
  final bool allowBellowBar;
  final RelativePositionRulerValueLabelFormatter valueLabelFormatter;

  @override
  void paint(Canvas canvas, Size size) {
    const startX = 0.0;
    final endX = size.width;
    final centerY = size.height / 2;
    final halfBarHeight = rulerHeight / 2;
    const belowPosition = startX;
    double normalStartPosition =
        startX + (minNormalValue - belowValue) / (aboveValue - belowValue) * (endX - startX);
    double normalEndPosition =
        startX + (maxNormalValue - belowValue) / (aboveValue - belowValue) * (endX - startX);
    double abovePosition =
        startX + (aboveValue - belowValue) / (aboveValue - belowValue) * (endX - startX);

    if (normalStartPosition.isNaN) normalStartPosition = endX / 3;
    if (normalEndPosition.isNaN) normalEndPosition = (endX / 3) * 2;
    if (abovePosition.isNaN) abovePosition = endX;

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
    if (allowCurrentValueIndicator) {
      _drawXIndicator(canvas, startX, endX, centerY);
    }

    final rulerLabelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    );

    if (allowBellowBar) {
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

    final valueLabelPainter = TextPainter(textDirection: TextDirection.ltr);

    if (allowBellowBar) {
      _paintValueLabel(
        value: belowValue,
        painter: valueLabelPainter,
        canvas: canvas,
        centerY: centerY,
        x: (_) => startX,
      );
    }

    _paintValueLabel(
      value: minNormalValue,
      painter: valueLabelPainter,
      canvas: canvas,
      centerY: centerY,
      x: (width) {
        if (allowBellowBar) {
          return normalStartPosition - (width / 2);
        }

        return startX;
      },
    );

    _paintValueLabel(
      value: maxNormalValue,
      painter: valueLabelPainter,
      canvas: canvas,
      centerY: centerY,
      x: (width) => normalEndPosition - (width / 2),
    );

    _paintValueLabel(
      value: aboveValue,
      painter: valueLabelPainter,
      canvas: canvas,
      centerY: centerY,
      x: (width) => abovePosition - width,
    );
  }

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

  void _paintValueLabel({
    required TextPainter painter,
    required double value,
    required Canvas canvas,
    required double centerY,
    required Function(double painterWidth) x,
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
    const radius = Radius.circular(20.0);

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

    final separatorPaint = Paint()
      ..color = borderColor ?? Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(normalStartPosition, centerY - halfBarHeight),
      Offset(normalStartPosition, centerY + halfBarHeight),
      separatorPaint,
    );

    canvas.drawLine(
      Offset(normalEndPosition, centerY - halfBarHeight),
      Offset(normalEndPosition, centerY + halfBarHeight),
      separatorPaint,
    );
  }

  void _drawXIndicator(
    Canvas canvas,
    double startX,
    double endX,
    double centerY,
  ) {
    final halfBarHeight = rulerHeight / 2;

    double xPosition =
        startX + (currentValue - belowValue) / (aboveValue - belowValue) * (endX - startX);

    if (xPosition < 8) xPosition = 8;
    if (xPosition > (endX - 8)) xPosition = endX - 8;

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

    canvas.drawLine(
      Offset(xPosition, centerY - halfBarHeight),
      Offset(xPosition, centerY + halfBarHeight - 1),
      Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0,
    );

    canvas.drawPath(trianglePath, Paint()..color = Colors.black);
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
