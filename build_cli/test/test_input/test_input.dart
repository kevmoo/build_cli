// @dart=3.6

import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow(
  'Could not handle field `number`. `Duration` is not a supported type.',
)
@CliOptions()
class UnsupportedFieldType {
  Duration? number;
}

@ShouldThrow(
  'Could not handle field `option`. '
  'The `defaultsTo` value – `a` is not in `allowedValues`.',
)
@CliOptions()
class DefaultNotInAllowed {
  @CliOption(defaultsTo: 'a', allowed: ['b'])
  String? option;
}

@ShouldThrow(
  'Could not handle field `option`. '
  '`negatable` is only valid for flags – type `bool`.',
)
@CliOptions()
class NegatableOption {
  @CliOption(negatable: true)
  String? option;
}

@ShouldThrow(
  'Could not handle field `options`. '
  '`negatable` is only valid for flags – type `bool`.',
)
@CliOptions()
class NegatableMultiOption {
  @CliOption(negatable: true)
  List<String>? options;
}

@ShouldThrow(
  'Could not handle field `option`. '
  'The function provided for `convert` must be top-level. '
  'Static class methods (like `_staticConvertStringToDuration`) are not '
  'supported.',
)
@CliOptions()
class ConvertAsStatic {
  @CliOption(convert: _staticConvertStringToDuration)
  String? option;

  static Duration? _staticConvertStringToDuration(String source) => null;
}

@ShouldThrow(
  'Could not handle field `option`. '
  'The convert function `_convertStringToDuration` return type '
  '`Duration` is not compatible with the field type `String`.',
)
@CliOptions()
class BadConvertReturn {
  @CliOption(convert: _convertStringToDuration)
  String? option;
}

Duration? _convertStringToDuration(String source) => null;

@ShouldThrow(
  'Could not handle field `option`. '
  'The convert function `_convertStringToDuration` return type '
  '`Duration` is not compatible with the field type `List<Duration>`.',
)
@CliOptions()
class ConvertOnMulti {
  @CliOption(convert: _convertStringToDuration)
  List<Duration>? option;
}

@ShouldThrow(
  'Could not handle field `option`. '
  'The value for `defaultsTo` must be assignable to `bool`.',
)
@CliOptions()
class FlagWithStringDefault {
  @CliOption(defaultsTo: 'string')
  bool? option;
}

@ShouldThrow(
  'Could not handle field `option`. '
  '`allowed` is not supported for flags.',
)
@CliOptions()
class FlagWithAllowed {
  @CliOption(allowed: [])
  bool? option;
}

@ShouldThrow(
  'Could not handle field `option`. '
  '`allowedHelp` is not supported for flags.',
)
@CliOptions()
class FlagWithAllowedHelp {
  @CliOption(allowedHelp: {})
  bool? option;
}

@ShouldThrow(
  'Could not handle field `option`. '
  '`valueHelp` is not supported for flags.',
)
@CliOptions()
class FlagWithValueHelp {
  @CliOption(valueHelp: 'string')
  bool? option;
}

@ShouldThrow(
  'Could not handle field `option`. '
  'The `allowedHelp` keys – {c} are not in `allowedValues`.',
)
@CliOptions()
class AllowedHelpKeyNotInAllowed {
  @CliOption(allowed: ['a', 'b'], allowedHelp: {'a': 'a help', 'c': 'c help'})
  String? option;
}

@ShouldThrow(
  'Could not handle field `option`. '
  'The `allowedHelp` keys – {a} are not in `allowedValues`.',
)
@CliOptions()
class AllowedHelpKeyNoAllowed {
  @CliOption(allowedHelp: {'a': 'a help'})
  String? option;
}

@ShouldGenerate(
  r'''
Empty _$parseEmptyResult(ArgResults result) => Empty();

ArgParser _$populateEmptyParser(ArgParser parser) => parser;

final _$parserForEmpty = _$populateEmptyParser(ArgParser());

Empty parseEmpty(List<String> args) {
  final result = _$parserForEmpty.parse(args);
  return _$parseEmptyResult(result);
}
''',
)
@CliOptions()
class Empty {}

