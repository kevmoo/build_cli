import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'to_share.dart';
import 'util.dart';

const boolChecker = TypeChecker.fromRuntime(bool);
const listChecker = TypeChecker.fromRuntime(List);
const numChecker = TypeChecker.fromRuntime(num);
const stringChecker = TypeChecker.fromRuntime(String);
const _argResultsChecker = TypeChecker.fromRuntime(ArgResults);
const _cliOptionChecker = TypeChecker.fromRuntime(CliOption);
const _iterableChecker = TypeChecker.fromRuntime(Iterable);

String getConvertName(CliOption option) => _convertName[option];
final _convertName = Expando<String>('convert name');

bool isMulti(DartType targetType) =>
    _iterableChecker.isExactlyType(targetType) ||
    listChecker.isExactlyType(targetType);

final _argInfoCache = Expando<ArgInfo>();

enum ArgType { option, flag, multiOption, rest, wasParsed, command }

// Would hope to be able to do this in-line.
// But hit https://github.com/dart-lang/sdk/issues/32933
typedef _fieldChecker = bool Function(FieldElement);

const specialTypes = <ArgType, _fieldChecker>{
  ArgType.rest: _couldBeRestArg,
  ArgType.wasParsed: _couldBeWasParsedArg,
  ArgType.command: _couldBeCommand
};

final wasParsedSuffix = 'WasParsed';

bool _couldBeRestArg(FieldElement element) => element.name == 'rest';

bool _couldBeWasParsedArg(FieldElement element) =>
    element.name.endsWith(wasParsedSuffix) &&
    element.name.length > wasParsedSuffix.length &&
    boolChecker.isAssignableFromType(element.type);

bool _couldBeCommand(FieldElement element) =>
    element.name == 'command' &&
    _argResultsChecker.isAssignableFromType(element.type);

class ArgInfo {
  final CliOption optionData;
  final ArgType argType;

  ArgInfo(this.argType, this.optionData);

  static ArgInfo fromField(FieldElement element) {
    final info = _argInfoCache[element];
    if (info != null) {
      return info;
    }

    final option = _getOptions(element);

    ArgType type;
    if (option == null) {
      type = specialTypes.entries
          .singleWhere((e) => e.value(element),
              orElse: () => throwBugFound(element))
          .key;
    } else {
      type = _getArgType(element, option);
    }

    if (option == null) {
      assert(specialTypes.keys.contains(type));
    } else {
      if (type == ArgType.flag) {
        if (option.defaultsTo != null && option.defaultsTo is! bool) {
          throwUnsupported(element,
              'The value for `defaultsTo` must be assignable to `bool`.');
        }
        if (option.allowed != null) {
          throwUnsupported(element, '`allowed` is not supported for flags.');
        }
        if (option.allowedHelp != null) {
          throwUnsupported(
              element, '`allowedHelp` is not supported for flags.');
        }
        if (option.valueHelp != null) {
          throwUnsupported(element, '`valueHelp` is not supported for flags.');
        }
      } else {
        if (option.negatable != null) {
          throwUnsupported(
              element, '`negatable` is only valid for flags – type `bool`.');
        }
      }
    }

    return _argInfoCache[element] = ArgInfo(type, option);
  }
}

ArgType _getArgType(FieldElement element, CliOption option) {
  final targetType = element.type;

  if (getConvertName(option) != null) {
    return ArgType.option;
  }

  if (boolChecker.isExactlyType(targetType)) {
    return ArgType.flag;
  }

  if (stringChecker.isExactlyType(targetType) ||
      isEnum(targetType) ||
      numChecker.isAssignableFromType(targetType)) {
    return ArgType.option;
  }

  if (isMulti(targetType)) {
    return ArgType.multiOption;
  }

  throwUnsupported(element, '`$targetType` is not supported.');
}

