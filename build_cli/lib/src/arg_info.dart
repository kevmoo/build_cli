// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import 'to_share.dart';

const boolChecker = TypeChecker.fromUrl('dart:core#bool');
const listChecker = TypeChecker.fromUrl('dart:core#List');
const numChecker = TypeChecker.fromUrl('dart:core#num');
const stringChecker = TypeChecker.fromUrl('dart:core#String');
const _argResultsChecker = TypeChecker.typeNamed(ArgResults);
const _cliOptionChecker = TypeChecker.typeNamed(CliOption);
const _iterableChecker = TypeChecker.fromUrl('dart:core#Iterable');

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

const specialTypes = <ArgType, bool Function(FieldElement2)>{
  ArgType.rest: _couldBeRestArg,
  ArgType.wasParsed: _couldBeWasParsedArg,
  ArgType.command: _couldBeCommand,
};

const wasParsedSuffix = 'WasParsed';

bool _couldBeRestArg(FieldElement2 element) => element.name3 == 'rest';

bool _couldBeWasParsedArg(FieldElement2 element) =>
    element.name3!.endsWith(wasParsedSuffix) &&
    element.name3!.length > wasParsedSuffix.length &&
    boolChecker.isAssignableFromType(element.type);

bool _couldBeCommand(FieldElement2 element) =>
    element.name3 == 'command' &&
    _argResultsChecker.isAssignableFromType(element.type);

class ArgInfo {
  final CliOption? optionData;
  final ArgType argType;
  final DartType dartType;

  ArgInfo(this.argType, this.optionData, FieldElement2 element)
    : dartType = element.type;

  static ArgInfo fromField(FieldElement2 element) {
    final info = _argInfoCache[element];
    if (info != null) {
      return info;
    }

    final option = _getOptions(element);

    ArgType type;
    if (option == null) {
      type =
          specialTypes.entries
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
          throwUnsupported(
            element,
            '`allowedHelp` is not supported for flags.',
          );
        }
        if (option.valueHelp != null) {
          throwUnsupported(element, '`valueHelp` is not supported for flags.');
        }
      } else {
        if (option.negatable != null) {
          throwUnsupported(
            element,
            '`negatable` is only valid for flags – type `bool`.',
          );
        }
      }
    }

    return _argInfoCache[element] = ArgInfo(type, option, element);
  }
}

ArgType _getArgType(FieldElement2 element, CliOption option) {
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

CliOption? _getOptions(FieldElement2 element) {
  final obj =
      _cliOptionChecker.firstAnnotationOfExact(element) ??
      _cliOptionChecker.firstAnnotationOfExact(element.getter2!);

  List<Object>? allowedValues;
  Object? defaultsTo;

  final annotation = ConstantReader(obj);

  if (annotation.isNull && specialTypes.values.any((p) => p(element))) {
    return null;
  }

  final defaultsToReader =
      annotation.isNull ? null : annotation.read('defaultsTo');

  if (element.type.isEnum) {
    final interfaceType = element.type as InterfaceType;

    final enumNames =
        interfaceType.getters
            .where(
              (p) =>
                  // An enum's values are non-nullable. For example, If the enum
                  // field's type is `BuildTool?` it's accessors will be the
                  // non-nullable type, `BuildTool`.
                  // TODO: find a better way to compare the underlying type
                  p.returnType.toStringNonNullable() ==
                  element.type.toStringNonNullable(),
            )
            .map((p) => p.name3!)
            .toList();

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

      defaultsTo = _enumValueForDartObject<String>(
        objectValue,
        enumNames,
        (v) => v,
      );
      defaultsTo = (defaultsTo as String).kebab;
    }

    allowedValues = enumNames.map((e) => e.kebab).toList();
  }

  if (annotation.isNull) {
    return CliOption(allowed: allowedValues);
  }

  Map<Object, String>? allowedHelp;
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
  }

  final allowedReader = annotation.read('allowed');
  if (!allowedReader.isNull) {
    allowedValues =
        allowedReader.listValue
            .map((o) => ConstantReader(o).literalValue!)
            .toList();
  }

  if (!defaultsToReader!.isNull) {
    if (element.type.isEnum) {
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
        '`${defaultsToReader.literalValue}`.',
      );
    }
  }

  if (allowedValues != null &&
      defaultsTo != null &&
      !allowedValues.contains(defaultsTo)) {
    throwUnsupported(
      element,
      'The `defaultsTo` value – `$defaultsTo` is not in `allowedValues`.',
    );
  }

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

  final convertReader = annotation.read('convert');
  if (!convertReader.isNull) {
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
        !element.library2.typeProvider.stringType.isAssignableTo(
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
    _convertName[option] = ConverterData(
      functionElement.name3!,
      formalParams.first.type.isNullableType,
    );
  }

  return option;
}

T _enumValueForDartObject<T>(
  DartObject source,
  List<T> items,
  String Function(T) name,
) => items[source.getField('index')!.toIntValue()!];
