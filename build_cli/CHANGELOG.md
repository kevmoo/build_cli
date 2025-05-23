## 2.2.7

- Fix issue with latest version of `package:source_gen`.

## 2.2.6

- Fix issue with latest version of `package:analyzer`.

## 2.2.5

- Fix issue with latest version of `package:analyzer`.

## 2.2.4

- Support the latest `package:analyzer` and `package:source_gen`.
- Require `sdk: ^3.6.0`

## 2.2.3

- Fix bug where nullable number options lead to an exception when parsing if
  `null` is the default value and no value is passed to the command line.

## 2.2.2

- Support the latest `package:analyzer`.
- Require `sdk: ^3.0.0`

## 2.2.1

- Require `analyzer: '>=4.6.0 <6.0.0'`
- Require `sdk: '>=2.17.0 <3.0.0'`

## 2.2.0

- Generate a `Command` helper class when (the new) `CliOptions.createCommand`
  field is `true`.

## 2.1.6
-
- Support the latest `package:analyzer`.

## 2.1.5

- Add trailing commas to many places in output.
- Fix issues with latest `package:analyzer` related to enums and annotations.

## 2.1.4

- Require the latest `package:source_helper`.
- Support the latest `package:analyzer`.

## 2.1.3

- Support the latest `package:analyzer`.

## 2.1.2

- Require the latest `package:build_config`.

## 2.1.1

- Change the name of the private `Map` used to support enums so that it does
  not conflict with the one generated by `package:json_serializable`.

## 2.1.0

- Improve generation of null-safe code.
- Migrate implementation to null-safe.

## 2.0.1

- Require `package:build` `^2.0.0`.

## 2.0.0

- Support generating null-safe code.
- Require Dart SDK `>=2.12.0 <3.0.0`.

## 1.3.10

- Require Dart SDK `>=2.7.0 <3.0.0`.
- `package:analyzer` `>=0.39.0 <0.41.0`.

## 1.3.9

- Avoid `avoid_redundant_argument_values` lint in generated code for
  `defaultValue`.

## 1.3.8

- Avoid `avoid_redundant_argument_values` lint.

## 1.3.7

- Support `package:build_cli_annotations` `>=1.1.0 <1.3.0`.
- `package:analyzer` `^0.39.0`.

## 1.3.6

- Support the latest release of `package:analyzer`.

## 1.3.5

- Fix issue with behavior change in recent `package:analyzer` releases.

## 1.3.4

- Support the latest release of `package:analyzer`.

## 1.3.3

- Support the latest release of `package:analyzer`.

## 1.3.2

- Support the latest release of `package:build_config`.
- Removed special handling of undefined types due to changes in
  `package:analyzer`. These types are now treated as `dynamic`.

## 1.3.1

- Support the latest release of `package:analyzer`.

## 1.3.0

- Added support for the new `provideDefaultToOverride` value on `CliOption` to
  allow users to provide an override to `defaultsTo` by including an optional
  `[fieldName]DefaultOverride` param to the generated
  `_$populate[ClassName]Parser` function.
- Handle kebab-case enum value names correctly, including when they are used as
  default values.
- Handle allowed values that require escaping.
- Support classes with one, non-default constructor.
- Require Dart `>=2.2.0 <3.0.0`.

## 1.2.2

- Support the latest release of `package:analyzer`.

## 1.2.1

- Generate all local variables as `final` where applicable.
  Allows consumers to enable the `prefer_final_locals` lint.

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
