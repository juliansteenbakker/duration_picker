## 1.2.0
* Add localization options
* Update deprecated functions
* Add upper and lower bound for duration

## [2.0.0](https://github.com/juliansteenbakker/duration_picker/compare/v1.3.0...v2.0.0) (2026-10-16)


### ⚠ BREAKING CHANGES

* `DurationPickerDialogState` and its `selectedDuration` getter are no longer public. Read the selected duration from the `Future` returned by `showDurationPicker`, or from `showDialog` when showing `DurationPickerDialog` yourself.
* The picker's default colors now come from the color scheme. The handle and elapsed ring use `ColorScheme.primary` instead of `secondary`, on Material 3 the ring uses `surfaceContainerHighest` instead of `Colors.grey[200]` (or `surface` in dark mode), and the middle of the dial is transparent instead of `canvasColor`; set `DurationPickerThemeData(handColor: colorScheme.secondary)` to get the old hand color back. `showDurationPicker` also no longer paints its content with `ColorScheme.surface`, so the dialog keeps its own background color and rounded shape; pass `decoration: BoxDecoration(color: colorScheme.surface)` for the old look.
* `DialPainter` is no longer exported; it couldn't be passed to the picker, so it had no use outside the package. The deprecated `snapToMins` parameter of `DurationPicker` is removed; it was never used, so drop the argument.

### Features

* make the dial adjustable with screen readers ([#57](https://github.com/juliansteenbakker/duration_picker/issues/57)) ([c9a63da](https://github.com/juliansteenbakker/duration_picker/commit/c9a63dad43ab5126f1bfe57a6a35caba40aa840a))
* style the picker through DurationPickerThemeData ([#53](https://github.com/juliansteenbakker/duration_picker/issues/53)) ([3049350](https://github.com/juliansteenbakker/duration_picker/commit/30493508797074d70f56d93e07d11235da409390))


### Bug Fixes

* dispose the dial's text painters and curved animation ([#55](https://github.com/juliansteenbakker/duration_picker/issues/55)) ([b4603a7](https://github.com/juliansteenbakker/duration_picker/commit/b4603a7f28218ec597b18e582e9cf7c4a073c4ab))
* scale the dial labels with the system text size ([#56](https://github.com/juliansteenbakker/duration_picker/issues/56)) ([f21d52e](https://github.com/juliansteenbakker/duration_picker/commit/f21d52e492be62762a01cfdc37afd4125b9fc284))


### Code Refactoring

* make DialPainter private and remove snapToMins ([ca29d9d](https://github.com/juliansteenbakker/duration_picker/commit/ca29d9d7cc62790a2a53014a30ab149795445ecc))
* make the dialog state private and export the localizations ([#54](https://github.com/juliansteenbakker/duration_picker/issues/54)) ([1f7c22a](https://github.com/juliansteenbakker/duration_picker/commit/1f7c22a1ab92fdfda24b3566ddc626ed84619bc7))

## [1.3.0](https://github.com/juliansteenbakker/duration_picker/compare/v1.2.0...v1.3.0) (2026-10-16)


### Features

* add an optional title to the duration picker dialog ([#46](https://github.com/juliansteenbakker/duration_picker/issues/46)) ([080ae39](https://github.com/juliansteenbakker/duration_picker/commit/080ae393e4f7e2ae334ab467a19351ffd6b90ad6))
* add German localization ([#31](https://github.com/juliansteenbakker/duration_picker/issues/31)) ([1524d8d](https://github.com/juliansteenbakker/duration_picker/commit/1524d8db13a2d97e9eaffc8f1231e8b1d450e74e))


### Bug Fixes

* allow dragging past 15 minutes in the first hour ([#42](https://github.com/juliansteenbakker/duration_picker/issues/42)) ([62723e5](https://github.com/juliansteenbakker/duration_picker/commit/62723e5159fd5a84ae1b98c3d3c1f4f0f32c2506))
* apply upperBound and lowerBound in showDurationPicker ([#40](https://github.com/juliansteenbakker/duration_picker/issues/40)) ([c735cea](https://github.com/juliansteenbakker/duration_picker/commit/c735ceae35311dc45889e415acc760971a6364c1))
* keep the dial in sync when the parent changes the duration or bounds ([#48](https://github.com/juliansteenbakker/duration_picker/issues/48)) ([2288183](https://github.com/juliansteenbakker/duration_picker/commit/2288183734f2de4690a4655dc9fcc36257f011f6))
* keep the initial time of showDurationPicker within its bounds ([#43](https://github.com/juliansteenbakker/duration_picker/issues/43)) ([c925e1d](https://github.com/juliansteenbakker/duration_picker/commit/c925e1db833cd09f0c56483c41c8f87d121625c5))
* let the dial win drags inside a scroll view ([#45](https://github.com/juliansteenbakker/duration_picker/issues/45)) ([243aac0](https://github.com/juliansteenbakker/duration_picker/commit/243aac0f2c1471330112cb2ed277d66b169d6a85))
* replace deprecated APIs and raise minimum Flutter to 3.27 ([#36](https://github.com/juliansteenbakker/duration_picker/issues/36)) ([c8dae93](https://github.com/juliansteenbakker/duration_picker/commit/c8dae9388a37e8a6be11aa12af7273f095634177))
* select a value by tapping the dial ([#44](https://github.com/juliansteenbakker/duration_picker/issues/44)) ([f0f4d8c](https://github.com/juliansteenbakker/duration_picker/commit/f0f4d8c45c30acccfbec8ecbcf76f79be491e734))

## 1.1.1
Switched to lint and applied all suggested lints.

## 1.1.0+1
New Features
* It is now possible to select the base unit of the timer using baseunit: parameter. 
See example app for an example.
  
## 1.0.1
Bug fixes
* Updated example app

## 1.0.0
#### Breaking Changes
* Added null-safety
#### New Features
* Popup duration picker with box decoration
#### Bug fixes
* Fixed Method not found: 'ButtonTheme.bar'

# Changelog from flutter_duration_picker
## [1.0.4] - Oct 23, 2018

* Fixed bug showing 60mins when approaching 0.

### [1.0.3] - Aug 01, 2018

* Fixed bug returning false from void function

## [1.0.2] - Jul 25, 2018

* Fixed initial duration when exceeding 1h

## [1.0.1] - Jun 26, 2018	 

* initial release.