CliOption _getOptions(FieldElement element) {
  final obj = _cliOptionChecker.firstAnnotationOfExact(element) ??
      _cliOptionChecker.firstAnnotationOfExact(element.getter);

  List<Object> allowedValues;
  Object defaultsTo;

  final annotation = ConstantReader(obj);

  if (annotation.isNull && specialTypes.values.any((p) => p(element))) {
    return null;
  }

  final defaultsToReader =
      annotation.isNull ? null : annotation?.read('defaultsTo');

  if (isEnum(element.type)) {
    final interfaceType = element.type as InterfaceType;

    allowedValues = interfaceType.accessors
        .where((p) => p.returnType == element.type)
        .map((p) => kebab(p.name))
        .toList();

    if (defaultsToReader != null && !defaultsToReader.isNull) {
      final objectValue = defaultsToReader.objectValue;
      if (objectValue.type != element.type) {
        throwUnsupported(element, 'this is also wack');
      }

      final enumValueIndex = objectValue.getField('index').toIntValue();
      defaultsTo = allowedValues[enumValueIndex];
    }
  }

  if (annotation.isNull) {
    return CliOption(allowed: allowedValues);
  }

  Map<Object, String> allowedHelp;
  final allowedHelpReader = annotation.read('allowedHelp');
  if (!allowedHelpReader.isNull) {
    if (!allowedHelpReader.isMap) {
      throwUnsupported(element, 'What are you doing?');
    }

    allowedHelp = <Object, String>{};
    for (var entry in allowedHelpReader.mapValue.entries) {
      final mapKeyReader = ConstantReader(entry.key);
      if (mapKeyReader.isString ||
          mapKeyReader.isInt ||
          mapKeyReader.isDouble) {
        allowedHelp[mapKeyReader.literalValue] = entry.value.toStringValue();
        continue;
      }

      if (isEnum(entry.key.type)) {
        assert(allowedValues != null);
        final enumValueIndex = entry.key.getField('index').toIntValue();
        final stringValue = allowedValues[enumValueIndex];
        allowedHelp[stringValue] = entry.value.toStringValue();
        continue;
      }

      throwUnsupported(element, 'I do not get it! - ${entry.key.type}');
    }
  }

  final allowedReader = annotation.read('allowed');
  if (!allowedReader.isNull) {
    allowedValues = allowedReader.listValue
        .map((o) => ConstantReader(o).literalValue)
        .toList();
  }

  if (!defaultsToReader.isNull) {
    if (isEnum(element.type)) {
      // Already taken care of above, right?
      assert(defaultsTo != null);
    } else if (defaultsToReader.isString ||
        defaultsToReader.isBool ||
        defaultsToReader.isInt ||
        defaultsToReader.isDouble) {
      defaultsTo = defaultsToReader.literalValue;
    } else {
      throwUnsupported(
          element,
          'Could not process the default value '
          '`${defaultsToReader.literalValue}`.');
    }
  }

  if (allowedValues != null &&
      defaultsTo != null &&
      !allowedValues.contains(defaultsTo)) {
    throwUnsupported(element,
        'The `defaultsTo` value – `$defaultsTo` is not in `allowedValues`.');
  }

  final option = CliOption(
      name: annotation.read('name').literalValue as String,
      abbr: annotation.read('abbr').literalValue as String,
      defaultsTo: defaultsTo,
      help: annotation.read('help').literalValue as String,
      valueHelp: annotation.read('valueHelp').literalValue as String,
      allowed: allowedValues,
      allowedHelp: allowedHelp,
      negatable: annotation.read('negatable').literalValue as bool,
      nullable: (annotation.read('nullable')?.literalValue ?? false) as bool,
      hide: annotation.read('hide').literalValue as bool);

  final convertReader = annotation.read('convert');
  if (!convertReader.isNull) {
    final objectValue = convertReader.objectValue;
    final type = objectValue.type as FunctionType;

    if (type.element is MethodElement) {
      throwUnsupported(
          element,
          'The function provided for `convert` must be top-level.'
          ' Static class methods (like `${type.element.name}`) are not supported.');
    }
    final functionElement = type.element as FunctionElement;

    if (functionElement.parameters.isEmpty ||
        functionElement.parameters.first.isNamed ||
        functionElement.parameters.where((pe) => !pe.isOptional).length > 1 ||
        !element.context.typeProvider.stringType
            .isAssignableTo(functionElement.parameters.first.type)) {
      throwUnsupported(
          element,
          'The convert function `${functionElement.name}` must have one '
          'positional paramater of type `String`.');
    }

    if (!functionElement.returnType.isAssignableTo(element.type)) {
      throwUnsupported(
          element,
          'The convert function `${functionElement.name}` return type '
          '`${functionElement.returnType}` is not compatible with the field type'
          ' `${element.type}`.');
    }
    _convertName[option] = functionElement.name;
  }

  return option;
}