@ShouldGenerate(
  r'''
WithCommand _$parseWithCommandResult(ArgResults result) =>
    WithCommand()..command = result.command;

ArgParser _$populateWithCommandParser(ArgParser parser) => parser;

final _$parserForWithCommand = _$populateWithCommandParser(ArgParser());

WithCommand parseWithCommand(List<String> args) {
  final result = _$parserForWithCommand.parse(args);
  return _$parseWithCommandResult(result);
}
''',
)
@CliOptions()
class WithCommand {
  ArgResults? command;
}

@ShouldGenerate(
  r'''
SpecialNotAnnotated _$parseSpecialNotAnnotatedResult(ArgResults result) =>
    SpecialNotAnnotated()
      ..option = result['option'] as String?
      ..rest = result.rest
      ..command = result.command
      ..optionWasParsed = result.wasParsed('option');

ArgParser _$populateSpecialNotAnnotatedParser(ArgParser parser) => parser
  ..addOption(
    'option',
  );

final _$parserForSpecialNotAnnotated =
    _$populateSpecialNotAnnotatedParser(ArgParser());

SpecialNotAnnotated parseSpecialNotAnnotated(List<String> args) {
  final result = _$parserForSpecialNotAnnotated.parse(args);
  return _$parseSpecialNotAnnotatedResult(result);
}
''',
)
@CliOptions()
class SpecialNotAnnotated {
  String? option;
  bool? rest;
  ArgResults? command;
  bool? optionWasParsed;
}

@ShouldGenerate(
  r'''
AnnotatedCommandWithParser _$parseAnnotatedCommandWithParserResult(
        ArgResults result) =>
    AnnotatedCommandWithParser()
      ..command = _stringToArgsResults(result['command'] as String);

ArgParser _$populateAnnotatedCommandWithParserParser(ArgParser parser) => parser
  ..addOption(
    'command',
  );

final _$parserForAnnotatedCommandWithParser =
    _$populateAnnotatedCommandWithParserParser(ArgParser());

AnnotatedCommandWithParser parseAnnotatedCommandWithParser(List<String> args) {
  final result = _$parserForAnnotatedCommandWithParser.parse(args);
  return _$parseAnnotatedCommandWithParserResult(result);
}
''',
)
@CliOptions()
class AnnotatedCommandWithParser {
  @CliOption(convert: _stringToArgsResults)
  ArgResults? command;
}

ArgResults? _stringToArgsResults(String value) => null;

@ShouldThrow(
  'Could not handle field `nothingWasParsed`. Could not find '
  'expected source field `nothing`.',
)
@CliOptions()
class LonelyWasParsed {
  bool? nothingWasParsed;
}

@ShouldThrow(
  'Could not handle field `command`. `ArgResults` is not a supported type.',
)
@CliOptions()
class AnnotatedCommandNoParser {
  @CliOption()
  ArgResults? command;
}

@ShouldThrow(
  'Generator cannot target `theAnswer`. `@CliOptions` can only be applied to a '
  'class.',
  todo: 'Remove the `@CliOptions` annotation from `theAnswer`.',
)
// ignore: invalid_annotation_target
@CliOptions()
const theAnswer = 42;

@ShouldThrow(
  'Generator cannot target `annotatedMethod`.'
  ' `@CliOptions` can only be applied to a class.',
  todo: 'Remove the `@CliOptions` annotation from `annotatedMethod`.',
)
// ignore: invalid_annotation_target
@CliOptions()
Object? annotatedMethod() => null;

