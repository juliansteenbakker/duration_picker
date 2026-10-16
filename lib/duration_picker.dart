import 'dart:math' as math;

import 'package:duration_picker/localization/localization.dart';
import 'package:duration_picker/src/duration_picker_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

export 'src/duration_picker_theme.dart';

const Duration _kDialAnimateDuration = Duration(milliseconds: 200);

const double _kDurationPickerWidthPortrait = 328.0;
const double _kDurationPickerWidthLandscape = 512.0;

const double _kDurationPickerHeightPortrait = 380.0;
const double _kDurationPickerHeightLandscape = 304.0;

const double _kTwoPi = 2 * math.pi; // 360 degrees in radians
const double _kPiByTwo = math.pi / 2; // 90 degrees in radians

const double _kCircleTop = _kPiByTwo;

class _DialPainter extends CustomPainter {
  const _DialPainter({
    required this.labels,
    required this.backgroundColor,
    required this.accentColor,
    required this.valueTextStyle,
    required this.scaleValueText,
    required this.unitTextStyle,
    required this.baseUnitLabel,
    required this.secondaryUnitLabel,
    required this.theta,
    required this.baseUnitMultiplier,
    required this.baseUnitHand,
  });

  final List<TextPainter> labels;
  final Color backgroundColor;
  final Color accentColor;
  final TextStyle valueTextStyle;
  final bool scaleValueText;
  final TextStyle unitTextStyle;
  final String baseUnitLabel;
  final String secondaryUnitLabel;
  final double theta;

  final int baseUnitMultiplier;
  final int baseUnitHand;

  @override
  void paint(Canvas canvas, Size size) {
    const epsilon = .001;
    const sweep = _kTwoPi - epsilon;
    const startAngle = -math.pi / 2.0;

    final radius = size.shortestSide / 2.0;
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final centerPoint = center;

    final pctTheta = (0.25 - (theta % _kTwoPi) / _kTwoPi) % 1.0;

    // The ring is stroked rather than filled, so whatever is behind the dial
    // shows through in the middle.
    final ringWidth = radius * 0.12;
    final ringRadius = radius - ringWidth / 2;
    Paint ringPaint(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..color = color;

    // Draw the background outer ring
    canvas.drawCircle(centerPoint, ringRadius, ringPaint(backgroundColor));

    // Draw a translucent ring for every secondary unit
    for (var i = 0; i < baseUnitMultiplier; i = i + 1) {
      canvas.drawCircle(
        centerPoint,
        ringRadius,
        ringPaint(accentColor.withValues(alpha: (i == 0) ? 0.3 : 0.1)),
      );
    }

    // Get the offset point for an angle value of theta, and a distance of _radius
    Offset getOffsetForTheta(double theta, double radius) {
      return center +
          Offset(radius * math.cos(theta), -radius * math.sin(theta));
    }

    // Draw the handle that is used to drag and to indicate the position around the circle
    final handlePaint = Paint()..color = accentColor;
    final handlePoint = getOffsetForTheta(theta, radius - 10.0);
    canvas.drawCircle(handlePoint, 20.0, handlePaint);

    // Draw the Text in the center of the circle which displays the duration string
    final secondaryUnits = (baseUnitMultiplier == 0)
        ? ''
        : '$baseUnitMultiplier$secondaryUnitLabel ';
    final baseUnits = '$baseUnitHand';

    final textDurationValuePainter = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '$secondaryUnits$baseUnits',
        style: scaleValueText
            ? valueTextStyle.copyWith(fontSize: size.shortestSide * 0.15)
            : valueTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final middleForValueText = Offset(
      centerPoint.dx - (textDurationValuePainter.width / 2),
      centerPoint.dy - textDurationValuePainter.height / 2,
    );
    textDurationValuePainter.paint(canvas, middleForValueText);

    final textMinPainter = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: baseUnitLabel,
        style: unitTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textMinPainter.paint(
      canvas,
      Offset(
        centerPoint.dx - (textMinPainter.width / 2),
        centerPoint.dy +
            (textDurationValuePainter.height / 2) -
            textMinPainter.height / 2,
      ),
    );

    // Draw an arc around the circle for the amount of the circle that has elapsed.
    final elapsedPainter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withValues(alpha: 0.3)
      ..isAntiAlias = true
      ..strokeWidth = ringWidth;

    canvas.drawArc(
      Rect.fromCircle(center: centerPoint, radius: ringRadius),
      startAngle,
      sweep * pctTheta,
      false,
      elapsedPainter,
    );

    // Paint the labels (the minute strings)
    void paintLabels(List<TextPainter> labels) {
      final labelThetaIncrement = -_kTwoPi / labels.length;
      var labelTheta = _kPiByTwo;

      for (final label in labels) {
        final labelOffset = Offset(-label.width / 2.0, -label.height / 2.0);

        label.paint(
          canvas,
          getOffsetForTheta(labelTheta, radius - 40.0) + labelOffset,
        );

        labelTheta += labelThetaIncrement;
      }
    }

    paintLabels(labels);
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.valueTextStyle != valueTextStyle ||
        oldDelegate.scaleValueText != scaleValueText ||
        oldDelegate.unitTextStyle != unitTextStyle ||
        oldDelegate.baseUnitLabel != baseUnitLabel ||
        oldDelegate.secondaryUnitLabel != secondaryUnitLabel ||
        oldDelegate.baseUnitMultiplier != baseUnitMultiplier ||
        oldDelegate.baseUnitHand != baseUnitHand ||
        oldDelegate.theta != theta;
  }
}

class _Dial extends StatefulWidget {
  const _Dial({
    required this.duration,
    required this.onChanged,
    this.baseUnit = BaseUnit.minute,
    this.upperBound,
    this.lowerBound,
    this.theme,
  });

