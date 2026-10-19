import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import 'enum_helpers.dart';
import 'to_share.dart';

const boolChecker = TypeChecker.typeNamed(bool, inPackage: 'core', inSdk: true);
const listChecker = TypeChecker.typeNamed(List, inPackage: 'core', inSdk: true);
const numChecker = TypeChecker.typeNamed(num, inPackage: 'core', inSdk: true);
const stringChecker = TypeChecker.typeNamed(
  String,
  inPackage: 'core',
  inSdk: true,
);
const _argResultsChecker = TypeChecker.typeNamed(ArgResults);
const _cliOptionChecker = TypeChecker.typeNamed(CliOption);
const _iterableChecker = TypeChecker.typeNamed(
  Iterable,
  inPackage: 'core',
  inSdk: true,
);

class ConverterData {
  final String name;
  final bool nullable;

  ConverterData(this.name, this.nullable);
}

ConverterData? converterDataFromOptions(CliOption option) =>
    _convertName[option];
final _convertName = Expando<ConverterData>('ConverterData');

bool isMulti(DartType targetType) =>
    _iterableChecker.isExactlyType(targetType) ||
    listChecker.isExactlyType(targetType);

final _argInfoCache = Expando<ArgInfo>();

enum ArgType { option, flag, multiOption, rest, wasParsed, command }

const specialTypes = <ArgType, bool Function(FieldElement)>{
  ArgType.rest: _couldBeRestArg,
  ArgType.wasParsed: _couldBeWasParsedArg,
  ArgType.command: _couldBeCommand,
};

const wasParsedSuffix = 'WasParsed';

bool _couldBeRestArg(FieldElement element) => element.name == 'rest';

bool _couldBeWasParsedArg(FieldElement element) =>
    element.name!.endsWith(wasParsedSuffix) &&
    element.name!.length > wasParsedSuffix.length &&
    boolChecker.isAssignableFromType(element.type);

bool _couldBeCommand(FieldElement element) =>
    element.name == 'command' &&
    _argResultsChecker.isAssignableFromType(element.type);

class ArgInfo {
  final CliOption? optionData;
  final ArgType argType;
  final DartType dartType;

  ArgInfo(this.argType, this.optionData, FieldElement element)
    : dartType = element.type;

  static ArgInfo fromField(FieldElement element) {
    final info = _argInfoCache[element];
    if (info != null) {
      return info;
    }

    final option = _getOptions(element);

    ArgType type;
    if (option == null) {
      type = specialTypes.entries
          .singleWhere(
            (e) => e.value(element),
            orElse: () => throwBugFound(element),
          )
          .key;
    } else {
      type = _getArgType(element, option);
    }

    if (option == null) {
      assert(specialTypes.keys.contains(type));
    } else {
      _validateFlagOptionConstraints(element, type, option);
    }

    return _argInfoCache[element] = ArgInfo(type, option, element);
  }
}

void _validateFlagOptionConstraints(
  FieldElement element,
  ArgType type,
  CliOption option,
) {
  if (type == ArgType.flag) {
    if (option.defaultsTo != null && option.defaultsTo is! bool) {
      throwUnsupported(
        element,
        'The value for `defaultsTo` must be assignable to `bool`.',
      );
    }
    if (option.allowed != null) {
      throwUnsupported(element, '`allowed` is not supported for flags.');
    }
    if (option.allowedHelp != null) {
      throwUnsupported(element, '`allowedHelp` is not supported for flags.');
    }
    if (option.valueHelp != null) {
      throwUnsupported(element, '`valueHelp` is not supported for flags.');
    }
  } else if (option.negatable != null) {
    throwUnsupported(
      element,
      '`negatable` is only valid for flags – type `bool`.',
    );
  }
}

