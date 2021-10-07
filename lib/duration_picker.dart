library duration_picker;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const Duration _kDialAnimateDuration = Duration(milliseconds: 200);

const double _kDurationPickerWidthPortrait = 328.0;
const double _kDurationPickerWidthLandscape = 512.0;

const double _kDurationPickerHeightPortrait = 380.0;
const double _kDurationPickerHeightLandscape = 304.0;

const double _kTwoPi = 2 * math.pi;
const double _kPiByTwo = math.pi / 2;

const double _kCircleTop = _kPiByTwo;

class DurationPickerDialPainter extends CustomPainter {
  const DurationPickerDialPainter({
    required this.context,
    required this.labels,
    required this.backgroundColor,
    required this.accentColor,
    required this.theta,
    required this.textDirection,
    required this.selectedValue,
    required this.pct,
    required this.multiplier,
    required this.minuteHand,
  });

  final List<TextPainter> labels;
  final Color? backgroundColor;
  final Color accentColor;
  final double theta;
  final TextDirection textDirection;
  final int? selectedValue;
  final BuildContext context;

  final double pct;
  final int multiplier;
  final int minuteHand;

  @override
  void paint(Canvas canvas, Size size) {
    const _epsilon = .001;
    const _sweep = _kTwoPi - _epsilon;
    const _startAngle = -math.pi / 2.0;

    final radius = size.shortestSide / 2.0;
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final centerPoint = center;

    var pctTheta = (0.25 - (theta % _kTwoPi) / _kTwoPi) % 1.0;

    // Draw the background outer ring
    canvas.drawCircle(centerPoint, radius, Paint()..color = backgroundColor!);

    // Draw a translucent circle for every hour
    for (var i = 0; i < multiplier; i = i + 1) {
      canvas.drawCircle(centerPoint, radius,
          Paint()..color = accentColor.withOpacity((i == 0) ? 0.3 : 0.1));
    }

    // Draw the inner background circle
    canvas.drawCircle(centerPoint, radius * 0.88,
        Paint()..color = Theme.of(context).canvasColor);

    // Get the offset point for an angle value of theta, and a distance of _radius
    Offset getOffsetForTheta(double theta, double _radius) {
      return center +
          Offset(_radius * math.cos(theta), -_radius * math.sin(theta));
    }

    // Draw the handle that is used to drag and to indicate the position around the circle
    final handlePaint = Paint()..color = accentColor;
    final handlePoint = getOffsetForTheta(theta, radius - 10.0);
    canvas.drawCircle(handlePoint, 20.0, handlePaint);

    // Draw the Text in the center of the circle which displays hours and mins
    var hours = (multiplier == 0) ? '' : '${multiplier}h ';
    var minutes = '$minuteHand';

    var textDurationValuePainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: '$hours$minutes',
            style: Theme.of(context)
                .textTheme
                .headline2!
                .copyWith(fontSize: size.shortestSide * 0.15)),
        textDirection: TextDirection.ltr)
      ..layout();
    var middleForValueText = Offset(
        centerPoint.dx - (textDurationValuePainter.width / 2),
        centerPoint.dy - textDurationValuePainter.height / 2);
    textDurationValuePainter.paint(canvas, middleForValueText);

    var textMinPainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'min.', //th: ${theta}',
            style: Theme.of(context).textTheme.bodyText2),
        textDirection: TextDirection.ltr)
      ..layout();
    textMinPainter.paint(
        canvas,
        Offset(
            centerPoint.dx - (textMinPainter.width / 2),
            centerPoint.dy +
                (textDurationValuePainter.height / 2) -
                textMinPainter.height / 2));

    // Draw an arc around the circle for the amount of the circle that has elapsed.
    var elapsedPainter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withOpacity(0.3)
      ..isAntiAlias = true
      ..strokeWidth = radius * 0.12;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: radius - radius * 0.12 / 2,
      ),
      _startAngle,
      _sweep * pctTheta,
      false,
      elapsedPainter,
    );

    // Paint the labels (the minute strings)
    void paintLabels(List<TextPainter> labels) {
      final labelThetaIncrement = -_kTwoPi / labels.length;
      var labelTheta = _kPiByTwo;

      for (var label in labels) {
        final labelOffset = Offset(-label.width / 2.0, -label.height / 2.0);

        label.paint(
            canvas, getOffsetForTheta(labelTheta, radius - 40.0) + labelOffset);

        labelTheta += labelThetaIncrement;
      }
    }

    paintLabels(labels);
  }

  @override
  bool shouldRepaint(DurationPickerDialPainter oldPainter) {
    return oldPainter.labels != labels ||
        oldPainter.backgroundColor != backgroundColor ||
        oldPainter.accentColor != accentColor ||
        oldPainter.theta != theta;
  }
}