@ShouldGenerate(
  r'''
T _$enumValueHelper<T>(Map<T, String> enumValues, String source) =>
    enumValues.entries
        .singleWhere(
          (e) => e.value == source,
          orElse: () => throw ArgumentError(
            '`$source` is not one of the supported values: '
            '${enumValues.values.join(', ')}',
          ),
        )
        .key;

T? _$nullableEnumValueHelperNullable<T>(
  Map<T, String> enumValues,
  String? source,
) =>
    source == null ? null : _$enumValueHelper(enumValues, source);

DefaultOverride _$parseDefaultOverrideResult(ArgResults result) =>
    DefaultOverride()
      ..shouldDoThing = result['should-do-thing'] as bool?
      ..otherSetting = result['other-setting'] as String?
      ..enumValue = _$nullableEnumValueHelperNullable(
        _$TestEnumEnumMapBuildCli,
        result['enum-value'] as String?,
      );

const _$TestEnumEnumMapBuildCli = <TestEnum, String>{
  TestEnum.alpha: 'alpha',
  TestEnum.beta: 'beta',
  TestEnum.$gama: r'$gama'
};

ArgParser _$populateDefaultOverrideParser(
  ArgParser parser, {
  bool? shouldDoThingDefaultOverride,
  String? otherSettingDefaultOverride,
  TestEnum? enumValueDefaultOverride,
}) =>
    parser
      ..addFlag(
        'should-do-thing',
        defaultsTo: shouldDoThingDefaultOverride ?? null,
      )
      ..addOption(
        'other-setting',
        defaultsTo: otherSettingDefaultOverride ?? 'default value',
      )
      ..addOption(
        'enum-value',
        defaultsTo: _$TestEnumEnumMapBuildCli[enumValueDefaultOverride],
        allowed: ['alpha', 'beta', r'$gama'],
      );

final _$parserForDefaultOverride = _$populateDefaultOverrideParser(ArgParser());

DefaultOverride parseDefaultOverride(List<String> args) {
  final result = _$parserForDefaultOverride.parse(args);
  return _$parseDefaultOverrideResult(result);
}
''',
)
@CliOptions()
class DefaultOverride {
  @CliOption(provideDefaultToOverride: true)
  bool? shouldDoThing;

  @CliOption(provideDefaultToOverride: true, defaultsTo: 'default value')
  String? otherSetting;

  @CliOption(provideDefaultToOverride: true)
  TestEnum? enumValue;
}

enum TestEnum { alpha, beta, $gama }

@ShouldGenerate(
  r'''
PrivateCtor _$parsePrivateCtorResult(ArgResults result) => PrivateCtor._(
      flag: result['flag'] as bool?,
    );

ArgParser _$populatePrivateCtorParser(ArgParser parser) => parser
  ..addFlag(
    'flag',
    defaultsTo: null,
  );

final _$parserForPrivateCtor = _$populatePrivateCtorParser(ArgParser());

PrivateCtor parsePrivateCtor(List<String> args) {
  final result = _$parserForPrivateCtor.parse(args);
  return _$parsePrivateCtorResult(result);
}
''',
)
@CliOptions()
class PrivateCtor {
  final bool? flag;

  // ignore: unused_element_parameter
  PrivateCtor._({this.flag});
}

@ShouldThrow('Could not pick a constructor to use.')
@CliOptions()
class TwoNonDefaultConstructors {
  final bool flag;

  TwoNonDefaultConstructors.values(this.flag);

  TwoNonDefaultConstructors.defaults() : flag = false;
}

@ShouldGenerate(
  r'''
T _$enumValueHelper<T>(Map<T, String> enumValues, String source) =>
    enumValues.entries
        .singleWhere(
          (e) => e.value == source,
          orElse: () => throw ArgumentError(
            '`$source` is not one of the supported values: '
            '${enumValues.values.join(', ')}',
          ),
        )
        .key;

T _$badNumberFormat<T extends num>(
  String source,
  String type,
  String argName,
) =>
    throw FormatException(
      'Cannot parse "$source" into `$type` for option "$argName".',
    );

NonNullableTypes _$parseNonNullableTypesResult(ArgResults result) =>
    NonNullableTypes(
      name: result['name'] as String,
      enumValue: _$enumValueHelper(
        _$TestEnumEnumMapBuildCli,
        result['enum-value'] as String,
      ),
      number: int.tryParse(result['number'] as String) ??
          _$badNumberFormat(
            result['number'] as String,
            'int',
            'number',
          ),
    );

const _$TestEnumEnumMapBuildCli = <TestEnum, String>{
  TestEnum.alpha: 'alpha',
  TestEnum.beta: 'beta',
  TestEnum.$gama: r'$gama'
};

ArgParser _$populateNonNullableTypesParser(ArgParser parser) => parser
  ..addOption(
    'name',
  )
  ..addOption(
    'enum-value',
    allowed: ['alpha', 'beta', r'$gama'],
  )
  ..addOption(
    'number',
  );

final _$parserForNonNullableTypes =
    _$populateNonNullableTypesParser(ArgParser());

NonNullableTypes parseNonNullableTypes(List<String> args) {
  final result = _$parserForNonNullableTypes.parse(args);
  return _$parseNonNullableTypesResult(result);
}
''',
)
@CliOptions()
class NonNullableTypes {
  final String name;
  final TestEnum enumValue;
  final int number;

