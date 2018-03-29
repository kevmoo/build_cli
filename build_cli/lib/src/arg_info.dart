import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'to_share.dart';
import 'util.dart';

final _listChecker = new TypeChecker.fromRuntime(List);
final _iterableChecker = new TypeChecker.fromRuntime(Iterable);
final boolChecker = new TypeChecker.fromRuntime(bool);
final stringChecker = new TypeChecker.fromRuntime(String);
final _cliOptionChecker = new TypeChecker.fromRuntime(CliOption);

// TODO: support Set, too...
bool isMulti(DartType targetType) =>
    _iterableChecker.isExactlyType(targetType) ||
    _listChecker.isExactlyType(targetType);

final _argInfoCache = new Expando<ArgInfo>();

enum ArgType { option, flag, multiOption, rest, wasParsed }

final wasParsedSuffix = 'WasParsed';

bool _couldBeRestArg(FieldElement element) => element.name == 'rest';
bool _couldBeWasParsedArg(FieldElement element) =>
    element.name.endsWith(wasParsedSuffix) &&
    element.name.length > wasParsedSuffix.length;

class ArgInfo {
  final CliOption optionData;
  final ArgType argType;

  ArgInfo(this.argType, this.optionData);

  static ArgInfo fromField(FieldElement element) {
    var info = _argInfoCache[element];
    if (info != null) {
      return info;
    }

    var option = _getOptions(element);

    ArgType type;
    if (option == null) {
      if (_couldBeRestArg(element)) {
        type = ArgType.rest;
      } else if (_couldBeWasParsedArg(element)) {
        type = ArgType.wasParsed;
      } else {
        throw new StateError('Should never get here!');
      }
    } else {
      type = _getArgType(element.type);
    }
    return _argInfoCache[element] = new ArgInfo(type, option);
  }
}

ArgType _getArgType(DartType targetType) {
  if (boolChecker.isExactlyType(targetType)) {
    return ArgType.flag;
  }

  if (stringChecker.isExactlyType(targetType)) {
    return ArgType.option;
  }

  if (isEnum(targetType)) {
    return ArgType.option;
  }

  if (isMulti(targetType)) {
    return ArgType.multiOption;
  }

  throw new UnsupportedError('Cannot party on `$targetType`.');
}

CliOption _getOptions(FieldElement element) {
  var obj = _cliOptionChecker.firstAnnotationOfExact(element) ??
      _cliOptionChecker.firstAnnotationOfExact(element.getter);

  List<String> allowedValues;
  String defaultsTo;

  var annotation = new ConstantReader(obj);

  if (annotation.isNull && _couldBeRestArg(element)) {
    // TODO: check this is a `List<String>`
    return null;
  }

  if (annotation.isNull && _couldBeWasParsedArg(element)) {
    // TODO: check this is a bool!
    return null;
  }

  var defaultsToReader =
      annotation.isNull ? null : annotation?.read('defaultsTo');

  if (isEnum(element.type)) {
    var interfaceType = element.type as InterfaceType;

    allowedValues = interfaceType.accessors
        .where((p) => p.returnType == element.type)
        .map((p) => kebab(p.name))
        .toList();

    if (defaultsToReader != null && !defaultsToReader.isNull) {
      var objectValue = defaultsToReader.objectValue;
      if (objectValue.type != element.type) {
        throw new StateError('this is also wack');
      }

      var enumValueIndex = objectValue.getField('index').toIntValue();
      defaultsTo = allowedValues[enumValueIndex];
    }
  }

  if (annotation.isNull) {
    return new CliOption(allowed: allowedValues);
  }

  Map<String, String> allowedHelp;
  var allowedHelpReader = annotation.read('allowedHelp');
  if (!allowedHelpReader.isNull) {
    if (!allowedHelpReader.isMap) {
      throw new StateError('What are you doing?');
    }

    allowedHelp = <String, String>{};
    for (var entry in allowedHelpReader.mapValue.entries) {
      var mapKeyReader = new ConstantReader(entry.key);
      if (mapKeyReader.isString) {
        allowedHelp[mapKeyReader.stringValue] = entry.value.toStringValue();
        continue;
      }

      if (isEnum(entry.key.type)) {
        assert(allowedValues != null);
        var enumValueIndex = entry.key.getField('index').toIntValue();
        var stringValue = allowedValues[enumValueIndex];
        allowedHelp[stringValue] = entry.value.toStringValue();
        continue;
      }

      throw new StateError('I do not get it! - ${entry.key.type}');
    }
  }

  var allowedReader = annotation.read('allowed');
  if (!allowedReader.isNull) {
    allowedValues = allowedReader.listValue
        .map((o) => new ConstantReader(o).stringValue)
        .toList();
  }

  if (!defaultsToReader.isNull) {
    if (isEnum(element.type)) {
      // Already taken care of above, right?
      assert(defaultsTo != null);
    } else if (defaultsToReader.isString) {
      defaultsTo = defaultsToReader.stringValue;
    } else {
      throw new StateError('What are you doing?');
    }
  }

  if (allowedValues != null &&
      defaultsTo != null &&
      !allowedValues.contains(defaultsTo)) {
    throw new StateError('Boo!');
  }

  return new CliOption(
      name: annotation.read('name').literalValue as String,
      abbr: annotation.read('abbr').literalValue as String,
      defaultsTo: defaultsTo,
      help: annotation.read('help').literalValue as String,
      allowed: allowedValues,
      allowedHelp: allowedHelp,
      negatable: annotation.read('negatable').literalValue as bool,
      hide: annotation.read('hide').literalValue as bool);
}
