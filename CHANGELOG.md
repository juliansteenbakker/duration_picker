## 1.2.0
* Add localization options
* Update deprecated functions
* Add upper and lower bound for duration

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
