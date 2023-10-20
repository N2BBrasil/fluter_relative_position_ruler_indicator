import 'package:flutter/material.dart' '';

typedef RelativePositionRulerValueLabelFormatter = String Function(
  double value,
);

class RelativePositionRulerPainter extends CustomPainter {
  RelativePositionRulerPainter({
    required this.currentValue,
    required this.belowValue,
    required this.minNormalValue,
    required this.maxNormalValue,
    required this.aboveValue,
    required this.gradientColor,
    this.barHeight = 20.0,
    this.borderColor = Colors.black,
    this.aboveLabel = 'Acima',
    this.belowLabel = 'Abaixo',
    this.normalLabel = 'Normal',
    this.textStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black,
    ),
    this.valueLabelFormatter = _defaultRulerValueLabelFormatter,
  });

  final double barHeight;
  final double belowValue;
  final double minNormalValue;
  final double maxNormalValue;
  final double aboveValue;
  final double currentValue;
  final Gradient gradientColor;
  final Color borderColor;
  final String belowLabel;
  final String normalLabel;
  final String aboveLabel;
  final TextStyle textStyle;
  final RelativePositionRulerValueLabelFormatter valueLabelFormatter;

  static String _defaultRulerValueLabelFormatter(double value) {
    return value
        .toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)
        .replaceAll('.', ',');
  }

  @override
  void paint(Canvas canvas, Size size) {
    const startX = 0.0;
    final endX = size.width;
    final centerY = size.height / 2;
    final halfBarHeight = barHeight / 2;
    const belowPosition = startX;
    final normalStartPosition = startX +
        (minNormalValue - belowValue) /
            (aboveValue - belowValue) *
            (endX - startX);
    final normalEndPosition = startX +
        (maxNormalValue - belowValue) /
            (aboveValue - belowValue) *
            (endX - startX);
    final abovePosition = startX +
        (aboveValue - belowValue) / (aboveValue - belowValue) * (endX - startX);

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
    _drawXIndicator(canvas, startX, endX, centerY);

    final rulerLabelPainter = TextPainter(textDirection: TextDirection.ltr);
    _paintRulerLabel(
      painter: rulerLabelPainter,
      label: belowLabel,
      canvas: canvas,
      centerY: centerY,
      startX: belowPosition,
      endX: normalStartPosition,
    );

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

    _paintValueLabel(
      value: belowValue,
      painter: valueLabelPainter,
      canvas: canvas,
      centerY: centerY,
      x: belowPosition,
    );

    _paintValueLabel(
      value: minNormalValue,
      painter: valueLabelPainter,
      canvas: canvas,
      centerY: centerY,
      x: normalStartPosition,
    );

    _paintValueLabel(
      value: maxNormalValue,
      painter: valueLabelPainter,
      canvas: canvas,
      centerY: centerY,
      x: normalEndPosition,
    );

    _paintValueLabel(
      value: aboveValue,
      painter: valueLabelPainter,
      canvas: canvas,
      centerY: centerY,
      x: abovePosition,
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
    required double x,
  }) {
    final label = value.format()!;
    painter.text = TextSpan(
      text: label,
      style: textStyle,
    );
    painter.layout(maxWidth: 30);
    painter.paint(
      canvas,
      Offset(
        x - label.length * 3,
        centerY + (barHeight / 2) + (textStyle.fontSize! / 2),
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
    final borderPaint = Paint()
      ..color = borderColor
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

    canvas.drawRRect(
      RRect.fromLTRBR(
        startX,
        centerY - halfBarHeight,
        endX,
        centerY + halfBarHeight,
        radius,
      ),
      Paint()
        ..shader = gradientColor.createShader(
          Rect.fromPoints(
            Offset.zero,
            Offset(size.width, 0),
          ),
        ),
    );

    final separatorPaint = Paint()
      ..color = borderColor
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
    final halfBarHeight = barHeight / 2;
    final xPaint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    final xPosition = startX +
        (currentValue - belowValue) /
            (aboveValue - belowValue) *
            (endX - startX);

    final trianglePath = Path();
    const triangleHeight = 13.0;
    const halfBase = triangleHeight / 2;
    trianglePath.moveTo(
      xPosition,
      centerY - halfBarHeight + 10,
    );
    trianglePath.lineTo(
      xPosition + halfBase,
      centerY - triangleHeight - halfBarHeight + 10,
    );
    trianglePath.lineTo(
      xPosition - halfBase,
      centerY - triangleHeight - halfBarHeight + 10,
    );
    trianglePath.lineTo(
      xPosition,
      centerY - halfBarHeight + 10,
    );
    canvas.drawPath(trianglePath, xPaint);
    canvas.drawLine(
      Offset(xPosition, centerY - halfBarHeight),
      Offset(xPosition, centerY + halfBarHeight - 2),
      xPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
