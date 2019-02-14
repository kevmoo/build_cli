import 'package:build_cli_annotations/build_cli_annotations.dart';

@CliOptions()
class UnknownCtorParamType {
  int number;

  // ignore: undefined_class, field_initializer_not_assignable, prefer_initializing_formals
  UnknownCtorParamType(Bob number) : number = number;
}

@CliOptions()
class UnknownFieldType {
  // ignore: undefined_class
  Bob number;
}

@CliOptions()
class UnsupportedFieldType {
  Duration number;
}

@CliOptions()
class DefaultNotInAllowed {
  @CliOption(defaultsTo: 'a', allowed: ['b'])
  String option;
}

@CliOptions()
class NegatableOption {
  @CliOption(negatable: true)
  String option;
}

@CliOptions()
class NegatableMultiOption {
  @CliOption(negatable: true)
  List<String> options;
}

@CliOptions()
class ConvertAsStatic {
  @CliOption(convert: _staticConvertStringToDuration)
  String option;

  static Duration _staticConvertStringToDuration(String source) => null;
}

@CliOptions()
class BadConvertReturn {
  @CliOption(convert: _convertStringToDuration)
  String option;
}

Duration _convertStringToDuration(String source) => null;

@CliOptions()
class BadConvertParam {
  // ignore: argument_type_not_assignable
  @CliOption(convert: _convertIntToString)
  String option;
}

String _convertIntToString(int source) => null;

@CliOptions()
class ConvertOnMulti {
  @CliOption(convert: _convertStringToDuration)
  List<Duration> option;
}

@CliOptions()
class FlagWithStringDefault {
  @CliOption(defaultsTo: 'string')
  bool option;
}

@CliOptions()
class FlagWithAllowed {
  @CliOption(allowed: [])
  bool option;
}

@CliOptions()
class FlagWithAllowedHelp {
  @CliOption(allowedHelp: {})
  bool option;
}

@CliOptions()
class FlagWithValueHelp {
  @CliOption(valueHelp: 'string')
  bool option;
}

@CliOptions()
class DefaultOverride {
  @CliOption(provideDefaultToOverride: true)
  bool shouldDoThing;

  @CliOption(provideDefaultToOverride: true, defaultsTo: 'default value')
  String otherSetting;

// TODO: enum field
}