  final Duration duration;
  final ValueChanged<Duration> onChanged;
  final BaseUnit baseUnit;
  final Duration? upperBound;
  final Duration? lowerBound;
  final DurationPickerThemeData? theme;

  @override
  _DialState createState() => _DialState();
}

class _DialState extends State<_Dial> with SingleTickerProviderStateMixin {
  double? _upperBoundAngle;
  double? _lowerBoundAngel;

  @override
  void initState() {
    super.initState();
    assert(
      widget.lowerBound == null ||
          widget.upperBound == null ||
          widget.lowerBound! <= widget.upperBound!,
      'lowerBound must not be greater than upperBound.',
    );
    _thetaController = AnimationController(
      duration: _kDialAnimateDuration,
      vsync: this,
    );
    _thetaTween = Tween<double>(
      begin: _getThetaForDuration(widget.duration, widget.baseUnit),
      end: 0,
      //end: _getThetaForDuration(widget.duration, widget.baseUnit),
    );
    _theta = _thetaTween.animate(
      CurvedAnimation(parent: _thetaController, curve: Curves.fastOutSlowIn),
    )..addListener(() => setState(() {}));
    _thetaController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _secondaryUnitValue = _secondaryUnitHand();
        _baseUnitValue = _baseUnitHand();
        setState(() {});
      }
    });
    _turningAngle = _kPiByTwo - _turningAngleFactor(null) * _kTwoPi;
    _secondaryUnitValue = _secondaryUnitHand();
    _baseUnitValue = _baseUnitHand();
    _updateBoundAngles();
  }

  @override
  void didUpdateWidget(_Dial oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateBoundAngles();
    if (!_dragging) {
      _syncTurningAngle();
    }
  }

  void _updateBoundAngles() {
    _upperBoundAngle = widget.upperBound != null
        ? _kPiByTwo - _turningAngleFactor(widget.upperBound) * _kTwoPi
        : null;
    _lowerBoundAngel = widget.lowerBound != null
        ? _kPiByTwo - _turningAngleFactor(widget.lowerBound) * _kTwoPi
        : null;
  }

  // The turning angle keeps the fraction of a unit between updates, so it is
  // only reset when the parent passes a duration it doesn't round down to.
  void _syncTurningAngle() {
    if (_angleToDuration(_turningAngle) != widget.duration) {
      _turningAngle = _kPiByTwo - _turningAngleFactor(null) * _kTwoPi;
      // A pan measures its turn from the hand's angle, so move the hand too.
      final theta = _getThetaForDuration(widget.duration, widget.baseUnit);
      _thetaTween
        ..begin = theta
        ..end = theta;
    }
  }

  late ThemeData themeData;
  MaterialLocalizations? localizations;
  MediaQueryData? media;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMediaQuery(context));
    themeData = Theme.of(context);
    localizations = MaterialLocalizations.of(context);
    media = MediaQuery.of(context);
  }

  @override
  void dispose() {
    _thetaController.dispose();
    super.dispose();
  }

  late Tween<double> _thetaTween;
  late Animation<double> _theta;
  late AnimationController _thetaController;

  int _secondaryUnitValue = 0;
  bool _dragging = false;
  int _baseUnitValue = 0;
  double _turningAngle = 0.0;

  static double _nearest(double target, double a, double b) {
    return ((target - a).abs() < (target - b).abs()) ? a : b;
  }

  void _animateTo(double targetTheta) {
    final currentTheta = _theta.value;
    var beginTheta =
        _nearest(targetTheta, currentTheta, currentTheta + _kTwoPi);
    beginTheta = _nearest(targetTheta, beginTheta, currentTheta - _kTwoPi);
    _thetaTween
      ..begin = beginTheta
      ..end = targetTheta;
    _thetaController
      ..value = 0.0
      ..forward();
  }

  // Converts the duration to the chosen base unit. For example, for base unit minutes, this gets the number of minutes
  // in the duration
  int _getDurationInBaseUnits(Duration duration, BaseUnit baseUnit) {
    switch (baseUnit) {
      case BaseUnit.millisecond:
        return duration.inMilliseconds;
      case BaseUnit.second:
        return duration.inSeconds;
      case BaseUnit.minute:
        return duration.inMinutes;
      case BaseUnit.hour:
        return duration.inHours;
    }
  }

  // Converts the duration to the chosen secondary unit. For example, for base unit minutes, this gets the number
  // of hours in the duration
  int _getDurationInSecondaryUnits(Duration duration, BaseUnit baseUnit) {
    switch (baseUnit) {
      case BaseUnit.millisecond:
        return duration.inSeconds;
      case BaseUnit.second:
        return duration.inMinutes;
      case BaseUnit.minute:
        return duration.inHours;
      case BaseUnit.hour:
        return duration.inDays;
    }
  }

  // Gets the relation between the base unit and the secondary unit, which is the unit just greater than the base unit.
  // For example if the base unit is second, it will get the number of seconds in a minute
  int _getBaseUnitToSecondaryUnitFactor(BaseUnit baseUnit) {
    switch (baseUnit) {
      case BaseUnit.millisecond:
        return Duration.millisecondsPerSecond;
      case BaseUnit.second:
        return Duration.secondsPerMinute;
      case BaseUnit.minute:
        return Duration.minutesPerHour;
      case BaseUnit.hour:
        return Duration.hoursPerDay;
    }
  }

  double _getThetaForDuration(Duration duration, BaseUnit baseUnit) {
    final int baseUnits = _getDurationInBaseUnits(duration, baseUnit);
    final int baseToSecondaryFactor =
        _getBaseUnitToSecondaryUnitFactor(baseUnit);

    return (_kPiByTwo -
            (baseUnits % baseToSecondaryFactor) /
                baseToSecondaryFactor.toDouble() *
                _kTwoPi) %
        _kTwoPi;
  }

  double _turningAngleFactor(Duration? duration) {
    return _getDurationInBaseUnits(
          duration ?? widget.duration,
          widget.baseUnit,
        ) /
        _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
  }

  Duration _notifyOnChangedIfNeeded() {
    _secondaryUnitValue = _secondaryUnitHand();
    _baseUnitValue = _baseUnitHand();
    final d = _angleToDuration(_turningAngle);
    widget.onChanged(d);

    return d;
  }

  double _angleForPosition() {
    final offset = _position! - _center!;
    return (math.atan2(offset.dx, offset.dy) - _kPiByTwo) % _kTwoPi;
  }

  void _updateThetaForPan() {
    setState(() {
      final angle = _angleForPosition();

      // Stop accidental abrupt pans from making the dial seem like it starts from 1h.
      // (happens when wanting to pan from 0 clockwise, but when doing so quickly, one actually pans from before 0 (e.g. setting the duration to 59mins, and then crossing 0, which would then mean 1h 1min).
      // Only a move from the first quarter across the top into the last
      // quarter is blocked, so moves past the 15 minute mark still work.
      if (_secondaryUnitValue == 0 &&
          _theta.value <= _kCircleTop &&
          angle > _kCircleTop &&
          angle <= math.pi) {
        return;
      }

      _thetaTween
        ..begin = angle
        ..end = angle;
    });
  }

  Offset? _position;
  Offset? _center;

  void _handlePanStart(DragStartDetails details) {
    assert(!_dragging);
    _dragging = true;
    final box = context.findRenderObject() as RenderBox?;
    _position = box?.globalToLocal(details.globalPosition);
    _center = box?.size.center(Offset.zero);

    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final oldTheta = _theta.value;
    _position = _position! + details.delta;
    // _position! += details.delta;
    _updateThetaForPan();
    final newTheta = _theta.value;

    _updateTurningAngle(oldTheta, newTheta);
    _notifyOnChangedIfNeeded();
  }

  int _secondaryUnitHand() {
    return _getDurationInSecondaryUnits(widget.duration, widget.baseUnit);
  }

  int _baseUnitHand() {
    // Result is in [0; num base units in secondary unit - 1], even if overall time is >= 1 secondary unit
    return _getDurationInBaseUnits(widget.duration, widget.baseUnit) %
        _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
  }

  Duration _angleToDuration(double angle) {
    return _baseUnitToDuration(_angleToBaseUnit(angle));
  }

  Duration _baseUnitToDuration(double baseUnitValue) {
    final int unitFactor = _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
    // Angles carry floating point error, so 5 minutes can come out as
    // 4.9999 and truncate to 4.
    final units = (baseUnitValue + 1e-9).floorToDouble();

    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        return Duration(
          seconds: units ~/ unitFactor,
          milliseconds: (units % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.second:
        return Duration(
          minutes: units ~/ unitFactor,
          seconds: (units % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.minute:
        return Duration(
          hours: units ~/ unitFactor,
          minutes: (units % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.hour:
        return Duration(
          days: units ~/ unitFactor,
          hours: (units % unitFactor.toDouble()).toInt(),
        );
    }
  }

  String _durationToBaseUnitString(Duration duration) {
    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        return duration.inMilliseconds.toString();
      case BaseUnit.second:
        return duration.inSeconds.toString();
      case BaseUnit.minute:
        return duration.inMinutes.toString();
      case BaseUnit.hour:
        return duration.inHours.toString();
    }
  }

  double _angleToBaseUnit(double angle) {
    // Coordinate transformation from mathematical COS to dial COS
    final dialAngle = _kPiByTwo - angle;

    // Turn dial angle into minutes, may go beyond 60 minutes (multiple turns)
    return dialAngle /
        _kTwoPi *
        _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
  }

  void _updateTurningAngle(double oldTheta, double newTheta) {
    // Register any angle by which the user has turned the dial.
    //
    // The resulting turning angle fully captures the state of the dial,
    // including multiple turns (= full hours). The [_turningAngle] is in
    // mathematical coordinate system, i.e. 3-o-clock position being zero, and
    // increasing counter clock wise.

    // From positive to negative (in mathematical COS)
    if (newTheta > 1.5 * math.pi && oldTheta < 0.5 * math.pi) {
      _turningAngle = _turningAngle - ((_kTwoPi - newTheta) + oldTheta);
    }
    // From negative to positive (in mathematical COS)
    else if (newTheta < 0.5 * math.pi && oldTheta > 1.5 * math.pi) {
      _turningAngle = _turningAngle + ((_kTwoPi - oldTheta) + newTheta);
    } else {
      _turningAngle = _turningAngle + (newTheta - oldTheta);
    }

    _clampTurningAngle();
  }

  void _clampTurningAngle() {
    // Without a lower bound, zero is the limit, so a fast pan back across
    // the top can't produce a negative duration.
    final lowerBoundAngle = _lowerBoundAngel ?? _kPiByTwo;
    final upperBoundAngle = _upperBoundAngle;
    if (upperBoundAngle != null && _turningAngle < upperBoundAngle) {
      _turningAngle = upperBoundAngle;
    } else if (_turningAngle > lowerBoundAngle) {
      _turningAngle = lowerBoundAngle;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging);
    _dragging = false;
    // Outside changes are ignored while dragging, so the dial doesn't stall
    // when the parent rounds the value; pick up the final one here.
    _syncTurningAngle();
    _position = null;
    _center = null;
    _animateTo(_getThetaForDuration(widget.duration, widget.baseUnit));
  }

  void _handleTapUp(TapUpDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    _position = box?.globalToLocal(details.globalPosition);
    _center = box?.size.center(Offset.zero);

    // A tap sets the position within the current turn and keeps the number
    // of full turns, like picking minutes on a clock without changing hours.
    final turns = (_angleToBaseUnit(_turningAngle) + 1e-9) ~/
        _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
    final turnFraction =
        ((_kPiByTwo - _angleForPosition()) % _kTwoPi) / _kTwoPi;
    _turningAngle = _kPiByTwo - (turns + turnFraction) * _kTwoPi;
    _clampTurningAngle();

    final duration = _notifyOnChangedIfNeeded();
    _animateTo(_getThetaForDuration(duration, widget.baseUnit));
    _dragging = false;
    _position = null;
    _center = null;
  }

  List<TextPainter> _buildBaseUnitLabels(TextStyle style) {
    var baseUnitMarkerValues = <Duration>[];

    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        const int interval = 100;
        const int factor = Duration.millisecondsPerSecond;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(milliseconds: index * interval),
        );
      case BaseUnit.second:
        const int interval = 5;
        const int factor = Duration.secondsPerMinute;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(seconds: index * interval),
        );
      case BaseUnit.minute:
        const int interval = 5;
        const int factor = Duration.minutesPerHour;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(minutes: index * interval),
        );
      case BaseUnit.hour:
        const int interval = 3;
        const int factor = Duration.hoursPerDay;
        const int length = factor ~/ interval;
        baseUnitMarkerValues =
            List.generate(length, (index) => Duration(hours: index * interval));
    }

    final labels = <TextPainter>[];
    for (final duration in baseUnitMarkerValues) {
      final painter = TextPainter(
        text: TextSpan(style: style, text: _durationToBaseUnitString(duration)),
        textDirection: TextDirection.ltr,
      )..layout();
      labels.add(painter);
    }
    return labels;
  }

  Color _defaultDialBackground() {
    if (themeData.useMaterial3) {
      return themeData.colorScheme.surfaceContainerHighest;
    }
    // Material 2 schemes set surfaceContainerHighest to surface, which would
    // hide the ring against the dialog, so keep the 1.x colors there.
    return themeData.brightness == Brightness.light
        ? Colors.grey[200]!
        : themeData.colorScheme.surface;
  }

  String _baseUnitLabel(DurationPickerLocalizations localization) {
    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        return localization.baseUnitMillisecond;
      case BaseUnit.second:
        return localization.baseUnitSecond;
      case BaseUnit.minute:
        return localization.baseUnitMinute;
      case BaseUnit.hour:
        return localization.baseUnitHour;
    }
  }

  String _secondaryUnitLabel(DurationPickerLocalizations localization) {
    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        return localization.secondaryUnitMillisecond;
      case BaseUnit.second:
        return localization.secondaryUnitSecond;
      case BaseUnit.minute:
        return localization.secondaryUnitMinute;
      case BaseUnit.hour:
        return localization.secondaryUnitHour;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = themeData.colorScheme;
    final textTheme = themeData.textTheme;
    final pickerTheme = (themeData.extension<DurationPickerThemeData>() ??
            const DurationPickerThemeData())
        .merge(widget.theme);
    final localization = DurationPickerLocalizations.of(context);

    _secondaryUnitValue = _secondaryUnitHand();
    _baseUnitValue = _baseUnitHand();

    return RawGestureDetector(
      excludeFromSemantics: true,
      gestures: <Type, GestureRecognizerFactory>{
        _DialPanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_DialPanGestureRecognizer>(
          () => _DialPanGestureRecognizer(debugOwner: this),
          (instance) => instance
            ..onStart = _handlePanStart
            ..onUpdate = _handlePanUpdate
            ..onEnd = _handlePanEnd,
        ),
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(debugOwner: this),
          (instance) => instance.onTapUp = _handleTapUp,
        ),
      },
      child: CustomPaint(
        painter: _DialPainter(
          baseUnitMultiplier: _secondaryUnitValue,
          baseUnitHand: _baseUnitValue,
          labels: _buildBaseUnitLabels(
            textTheme.titleMedium!.merge(pickerTheme.labelTextStyle),
          ),
          backgroundColor:
              pickerTheme.dialBackgroundColor ?? _defaultDialBackground(),
          accentColor: pickerTheme.handColor ?? colorScheme.primary,
          valueTextStyle:
              textTheme.displayMedium!.merge(pickerTheme.valueTextStyle),
          scaleValueText: pickerTheme.valueTextStyle?.fontSize == null,
          unitTextStyle: textTheme.bodyMedium!.merge(pickerTheme.unitTextStyle),
          baseUnitLabel: _baseUnitLabel(localization),
          secondaryUnitLabel: _secondaryUnitLabel(localization),
          theta: _getThetaForDuration(widget.duration, widget.baseUnit),
        ),
      ),
    );
  }
}