class DurationPickerDial extends StatefulWidget {
  const DurationPickerDial(
      {required this.duration, required this.onChanged, this.snapToMins = 1.0});

  final Duration duration;
  final ValueChanged<Duration> onChanged;

  /// The resolution of mins of the dial, i.e. if snapToMins = 5.0, only durations of 5min intervals will be selectable.
  final double? snapToMins;
  @override
  DurationPickerDialState createState() => DurationPickerDialState();
}

class DurationPickerDialState extends State<DurationPickerDial> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _thetaController = AnimationController(
      duration: _kDialAnimateDuration,
      vsync: this,
    );
    _thetaTween = Tween<double>(begin: _getThetaForDuration(widget.duration));
    _theta = _thetaTween.animate(
        CurvedAnimation(parent: _thetaController, curve: Curves.fastOutSlowIn))
      ..addListener(() => setState(() {}));
    _thetaController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _hours = _hourHand();
        _minutes = _minuteHand();
        setState(() {});
      }
    });

    _turningAngle = _kPiByTwo - widget.duration.inMinutes / 60.0 * _kTwoPi;
    _hours = _hourHand();
    _minutes = _minuteHand();
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

  final double _pct = 0.0;
  int _hours = 0;
  bool _dragging = false;
  int _minutes = 0;
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

  double _getThetaForDuration(Duration duration) {
    return (_kPiByTwo - (duration.inMinutes % 60) / 60.0 * _kTwoPi) % _kTwoPi;
  }

  // TODO: Fix snap to mins
  Duration _getTimeForTheta(double theta) {
    return _angleToDuration(_turningAngle);
    // var fractionalRotation = (0.25 - (theta / _kTwoPi));
    // fractionalRotation = fractionalRotation < 0
    //    ? 1 - fractionalRotation.abs()
    //    : fractionalRotation;
    // var mins = (fractionalRotation * 60).round();
    // debugPrint('Mins0: ${widget.snapToMins }');
    // if (widget.snapToMins != null) {
    //   debugPrint('Mins1: $mins');
    //  mins = ((mins / widget.snapToMins!).round() * widget.snapToMins!).round();
    //   debugPrint('Mins2: $mins');
    // }
    // if (mins == 60) {
    //  // _snappedHours = _hours + 1;
    //  // mins = 0;
    //  return new Duration(hours: 1, minutes: mins);
    // } else {
    //  // _snappedHours = _hours;
    //  return new Duration(hours: _hours, minutes: mins);
    // }
  }

  Duration _notifyOnChangedIfNeeded() {
    _hours = _hourHand();
    _minutes = _minuteHand();
    var d = _angleToDuration(_turningAngle);
    widget.onChanged(d);

    return d;
  }

  void _updateThetaForPan() {
    setState(() {
      final offset = _position! - _center!;
      final angle = (math.atan2(offset.dx, offset.dy) - _kPiByTwo) % _kTwoPi;

      // Stop accidental abrupt pans from making the dial seem like it starts from 1h.
      // (happens when wanting to pan from 0 clockwise, but when doing so quickly, one actually pans from before 0 (e.g. setting the duration to 59mins, and then crossing 0, which would then mean 1h 1min).
      if (angle >= _kCircleTop &&
          _theta.value <= _kCircleTop &&
          _theta.value >= 0.1 && // to allow the radians sign change at 15mins.
          _hours == 0) return;

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
    final box = context.findRenderObject() as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);

    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    var oldTheta = _theta.value;
    _position = _position! + details.delta;
    // _position! += details.delta;
    _updateThetaForPan();
    var newTheta = _theta.value;

    _updateTurningAngle(oldTheta, newTheta);
    _notifyOnChangedIfNeeded();
  }

  int _hourHand() {
    return widget.duration.inHours;
  }

  int _minuteHand() {
    // Result is in [0; 59], even if overall time is >= 1 hour
    return widget.duration.inMinutes % 60;
  }

  Duration _angleToDuration(double angle) {
    return _minutesToDuration(_angleToMinutes(angle));
  }

  Duration _minutesToDuration(minutes) {
    return Duration(
        hours: (minutes ~/ 60).toInt(), minutes: (minutes % 60.0).toInt());
  }

  double _angleToMinutes(double angle) {
    // Coordinate transformation from mathematical COS to dial COS
    var dialAngle = _kPiByTwo - angle;

    // Turn dial angle into minutes, may go beyond 60 minutes (multiple turns)
    return dialAngle / _kTwoPi * 60.0;
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
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging);
    _dragging = false;
    _position = null;
    _center = null;
    _animateTo(_getThetaForDuration(widget.duration));
  }

  void _handleTapUp(TapUpDetails details) {
    final box = context.findRenderObject() as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();

    _animateTo(_getThetaForDuration(_getTimeForTheta(_theta.value)));
    _dragging = false;
    _position = null;
    _center = null;
  }

  List<TextPainter> _buildMinutes(TextTheme textTheme) {
    final style = textTheme.subtitle1;

    const _minuteMarkerValues = <Duration>[
      Duration(hours: 0, minutes: 0),
      Duration(hours: 0, minutes: 5),
      Duration(hours: 0, minutes: 10),
      Duration(hours: 0, minutes: 15),
      Duration(hours: 0, minutes: 20),
      Duration(hours: 0, minutes: 25),
      Duration(hours: 0, minutes: 30),
      Duration(hours: 0, minutes: 35),
      Duration(hours: 0, minutes: 40),
      Duration(hours: 0, minutes: 45),
      Duration(hours: 0, minutes: 50),
      Duration(hours: 0, minutes: 55),
    ];

    final labels = <TextPainter>[];
    for (var duration in _minuteMarkerValues) {
      var painter = TextPainter(
        text: TextSpan(style: style, text: duration.inMinutes.toString()),
        textDirection: TextDirection.ltr,
      )..layout();
      labels.add(painter);
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    switch (themeData.brightness) {
      case Brightness.light:
        backgroundColor = Colors.grey[200];
        break;
      case Brightness.dark:
        backgroundColor = themeData.backgroundColor;
        break;
    }

    final theme = Theme.of(context);

    int? selectedDialValue;
    _hours = _hourHand();
    _minutes = _minuteHand();

    return GestureDetector(
        excludeFromSemantics: true,
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTapUp: _handleTapUp,
        child: CustomPaint(
          painter: DurationPickerDialPainter(
            pct: _pct,
            multiplier: _hours,
            minuteHand: _minutes,
            context: context,
            selectedValue: selectedDialValue,
            labels: _buildMinutes(theme.textTheme),
            backgroundColor: backgroundColor,
            accentColor: themeData.accentColor,
            theta: _theta.value,
            textDirection: Directionality.of(context),
          ),
        ));
  }
}