ArgType _getArgType(FieldElement element, CliOption option) {
  final targetType = element.type;

  if (converterDataFromOptions(option) != null) {
    return ArgType.option;
  }

  if (boolChecker.isExactlyType(targetType)) {
    return ArgType.flag;
  }

  if (stringChecker.isExactlyType(targetType) ||
      targetType.isEnum ||
      numChecker.isAssignableFromType(targetType)) {
    return ArgType.option;
  }

  if (isMulti(targetType)) {
    return ArgType.multiOption;
  }

  throwUnsupported(
    element,
    '`${targetType.toStringNonNullable()}`'
    ' is not a supported type.',
  );
}

CliOption? _getOptions(FieldElement element) {
  final obj =
      _cliOptionChecker.firstAnnotationOfExact(element) ??
      _cliOptionChecker.firstAnnotationOfExact(element.getter!);

  List<Object>? allowedValues;
  Object? defaultsTo;

  final annotation = ConstantReader(obj);

  if (annotation.isNull && specialTypes.values.any((p) => p(element))) {
    return null;
  }

  final defaultsToReader = annotation.isNull
      ? null
      : annotation.read('defaultsTo');

  if (element.type.isEnum) {
    final enumValues = _extractEnumValues(element, defaultsToReader);
    allowedValues = enumValues.allowedValues;
    defaultsTo = enumValues.defaultsTo;
  }

  if (annotation.isNull) {
    return CliOption(allowed: allowedValues);
  }

  final allowedHelp = _parseAllowedHelp(
    element,
    annotation.read('allowedHelp'),
    allowedValues,
  );

  final allowedReader = annotation.read('allowed');
  if (!allowedReader.isNull) {
    allowedValues = allowedReader.listValue
        .map((o) => ConstantReader(o).literalValue!)
        .toList();
  }

  defaultsTo = _resolveDefaultsTo(element, defaultsToReader!, defaultsTo);

  _validateAllowedValues(element, allowedValues, defaultsTo, allowedHelp);

  final option = CliOption(
    abbr: annotation.read('abbr').literalValue as String?,
    allowed: allowedValues,
    allowedHelp: allowedHelp,
    defaultsTo: defaultsTo,
    help: annotation.read('help').literalValue as String?,
    hide: annotation.read('hide').literalValue as bool?,
    name: annotation.read('name').literalValue as String?,
    negatable: annotation.read('negatable').literalValue as bool?,
    provideDefaultToOverride:
        annotation.read('provideDefaultToOverride').literalValue as bool? ??
        false,
    valueHelp: annotation.read('valueHelp').literalValue as String?,
  );

  final convertData = _parseConvertData(element, annotation.read('convert'));
  if (convertData != null) {
    _convertName[option] = convertData;
  }

  return option;
}

({List<Object> allowedValues, Object? defaultsTo}) _extractEnumValues(
  FieldElement element,
  ConstantReader? defaultsToReader,
) {
  final enumNames = enumConstants(element.type).map((e) => e.name!).toList();

  Object? defaultsTo;
  if (defaultsToReader != null && !defaultsToReader.isNull) {
    final objectValue = defaultsToReader.objectValue;
    if (objectValue.type != element.type) {
      throwUnsupported(
        element,
        'The type provided to defaultsTo is '
        'different than the field type. Check that the num types are the '
        'same, or try making the field type non-nullable.',
      );
    }

    final enumVal = _enumValueForDartObject<String>(
      objectValue,
      enumNames,
      (v) => v,
    );
    defaultsTo = enumVal.kebab;
  }

  return (
    allowedValues: enumNames.map((e) => e.kebab).toList(),
    defaultsTo: defaultsTo,
  );
}