/// A pan that starts at half the touch slop instead of the larger pan slop,
/// so it claims the drag before a surrounding scroll view does.
class _DialPanGestureRecognizer extends PanGestureRecognizer {
  _DialPanGestureRecognizer({super.debugOwner});

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    return globalDistanceMoved.abs() >
        computeHitSlop(pointerDeviceKind, gestureSettings) / 2;
  }
}

/// A duration picker designed to appear inside a popup dialog.
///
/// Pass this widget to [showDialog]. The value returned by [showDialog] is the
/// selected [Duration] if the user taps the "OK" button, or null if the user
/// taps the "CANCEL" button. The selected time is reported by calling
/// [Navigator.pop].
class DurationPickerDialog extends StatefulWidget {
  /// Creates a duration picker.
  ///
  /// [initialTime] must not be null.
  const DurationPickerDialog({
    super.key,
    required this.initialTime,
    this.baseUnit = BaseUnit.minute,
    this.decoration,
    this.upperBound,
    this.lowerBound,
    this.title,
    this.theme,
  });

  /// The duration initially selected when the dialog is shown.
  final Duration initialTime;
  final BaseUnit baseUnit;
  final BoxDecoration? decoration;
  final Duration? upperBound;
  final Duration? lowerBound;

  /// Shown above the dial, usually a [Text].
  final Widget? title;

