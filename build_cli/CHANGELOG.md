## 0.2.0

- Fail unless the minimum SDK constraint on the target package is at least
  `2.0.0-dev.48`.

- Added support `valueHelp` to `CliOption`.

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