  NonNullableTypes({
    required this.name,
    required this.enumValue,
    required this.number,
  });
}

class SuperClass {
  String? superField;
}

@ShouldGenerate(r'''
SubClass _$parseSubClassResult(ArgResults result) => SubClass()
  ..superField = result['super-field'] as String?
  ..yLocal = result['y-local'] as String?
  ..xLocal = result['x-local'] as String?
  ..wExplicitSetter = result['w-explicit-setter'] as String?
  ..subclassField = result['subclass-field'] as String?;

ArgParser _$populateSubClassParser(ArgParser parser) => parser
  ..addOption(
    'super-field',
  )
  ..addOption(
    'y-local',
  )
  ..addOption(
    'x-local',
  )
  ..addOption(
    'w-explicit-setter',
  )
  ..addOption(
    'subclass-field',
  );

final _$parserForSubClass = _$populateSubClassParser(ArgParser());

SubClass parseSubClass(List<String> args) {
  final result = _$parserForSubClass.parse(args);
  return _$parseSubClassResult(result);
}
''')
@CliOptions()
class SubClass extends SuperClass {
  String? yLocal;
  String? xLocal;
  String? get wExplicitSetter => null;
  set wExplicitSetter(String? value) {}
  String? subclassField;
}

abstract class GenericSuperClass<T> {
  T? bField;
  T? aField;
}

@ShouldGenerate(r'''
T _$badNumberFormat<T extends num>(
  String source,
  String type,
  String argName,
) =>
    throw FormatException(
      'Cannot parse "$source" into `$type` for option "$argName".',
    );

GenericSubClass _$parseGenericSubClassResult(ArgResults result) =>
    GenericSubClass()
      ..bField = result['b-field'] != null
          ? int.tryParse(result['b-field'] as String) ??
              _$badNumberFormat(
                result['b-field'] as String,
                'int',
                'b-field',
              )
          : null
      ..aField = result['a-field'] != null
          ? int.tryParse(result['a-field'] as String) ??
              _$badNumberFormat(
                result['a-field'] as String,
                'int',
                'a-field',
              )
          : null
      ..subclassField = result['subclass-field'] as String?;

ArgParser _$populateGenericSubClassParser(ArgParser parser) => parser
  ..addOption(
    'b-field',
  )
  ..addOption(
    'a-field',
  )
  ..addOption(
    'subclass-field',
  );

final _$parserForGenericSubClass = _$populateGenericSubClassParser(ArgParser());

GenericSubClass parseGenericSubClass(List<String> args) {
  final result = _$parserForGenericSubClass.parse(args);
  return _$parseGenericSubClassResult(result);
}
''')
@CliOptions()
class GenericSubClass extends GenericSuperClass<int> {
  String? subclassField;
}

abstract class InterfaceWithGetter {
  String? get fromInterface;
}

// Pins current behavior: the abstract interface getter is treated as an
// inherited field, so `fromInterface` takes the (earlier) super slot even
// though `ownFirst` is declared first in the class.
@ShouldGenerate(r'''
ImplementsInterfaceGetter _$parseImplementsInterfaceGetterResult(
        ArgResults result) =>
    ImplementsInterfaceGetter()
      ..fromInterface = result['from-interface'] as String?
      ..ownFirst = result['own-first'] as String?;

ArgParser _$populateImplementsInterfaceGetterParser(ArgParser parser) => parser
  ..addOption(
    'from-interface',
  )
  ..addOption(
    'own-first',
  );

final _$parserForImplementsInterfaceGetter =
    _$populateImplementsInterfaceGetterParser(ArgParser());

ImplementsInterfaceGetter parseImplementsInterfaceGetter(List<String> args) {
  final result = _$parserForImplementsInterfaceGetter.parse(args);
  return _$parseImplementsInterfaceGetterResult(result);
}
''')
@CliOptions()
class ImplementsInterfaceGetter implements InterfaceWithGetter {
  String? ownFirst;

  @override
  String? fromInterface;
}

class SetterOnlySuper {
  // ignore: avoid_setters_without_getters
  set setterOnly(String? value) {}
}

// Current behavior is pinned in `build_cli_test.dart`: the inherited
// setter-only property is collected as a field, then crashes the generator
// with a `TypeError` (`element.getter!`) instead of a generation error.
@CliOptions()
class InheritsSetterOnly extends SetterOnlySuper {
  String? own;
}