/// A duration picker designed to appear inside a popup dialog.
///
/// Pass this widget to [showDialog]. The value returned by [showDialog] is the
/// selected [Duration] if the user taps the "OK" button, or null if the user
/// taps the "CANCEL" button. The selected time is reported by calling
/// [Navigator.pop].
class _DurationPickerDialog extends StatefulWidget {
  /// Creates a duration picker.
  ///
  /// [initialTime] must not be null.
  const _DurationPickerDialog(
      {Key? key,
      required this.initialTime,
      this.snapToMins = 1.0,
      this.decoration})
      : super(key: key);

  /// The duration initially selected when the dialog is shown.
  final Duration initialTime;
  final double snapToMins;
  final BoxDecoration? decoration;

  @override
  _DurationPickerDialogState createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialTime;
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
    final boxDecoration =
        widget.decoration ?? BoxDecoration(color: theme.dialogBackgroundColor);
    final Widget picker = Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
            aspectRatio: 1.0,
            child: DurationPickerDial(
              duration: _selectedDuration!,
              onChanged: _handleTimeChanged,
              snapToMins: widget.snapToMins,
            )));

    final Widget actions = ButtonBarTheme(
        data: ButtonBarTheme.of(context),
        child: ButtonBar(children: <Widget>[
          TextButton(
              onPressed: _handleCancel,
              child: Text(localizations.cancelButtonLabel)),
          TextButton(
              onPressed: _handleOk, child: Text(localizations.okButtonLabel)),
        ]));

    final dialog = Dialog(child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      final Widget pickerAndActions = Container(
        decoration: boxDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
                child:
                    picker), // picker grows and shrinks with the available space
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
                  ]));
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
                  ]));
      }
    }));

    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
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
Future<Duration?> showDurationPicker(
    {required BuildContext context,
    required Duration initialTime,
    double snapToMins = 1.0,
    BoxDecoration? decoration}) async {
  return await showDialog<Duration>(
    context: context,
    builder: (BuildContext context) => _DurationPickerDialog(
      initialTime: initialTime,
      snapToMins: snapToMins,
      decoration: decoration,
    ),
  );
}

class DurationPicker extends StatelessWidget {
  final Duration duration;
  final ValueChanged<Duration> onChange;
  final double? snapToMins;

  final double? width;
  final double? height;

  const DurationPicker(
      {Key? key,
      this.duration = const Duration(minutes: 0),
      required this.onChange,
      this.snapToMins,
      this.width,
      this.height})
      : super(key: key);

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
                child: DurationPickerDial(
                  duration: duration,
                  onChanged: onChange,
                  snapToMins: snapToMins,
                ),
              ),
            ]));
  }
}