  /// Overrides the [DurationPickerThemeData] from the app's theme.
  final DurationPickerThemeData? theme;

  @override
  DurationPickerDialogState createState() => DurationPickerDialogState();
}

class DurationPickerDialogState extends State<DurationPickerDialog> {
  @override
  void initState() {
    super.initState();
    var initialTime = widget.initialTime;
    final lowerBound = widget.lowerBound;
    final upperBound = widget.upperBound;
    if (lowerBound != null && initialTime < lowerBound) {
      initialTime = lowerBound;
    } else if (upperBound != null && initialTime > upperBound) {
      initialTime = upperBound;
    }
    _selectedDuration = initialTime;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
  }

  Duration? get selectedDuration => _selectedDuration;
  Duration? _selectedDuration;

  late MaterialLocalizations localizations;

  void _handleTimeChanged(Duration value) {
    setState(() {
      _selectedDuration = value;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    Navigator.pop(context, _selectedDuration);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final theme = Theme.of(context);
    final boxDecoration = widget.decoration ?? const BoxDecoration();
    final Widget picker = Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: _Dial(
          duration: _selectedDuration!,
          onChanged: _handleTimeChanged,
          baseUnit: widget.baseUnit,
          upperBound: widget.upperBound,
          lowerBound: widget.lowerBound,
          theme: widget.theme,
        ),
      ),
    );

    final Widget actions = Padding(
      padding: const EdgeInsets.all(8.0),
      child: OverflowBar(
        alignment: MainAxisAlignment.end,
        spacing: 8.0,
        children: <Widget>[
          TextButton(
            onPressed: _handleCancel,
            child: Text(localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: _handleOk,
            child: Text(localizations.okButtonLabel),
          ),
        ],
      ),
    );

    final dialog = Dialog(
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          final Widget pickerAndActions = DecoratedBox(
            decoration: boxDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
                    child: DefaultTextStyle(
                      style: theme.textTheme.titleLarge!,
                      child: widget.title!,
                    ),
                  ),
                Expanded(
                  child: picker,
                ), // picker grows and shrinks with the available space
                actions,
              ],
            ),
          );

