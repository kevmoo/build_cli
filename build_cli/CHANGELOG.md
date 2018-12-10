## 1.2.0

- Require Dart 2.0 "gold" in the target package.
- Omit `new` keyword in generated code.
- Update `package:analyzer` constraint to `>=0.33.0 <0.35.0`.

## 1.1.0

- Support nullable annotation

## 1.0.2

- Support the latest release of `package:analyzer`.

## 1.0.1

- Support `package:build` `v1`.

## 1.0.0

- Support `package:build_cli_annotations` `v1`.

## 0.2.6

- Helper methods that were previously generated inline within functions are now
  generated as top-level functions and shared.

## 0.2.5

- Require `package:source_gen` `^0.9.0`.

- The `header` configuration option is no longer supported. (It's ignored.)

## 0.2.4+1

- Support Dart 2 stable.

## 0.2.4

- Support the latest version of `package:build_config`.

## 0.2.3

- Require the latest `package:analyzer`.
- Support convert functions with optional parameters.

## 0.2.2

- Added support for populating `ArgResults command` if the field is not 
  annotated.
- Improved error output, including in cases where a bug may be found.

## 0.2.1

- Added support for `covert` to `CliOption`.
- Throw many more errors during build that would create invalid code at runtime.

## 0.2.0

- Fail unless the minimum SDK constraint on the target package is at least
  `2.0.0-dev.48`.

- Added for support `valueHelp` to `CliOption`.

## 0.1.2

- Support `int`, `double`, and `num` for options.
- Improve error messages for some failures.
- Support `defaultsTo` for flags.
- Generate another private method `_$populate[OptionClassName]Parser`.
  Allows usage for already existing `ArgParser` instances, such as with 
  `package:args` `CommandRunner`.

## 0.1.1+1

- Fix link to `package:peanut` usage example.

## 0.1.1

- Add setup instructions to `README.md`.
- Use the logger built into `pkg:build`.
- Don't generate CLI entries for unassignable fields.
- Support latest `pkg:source_gen`.
- Properly escape `String` literals.

## 0.1.0

- First release