Map<Object, String>? _parseAllowedHelp(
  FieldElement element,
  ConstantReader allowedHelpReader,
  List<Object>? allowedValues,
) {
  if (allowedHelpReader.isNull) {
    return null;
  }
  if (!allowedHelpReader.isMap) {
    throwUnsupported(element, 'What are you doing?');
  }

  final allowedHelp = <Object, String>{};
  for (var entry in allowedHelpReader.mapValue.entries) {
    final mapKeyReader = ConstantReader(entry.key);
    if (mapKeyReader.isString || mapKeyReader.isInt || mapKeyReader.isDouble) {
      allowedHelp[mapKeyReader.literalValue!] = entry.value!.toStringValue()!;
      continue;
    }

    if (entry.key!.type!.isEnum) {
      assert(allowedValues != null);
      final stringValue = _enumValueForDartObject<String>(
        entry.key!,
        allowedValues!.cast<String>(),
        (v) => v,
      );
      allowedHelp[stringValue] = entry.value!.toStringValue()!;
      continue;
    }

    throwUnsupported(element, 'I do not get it! - ${entry.key!.type}');
  }
  return allowedHelp;
}

Object? _resolveDefaultsTo(
  FieldElement element,
  ConstantReader defaultsToReader,
  Object? currentDefault,
) {
  if (defaultsToReader.isNull) {
    return currentDefault;
  }
  if (element.type.isEnum) {
    assert(currentDefault != null);
    return currentDefault;
  }
  if (defaultsToReader.isString ||
      defaultsToReader.isBool ||
      defaultsToReader.isInt ||
      defaultsToReader.isDouble) {
    return defaultsToReader.literalValue;
  }
  throwUnsupported(
    element,
    'Could not process the default value `${defaultsToReader.literalValue}`.',
  );
}

void _validateAllowedValues(
  FieldElement element,
  List<Object>? allowedValues,
  Object? defaultsTo,
  Map<Object, String>? allowedHelp,
) {
  if (allowedValues != null &&
      defaultsTo != null &&
      !allowedValues.contains(defaultsTo)) {
    throwUnsupported(
      element,
      'The `defaultsTo` value – `$defaultsTo` is not in `allowedValues`.',
    );
  }

  if (allowedHelp != null) {
    final unallowedKeys = allowedHelp.keys
        .where((k) => !(allowedValues?.contains(k) ?? false))
        .toList();
    if (unallowedKeys.isNotEmpty) {
      throwUnsupported(
        element,
        'The `allowedHelp` keys – {${unallowedKeys.join(', ')}} '
        'are not in `allowedValues`.',
      );
    }
  }
}

ConverterData? _parseConvertData(
  FieldElement element,
  ConstantReader convertReader,
) {
  if (convertReader.isNull) {
    return null;
  }
  final functionElement = convertReader.objectValue.toFunctionValue()!;

  if (functionElement is MethodElement) {
    throwUnsupported(
      element,
      'The function provided for `convert` must be top-level.'
      ' Static class methods (like `${functionElement.name}`) are not '
      'supported.',
    );
  }

  final formalParams = functionElement.formalParameters;

  if (formalParams.isEmpty ||
      formalParams.first.isNamed ||
      formalParams.where((pe) => !pe.isOptional).length > 1 ||
      !element.library.typeProvider.stringType.isAssignableTo(
        formalParams.first.type,
      )) {
    throwUnsupported(
      element,
      'The convert function `${functionElement.name}` must have one '
      'positional parameter of type `String`.',
    );
  }

  if (!functionElement.returnType.isAssignableTo(element.type)) {
    final typeString = functionElement.returnType.toStringNonNullable();
    throwUnsupported(
      element,
      'The convert function `${functionElement.name}` return type '
      '`$typeString` is not compatible with the field '
      'type `${element.type.toStringNonNullable()}`.',
    );
  }
  return ConverterData(
    functionElement.name!,
    formalParams.first.type.isNullableType,
  );
}

/// Returns the entry of [items] for the enum value [source].
///
/// [items] must be in enum constant declaration order, so that an enum
/// value's `index` selects its entry.
T _enumValueForDartObject<T>(
  DartObject source,
  List<T> items,
  String Function(T) name,
) => items[source.getField('index')!.toIntValue()!];