          switch (orientation) {
            case Orientation.portrait:
              return SizedBox(
                width: _kDurationPickerWidthPortrait,
                height: _kDurationPickerHeightPortrait,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: pickerAndActions,
                    ),
                  ],
                ),
              );
            case Orientation.landscape:
              return SizedBox(
                width: _kDurationPickerWidthLandscape,
                height: _kDurationPickerHeightLandscape,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: pickerAndActions,
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );

    return dialog;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Shows a dialog containing the duration picker.
///
/// The returned Future resolves to the duration selected by the user when the user
/// closes the dialog. If the user cancels the dialog, null is returned.
///
/// To show a dialog with [initialTime] equal to the current time:
///
/// ```dart
/// showDurationPicker(
///   initialTime: new Duration.now(),
///   context: context,
/// );
/// ```
Future<Duration?> showDurationPicker({
  required BuildContext context,
  required Duration initialTime,
  BaseUnit baseUnit = BaseUnit.minute,
  BoxDecoration? decoration,
  Duration? upperBound,
  Duration? lowerBound,
  Widget? title,
  DurationPickerThemeData? theme,
}) {
  return showDialog<Duration>(
    context: context,
    builder: (BuildContext context) => DurationPickerDialog(
      initialTime: initialTime,
      baseUnit: baseUnit,
      decoration: decoration,
      upperBound: upperBound,
      lowerBound: lowerBound,
      title: title,
      theme: theme,
    ),
  );
}

/// The [DurationPicker] widget.
class DurationPicker extends StatelessWidget {
  final Duration duration;
  final ValueChanged<Duration> onChange;
  final BaseUnit baseUnit;
  final Duration? upperBound;
  final Duration? lowerBound;

  final double? width;
  final double? height;

  /// Overrides the [DurationPickerThemeData] from the app's theme.
  final DurationPickerThemeData? theme;

  const DurationPicker({
    super.key,
    this.duration = Duration.zero,
    required this.onChange,
    this.baseUnit = BaseUnit.minute,
    this.upperBound,
    this.lowerBound,
    this.width,
    this.height,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? _kDurationPickerWidthPortrait / 1.5,
      height: height ?? _kDurationPickerHeightPortrait / 1.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _Dial(
              duration: duration,
              onChanged: onChange,
              baseUnit: baseUnit,
              upperBound: upperBound,
              lowerBound: lowerBound,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

/// This enum contains the possible units for the [DurationPicker]
enum BaseUnit {
  millisecond,
  second,
  minute,
  hour,
}