class AnnotatedSuper {
  @CliOption(name: 'custom-name', help: 'Help from the super class.')
  String? overridden;
}

// Pins current behavior: when a subclass overrides a super field, the
// super-only `@CliOption` is lost (last-wins by name) while the option keeps
// the super field's (earlier) position.
@ShouldGenerate(r'''
OverridesAnnotatedSuperField _$parseOverridesAnnotatedSuperFieldResult(
        ArgResults result) =>
    OverridesAnnotatedSuperField()
      ..overridden = result['overridden'] as String?
      ..own = result['own'] as String?;

ArgParser _$populateOverridesAnnotatedSuperFieldParser(ArgParser parser) =>
    parser
      ..addOption(
        'overridden',
      )
      ..addOption(
        'own',
      );

final _$parserForOverridesAnnotatedSuperField =
    _$populateOverridesAnnotatedSuperFieldParser(ArgParser());

OverridesAnnotatedSuperField parseOverridesAnnotatedSuperField(
    List<String> args) {
  final result = _$parserForOverridesAnnotatedSuperField.parse(args);
  return _$parseOverridesAnnotatedSuperFieldResult(result);
}
''')
@CliOptions()
class OverridesAnnotatedSuperField extends AnnotatedSuper {
  String? own;

  @override
  // ignore: overridden_fields
  String? overridden;
}

// Pins current behavior: no type arguments are emitted for an annotated
// generic class.
@ShouldGenerate(r'''
GenericOptions _$parseGenericOptionsResult(ArgResults result) =>
    GenericOptions()..value = result['value'] as String?;

ArgParser _$populateGenericOptionsParser(ArgParser parser) => parser
  ..addOption(
    'value',
  );

final _$parserForGenericOptions = _$populateGenericOptionsParser(ArgParser());

GenericOptions parseGenericOptions(List<String> args) {
  final result = _$parserForGenericOptions.parse(args);
  return _$parseGenericOptionsResult(result);
}
''')
@CliOptions()
class GenericOptions<T> {
  String? value;
}

@ShouldThrow('Cannot populate the required constructor argument: missing.')
@CliOptions()
class RequiredNamedWithoutField {
  String? option;

  // ignore: avoid_unused_constructor_parameters
  RequiredNamedWithoutField({required String missing});
}

@ShouldThrow('Cannot populate the required constructor argument: missing.')
@CliOptions()
class OptionalPositionalWithoutField {
  String? option;

  // ignore: avoid_unused_constructor_parameters
  OptionalPositionalWithoutField([String? missing]);
}

enum EnumWithStaticGetter {
  one,
  two;

  static EnumWithStaticGetter get fallback => one;
}

@ShouldGenerate(r'''
T _$enumValueHelper<T>(Map<T, String> enumValues, String source) =>
    enumValues.entries
        .singleWhere(
          (e) => e.value == source,
          orElse: () => throw ArgumentError(
            '`$source` is not one of the supported values: '
            '${enumValues.values.join(', ')}',
          ),
        )
        .key;

T? _$nullableEnumValueHelperNullable<T>(
  Map<T, String> enumValues,
  String? source,
) =>
    source == null ? null : _$enumValueHelper(enumValues, source);

EnumStaticGetter _$parseEnumStaticGetterResult(ArgResults result) =>
    EnumStaticGetter()
      ..value = _$nullableEnumValueHelperNullable(
        _$EnumWithStaticGetterEnumMapBuildCli,
        result['value'] as String?,
      );

const _$EnumWithStaticGetterEnumMapBuildCli = <EnumWithStaticGetter, String>{
  EnumWithStaticGetter.one: 'one',
  EnumWithStaticGetter.two: 'two'
};

ArgParser _$populateEnumStaticGetterParser(ArgParser parser) => parser
  ..addOption(
    'value',
    allowed: ['one', 'two', 'fallback'],
  );

final _$parserForEnumStaticGetter =
    _$populateEnumStaticGetterParser(ArgParser());

EnumStaticGetter parseEnumStaticGetter(List<String> args) {
  final result = _$parserForEnumStaticGetter.parse(args);
  return _$parseEnumStaticGetterResult(result);
}
''')
@CliOptions()
class EnumStaticGetter {
  EnumWithStaticGetter? value;
}
